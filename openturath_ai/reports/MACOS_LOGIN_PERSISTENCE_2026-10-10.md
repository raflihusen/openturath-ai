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
