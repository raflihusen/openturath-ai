# Notebook main-document TIMEOUT — local investigation, 9 October 2026

## Observed failure

The active release process logged `Main-document load failed: TIMEOUT`, matching the user's Al-Muhaqqiq error screen. This callback is restricted to main-document failures. It is distinct from the application's 45-second DOM/readiness timeout.

On the same Mac/network:

| Check | Result |
|---|---|
| Google Accounts HTTPS | HTTP 302, 0.89 seconds |
| Legacy notebooklm.google.com origin | TCP connection timeout; DNS resolved in 0.009 seconds |
| Legacy origin IPv4 | No TCP connection after 8 seconds |
| Legacy origin IPv6 | No TCP connection after 8 seconds |
| Current notebook.google.com origin | HTTP 200, 2.73 seconds |
| Legacy origin using the reachable Google edge IP, normal TLS verification | HTTP 301, 0.68 seconds |
| Legacy /notebook/synthetic-UUID via reachable edge | HTTP 301 Location to notebook.google.com with identical path |

The legacy host resolved to IPv4 142.250.181.206 / IPv6 2a00:1450:4006:81f::200e; the current host connected to 142.251.36.206. This proves an unreachable legacy-origin connection path during the audit. It does not determine whether the underlying routing issue is at the ISP, an intermediate network, or the particular Google edge. It is not evidence that all internet connectivity is unavailable or that Google globally failed.

The pinned-IP request was diagnostic only. Production does not pin an IP, override system DNS, bypass TLS, or use a proxy.

## Correction

AgentService still validates the authenticated server response, strict HTTPS host allowlist, exact UUID path, and absence of query/fragment before returning a URL. It now replaces only the legacy host with Google's observed redirect destination, notebook.google.com. Server notebook selection, path, ID and entitlement remain unchanged; there is no fallback notebook catalog.

The Google session screen uses the canonical origin as its login continuation, while cookie discovery still checks both old and new origins for compatibility. Native WebView lifecycle files were not changed. Four readiness samples, minimum 3000ms, 250ms stabilization and complete viewport replacement on errors remain intact.

## Verification so far

- 30 tests passed across agent URL security/assignment, auth UI and notebook navigation.
- Auth test additionally checks the Google login continuation resolves directly to the canonical origin.
- Analyzer: no issues found.
- Corrected local macOS release version: 1.0.64+65.
- Final macOS release build: exit 0, application 132.5 MB.
- Packaging: exit 0; hdiutil verification VALID; read-only mounted package matched the build's Info.plist and App.framework hashes, and included the Applications link. Volume detached.
- All 37 distinct Mach-O files support both arm64 and x86_64; deep/strict signature verification passed. Ad-hoc signature; no Apple notarization or Intel-host launch.
- Native app 1.0.64+65 launched successfully, but returned to the OpenTurath sign-in screen after binary replacement. The user was asked to sign in and open Al-Muhaqqiq. Authenticated NotebookLM loading/response verification remains pending; public HTTPS success is not treated as that proof.

## Local artifact

- `/Users/apple/Downloads/ramadhan/OpenTurath_AI_macOS_1.0.64.dmg`
- Version 1.0.64+65; 51,324,782 bytes; timestamp 2026-10-09 13:08:45 +03:00.
- SHA-256: `1569dec389d1c660a8b254379eb51685f45e1ff1f73cf426179a878fd9689b25`.
- Implementation checkpoints: dfad76c, d038298, d836971, d3a17aa; version eb3eb77.
- Local build only; no deployment, upload or update broadcast. Prior DMGs retained.

The implemented correction removes the observed dependency on an unreachable legacy-origin route. It cannot guarantee Google service availability or eliminate future network outages. The audit does not claim that actual authenticated AI use has already passed.
