"""Fixture-only tests: no Google requests, accounts, or credentials."""

import io
import json
import os
from pathlib import Path
import queue
import socket
import struct
import tempfile
import threading
import time
import unittest
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from unittest.mock import patch

import native_host as host

EPOCH = "1" * 32
NOTEBOOK = "11111111-1111-1111-1111-111111111111"
CONVERSATION = "22222222-2222-2222-2222-222222222222"


def job(epoch=EPOCH, request_id="a" * 32):
    return {"requestId": request_id, "epoch": epoch, "uid": "reader",
            "googleSub": "123456789012345678901", "email": "reader@example.com",
            "notebookId": NOTEBOOK, "question": "Fixture question", "history": None,
            "conversationId": None}


def result(value):
    return {**{key: value[key] for key in host.TUPLE}, "answer": "Fixture answer",
            "accountEmail": value["email"], "conversationId": CONVERSATION,
            "citations": [{"sourceId": NOTEBOOK, "citationNumber": 1, "excerpt": "Fixture"}]}


class Capture:
    def __init__(self):
        self.messages = []
        self.condition = threading.Condition()

    def write(self, raw):
        message = host.read_frame(io.BytesIO(raw))
        with self.condition:
            self.messages.append(message)
            self.condition.notify_all()
        return len(raw)

    def flush(self):
        pass

    def wait(self, predicate, timeout=4):
        deadline = time.monotonic() + timeout
        with self.condition:
            while True:
                for message in self.messages:
                    if predicate(message):
                        return message
                remaining = deadline - time.monotonic()
                if remaining <= 0:
                    raise AssertionError("Fixture event not received")
                self.condition.wait(remaining)


class Fixture:
    def __init__(self, epoch=EPOCH):
        self.epoch = epoch
        self.bearer = "f" * 64
        self.jobs = queue.Queue()
        self.requests = []
        self.results = []
        self.attached = threading.Event()
        self.result_received = threading.Event()
        self.disconnected = threading.Event()
        self.lock = threading.Lock()
        self.response = None
        self.result_hook = None
        self.heartbeat_deadline = None
        self.last_seen = 0
        self.attach_count = 0
        self.reject_heartbeat = False
        fixture = self

        class Handler(BaseHTTPRequestHandler):
            def log_message(self, *_args):
                pass

            def reply(self, code, raw, content_type="application/json"):
                self.send_response(code)
                self.send_header("Content-Type", content_type)
                self.send_header("Content-Length", str(len(raw)))
                self.end_headers()
                try:
                    self.wfile.write(raw)
                except (BrokenPipeError, ConnectionResetError):
                    pass

            def do_POST(self):
                body = json.loads(self.rfile.read(int(self.headers["Content-Length"])))
                with fixture.lock:
                    fixture.requests.append((self.path, dict(self.headers), body))
                if self.headers.get("Authorization") != "Bearer " + fixture.bearer:
                    self.reply(403, b'{}')
                    return
                if fixture.response is not None:
                    self.reply(*fixture.response)
                    return
                if self.path == "/attach":
                    fixture.attach_count += 1
                    if fixture.reject_heartbeat and fixture.attach_count > 1:
                        self.reply(409, b'{}')
                        return
                    fixture.last_seen = time.monotonic()
                    fixture.attached.set()
                    value = {"ok": True}
                elif self.path == "/poll":
                    fixture.last_seen = time.monotonic()
                    try:
                        value = {"job": fixture.jobs.get_nowait()}
                    except queue.Empty:
                        value = {"job": None}
                elif self.path == "/result":
                    if (fixture.heartbeat_deadline is not None and
                            time.monotonic() - fixture.last_seen > fixture.heartbeat_deadline):
                        self.reply(409, b'{}')
                        return
                    fixture.last_seen = time.monotonic()
                    with fixture.lock:
                        fixture.results.append(body)
                    fixture.result_received.set()
                    if fixture.result_hook is not None:
                        action = fixture.result_hook()
                        if action == "drop":
                            self.close_connection = True
                            self.connection.shutdown(socket.SHUT_RDWR)
                            return
                        if action == "stale":
                            self.reply(409, b'{}')
                            return
                    value = {"ok": True}
                elif self.path == "/disconnect":
                    fixture.disconnected.set()
                    value = {"ok": True}
                else:
                    self.reply(404, b'{}')
                    return
                self.reply(200, json.dumps(value).encode())

        self.server = ThreadingHTTPServer(("127.0.0.1", 0), Handler)
        self.thread = threading.Thread(target=self.server.serve_forever, daemon=True)
        self.thread.start()

    @property
    def runtime(self):
        return {"version": 1, "port": self.server.server_port, "bearer": self.bearer,
                "epoch": self.epoch, "pid": os.getpid()}

    def close(self):
        self.server.shutdown()
        self.server.server_close()
        self.thread.join(timeout=2)


