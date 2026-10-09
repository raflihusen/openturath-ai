"""Restricted sharing adapter for the VPS worker; JSON stdin/stdout only.

Existing consented NotebookLM storage is used. Never mints Google credentials,
never switches identities, and never reports success from a viewer count alone.
"""
import asyncio
import json
import os
import re
import sys

UUID = re.compile(r"^[0-9a-f]{8}(?:-[0-9a-f]{4}){3}-[0-9a-f]{12}$", re.I)


async def observe(client, notebook_id):
    from notebooklm.rpc import RPCMethod
    from notebooklm.types import ShareStatus

    raw = await client.rpc_call(RPCMethod.GET_SHARE_STATUS, [notebook_id, [2]],
                                source_path=f"/notebook/{notebook_id}")
    # The SDK parser tolerates malformed lists. A revoke verifier must not turn
    # absent/malformed data into an empty, apparently successful viewer list.
    if not isinstance(raw, list) or len(raw) < 2 or not isinstance(raw[0], list):
        raise ValueError("Incomplete share response")
    for row in raw[0]:
        if not isinstance(row, list) or not row or not isinstance(row[0], str) or "@" not in row[0]:
            raise ValueError("Incomplete member identity")
    status = ShareStatus.from_api_response(raw, notebook_id)
    return {"notebookId": notebook_id, "isPublic": status.is_public,
            "emails": [u.email.strip().lower() for u in status.shared_users], "complete": True}


async def run(request):
    from notebooklm import NotebookLMClient
    from notebooklm.rpc.types import SharePermission, ShareViewLevel

    notebook_id = request.get("notebookId", "")
    operation = request.get("operation")
    if not UUID.fullmatch(notebook_id) or operation not in {"observe", "apply", "restrict"}:
        raise ValueError("Invalid sharing request")
    path = os.environ.get("NOTEBOOKLM_STORAGE_PATH")
    if not path or not os.path.isfile(path):
        raise ValueError("Consented owner storage is unavailable")
    async with NotebookLMClient.from_storage(path=path) as client:
        initial = await observe(client, notebook_id)
        if operation != "observe":
            if initial["isPublic"]:
                await client.sharing.set_public(notebook_id, False)
            if operation == "apply":
                email = request.get("email", "").strip().lower()
                if not re.fullmatch(r"[^\s@]+@[^\s@]+\.[^\s@]+", email) or not isinstance(request.get("desired"), bool):
                    raise ValueError("Invalid target identity")
                present = email in initial["emails"]
                if request["desired"] and not present:
                    await client.sharing.add_user(notebook_id, email, SharePermission.VIEWER, notify=False)
                elif not request["desired"] and present:
                    await client.sharing.remove_user(notebook_id, email)
                await client.sharing.set_view_level(notebook_id, ShareViewLevel.CHAT_ONLY)
            result = await observe(client, notebook_id)
            if result["isPublic"]:
                raise ValueError("Restricted sharing could not be verified")
            return result
        return initial


if __name__ == "__main__":
    try:
        result = asyncio.run(asyncio.wait_for(run(json.load(sys.stdin)), timeout=90))
        print(json.dumps(result))
    except Exception as error:
        # SDK exception strings can contain private payloads or session details.
        print(json.dumps({"error": "Sharing observation/operation failed", "category": type(error).__name__}))
        sys.exit(1)
