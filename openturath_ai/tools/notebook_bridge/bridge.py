"""Local-only NotebookLM chat prototype. No credential discovery or login automation.

Run only after authorizing a dedicated operator session and isolated test notebook.
The callable authenticates Firebase users; this process authenticates the callable.
It intentionally supports ONE test user, one process and no shared master notebook.
"""
from __future__ import annotations

import asyncio
import hashlib
import hmac
import json
import logging
import os
from pathlib import Path
import re
import sqlite3
from http.server import BaseHTTPRequestHandler, HTTPServer
from typing import Any

UUID = re.compile(r"^[a-f0-9]{8}(?:-[a-f0-9]{4}){3}-[a-f0-9]{12}$", re.I)
REQUEST_ID = re.compile(r"^[a-f0-9]{32}$")


class BridgeFailure(Exception):
    """Safe status only; never contains a question, session or upstream exception."""


def validate_bindings(value: Any, test_uid: str) -> dict[tuple[str, str], str]:
    if not test_uid or not isinstance(value, list) or not value:
        raise BridgeFailure("invalid-bindings")
    bindings: dict[tuple[str, str], str] = {}
    notebooks: set[str] = set()
    for item in value:
        if not isinstance(item, dict) or set(item) != {"uid", "agentId", "notebookId"}:
            raise BridgeFailure("invalid-bindings")
        uid, agent, notebook = item["uid"], item["agentId"], item["notebookId"]
        if uid != test_uid or not isinstance(agent, str) or not re.fullmatch(r"[a-z][a-z0-9_]{0,79}", agent):
            raise BridgeFailure("invalid-bindings")
        if not isinstance(notebook, str) or not UUID.fullmatch(notebook):
            raise BridgeFailure("invalid-bindings")
        if (uid, agent) in bindings or notebook in notebooks:
            raise BridgeFailure("notebook-must-be-exclusive")
        bindings[uid, agent] = notebook
        notebooks.add(notebook)
    return bindings


class NotebookProvider:
    def __init__(self, session_path: Path):
        self.session_path = session_path

    async def ask(self, notebook: str, question: str, conversation: str | None) -> tuple[dict, str]:
        # This is the ONLY Google connection point. It is not executed by offline tests.
        from notebooklm import NotebookLMClient

        # The SDK can log answer previews on post-ask failures. Disable those loggers
        # before creating the client; this service does not keep an upstream audit dump.
        for name in ["notebooklm", "httpx", "httpcore"]:
            logger = logging.getLogger(name)
            logger.handlers = [logging.NullHandler()]
            logger.propagate = False
            logger.setLevel(logging.CRITICAL + 1)
        async with asyncio.timeout(70):
            async with NotebookLMClient.from_storage(path=str(self.session_path)) as client:
                current = await client.chat.get_conversation_id(notebook)
                if current != conversation:
                    raise BridgeFailure("conversation-isolation-failed")
                source_ids = await client.notebooks.get_source_ids(notebook)
                if not source_ids:
                    raise BridgeFailure("notebook-has-no-sources")
                result = await client.chat.ask(notebook, question, source_ids=source_ids, conversation_id=conversation)
                if not result.conversation_id or await client.chat.get_conversation_id(notebook) != result.conversation_id:
                    raise BridgeFailure("conversation-isolation-failed")
                citations = []
                for reference in result.references:
                    number = reference.citation_number
                    if reference.source_id not in source_ids:
                        raise BridgeFailure("unexpected-source")
                    # Do not invent a citation number or bibliographical title.
                    if number is None:
                        continue
                    citations.append({"sourceId": reference.source_id, "citationNumber": number,
                                      "excerpt": reference.cited_text[:4000] if reference.cited_text else None})
                return {"answer": result.answer, "citations": citations}, result.conversation_id


