# macOS login persistence correction — 10 October 2026

## Root cause

The macOS AppDelegate's launch handler deleted three credential keys from the Firebase SDK preference domain on every launch. This cleanup was introduced in ed96be9 for a former browser-only authentication implementation; the app subsequently returned to native Firebase authentication.

The installed FirebaseAuth SDK's AuthKeychainServices.setItemLegacy explicitly stores the official SDK user data in AuthUserDefaults on macOS if Keychain writes fail. AuthStoredUserManager also uses a fallback key matched by the cleanup. The launch handler therefore deleted SDK-managed persisted sessions before Firebase could restore them. Cached app profiles survived, but did not restore a valid authenticated Firebase session; the dashboard's currentUser guard consequently returned to login.

The release target also used ad-hoc signing without keychain-access-groups. A synthetic Data Protection Keychain write from an unentitled native probe returned -34018 (missing entitlement). No user credentials were read or printed. A signed standalone probe without a provisioning profile was rejected by macOS, which confirms signature verification alone is insufficient for restricted entitlements.

Primary reference: https://firebase.google.com/docs/ios/troubleshooting-faq#macos-keychain-sharing.

## Changes and checkpoints

- b7c9fda: remove startup credential purge; retain normal explicit logout.
- f4e5c48: add release Keychain group for the existing team and bundle.
- 5e6bc6e: use the installed Apple Development identity and automatic signing instead of ad-hoc signing.
- aa8e841: version 1.0.65+66.
- a422ec6, f780405, 3befc24: packaging checks stable signing, own Keychain group and a valid authorizing development profile; rejects old ad-hoc packages.

No Firebase token store was implemented in app preferences. Firebase SDK remains the authentication authority and owns its persisted state. No VIP, module entitlement, transaction/reaper, or protected WebView lifecycle logic changed.

## Validation and pending gate

- Five splash/auth-stream tests passed.
- Flutter analyzer: no issues found.
- Release entitlements and project file plist validation passed.
- The new packaging gate rejected the old ad-hoc app as expected.
- Release build failed because no Mac development provisioning profile was present.
- Retrying Xcode with provisioning updates allowed confirmed `No Accounts: Add a new account in Accounts settings` and no matching profile.
- Xcode Apple Accounts screen showed no signed-in account. User was asked to sign in personally; no password was requested by the agent.

The code correction is checkpointed, but a new signed app/DMG and real account sign-in followed by close/reopen verification are pending the Apple account/provisioning prerequisite. Existing installed app and prior DMGs were not replaced. No public upload or update broadcast occurred.

## Follow-up after user completed Xcode account sign-in

Xcode generated a team TG4G5DYSFG development profile authorizing `TG4G5DYSFG.*` Keychain groups. It contains one registered device and expires 2026-10-17 13:06:52 UTC. This profile enables a local signed test; it is not a durable public release identity. Developer ID signing and notarization remain prerequisites for public macOS distribution.

The account UI now exposes a labelled Langganan button directly beneath identity on home and profile. Owner VIP status wins over paid/expired packages; active subscribers show PRO, trials show TRIAL, and pending payment does not claim PRO. No rights were granted or revoked by this presentation change. Fourteen focused membership/control tests passed, Flutter analyzer reported no issues, and the existing visual suite rendered 91 representative screens successfully. Desktop and enlarged-text phone profile captures were inspected. Fixtures are visual evidence, not authenticated production-session evidence.

## Final local release after owner declined paid Developer membership

Owner requested a free alternative. The earlier assumption that stable Apple identity is required for the session-purge fix was too restrictive: Apple identity is required for authorized Data Protection Keychain use and Apple-verified distribution, while the installed Firebase SDK already implements a macOS AuthUserDefaults fallback. The mandatory fix remains preserving those SDK entries on startup.

