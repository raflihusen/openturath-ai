# OpenTurath V6 — design specification

A true-white scholarly canvas, black and white branding, monumental sans-serif numbers, Newsreader editorial titles, Naskh Arabic accents. Light is the initial theme; saved dark preferences remain respected. Light #FFFFFF, surface #F5F5F7, ink #111111; dark #08090A, surface #151517, ink #F5F5F7. No beige or gold logo.

Six generated section references: hero, corpus metrics, catalogue, method, membership/adab, FAQ/footer. References deliberately do not replace the site's actual navigation, legal links, data or translations. Generator-invented login/social/registration features, unverified book labels and source facsimiles are excluded. The existing approved book-stack composition is preserved using a separately generated transparent asset. Numbers are live metadata, not generated pixels.

## Structure
1. Centered typographic hero: 100–116px title, 30–36px subtitle, 17px two-line description, black and outline CTAs. Independent book/calligraphy layers react to scroll and fine pointer movement.
2. Corpus bento immediately below hero: dominant black 5,370-book tile; four large secondary metrics, then a 2,876-partition line. 144–166px primary / 64–90px secondary desktop figures. Exact counts and provenance stay available.
3. Verification: sticky reading stage with four progressively illuminated manuscript states; four actual scrolling narrative steps. No synthetic facsimile or claim of error-free AI.
4. Catalogue: first two cards span half width, subsequent thirds, Tahawwulat broad. Kitab count 80–112px; secondary metrics 24–32px, labels 14px. Every active profile has its own metadata and every profile remains searchable.
5. Q001 source archive: original text and existing source dialog.
6. Membership: one dark banner, dominant Rp49,000, existing DOKU activation flow.
7. Adab: large Arabic accent, three practical principles on home, seven full principles and editorial provenance on guidelines page.
8. FAQ and footer: two-column FAQ, native details, larger 15–18px support text, monochrome brand.

## Motion system
Default HTML is visible. IntersectionObserver triggers entrances as content arrives, with no global expiry timer. Each major section and each card has an entrance; statistics use clipped number rises, manuscript stages respond to scroll progress, archive and adab have independent depth. CSS/WAAPI animate transform and opacity. Native scroll remains under user control. Reduced-motion removes scroll-linked motion; a persistent manual motion preference is available. No continuous idle animations.

## Research
Apple homepage inspected in browser on 20 September 2026: large product imagery, short headings, paired CTAs, full-width bands and paired product tiles. Observed desktop headline samples: 56px / 60px, weight 600; smaller tile headlines 40px / 44px, weight 600. This informs hierarchy and restraint, while OpenTurath keeps its own serif and Arabic identity. Source: https://www.apple.com/ .
