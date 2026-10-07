# Checkpoint Cairo dan katalog editorial

Branch: `codex/cairo-editorial-2026-10-07`. Baseline: `e8c6861`.

Setiap perubahan kode/aset/test/dokumen disimpan terpisah. Pemulihan selektif memakai `git revert <hash>` pada commit komponen yang dipilih; jangan reset seluruh workspace karena ada perubahan lain di luar pekerjaan ini. Commit perbaikan yang bergantung pada komponen awal harus ditinjau bersama. Tidak ada push, upload, atau broadcast.

| Commit | Perubahan |
|---|---|
| 422fd46 | feat(typography): bundle Cairo original weights for Arabic UI |
| 6f47967 | feat(arabic): separate concise decorative labels from scholarly identities |
| 65d3cbd | feat(cards): fill decorative layer with bold Cairo without reserved space |
| 2115f9a | feat(ai): center identities and separate icon pill from circular references |
| 48cae29 | feat(navigation): give desktop brand mark stronger visual presence |
| a7c3705 | feat(tahawwulat): host circular reference action inside exclusive hero |
| ad847b3 | refactor(tahawwulat): remove detached reference action below hero |
| db3ec4c | feat(catalog): compose flexible editorial identity rows with grouped metadata |
| fa095f1 | feat(catalog): make editorial list the default collection view |
| f38755c | feat(dashboard): unify greeting access pill and concise Arabic field watermark |
| bae786e | fix(arabic): name language AI علوم العربية while preserving IDs |
| c41f5ce | docs(webview): dokumentasikan standar emas format ideal WebView di AGENTS.md dan docs |
| a1a14ee | fix(tahawwulat): expose reference callback in hero constructor |
| 1b67ef4 | fix(dashboard): separate greeting from rounded session action |
| ea06972 | feat(calendar): provide structured localized dates without string splitting |
| da3a85d | feat(calendar): add equal date columns and quiet visual separation |
| 9a56cbc | fix(motion): repaint folios directly with continuous moderate loop velocity |
| 6c0e350 | fix(motion): close painter semantics boundary correctly |
| 6b44cfe | feat(tokens): add explicit calendar day typography role |
| a1c3057 | fix(calendar): use shared day role for equal calendar emphasis |
| cbf20e8 | feat(catalog): keep edition details in detail and core facts in list |
| 24ca370 | feat(dashboard): organize factual library metrics with icons and dividers |
| c36988d | feat(localization): assign stable section IDs to canonical legal documents |
| a22a71d | feat(localization): translate all canonical legal sections into English offline |
| bbaa14f | feat(localization): provide full offline Arabic policy and scholarly conduct documents |
| 1eed6bf | feat(localization): resolve legal documents by stable ID and current locale |
| 1b98c18 | feat(adab): share eight monochrome conduct icons keyed by section |
| 260a0a1 | feat(documents): render localized reactive sheets and conduct icons |
| 9b44cdc | fix(localization): rebuild about dialog with live language and direction |
| 563c114 | feat(adab): show localized daily conduct with stable identity and icon |
| ca4280d | fix(localization): escape possessive English section heading |
| a8799f1 | refactor(ui): remove replaced canonical-copy and catalog helper imports |
| 2cf6836 | test(visual): render actual bundled Cairo weights in snapshots |
| a1bf3da | style(flutter): format Cairo editorial and localized document implementation |
| 3ec9db1 | test(localization): verify document parity live locale and icon routing |
| 0d2a6db | fix(arabic): resolve decorative labels for actual discipline identifiers |
| 2d8e254 | style(calendar): make responsive branch explicit |
| 55abbe7 | fix(catalog): label numeric page counts and omit absent metadata |
| 79ae8f9 | test(visual): add bilingual documents and genuine Cairo specimens |
| 2f3e8fc | docs(design): synchronize Cairo editorial controls and localization contracts |
| 31da289 | style(review): format final metadata and visual fixture additions |
| 5dfc015 | test(motion): add native ten-cycle profiling and separate render capture harness |
| 3e435df | style(motion): format native motion review harness |
| 711f38e | style(localization): use explicit blocks in document parity assertions |
| 8a21bda | test(catalog): assert core list metadata without detail-only publisher |
| 506b401 | docs(review): publish local gallery of 82 production-widget Cairo editorial renders |
| b31c448 | fix(localization): isolate Latin contact and regulation identifiers in Arabic display |
| 296ebfb | fix(legal-ui): apply local bidi isolation while preserving source semantics |
| b7842e2 | test(legal-ui): verify Arabic isolation does not mutate source content |
| c7b99e4 | style(legal-ui): format isolated body resolver and checks |
| ff66f94 | test(native): add isolated real-route Cairo review entry point |
| c6742d8 | style(native): format isolated route review harness |