`tool/macos/verify_firebase_fallback.py` compiled the installed SDK AuthUserDefaults source unchanged, using only a unique disposable service and synthetic marker. The ad-hoc native probe returned Data Protection Keychain status -34018, wrote the marker through the official SDK helper, exited, and restored it in a new process. The probe cleared only its synthetic test domain. This establishes fallback storage persistence, not a real authenticated account session.

Xcode release compilation completed with exit 0. Final artifact was explicitly re-signed locally after compilation: no embedded short-lived development profile and no restricted Keychain entitlement. Source release configuration now selects the same profile-free local mode. No Gatekeeper setting was changed. Signing validation, both-architecture checks, DMG checksum verification, read-only mount inspection, version 1.0.65+66, Applications symlink, and exact App.framework hash comparison passed.

Installer: `/Users/apple/Downloads/ramadhan/OpenTurath_AI_macOS_1.0.65.dmg`
Size: 51,502,186 bytes
SHA-256: `8ae38522ff4e0716e4f7f699ffe6e7c2de2d3ae2bc0daf9b5bcac250a5bef312`

Installed app: `/Applications/OpenTurath AI.app`
Previous app preserved at `/Users/apple/Downloads/ramadhan/openturath_ai/build/release-backups/OpenTurath_AI_before_1.0.65_20261010_193747.app`.

The local app launched and rendered the real login screen. Google sign-in was started through its normal button; macOS AuthenticationServicesAgent was running, but its authentication dialog was unavailable through the enabled computer-use surface. User was asked to complete real login personally. Authenticated home/profile inspection and cold-close/reopen remain pending that input. No logged-in success is claimed. Fifteen focused membership tests passed; 91 visual fixtures passed; these remain distinct from authenticated runtime acceptance. No public broadcast/upload occurred.


## Follow-up: Google login fails before Firebase (1.0.66+67)

The user supplied two screenshots of the generic Google failure. A release build
was launched with stdout captured; real authorization produced this safe event:
`OpenTurathAuth stage=google-authorize code=sign_in_failed category=keychain`.
No email, OAuth token, or SDK credential payload was logged.

The installed GoogleSignIn source (`GIDSignIn.m`, `addSaveAuthCallback`) treats
failure to save GTMAppAuth's auth session as `kGIDSignInErrorCodeKeychain`.
The Flutter plugin maps this to `sign_in_failed` and details `keychain error`.
Previously the screen discarded those details and showed the generic retry text.
The Firebase fallback probe did not cover this earlier Google SDK write; it is
not proof that real Google login works. The previously suspected invisible
Google permission dialog was not established as the cause.

Independent native probes on this Mac:
- A fresh synthetic classic-Keychain `SecItemAdd` returned `-25293` (`errSecAuthFailed`).
- Apple's signed `/usr/bin/security add-generic-password`, with an unrelated
  synthetic service/account/value, also failed with exit 51 and the message
  `The user name or passphrase you entered is not correct.`
- `security show-keychain-info` on the existing login keychain produced the same error.
- `SecKeychainGetStatus` reported unlocked/readable/writable. Therefore this is
  **not established as a simply locked keychain**.
- A system unlock attempt returned `-25293`. Signing the synthetic probe with
  the existing Apple Development identity also returned `errSecInternalComponent`.

These observations establish a host login-Keychain access/authentication problem
that affects operations outside OpenTurath. They do not establish whether its
underlying cause is a password mismatch, OS authorization state, or a damaged
keychain. No keychain reset, credential deletion, trust relaxation, stored
password inspection, or security bypass was performed. Real login and a cold
quit/reopen remain blocked by this host condition. A paid Developer ID account
has not been demonstrated necessary to resolve this host failure.

The app now maps Google's actual Keychain failure to actionable localized copy,
treats authorization cancellation quietly, distinguishes network errors, and
never displays raw unknown SDK credential payloads. Six new regression tests
plus existing auth/splash/membership tests passed (26 total); analysis passed.
This build diagnoses the failure correctly; it is not an authenticated success
claim or a claim that system Keychain access has been repaired.
