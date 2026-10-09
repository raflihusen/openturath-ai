# Local macOS WebView correction candidate — 9 October 2026

Source implementation: 867533b; diagnostic removal: f98e90c; regression captures: 1f5db55.

## Regression and correction

The previous layout gave flex growth to both the transcript branch and an input-only branch, allowing each to consume viewport space. It also excluded disabled inputs and consequently removed composer positioning during response generation. A separate-branch fixture with upstream padding/min-height and a constrained inner scroller failed before the correction (bottom gap 70 px; legacy transcript limit 450 px).

The nearest shared conversation parent now allocates remaining height to the transcript, and input-only branches retain natural height. The scrolling transcript releases legacy height/max-height restrictions. Visible disabled composers retain their layout; session-readiness criteria remain separate. Placeholder removal and accessible names remain preserved.

## Validation

- WebKit: 3 tests passed; includes nested branches, disabled/active transition, empty/populated/replaced DOM, resize, long Arabic text, light/dark captures, and complete script execution.
- Script/readiness: 9 tests passed. Notebook navigation: 3 tests passed.
- Flutter analyzer: no issues.
- Flutter macOS release compilation: exit 0, app 132.5 MB.
- Local packaging: exit 0; hdiutil verification VALID.
- 37 distinct Mach-O files verified for both arm64 and x86_64.
- Deep/strict codesign and Info.plist checks passed. Signature is ad-hoc.
- Corrected layout markers verified in the compiled UTF-16 Dart script; temporary diagnostic marker absent.
- Read-only mounted package signature passed; Info.plist and App.framework match the build; Applications symlink present; mount detached.
- Protected WebView lifecycle files are unchanged by this correction.

## Artifact

Path: `/Users/apple/Downloads/ramadhan/OpenTurath_AI_macOS_webview_fix.dmg`

Version: 1.0.63+64. Size: 51,326,108 bytes. Copy timestamp: 2026-10-09 11:30:02 +03:00.

SHA-256: `cedf52740c899ed166f2aa9ca7979966d08edc8b2cdbc8b313c8176c0a94223b`.

## Remaining gate

This is a local correction candidate, not a claim of authenticated NotebookLM validation. The old installed app's clipped answer was visually reproduced. The diagnostic app then opened at the OpenTurath login screen, so geometry capture of the authenticated NotebookLM DOM and verification of this correction on that DOM remain pending user sign-in. Synthetic WebKit fixtures do not establish visual acceptance or end-to-end service correctness. Intel-host launch and Apple notarization were not performed. No upload or update broadcast occurred.