class HostTests(unittest.TestCase):
    def setUp(self):
        self.temp = tempfile.TemporaryDirectory()
        self.directory = Path(self.temp.name) / "Companion"
        self.directory.mkdir(mode=0o700)
        self.path = self.directory / "runtime.json"
        self.fixtures = []
        self.relays = []

    def tearDown(self):
        for relay, thread, stop, _incoming, _capture in self.relays:
            stop.set()
            thread.join(timeout=4)
            self.assertFalse(thread.is_alive())
        for fixture in self.fixtures:
            fixture.close()
        self.temp.cleanup()

    def fixture(self, epoch=EPOCH):
        value = Fixture(epoch)
        self.fixtures.append(value)
        return value

    def metadata(self, runtime):
        self.path.write_text(json.dumps(runtime), encoding="utf-8")
        self.path.chmod(0o600)

    def relay(self, fixture, job_timeout=180, heartbeat_interval=10):
        self.metadata(fixture.runtime)
        stop, incoming, capture = threading.Event(), queue.Queue(), Capture()
        relay = host.Relay(self.path, incoming, host.FrameWriter(capture, stop), stop,
                           retry_delay=0.03, http_timeout=1, job_timeout=job_timeout,
                           heartbeat_interval=heartbeat_interval)
        thread = threading.Thread(target=relay.run)
        self.relays.append((relay, thread, stop, incoming, capture))
        thread.start()
        capture.wait(lambda message: message.get("code") == "ready")
        return relay, stop, incoming, capture

    def test_frame_little_endian_round_trip_and_exact_limit(self):
        stop, out = threading.Event(), io.BytesIO()
        host.FrameWriter(out, stop).send({"type": "state", "status": "waiting", "code": "waiting"})
        raw = out.getvalue()
        self.assertEqual(struct.unpack("<I", raw[:4])[0], len(raw) - 4)
        self.assertEqual(host.read_frame(io.BytesIO(raw))["status"], "waiting")
        payload = b'{"x":"' + b'a' * (host.MAX_FRAME - 8) + b'"}'
        self.assertEqual(len(payload), host.MAX_FRAME)
        self.assertEqual(len(host.read_frame(io.BytesIO(struct.pack("<I", len(payload)) + payload))["x"]), host.MAX_FRAME - 8)
        self.assertIsNone(host.read_frame(io.BytesIO()))

    def test_invalid_frame_variants_are_bounded(self):
        cases = [b'\x01', struct.pack("<I", 0), struct.pack("<I", host.MAX_FRAME + 1),
                 struct.pack("<I", 5) + b'{}', struct.pack("<I", 1) + b'\xff']
        for value in [b'[]', b'{"x":1,"x":2}', b'{"x":NaN}', b'{"x":' + b'[' * 2000 + b'0' + b']' * 2000 + b'}']:
            cases.append(struct.pack("<I", len(value)) + value)
        for raw in cases:
            with self.subTest(raw=raw[:8]), self.assertRaises(host.ProtocolError):
                host.read_frame(io.BytesIO(raw))

    def test_invalid_caller_never_reads_metadata_or_connects(self):
        for caller in ["", host.CALLER.rstrip("/"), host.CALLER + "evil", "chrome-extension://other/"]:
            out = io.BytesIO()
            with patch.object(host, "read_runtime", side_effect=AssertionError("must not read")):
                self.assertEqual(host.main([caller], io.BytesIO(), out), 2)
            self.assertEqual(host.read_frame(io.BytesIO(out.getvalue()))["code"], "invalid-caller")

    def test_runtime_strict_schema(self):
        fixture = self.fixture()
        self.metadata(fixture.runtime)
        self.assertEqual(host.read_runtime(self.path), fixture.runtime)
        for change in [{"port": "1234"}, {"port": 80}, {"version": True},
                       {"bearer": "bad"}, {"epoch": "bad"}, {"pid": 0}, {"extra": "unused"}]:
            self.metadata({**fixture.runtime, **change})
            with self.subTest(change=change), self.assertRaises(host.ProtocolError):
                host.read_runtime(self.path)

    @unittest.skipUnless(os.name == "posix", "POSIX mode checks")
    def test_runtime_symlinks_modes_owner_and_hardlinks_rejected(self):
        fixture = self.fixture()
        self.metadata(fixture.runtime)
        target = self.directory / "target.json"
        self.path.rename(target)
        self.path.symlink_to(target)
        with self.assertRaises(host.ProtocolError):
            host.read_runtime(self.path)
        self.path.unlink()
        target.rename(self.path)
        self.path.chmod(0o644)
        with self.assertRaises(host.ProtocolError):
            host.read_runtime(self.path)
        self.path.chmod(0o600)
        self.directory.chmod(0o755)
        with self.assertRaises(host.ProtocolError):
            host.read_runtime(self.path)
        self.directory.chmod(0o700)
        with patch.object(os, "getuid", return_value=os.getuid() + 1), self.assertRaises(host.ProtocolError):
            host.read_runtime(self.path)
        os.link(self.path, target)
        with self.assertRaises(host.ProtocolError):
            host.read_runtime(self.path)
        target.unlink()
        alias = Path(self.temp.name) / "alias"
        alias.symlink_to(self.directory, target_is_directory=True)
        with self.assertRaises(host.ProtocolError):
            host.read_runtime(alias / "runtime.json")

    def test_loopback_http_headers_and_typed_ack(self):
        fixture = self.fixture()
        self.assertEqual(host.post(fixture.runtime, "/attach", {"clientId": "b" * 32, "protocol": 1, "epoch": EPOCH}), {"ok": True})
        route, headers, _payload = fixture.requests[-1]
        self.assertEqual(route, "/attach")
        self.assertEqual(headers["Host"], f"127.0.0.1:{fixture.server.server_port}")
        self.assertNotIn("Origin", headers)
        self.assertEqual(headers["Authorization"], "Bearer " + fixture.bearer)

    def test_http_rejects_redirect_wrong_type_oversize_and_wrong_schema(self):
        fixture = self.fixture()
        for response in [(302, b'{}'), (200, b'{}', "text/html"),
                         (200, b'x' * (host.MAX_FRAME + 1)), (200, b'{"ok":1}'),
                         (200, b'{"ok":true,"token":"must-not-forward"}')]:
            fixture.response = response
            with self.subTest(status=response[0]), self.assertRaises(host.ProtocolError):
                host.post(fixture.runtime, "/attach", {}, timeout=1)
        fixture.response = (200, b'{"job":false}')
        with self.assertRaises(host.ProtocolError):
            host.post(fixture.runtime, "/poll", {}, timeout=1)

    def test_job_result_sanitization_and_identity_binding(self):
        value = job()
        sanitized = host.validate_job({**value, "bearer": "do-not-forward", "raw": {}}, EPOCH)
        self.assertEqual(sanitized, value)
        reply = host.validate_result({**result(value), "cookies": "do-not-forward"}, value)
        self.assertNotIn("cookies", reply)
        for change in [{"uid": "other"}, {"epoch": "2" * 32}, {"accountEmail": "other@example.com"},
                       {"answer": "x" * 128001}, {"conversationId": "bad"},
                       {"citations": [{"sourceId": "bad", "citationNumber": 1}]}, {"code": []}]:
            with self.subTest(change=list(change)), self.assertRaises(host.ProtocolError):
                host.validate_result({**result(value), **change}, value)
        self.assertEqual(host.validate_result({**result(value), "code": "uncertain"}, value)["code"], "uncertain")
        for change in [{"history": [["text", None, True]]}, {"googleSub": "user"}, {"epoch": "2" * 32},
                       {"notebookId": "bad"}, {"question": ""}, {"email": "UPPER@example.com"}]:
            with self.subTest(change=list(change)), self.assertRaises(host.ProtocolError):
                host.validate_job({**value, **change}, EPOCH)

    def test_real_fixture_dispatch_result_once_and_no_secret_frames(self):
        fixture = self.fixture()
        value = job()
        fixture.jobs.put({**value, "bearer": "must-not-forward"})
        _relay, stop, incoming, capture = self.relay(fixture)
        self.assertEqual(capture.wait(lambda message: message.get("type") == "job")["job"], value)
        incoming.put({"type": "result", "result": {**result(value), "session": "must-not-forward"}})
        self.assertTrue(fixture.result_received.wait(3))
        incoming.put({"type": "result", "result": result(value)})
        time.sleep(0.1)
        self.assertEqual(len(fixture.results), 1)
        self.assertNotIn("session", fixture.results[0]["result"])
        serialized = json.dumps(capture.messages)
        self.assertNotIn(fixture.bearer, serialized)
        self.assertNotIn("must-not-forward", serialized)
        self.assertNotIn('"port"', serialized)
        stop.set()

    def test_utf16_limits_match_dart_for_arabic_and_emoji_history(self):
        value = job()
        arabic = [["ع" * 60000, None, 2]]
        self.assertGreater(len(json.dumps(arabic, ensure_ascii=False).encode("utf-8")), 120000)
        self.assertEqual(host.validate_job({**value, "history": arabic}, EPOCH)["history"], arabic)
        for text in ["x" * 119987, "😀" * 59993]:
            host.validate_job({**value, "history": [[text, None, 2]]}, EPOCH)
        for text in ["x" * 119988, "😀" * 59994]:
            with self.subTest(units=host._utf16_units(text)), self.assertRaises(host.ProtocolError):
                host.validate_job({**value, "history": [[text, None, 2]]}, EPOCH)
        host.validate_job({**value, "question": "😀" * 4000}, EPOCH)
        with self.assertRaises(host.ProtocolError):
            host.validate_job({**value, "question": "😀" * 4001}, EPOCH)
        host.validate_result({**result(value), "answer": "😀" * 64000}, value)
        with self.assertRaises(host.ProtocolError):
            host.validate_result({**result(value), "answer": "😀" * 64001}, value)

    def test_pending_heartbeat_keeps_session_alive_without_job_polling(self):
        fixture, value = self.fixture(), job()
        fixture.heartbeat_deadline = 0.12
        fixture.jobs.put(value)
        fixture.jobs.put(job(request_id="b" * 32))
        relay, stop, incoming, capture = self.relay(fixture, heartbeat_interval=0.02)
        capture.wait(lambda message: message.get("type") == "job")
        time.sleep(0.25)
        with fixture.lock:
            requests = list(fixture.requests)
        pulses = [body for route, _headers, body in requests if route == "/attach"]
        self.assertGreaterEqual(len(pulses), 3)
        self.assertTrue(all(body == {"clientId": relay.client_id, "protocol": 1, "epoch": EPOCH}
                            for body in pulses))
        self.assertEqual(len([route for route, _headers, _body in requests if route == "/poll"]), 1)
        self.assertEqual(len([message for message in capture.messages if message.get("type") == "job"]), 1)
        incoming.put({"type": "result", "result": result(value)})
        self.assertTrue(fixture.result_received.wait(3))
        stop.set()
        self.assertEqual(len(fixture.results), 1)
        self.assertFalse(any(message.get("status") == "uncertain" for message in capture.messages))

    def test_lost_pending_heartbeat_marks_uncertain_without_replay(self):
        fixture, value = self.fixture(), job()
        fixture.reject_heartbeat = True
        fixture.jobs.put(value)
        _relay, _stop, incoming, capture = self.relay(fixture, heartbeat_interval=0.02)
        capture.wait(lambda message: message.get("type") == "job")
        capture.wait(lambda message: message.get("status") == "uncertain"
                     and message.get("requestId") == value["requestId"])
        self.assertTrue(fixture.disconnected.wait(3))
        incoming.put({"type": "result", "result": result(value)})
        time.sleep(0.1)
        self.assertEqual(fixture.results, [])
        self.assertEqual(len([message for message in capture.messages if message.get("type") == "job"]), 1)

    def test_late_wrong_tuple_does_not_consume_current_job(self):
        fixture, value = self.fixture(), job()
        fixture.jobs.put(value)
        _relay, _stop, incoming, capture = self.relay(fixture)
        capture.wait(lambda message: message.get("type") == "job")
        incoming.put({"type": "result", "result": {**result(value), "requestId": "b" * 32}})
        capture.wait(lambda message: message.get("code") == "invalid-result")
        self.assertEqual(fixture.results, [])
        incoming.put({"type": "result", "result": result(value)})
        self.assertTrue(fixture.result_received.wait(3))
        self.assertEqual(len(fixture.results), 1)

    def test_result_lost_ack_never_retries(self):
        fixture, value = self.fixture(), job()
        fixture.jobs.put(value)
        fixture.result_hook = lambda: "drop"
        _relay, _stop, incoming, capture = self.relay(fixture)
        capture.wait(lambda message: message.get("type") == "job")
        incoming.put({"type": "result", "result": result(value)})
        capture.wait(lambda message: message.get("status") == "uncertain" and message.get("requestId") == value["requestId"])
        time.sleep(0.15)
        self.assertEqual(len(fixture.results), 1)

    def test_409_refreshes_runtime_without_resubmitting_result(self):
        old, new = self.fixture(), self.fixture("2" * 32)
        value = job()
        old.jobs.put(value)

        def rotate():
            self.metadata(new.runtime)
            return "stale"

        old.result_hook = rotate
        _relay, _stop, incoming, capture = self.relay(old)
        capture.wait(lambda message: message.get("type") == "job")
        incoming.put({"type": "result", "result": result(value)})
        self.assertTrue(new.attached.wait(3))
        self.assertEqual(len(old.results), 1)
        self.assertEqual(new.results, [])

    def test_repeated_job_does_not_dispatch_again(self):
        fixture, value = self.fixture(), job()
        fixture.jobs.put(value)
        fixture.jobs.put(value)
        _relay, _stop, incoming, capture = self.relay(fixture)
        capture.wait(lambda message: message.get("type") == "job")
        incoming.put({"type": "result", "result": result(value)})
        self.assertTrue(fixture.disconnected.wait(3))
        self.assertEqual(len([m for m in capture.messages if m.get("type") == "job"]), 1)

    def test_pending_timeout_disconnect_marks_uncertain_without_result(self):
        fixture, value = self.fixture(), job()
        fixture.jobs.put(value)
        _relay, _stop, _incoming, capture = self.relay(fixture, job_timeout=0.05)
        capture.wait(lambda message: message.get("type") == "job")
        capture.wait(lambda message: message.get("status") == "uncertain" and message.get("requestId") == value["requestId"])
        self.assertTrue(fixture.disconnected.wait(3))
        self.assertEqual(fixture.results, [])

    def test_waiting_state_emitted_once_and_stdin_errors_are_silent(self):
        stop, capture = threading.Event(), Capture()
        relay = host.Relay(self.path, queue.Queue(), host.FrameWriter(capture, stop), stop, retry_delay=0.02)
        thread = threading.Thread(target=relay.run)
        thread.start()
        capture.wait(lambda message: message.get("status") == "waiting")
        time.sleep(0.08)
        stop.set()
        thread.join(timeout=2)
        self.assertEqual(len(capture.messages), 1)
        stderr = io.StringIO()
        for frame in [b'\x01', struct.pack("<I", host.MAX_FRAME + 1), struct.pack("<I", 2) + b'[]']:
            out = io.BytesIO()
            with patch("sys.stderr", stderr):
                self.assertEqual(host.main([host.CALLER, "--runtime", str(self.path)], io.BytesIO(frame), out), 1)
            stream = io.BytesIO(out.getvalue())
            messages = []
            while (message := host.read_frame(stream)) is not None:
                messages.append(message)
            self.assertTrue(any(message.get("code") == "invalid-frame" for message in messages))
        self.assertEqual(stderr.getvalue(), "")


if __name__ == "__main__":
    unittest.main()
