#!/usr/bin/env python3
"""Restricted native-messaging relay; Google credentials stay in the browser.

Only one worker owns HTTP. POSIX runtime ownership/modes are checked without
following symlinks. Windows native ACL verification is not implemented here;
the installer must provision a user-private directory and file ACL.
"""

import http.client
import json
import os
from pathlib import Path
import queue
import re
import secrets
import stat
import struct
import sys
import threading
import time

CALLER = "chrome-extension://hbbeklipfbgookgdmkmodkanoflegbok/"
MAX_FRAME = 1024 * 1024
NONCE = re.compile(r"[0-9a-f]{32}\Z")
BEARER = re.compile(r"[0-9a-f]{64}\Z")
UUID = re.compile(r"[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}\Z", re.I)
EMAIL = re.compile(r"[^\s@]+@[^\s@]+\.[^\s@]+\Z")
TUPLE = ("requestId", "epoch", "uid", "googleSub", "email", "notebookId")
SAFE_CODES = frozenset({"invalid-argument", "unavailable", "unauthenticated",
                        "account-mismatch", "failed-precondition",
                        "deadline-exceeded", "uncertain", "busy"})


class ProtocolError(Exception):
    """Intentionally carries no untrusted text or credentials."""


class StaleSession(ProtocolError):
    pass


def _object(pairs):
    result = {}
    for key, value in pairs:
        if key in result:
            raise ProtocolError()
        result[key] = value
    return result


def decode_json(raw):
    try:
        value = json.loads(raw.decode("utf-8"), object_pairs_hook=_object,
                           parse_constant=lambda _: (_ for _ in ()).throw(ProtocolError()))
    except (ValueError, UnicodeError, RecursionError):
        raise ProtocolError() from None
    if not isinstance(value, dict):
        raise ProtocolError()
    return value


def encode_json(value):
    try:
        raw = json.dumps(value, ensure_ascii=False, allow_nan=False,
                         separators=(",", ":")).encode("utf-8")
    except (ValueError, TypeError, UnicodeError, RecursionError):
        raise ProtocolError() from None
    if len(raw) > MAX_FRAME:
        raise ProtocolError()
    return raw


def _read_exact(stream, length):
    chunks = []
    remaining = length
    while remaining:
        chunk = stream.read(remaining)
        if not chunk:
            raise ProtocolError()
        chunks.append(chunk)
        remaining -= len(chunk)
    return b"".join(chunks)


def read_frame(stream):
    first = stream.read(1)
    if not first:
        return None
    size = struct.unpack("<I", first + _read_exact(stream, 3))[0]
    if not 1 <= size <= MAX_FRAME:
        raise ProtocolError()
    return decode_json(_read_exact(stream, size))


class FrameWriter:
    def __init__(self, stream, stop):
        self.stream, self.stop = stream, stop
        self.lock = threading.Lock()

    def send(self, value):
        raw = encode_json(value)
        with self.lock:
            try:
                self.stream.write(struct.pack("<I", len(raw)) + raw)
                self.stream.flush()
            except (BrokenPipeError, OSError, ValueError):
                self.stop.set()
                return False
        return True


def default_runtime_path():
    if sys.platform == "darwin":
        return Path.home() / "Library/Application Support/OpenTurath/Companion/runtime.json"
    if sys.platform == "win32":
        local = os.environ.get("LOCALAPPDATA")
        if not local:
            raise ProtocolError()
        return Path(local) / "OpenTurath/Companion/runtime.json"
    return Path.home() / ".local/share/OpenTurath/Companion/runtime.json"


def _private(info, mode):
    return info.st_uid == os.getuid() and stat.S_IMODE(info.st_mode) == mode


