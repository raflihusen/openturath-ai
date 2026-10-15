> Arsip revisi sebelumnya. Status terbaru ada pada AUDIT_WEBSITE_V4.md dan BROWSER_QA.json.

# OpenTurath Website Implementation Plan

Goal: deliver the complete multilingual public website as a portable ZIP with source, static build, optional report server, and evidence of verification.
Architecture: dependency-free Node static generator; localized HTML routes; progressively enhanced JavaScript; Python standard-library report server with SQLite.
Spec: MASTER_SPEC.md. User explicitly requested implementation and ZIP delivery; proceed without another design approval cycle.

## Global constraints
- Exact tagline: AI For Islamic Scholarship.
- ID, EN, AR; Arabic RTL; Inter, Cormorant, Amiri local fonts.
- Preserve original evaluation output; do not fabricate verification or product-release facts.
- No external publication in this ZIP delivery task.

## Tasks
- [x] 1. Content foundation: src/core.mjs, content/catalog.json, content/evaluation.json, configuration. Validate source preservation, search normalization and URL escaping.
- [x] 2. Presentation: src/copy.mjs, src/render.mjs, src/pages.mjs, public/assets/site.css. Build all required localized templates, links, metadata and states.
- [x] 3. Interaction: public/assets/site.js, server/app.py. Implement search/filter URLs, navigation, preferences, reading panels, comparison, forms, download configuration.
- [x] 4. Verification: tests, route/link checks, browser desktop/mobile/RTL, security and deployment gates. Fix material findings.
- [x] 5. Delivery: docs, deployment recipes, configuration assistant, release audit, ZIP with built dist and source.

## Review focus
1. Mixed Arabic/Latin input and URLs must preserve text and direction.
2. Empty release/operator config must never invent real links or successful actions.
3. Comparison originals must not become executable HTML or silently edited text.
4. Form failures and duplicates must preserve user text and accurately report persistence.
5. Direct navigation and locale changes must retain the same document and query.

## Decisions
- Static export and standard-library server chosen for a portable download without dependency installation. Forms need the included server; static deployments offer a downloadable report and configured email fallback.
- Missing production facts are explicit release-gate failures. The delivered site remains fully reviewable locally.
- Local WOFF fonts used because WOFF2 encoding dependency is unavailable; existing font licenses retained.

## Completion evidence
See QA.md for automated and browser results, COVERAGE.md for the 21-part mapping, and BUILD_REPORT.json for owner-input blockers. Final code review findings were fixed and re-reviewed. External publication is outside the requested ZIP handover; no deployment is claimed.
