"""Offline contract tests only. No sessions, Google requests or production access."""
import asyncio
import json
from pathlib import Path
import sys
from tempfile import TemporaryDirectory
from types import SimpleNamespace
import unittest
from unittest.mock import patch

from bridge import BridgeEngine, BridgeFailure, NotebookProvider, validate_bindings

N1 = "11111111-1111-1111-1111-111111111111"
N2 = "22222222-2222-2222-2222-222222222222"


class FakeProvider:
    def __init__(self):
        self.calls = []
        self.failure = False

    async def ask(self, notebook, question, conversation):
        self.calls.append((notebook, question, conversation))
        if self.failure:
            raise RuntimeError("Bearer secret-fixture")
        return {"answer": "Jawaban fixture [1]", "citations": [
            {"sourceId": N1, "citationNumber": 1, "excerpt": "Kutipan fixture"},
        ], "session": "secret-fixture"}, "conv-" + notebook


class EngineTests(unittest.TestCase):
    def setUp(self):
        self.temp = TemporaryDirectory()
        self.path = Path(self.temp.name) / "chat.sqlite3"
        self.provider = FakeProvider()
        self.bindings = {("reader", "fiqh_syafii"): N1, ("reader", "fiqh_hanafi"): N2}
        self.engine = BridgeEngine(self.bindings, self.path, self.provider)

    def tearDown(self):
        self.engine.close()
        self.temp.cleanup()

    def request(self, id="a", **overrides):
        return {"uid": "reader", "agentId": "fiqh_syafii", "question": "Pertanyaan fixture",
                "requestId": id * 32, **overrides}

    def test_notebook_is_chosen_only_by_server_binding(self):
        self.engine.ask(self.request())
        self.assertEqual(self.provider.calls[0][0], N1)
        with self.assertRaises(BridgeFailure):
            self.engine.ask(self.request(notebookId=N2))
        self.assertEqual(len(self.provider.calls), 1)

    def test_other_user_cannot_ask_or_read_cached_response(self):
        self.engine.ask(self.request())
        with self.assertRaises(BridgeFailure):
            self.engine.ask(self.request(uid="other"))
        self.assertEqual(len(self.provider.calls), 1)

    def test_duplicate_id_returns_cached_answer_without_second_ask(self):
        first = self.engine.ask(self.request())
        self.assertEqual(first, self.engine.ask(self.request()))
        self.assertEqual(len(self.provider.calls), 1)
        self.assertNotIn("session", first)
        self.assertNotIn("conversationId", first)

    def test_request_id_reuse_for_different_agent_or_question_is_rejected(self):
        self.engine.ask(self.request())
        for override in ({"question": "Berbeda"}, {"agentId": "fiqh_hanafi"}):
            with self.assertRaises(BridgeFailure):
                self.engine.ask(self.request(**override))
        self.assertEqual(len(self.provider.calls), 1)

    def test_conversations_are_persisted_and_separated_by_notebook(self):
        self.engine.ask(self.request())
        self.engine.ask(self.request("b", agentId="fiqh_hanafi"))
        self.engine.close()
        self.engine = BridgeEngine(self.bindings, self.path, self.provider)
        self.engine.ask(self.request("c"))
        self.assertEqual([row[2] for row in self.provider.calls], [None, None, "conv-" + N1])

    def test_failures_stop_followups_and_do_not_leak_upstream_error(self):
        self.provider.failure = True
        with self.assertRaisesRegex(BridgeFailure, "^upstream-result-unknown$"):
            self.engine.ask(self.request())
        for request in (self.request(), self.request("b")):
            with self.assertRaises(BridgeFailure) as caught:
                self.engine.ask(request)
            self.assertNotIn("secret-fixture", str(caught.exception))
        self.assertEqual(len(self.provider.calls), 1)

    def test_bad_answer_does_not_become_a_fake_assistant_reply(self):
        async def invalid(*_):
            return {"answer": "", "citations": []}, "conv"
        self.provider.ask = invalid
        with self.assertRaises(BridgeFailure):
            self.engine.ask(self.request())

    def test_reassigning_a_notebook_requires_review(self):
        self.engine.close()
        with self.assertRaises(BridgeFailure):
            BridgeEngine({("reader", "other_agent"): N1}, self.path, self.provider)
        self.engine = BridgeEngine(self.bindings, self.path, self.provider)

    def test_single_test_user_and_exclusive_notebook_are_required(self):
        first = {"uid": "reader", "agentId": "fiqh_syafii", "notebookId": N1}
        self.assertEqual(validate_bindings([first], "reader"), {("reader", "fiqh_syafii"): N1})
        for rows in ([first, {**first, "uid": "other"}],
                     [first, {**first, "agentId": "fiqh_hanafi"}], [first, first]):
            with self.assertRaises(BridgeFailure):
                validate_bindings(rows, "reader")


class ProviderTests(unittest.TestCase):
    def client(self, current=None, change_after_ask=False):
        calls = []
        state = {"conversation": current}

        async def get_conversation_id(_):
            return state["conversation"]

        async def source_ids(_):
            return [N1]

        async def ask(notebook, question, **kwargs):
            calls.append((notebook, question, kwargs))
            state["conversation"] = "changed" if change_after_ask else "new-conversation"
            return SimpleNamespace(answer="Fixture [1]", conversation_id="new-conversation", references=[
                SimpleNamespace(source_id=N1, citation_number=1, cited_text="Fixture excerpt")])

        class FakeClient:
            chat = SimpleNamespace(get_conversation_id=get_conversation_id, ask=ask)
            notebooks = SimpleNamespace(get_source_ids=source_ids)

            async def __aenter__(self):
                return self

            async def __aexit__(self, *_):
                pass

            @classmethod
            def from_storage(cls, *, path):
                self.assert_session = path
                return cls()

        return SimpleNamespace(NotebookLMClient=FakeClient), calls

    def test_existing_untracked_conversation_is_rejected_before_asking(self):
        module, calls = self.client("someone-elses-conversation")
        with patch.dict(sys.modules, {"notebooklm": module}):
            with self.assertRaises(BridgeFailure):
                asyncio.run(NotebookProvider(Path("/dedicated/test/session.json")).ask(N1, "fixture", None))
        self.assertEqual(calls, [])

    def test_known_history_passes_explicit_id_and_source_ids_to_sdk(self):
        module, calls = self.client("known-conversation")
        with patch.dict(sys.modules, {"notebooklm": module}):
            result, conversation = asyncio.run(NotebookProvider(Path("/dedicated/test/session.json")).ask(N1, "fixture", "known-conversation"))
        self.assertEqual(calls[0][2], {"source_ids": [N1], "conversation_id": "known-conversation"})
        self.assertEqual(conversation, "new-conversation")
        self.assertEqual(result["citations"][0]["excerpt"], "Fixture excerpt")

    def test_unexpected_history_change_after_ask_discards_answer(self):
        module, calls = self.client(change_after_ask=True)
        with patch.dict(sys.modules, {"notebooklm": module}):
            with self.assertRaises(BridgeFailure):
                asyncio.run(NotebookProvider(Path("/dedicated/test/session.json")).ask(N1, "fixture", None))
        self.assertEqual(len(calls), 1)


if __name__ == "__main__":
    unittest.main()