def read_runtime(path):
    path = Path(path)
    directory_fd = None
    fd = None
    try:
        parent = path.parent.lstat()
        if not stat.S_ISDIR(parent.st_mode) or stat.S_ISLNK(parent.st_mode):
            raise ProtocolError()
        if os.name == "posix":
            if not _private(parent, 0o700):
                raise ProtocolError()
            directory_fd = os.open(path.parent, os.O_RDONLY | os.O_DIRECTORY | os.O_NOFOLLOW)
            if not _private(os.fstat(directory_fd), 0o700):
                raise ProtocolError()
            fd = os.open(path.name, os.O_RDONLY | os.O_NOFOLLOW, dir_fd=directory_fd)
        else:
            if path.is_symlink() or not stat.S_ISREG(path.lstat().st_mode):
                raise ProtocolError()
            fd = os.open(path, os.O_RDONLY | getattr(os, "O_BINARY", 0))
        info = os.fstat(fd)
        if not stat.S_ISREG(info.st_mode) or info.st_nlink != 1 or info.st_size > 8192:
            raise ProtocolError()
        if os.name == "posix" and not _private(info, 0o600):
            raise ProtocolError()
        raw = os.read(fd, 8193)
        if len(raw) > 8192:
            raise ProtocolError()
        runtime = decode_json(raw)
        if (set(runtime) != {"version", "port", "bearer", "epoch", "pid"}
                or type(runtime["version"]) is not int or runtime["version"] != 1
                or type(runtime["port"]) is not int or not 1024 <= runtime["port"] <= 65535
                or type(runtime["pid"]) is not int or runtime["pid"] <= 0
                or not isinstance(runtime["bearer"], str) or not BEARER.fullmatch(runtime["bearer"])
                or not isinstance(runtime["epoch"], str) or not NONCE.fullmatch(runtime["epoch"])):
            raise ProtocolError()
        return runtime
    except (OSError, ValueError, KeyError):
        raise ProtocolError() from None
    finally:
        if fd is not None:
            os.close(fd)
        if directory_fd is not None:
            os.close(directory_fd)


def _email(value):
    return (isinstance(value, str) and len(value) <= 320
            and value == value.lower() and EMAIL.fullmatch(value))


def validate_job(raw, epoch):
    if not isinstance(raw, dict):
        raise ProtocolError()
    required = {*TUPLE, "question", "history", "conversationId"}
    if not required.issubset(raw):
        raise ProtocolError()
    if (not isinstance(raw["requestId"], str) or not NONCE.fullmatch(raw["requestId"])
            or raw["epoch"] != epoch
            or not isinstance(raw["uid"], str) or not 1 <= len(raw["uid"]) <= 128
            or any(ord(c) < 32 or ord(c) == 127 for c in raw["uid"])
            or not isinstance(raw["googleSub"], str)
            or not re.fullmatch(r"\d{1,64}", raw["googleSub"], re.ASCII)
            or not _email(raw["email"])
            or not isinstance(raw["notebookId"], str) or not UUID.fullmatch(raw["notebookId"])
            or not isinstance(raw["question"], str) or not raw["question"].strip()
            or len(raw["question"]) > 8000
            or not (raw["conversationId"] is None or
                    isinstance(raw["conversationId"], str) and UUID.fullmatch(raw["conversationId"]))):
        raise ProtocolError()
    history = raw["history"]
    if history is not None:
        if (not isinstance(history, list) or len(history) > 80
                or any(not isinstance(turn, list) or len(turn) != 3
                       or not isinstance(turn[0], str) or len(turn[0]) > 128000
                       or turn[1] is not None or type(turn[2]) is not int or turn[2] not in (1, 2)
                       for turn in history)
                or len(encode_json({"history": history})) > 120000):
            raise ProtocolError()
    job = {key: raw[key] for key in (*TUPLE, "question", "history", "conversationId")}
    encode_json({"type": "job", "job": job})
    return job