class BridgeEngine:
    def __init__(self, bindings: dict[tuple[str, str], str], database: Path, provider: Any):
        self.bindings, self.provider = bindings, provider
        self.db = sqlite3.connect(database)
        self.db.execute("CREATE TABLE IF NOT EXISTS assignments (uid TEXT, agent TEXT, notebook TEXT UNIQUE, conversation TEXT, blocked INTEGER NOT NULL DEFAULT 0, PRIMARY KEY(uid, agent))")
        self.db.execute("CREATE TABLE IF NOT EXISTS requests (id TEXT PRIMARY KEY, uid TEXT, agent TEXT, digest TEXT, response TEXT)")
        for (uid, agent), notebook in bindings.items():
            row = self.db.execute("SELECT notebook FROM assignments WHERE uid=? AND agent=?", (uid, agent)).fetchone()
            if row and row[0] != notebook:
                raise BridgeFailure("assignment-change-requires-review")
            owner = self.db.execute("SELECT uid,agent FROM assignments WHERE notebook=?", (notebook,)).fetchone()
            if owner and owner != (uid, agent):
                raise BridgeFailure("notebook-must-be-exclusive")
            self.db.execute("INSERT OR IGNORE INTO assignments(uid,agent,notebook) VALUES(?,?,?)", (uid, agent, notebook))
        self.db.commit()

    def close(self):
        self.db.close()

    def ask(self, data: Any) -> dict:
        if not isinstance(data, dict) or set(data) != {"uid", "agentId", "question", "requestId"}:
            raise BridgeFailure("invalid-request")
        uid, agent, question, request_id = (data[k] for k in ("uid", "agentId", "question", "requestId"))
        if not all(isinstance(x, str) for x in (uid, agent, question, request_id)):
            raise BridgeFailure("invalid-request")
        if not question.strip() or len(question) > 8000 or not REQUEST_ID.fullmatch(request_id):
            raise BridgeFailure("invalid-request")
        notebook = self.bindings.get((uid, agent))
        if not notebook:
            raise BridgeFailure("binding-unavailable")
        digest = hashlib.sha256(question.strip().encode()).hexdigest()
        previous = self.db.execute("SELECT uid,agent,digest,response FROM requests WHERE id=?", (request_id,)).fetchone()
        if previous:
            if previous[:3] != (uid, agent, digest):
                raise BridgeFailure("request-id-conflict")
            if previous[3] is None:
                raise BridgeFailure("request-result-unknown")
            return json.loads(previous[3])
        conversation, blocked = self.db.execute("SELECT conversation,blocked FROM assignments WHERE uid=? AND agent=?", (uid, agent)).fetchone()
        if blocked:
            raise BridgeFailure("assignment-needs-review")
        # Commit before sending: crashes/timeouts must not cause automatic duplicate questions.
        self.db.execute("INSERT INTO requests(id,uid,agent,digest) VALUES(?,?,?,?)", (request_id, uid, agent, digest))
        self.db.commit()
        try:
            result, new_conversation = asyncio.run(self.provider.ask(notebook, question.strip(), conversation))
            if not isinstance(result, dict) or not isinstance(result.get("answer"), str) or not result["answer"].strip() or len(result["answer"]) > 128000:
                raise BridgeFailure("invalid-answer")
            if not isinstance(new_conversation, str) or not new_conversation:
                raise BridgeFailure("invalid-conversation")
            refs = result.get("citations")
            if not isinstance(refs, list) or len(refs) > 100:
                raise BridgeFailure("invalid-answer")
            clean_refs = []
            for ref in refs:
                if not isinstance(ref, dict) or not isinstance(ref.get("sourceId"), str) or not UUID.fullmatch(ref["sourceId"]):
                    raise BridgeFailure("invalid-answer")
                number, excerpt = ref.get("citationNumber"), ref.get("excerpt")
                if type(number) is not int or not 1 <= number <= 1000 or (excerpt is not None and (not isinstance(excerpt, str) or len(excerpt) > 4000)):
                    raise BridgeFailure("invalid-answer")
                clean_refs.append({"sourceId": ref["sourceId"], "citationNumber": number, "excerpt": excerpt})
            reply = {"requestId": request_id, "answer": result["answer"].strip(), "citations": clean_refs}
            self.db.execute("UPDATE assignments SET conversation=? WHERE uid=? AND agent=?", (new_conversation, uid, agent))
            self.db.execute("UPDATE requests SET response=? WHERE id=?", (json.dumps(reply), request_id))
            self.db.commit()
            return reply
        except Exception:
            # A question may already have reached Google. Stop this binding until reviewed.
            self.db.execute("UPDATE assignments SET blocked=1 WHERE uid=? AND agent=?", (uid, agent))
            self.db.commit()
            raise BridgeFailure("upstream-result-unknown") from None


def serve(engine: BridgeEngine, key: str, port: int):
    if len(key) < 32:
        raise BridgeFailure("missing-bridge-key")

    class Handler(BaseHTTPRequestHandler):
        def setup(self):
            super().setup()
            self.connection.settimeout(5)

        def log_message(self, *_):
            pass  # No account, request-body, answer or upstream logs.

        def respond(self, status: int, data: dict):
            body = json.dumps(data).encode()
            self.send_response(status)
            self.send_header("Content-Type", "application/json; charset=utf-8")
            self.send_header("Cache-Control", "no-store")
            self.send_header("Content-Length", str(len(body)))
            self.end_headers()
            self.wfile.write(body)

        def do_POST(self):
            supplied = self.headers.get("Authorization", "")
            if not hmac.compare_digest(supplied.encode(), f"Bearer {key}".encode()):
                self.respond(401, {"error": "unauthorized"})
                return
            try:
                size = int(self.headers.get("Content-Length", "0"))
                if self.path != "/ask" or not 0 < size <= 40000 or self.headers.get("Transfer-Encoding"):
                    raise BridgeFailure("invalid-request")
                data = json.loads(self.rfile.read(size))
                self.respond(200, engine.ask(data))
            except (BridgeFailure, ValueError, TimeoutError):
                self.respond(503, {"error": "bridge-unavailable"})

    # Single synchronous server serializes asks. Never expose this HTTP port publicly.
    HTTPServer(("127.0.0.1", port), Handler).serve_forever()


def main():
    import fcntl

    # Explicit paths only: never search browsers, personal sessions, or master-token files.
    session = Path(os.environ["NOTEBOOK_OPERATOR_SESSION"]).resolve()
    runtime = Path(os.environ["NOTEBOOK_BRIDGE_RUNTIME"]).resolve()
    manifest = Path(os.environ["NOTEBOOK_BRIDGE_BINDINGS"]).resolve()
    uid = os.environ["NOTEBOOK_BRIDGE_TEST_UID"]
    key = os.environ["NOTEBOOK_BRIDGE_KEY"]
    if not session.is_file() or session.stat().st_mode & 0o077:
        raise BridgeFailure("operator-session-must-be-private")
    runtime.mkdir(mode=0o700, parents=True, exist_ok=True)
    if runtime.stat().st_mode & 0o077:
        raise BridgeFailure("runtime-must-be-private")
    with (runtime / "bridge.lock").open("a") as lock:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
        bindings = validate_bindings(json.loads(manifest.read_text()), uid)
        engine = BridgeEngine(bindings, runtime / "chat.sqlite3", NotebookProvider(session))
        try:
            serve(engine, key, int(os.environ.get("NOTEBOOK_BRIDGE_PORT", "8794")))
        finally:
            engine.close()


if __name__ == "__main__":
    try:
        main()
    except (BridgeFailure, KeyError, ValueError, OSError):
        raise SystemExit("Bridge belum dapat dijalankan; periksa konfigurasi privat.") from None
