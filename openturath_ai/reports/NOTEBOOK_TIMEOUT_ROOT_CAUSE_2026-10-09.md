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
- Real authenticated runtime and final package verification pending at this checkpoint.