def validate_result(raw, job):
    if not isinstance(raw, dict) or any(raw.get(key) != job[key] for key in TUPLE):
        raise ProtocolError()
    result = {key: job[key] for key in TUPLE}
    if raw.get("code") is not None:
        if not isinstance(raw["code"], str) or raw["code"] not in SAFE_CODES:
            raise ProtocolError()
        return {**result, "answer": "", "citations": [], "conversationId": None, "code": raw["code"]}
    if (not isinstance(raw.get("answer"), str) or not raw["answer"].strip()
            or len(raw["answer"]) > 128000
            or raw.get("accountEmail") != job["email"]
            or not isinstance(raw.get("conversationId"), str)
            or not UUID.fullmatch(raw["conversationId"])
            or not isinstance(raw.get("citations"), list) or len(raw["citations"]) > 100):
        raise ProtocolError()
    citations = []
    for citation in raw["citations"]:
        if (not isinstance(citation, dict) or not isinstance(citation.get("sourceId"), str)
                or not UUID.fullmatch(citation["sourceId"])
                or type(citation.get("citationNumber")) is not int
                or not 1 <= citation["citationNumber"] <= 1000
                or not (citation.get("excerpt") is None or
                        isinstance(citation["excerpt"], str) and len(citation["excerpt"]) <= 4000)):
            raise ProtocolError()
        citations.append({"sourceId": citation["sourceId"],
                          "citationNumber": citation["citationNumber"], "excerpt": citation.get("excerpt")})
    result.update(answer=raw["answer"], citations=citations,
                  conversationId=raw["conversationId"], accountEmail=raw["accountEmail"])
    encode_json(result)
    return result


def post(runtime, route, payload, timeout=25):
    if route not in ("/attach", "/poll", "/result", "/disconnect"):
        raise ProtocolError()
    connection = http.client.HTTPConnection("127.0.0.1", runtime["port"], timeout=timeout)
    try:
        connection.request("POST", route, body=encode_json(payload), headers={
            "Authorization": "Bearer " + runtime["bearer"],
            "Content-Type": "application/json", "Accept": "application/json",
        })
        response = connection.getresponse()
        if response.status == 409:
            raise StaleSession()
        if response.status != 200 or response.headers.get_content_type() != "application/json":
            raise ProtocolError()
        length = response.getheader("Content-Length")
        if length is not None and (not length.isdecimal() or int(length) > MAX_FRAME):
            raise ProtocolError()
        raw = response.read(MAX_FRAME + 1)
        if len(raw) > MAX_FRAME:
            raise ProtocolError()
        data = decode_json(raw)
        if route == "/poll":
            if set(data) != {"job"} or not (data["job"] is None or isinstance(data["job"], dict)):
                raise ProtocolError()
        elif set(data) != {"ok"} or data["ok"] is not True:
            raise ProtocolError()
        return data
    except (OSError, http.client.HTTPException, ValueError):
        raise ProtocolError() from None
    finally:
        connection.close()


