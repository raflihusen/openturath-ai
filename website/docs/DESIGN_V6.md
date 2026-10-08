# OpenTurath V6 — current design specification, 8 October 2026

Keep the accepted white scholarly canvas, monochrome branding, Newsreader editorial titles, Arabic Naskh text and original book composition. Light starts at #FFFFFF, ink #111111; saved dark mode remains respected. Refinements are layered in assets/refinements.css.

## Structure

1. Centered two-line hero, 88px desktop title, concise description and visible mobile actions. Arabic actions stack at narrow widths. The original book artwork and pointer/scroll motion remain.
2. Fikih Tahawwulat follows the hero: app-sourced monochrome four-part sculpture, 58 books and 1,099 lectures explicitly labelled collection metadata, and five linked assistants. Exclusive refers to OpenTurath’s assistant organization, not ownership of the scholarly works.
3. The dedicated Tahawwulat page presents the four introductory fields, five assistants, and six actual app introduction titles. Editorial explanations are labelled; no text is presented as a verified scholarly quotation.
4. Corpus metrics retain large typographic hierarchy, with links to definitions and six unresolved app-metadata disagreements. Home shows six representative general fields; the library retains all 21 profiles.
5. Method, comparison archive and source dialog distinguish stored outputs from reviewed accuracy. Q001 has one question, six responses, seven review dimensions and ten pending records. Missing original-source evidence is visible.
6. Access has separate app-sourced general-assistant and Tahawwulat prices for 1/6/12 months. Activation leads to contact while public checkout and binary distribution remain unverified. No download QR loop.
7. Adab, native FAQ, legal pages and footer retain the editorial layout. Privacy distinguishes local research notes from synced bookmarks and names the relevant providers.

## Motion and accessibility

HTML is readable before JavaScript. Entrances have no global expiry timer. Pointer and scroll effects use transform/opacity, preserve native scrolling, and stop for system or saved reduced-motion preferences. Interactive framework choices expose aria-pressed and a live output. Dialogs restore focus; navigation, filters and FAQ support keyboards. Local fonts remain bundled.

## Evidence and scope

BROWSER_QA.json records the local responsive/RTL/browser matrix and optional axe checks. MOTION_QA.json records real browser motion checks. Screenshots in previews/refined and previews/refined-motion are observed renders, not visual approval by the user. App source parity does not establish production payment, corpus indexing or answer correctness.

## Deployment verification

Build locally, then run check:deployment after an explicitly authorized release. The read-only checker compares actual response headers to firebase.json and records Cloudflare beacon presence; configuration alone does not prove deployment. If Cloudflare injects a beacon, review its setting against the self-hosted script policy. Deployment, provider settings and public release artifacts are outside the local build.
