# Personal browser companion — local desktop pilot

Status on 2026-10-01: implemented and automatically checkpointed; authenticated end-to-end testing is still pending. This is not an all-platform release.

The study conversation stays in the native OpenTurath interface. Official Firebase Google sign-in opens Google Chrome. A narrowly scoped Chrome extension subsequently uses the user's own NotebookLM session in that browser. Google cookies remain browser-managed; neither cookies, browser profiles, bootstrap HTML, nor NotebookLM session tokens are exported to Flutter or a server.

## Boundaries

- The extension requests only `nativeMessaging` and the two NotebookLM HTTPS hosts. Its stable ID is `hbbeklipfbgookgdmkmodkanoflegbok`.
- A registered Python native host communicates with Flutter over authenticated IPv4 loopback. Runtime capabilities are short-lived and stored under a private directory, never sent to the extension.
- Firebase's verified Google provider establishes the app identity. Every send rechecks server entitlement and resolves the notebook through `getAgentUrl`.
- Request ID, session epoch, Firebase UID, Google subject, email, and notebook ID bind replies to their original owner. Browser email is an observed account label from NotebookLM bootstrap data; it is not signed proof of the browser's Google subject.
- The browser adapter uses NotebookLM's undocumented web protocol. Future changes can break it. Chrome native messaging is supported infrastructure; the consumer NotebookLM chat protocol is not an official integration API.
- A dispatch ledger records correlation fields and state, without question/answer contents or Google secrets. Dispatch is saved before delivery. Interrupted requests remain uncertain and never replay automatically, including after restart.
- Native logout revokes the companion and its pending work. It does not sign the user out of Google globally.
- Same-user local processes and an explicitly installed extension remain part of the trust boundary. The immediate directory/file permissions are checked; this is not a full ancestor/ACL or machine-compromise audit.
- The pilot deliberately stops at 4096 retained request IDs. A reviewed retention policy and packaged host/extension are required before release.

## Local setup

Normal builds leave this experiment disabled. The operator-account backend prototype is unrelated and remains disabled.

1. Review the extension and native host source and approve installing the local extension.
2. Register the native host with `python3 tools/browser_companion/register_host.py --install`.
3. In the intended Chrome profile, open Chrome Extensions, enable developer mode, and load `tools/browser_companion/extension` as an unpacked extension.
4. Build with `flutter build macos --debug --dart-define=OPENTURATH_BROWSER_COMPANION=true`.
5. Sign into OpenTurath using the approved Google account in that same Chrome profile. Open a study assistant, verify connection, and send an ordinary test question.
6. Verify citations, follow-up context, restart, account mismatch, and logout using the real account. Build and fixture success do not satisfy these steps.

Registration creates a user-specific Chrome native messaging manifest and a launcher pointing at this checkout. This is a development installation; it requires the local Python runtime and is not a distributable app installer.

## Verification evidence

| Check | Result |
| --- | --- |
| Full Flutter regression suite | 318 passed, exit 0 |
| Additional chat lifecycle suite | 14 passed, exit 0; simulated identities/entitlement stages |
| Protocol module | 20 passed, exit 0; synthetic NotebookLM responses |
| Native host | 18 passed, exit 0; actual local HTTP and framed transport fixtures |
| Extension worker | 13 passed, exit 0; mocked Chrome APIs |
| Flutter analyzer | Clean after integration fixes; lifecycle suite also clean |
| macOS ARM64 development build | Built successfully, exit 0 |
| Apple signature | Deep/strict verification passed, exit 0; Team `TG4G5DYSFG`, valid Keychain access group |
| Web release compilation | Built successfully, exit 0; desktop companion is explicitly unavailable on web |
| Local registration script | Temporary-directory fixture passed; real browser registration not applied yet |
| Approved account end-to-end | Pending extension installation and permitted local account switch |

The first macOS build ran out of disk space. Rebuildable Android intermediates were removed while APK outputs were retained; the subsequent macOS build completed. Existing APK release files were not replaced or published.

Launching the signed build restored a different previously saved app account. Its session has not been changed. An isolated bundle build was attempted instead, but Xcode could not create its new provisioning profile because its saved Apple account credentials were unavailable. The ordinary registered-bundle build and signature verification succeeded.

## Platform matrix

| Platform | Current companion status |
| --- | --- |
| macOS | Code, local transport tests, signed build verified; real account test pending |
| Linux desktop | Source path present; no Linux runtime/build verification |
| Windows | Fails closed; native executable packaging, Windows caller arguments, and verified private ACLs still required |
| Android / iOS | Companion unavailable; no supported Chrome mobile native-messaging path implemented |
| Web | Compiles with an explicit unsupported transport; no silent WebView or operator-account fallback |

The available test machine exposes macOS and Chrome only. No Android device, iOS simulator runtime, or Windows host was available. This matrix cannot be represented as all-platform success.

## Primary references

- [Chrome native messaging](https://developer.chrome.com/docs/extensions/develop/concepts/native-messaging)
- [Chrome service worker lifecycle](https://developer.chrome.com/docs/extensions/develop/concepts/service-workers/lifecycle)
- [Content script network requests](https://developer.chrome.com/docs/extensions/develop/concepts/network-requests)
- [Google OAuth policies](https://developers.google.com/identity/protocols/oauth2/policies)
- [Firebase Flutter federated authentication](https://firebase.google.com/docs/auth/flutter/federated-auth)

The web-protocol adapter was inspected against the project's local `notebooklm-py` wheel, SHA-256 `f5cb9f5e9bac1064233f889aebd01bf6a92acb1e2738476d4d422d4d42aa0a88`. No stored Google credential files were read or used by these tests.