class Relay:
    def __init__(self, runtime_path, incoming, writer, stop, retry_delay=0.5, http_timeout=25, job_timeout=180):
        self.runtime_path, self.incoming, self.writer, self.stop = runtime_path, incoming, writer, stop
        self.retry_delay, self.http_timeout = retry_delay, http_timeout
        self.job_timeout, self.pending_since = job_timeout, 0
        self.client_id = secrets.token_hex(16)
        self.runtime = None
        self.attached = False
        self.pending = None
        self.seen_jobs = set()
        self.last_state = None

    def state(self, status, code, request_id=None):
        identity = (status, code, request_id)
        if identity == self.last_state:
            return
        self.last_state = identity
        message = {"type": "state", "status": status, "code": code}
        if request_id is not None:
            message["requestId"] = request_id
        self.writer.send(message)

    def call(self, route, payload):
        return post(self.runtime, route, payload, self.http_timeout)

    def disconnect(self):
        if self.pending is not None:
            self.state("uncertain", "uncertain", self.pending["requestId"])
        if self.attached:
            try:
                self.call("/disconnect", {"clientId": self.client_id, "epoch": self.runtime["epoch"]})
            except ProtocolError:
                pass
        self.pending, self.attached, self.runtime = None, False, None

    def run(self):
        try:
            while not self.stop.is_set():
                if not self.attached:
                    try:
                        self.runtime = read_runtime(self.runtime_path)
                        self.call("/attach", {"clientId": self.client_id, "protocol": 1,
                                              "epoch": self.runtime["epoch"]})
                        self.attached = True
                        self.state("connected", "ready")
                    except ProtocolError:
                        self.runtime = None
                        self.state("waiting", "waiting")
                        self.stop.wait(self.retry_delay)
                        continue
                try:
                    if self.pending is not None:
                        if time.monotonic() - self.pending_since >= self.job_timeout:
                            raise ProtocolError()
                        try:
                            message = self.incoming.get(timeout=self.retry_delay)
                        except queue.Empty:
                            continue
                        if message.get("type") == "connected":
                            continue
                        raw = message.get("result")
                        # A stale response cannot consume another pending request.
                        if not isinstance(raw, dict) or any(raw.get(k) != self.pending[k] for k in TUPLE):
                            self.state("uncertain", "invalid-result")
                            continue
                        result = validate_result(raw, self.pending)
                        # Consume before HTTP. If acknowledgement is lost, never resubmit.
                        self.pending = None
                        try:
                            self.call("/result", {"clientId": self.client_id,
                                                 "epoch": self.runtime["epoch"], "result": result})
                        except ProtocolError:
                            self.state("uncertain", "uncertain", result["requestId"])
                            raise
                        continue
                    # Reject late/duplicated frames before asking for another job.
                    while True:
                        try:
                            self.incoming.get_nowait()
                        except queue.Empty:
                            break
                    polled = self.call("/poll", {"clientId": self.client_id, "epoch": self.runtime["epoch"]})
                    if polled["job"] is None:
                        self.stop.wait(0.05)
                        continue
                    job = validate_job(polled["job"], self.runtime["epoch"])
                    key = tuple(job[k] for k in ("uid", "googleSub", "notebookId", "requestId"))
                    if key in self.seen_jobs or len(self.seen_jobs) >= 4096:
                        raise ProtocolError()
                    self.seen_jobs.add(key)
                    self.pending = job
                    self.pending_since = time.monotonic()
                    if self.stop.is_set():
                        break
                    self.writer.send({"type": "job", "job": job})
                except ProtocolError:
                    self.state("uncertain", "uncertain")
                    self.disconnect()
                    self.stop.wait(self.retry_delay)
        finally:
            self.disconnect()


def main(argv=None, input_stream=None, output_stream=None):
    argv = sys.argv[1:] if argv is None else argv
    incoming = queue.Queue(maxsize=64)
    stop = threading.Event()
    writer = FrameWriter(output_stream or sys.stdout.buffer, stop)
    if not argv or argv[0] != CALLER or not (len(argv) == 1 or
            len(argv) == 3 and argv[1] == "--runtime" and 0 < len(argv[2]) <= 4096):
        writer.send({"type": "state", "status": "disconnected", "code": "invalid-caller"})
        return 2
    try:
        runtime_path = Path(argv[2]) if len(argv) == 3 else default_runtime_path()
    except ProtocolError:
        writer.send({"type": "state", "status": "waiting", "code": "waiting"})
        return 1
    relay = Relay(runtime_path, incoming, writer, stop)
    worker = threading.Thread(target=relay.run, name="companion-relay")
    worker.start()
    exit_code = 0
    try:
        while not stop.is_set():
            message = read_frame(input_stream or sys.stdin.buffer)
            if message is None:
                break
            if (set(message) == {"type", "protocol"} and message["type"] == "connected"
                    and type(message["protocol"]) is int and message["protocol"] == 1):
                continue
            if set(message) != {"type", "result"} or message["type"] != "result" or not isinstance(message["result"], dict):
                raise ProtocolError()
            try:
                incoming.put_nowait(message)
            except queue.Full:
                raise ProtocolError() from None
    except (ProtocolError, OSError, ValueError):
        writer.send({"type": "state", "status": "disconnected", "code": "invalid-frame"})
        exit_code = 1
    finally:
        stop.set()
        worker.join()
    return exit_code


if __name__ == "__main__":
    raise SystemExit(main())
