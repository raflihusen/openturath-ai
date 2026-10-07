# Checkpoint penyempurnaan kompak

Branch: `codex/visual-audit-fixes-2026-10-07`. Baseline: `33fbdd1`. Pemulihan selektif memakai `git revert <commit>`, setelah memeriksa perubahan berikutnya. Perubahan lain di workspace tidak ikut dimasukkan.

```text
39f63a9 revert(loader): restore the previously preferred rounded folio animation
0ab9d1a refactor(cards): overlay faint Arabic without reserving footer space
6236a75 refactor(dashboard): compact science cards after removing decorative footer
0b02047 fix(theme): distinguish rounded dark surfaces from the canvas
ea0d22a style(cards): use shared dark surface token
0db6293 feat(tahawwulat): add a dedicated five-AI chooser with purpose descriptions
dd41728 fix(tahawwulat): open the five-AI chooser from the flagship action
d3c7c1e fix(copy): identify the Tahawwulat action as entering its AI collection
2d7f94c refactor(profile): use icon-only theme controls and compact identity-access panel
1f0b729 fix(profile): complete theme control widget nesting
c43f0fd refactor(dashboard): place resume study inside the rounded greeting panel
eed8dda refactor(pricing): simplify duration selection and clarify product-payment hierarchy
de68288 refactor(catalog): use a restrained book-spine composition with grouped facts
b019690 feat(payment): show a polished receipt only after verified checkout confirmation
6df403e feat(checkout): connect confirmed payments to the receipt dialog
38cfc3d style(profile): keep the icon-only theme selector in one row
336ce15 style(tahawwulat): remove unused chooser import
82d1311 refactor(copy): describe each Tahawwulat AI through its study purpose
3ef99fb test(tahawwulat): verify chooser opens before an AI can be selected
e8b5f61 test(hero): follow the explicit AI collection entry label
3aa8571 test(visual): render the dedicated AI chooser and confirmed-payment receipt
d951155 test(visual): open compact icon actions through accessible tooltips
80abaaf fix(profile): retain ID EN AR labels in language selector
e9f0442 fix(payment): use restored folio loader while processing checkout
73ab6c0 docs(design): synchronize compact composition and dark surfaces
2eba086 style(ui): format compact refinement components
d0cf449 fix(payment): keep receipt confirmation separate from access activation
6abd477 test(payment): verify invoice receipt and dismiss without access claims
112b547 fix(test): initialize receipt language through app configuration
e4f76ef test(dashboard): render resume session inside greeting card
c81eada fix(payment): preserve exclusive charcoal identity in both themes
9094731 fix(copy): avoid duplicated AI naming in subscription benefits
```
