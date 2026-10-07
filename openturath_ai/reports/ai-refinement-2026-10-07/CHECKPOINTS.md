# Checkpoint pemulihan — AI refinement

Branch: `codex/rounded-flagship-review-2026-10-07`. Baseline sebelum koreksi ini: `54d9a35`. Semua perubahan kode, token, tes dan aset tinjauan memperoleh checkpoint tersendiri.

| Bagian | Checkpoint utama |
|---|---|
| Beranda tanpa hero, kartu ilmu gelap | `4bd8e16`, `9f86f83` |
| Permukaan watermark Arab bersama | `e3ccf78`, `e7dc70c` |
| AI grid dan hero eksklusif | `8843273`, `a858f2d` |
| Profil dan ID–EN–AR | `4a494cc`, `f150828`, `c0e1251` |
| Harga coret aktual | `7967032` |
| Prefix AI pada nama ilmu | `73ef96e`, `dd88ef0` |
| Animasi empat folio | `16faee9` |
| Katalog berkelompok | `d3f72d9`, `307332d`, `e0ad998`, `0833815` |
| Kesiapan dan pesan WebView | `ba1bfc4`, `4a23d7c`, `a7b6f59`, `192f938`, `01f5ae9` |
| Regresi adapter | `512c7d8` |
| Render dan rekaman gerak | `508d654`, `213fd2e`, `03e9759`, `7cd101f` |

Pemulihan selektif menggunakan revert dalam urutan terbalik. Kartu konsumennya bergantung pada `OTInkCard`; jangan menghapus komponen bersama sebelum memulihkan layar pemakainya. Hindari reset menyeluruh karena workspace mengandung perubahan lain di luar pekerjaan ini.

## Ledger sampai 7cd101f

```text
e3ccf78 feat(cards): introduce charcoal cards with quiet Arabic watermarks
4bd8e16 feat(home): remove flagship duplicate and introduce dark science cards
a858f2d feat(flagship): label Tahawwulat as an exclusive OpenTurath collection
8843273 feat(ai): render science AI cards on charcoal Arabic watermark surfaces
7967032 fix(pricing): display recorded regular prices above discounted offers
4a494cc feat(profile): simplify identity and group expiry with access; add ID EN AR selector
73ef96e feat(copy): prefix science AI display names without changing source identifiers
dd88ef0 feat(copy): replace Indonesian assistant wording with AI
8c9f372 fix(profile): balance inline language selector layout
e7dc70c fix(cards): scale decorative Arabic within the existing typography tokens
4076aa4 refactor(home): remove unused flagship statistics import
69bd38a refactor(cards): use constant inverse text style
e897778 fix(ai): preserve AI prefix on study room tabs
9f86f83 feat(stats): group real library totals in rounded charcoal metric capsules
16faee9 feat(motion): animate four rounded folios with seamless variable velocity
d3f72d9 feat(catalog): add restrained book identity and grouped edition fact pills
ba1bfc4 fix(webview): detect a usable composer rather than the first hidden input or unrelated spinner
4a23d7c fix(webview): show actual failure state and ignore stale main-document errors
1e33f26 fix(copy): distinguish page readiness from network failure
f150828 feat(settings): share appearance pill treatment with ID EN AR language choices
0ab3b1e feat(copy): align visible science terminology with AI naming
7c88468 feat(copy): align visible science terminology with AI naming
28603a0 feat(copy): align visible science terminology with AI naming
905c245 feat(copy): align visible science terminology with AI naming
a7f7613 feat(copy): align visible science terminology with AI naming
a6e3eb8 feat(copy): align visible science terminology with AI naming
340b20a feat(copy): align visible science terminology with AI naming
4da2b94 feat(copy): align visible science terminology with AI naming
133df5f feat(copy): align visible science terminology with AI naming
687c7a9 feat(copy): align visible science terminology with AI naming
c0e1251 fix(settings): remove empty icon spacing from language pills
512c7d8 test(webview): cover hidden inputs and unrelated loading panels in readiness detection
34077e3 style(ui): format updated native components
382ac0c style(ui): format updated native components
b2822a9 style(ui): format updated native components
45c75bc style(ui): format updated native components
325467a style(ui): format updated native components
a040b5e style(ui): format updated native components
ce85376 style(ui): format updated native components
b13460a style(ui): format updated native components
2f01ff6 style(ui): format updated native components
963646e style(ui): format updated native components
df16ce7 style(ui): format updated native components
9a204f2 style(ui): format updated native components
e31e8eb style(ui): format updated native components
6d69473 style(ui): format updated native components
d6ff248 style(ui): format updated native components
a7b6f59 fix(webview): retain genuine initial-load errors while rejecting superseded session errors
1eb3eb1 test(visual): follow renamed active AI action in profile rendering
c791495 docs(design): record requested AI card profile pricing and loading corrections
ed97c0a docs(tokens): synchronize AI refinement component contract
daef455 test(copy): adopt requested AI terminology in existing behavioral expectations
e66b4f2 test(copy): adopt requested AI terminology in existing behavioral expectations
2375580 test(copy): adopt requested AI terminology in existing behavioral expectations
8dcfa9f test(copy): adopt requested AI terminology in existing behavioral expectations
7d97f9b test(copy): require AI title prefix while preserving entitlement IDs
192f938 fix(webview): surface main-document HTTP failures instead of indefinite readiness checks
8f41aaf fix(copy): add factual localized HTTP failure guidance
307332d feat(catalog): compose title and author together with indexed folio headers
f9f228b style(ui): format refinement code and regression expectations
0251fa1 style(ui): format refinement code and regression expectations
d75c832 style(ui): format refinement code and regression expectations
d3652eb style(ui): format refinement code and regression expectations
e0ad998 fix(catalog): constrain long Arabic titles within grouped card content
704948f fix(copy): remove duplicate AI wording introduced by terminology replacement
05c6831 fix(copy): remove duplicate AI wording introduced by terminology replacement
3319f75 fix(copy): align companion recovery wording with AI terminology
d20cee2 fix(copy): align connection fallback wording with AI terminology
213fd2e docs(motion): record native four-folio loader in light theme
03e9759 docs(motion): record native four-folio loader in dark theme
98aeda2 docs(review): add current AI refinement gallery and native loading videos
133eb41 chore(review): exclude intermediate motion frames while preserving final videos
508d654 docs(visual): checkpoint verified Flutter screens across locales themes and sizes
0833815 fix(catalog): start displayed folio numbering at one
01f5ae9 fix(copy): avoid claiming a page opened before readiness is known
0d16c40 fix(branding): gantikan favicon placeholder 'O' dengan logo vektor resmi OpenTurath responsif tema
7cd101f docs(visual): refresh catalogue previews with corrected folio numbering
```

Penghapusan lama di direktori lain serta perubahan cache Firebase yang muncul selama pengerjaan tidak dimasukkan ke checkpoint ini. Paket binary lokal dicatat dengan checksum di VERIFICATION.md; tidak ada perintah publikasi atau broadcast yang dijalankan oleh pekerjaan ini.
