/// Kulit OpenTurath untuk halaman obrolan NotebookLM di WebView.
///
/// Murni aditif: satu blok `<style id="ot-skin">` yang menimpa token warna
/// (`--nlm-*`, `--mat-sys-*`) dengan token aplikasi (`OTColors`), memakai
/// huruf aplikasi (lihat `notebook_fonts.dart`), dan menandai bagian jawaban
/// lewat kelas CSS saja (isi teks tidak pernah diubah). Aturan penyembunyian
/// inti, polling kesiapan, dan siklus hidup WebView di
/// `notebook_ui_script.dart` dan `agent_multi_tab_room.dart` tidak disentuh.
///
/// Ciri khas: ibarah Arab tampil sebagai lembar naskah berbingkai ganda
/// (jadwal), kepala bagian jawaban menjadi label huruf kapital kecil, dan
/// tahap berpikir memakai lengkung bersarang yang sama dengan logo, splash,
/// dan situs.
///
/// Selektor diambil dari DOM langsung NotebookLM (Angular, Okt 2026); lihat
/// `docs/DOKUMEN_STRUKTUR_DOM_LENGKAP_NOTEBOOKLM.md`. Dilarang menggabungkan
/// `:has(...)` ke dalam daftar selektor berkoma (STANDAR_IDEAL_WEBVIEW.md).
const notebookSkinScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;
  if (window.__otSkinInstalled) {
    if (typeof window.otSkinApply === 'function') { try { window.otSkinApply(); } catch (_) {} }
    return;
  }
  window.__otSkinInstalled = true;

  const LABELS = {
    id: {
      thought: 'Proses berpikir', ibarah: 'Ibarah', copy: 'Salin jawaban', copied: 'Tersalin', copyFailed: 'Gagal menyalin',
      disclaimer: 'OpenTurath AI bisa salah, maka verifikasi ulang jawabannya.',
      stages: ['Mencari ibarah di kitab…', 'Membaca rujukan…', 'Menimbang pendapat dalam mazhab…', 'Menyusun jawaban…']
    },
    en: {
      thought: 'Reasoning', ibarah: 'Passage', copy: 'Copy answer', copied: 'Copied', copyFailed: 'Could not copy',
      disclaimer: 'OpenTurath AI can be wrong, so please verify its answers.',
      stages: ['Looking for the passage in the books…', 'Reading the references…', 'Weighing the views within the school…', 'Writing the answer…']
    },
    ar: {
      thought: 'مسار التفكير', ibarah: 'عبارة', copy: 'نسخ الجواب', copied: 'تم النسخ', copyFailed: 'تعذّر النسخ',
      disclaimer: 'قد يخطئ OpenTurath AI، فتحقّق من الإجابات.',
      stages: ['جارٍ البحث عن العبارة في الكتب…', 'قراءة المراجع…', 'الموازنة بين الأقوال في المذهب…', 'صياغة الجواب…']
    }
  };
  function lang() {
    let saved = null;
    try { saved = sessionStorage.getItem('ot_lang'); } catch (_) {}
    if (LABELS[saved]) return saved;
    return LABELS[window._otLang] ? window._otLang : 'id';
  }

  /* Lengkung bersarang (logo, splash, situs): empat bingkai berdampingan.
     Bingkai 0-2 menyalakan satu lengkung bergantian, bingkai 3 menyalakan semuanya. */
  function archSprite() {
    const arches = [
      'M3 22V11.5C3 7.5 7.5 3 12 2c4.5 1 9 5.5 9 9.5V22',
      'M6.5 22V13c0-2.7 2.9-5.6 5.5-6.4 2.6.8 5.5 3.7 5.5 6.4v9',
      'M10 22v-6c0-1.4 1-3 2-3.5 1 .5 2 2.1 2 3.5v6'
    ];
    let body = '';
    for (let frame = 0; frame < 4; frame++) {
      body += '<g transform="translate(' + frame * 24 + ' 0)">';
      arches.forEach((d, i) => {
        const o = frame === 3 ? 0.9 : (i === frame ? 1 : 0.22);
        body += '<path d="' + d + '" stroke-opacity="' + o + '"/>';
      });
      body += '</g>';
    }
    const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 96 24" fill="none" stroke="#000" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round">' + body + '</svg>';
    return 'url("data:image/svg+xml,' + encodeURIComponent(svg) + '")';
  }

  /* Panah kirim berbentuk lengkung mihrab: batang lurus dengan ujung melengkung seperti arch logo. */
  function sendIcon() {
    const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M12 19.5V8"/><path d="M6.5 12.5C8.8 11 10.8 8.6 12 5.5c1.2 3.1 3.2 5.5 5.5 7"/></svg>';
    return 'url("data:image/svg+xml,' + encodeURIComponent(svg) + '")';
  }

  function copyIcon() {
    const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="1.8" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="11" height="11" rx="2.5"/><path d="M5 15V6.5A2.5 2.5 0 0 1 7.5 4H15"/></svg>';
    return 'url("data:image/svg+xml,' + encodeURIComponent(svg) + '")';
  }

  function checkIcon() {
    const svg = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="none" stroke="#000" stroke-width="2.1" stroke-linecap="round" stroke-linejoin="round"><path d="M5 13l4.5 4.5L19 7.5"/></svg>';
    return 'url("data:image/svg+xml,' + encodeURIComponent(svg) + '")';
  }

  const CSS = `
    /* ── Token: satu sumber dengan OTColors ── */
    html body, html body.luminous-ui {
      --ot-sans: "OT Outfit", "OT Scheherazade", "Outfit", "Inter", "SF Pro Text", -apple-system, system-ui, "Segoe UI", sans-serif;
      --ot-arabic: "OT Scheherazade", "Scheherazade New", "Geeza Pro", "Noto Naskh Arabic", "Amiri", serif;
      --ot-canvas: light-dark(#F6F6F6, #151515);
      --ot-surface: light-dark(#FFFFFF, #292929);
      --ot-subtle: light-dark(#EDEDED, #353535);
      --ot-ink: light-dark(#171717, #F5F5F5);
      --ot-muted: light-dark(#606060, #B8B8B8);
      --ot-faint: light-dark(#6B6B6B, #9A9A9A);
      --ot-line: light-dark(#DADADA, #454545);
      --ot-line-soft: light-dark(#EBEBEB, #2D2D2D);
      --ot-line-strong: light-dark(#767676, #808080);
      --ot-on-ink: light-dark(#FFFFFF, #171717);
      --ot-shadow: light-dark(rgba(0,0,0,.05), rgba(0,0,0,.2));
      --nlm-font-family-sans: var(--ot-sans) !important;
      --chat-panel-bg: var(--ot-canvas) !important;
      --nlm-fills-surface-page: var(--ot-canvas) !important;
      --nlm-fills-surface-panel: var(--ot-surface) !important;
      --nlm-fills-surface-container: var(--ot-subtle) !important;
      --nlm-fills-ui-grey-fill: var(--ot-subtle) !important;
      --nlm-fills-ui-blue-fill: var(--ot-subtle) !important;
      --nlm-text-body-text: var(--ot-ink) !important;
      --nlm-text-titles-and-labels: var(--ot-ink) !important;
      --nlm-text-secondary-text: var(--ot-muted) !important;
      --nlm-text-ghost-text: var(--ot-faint) !important;
      --nlm-stroke-default: var(--ot-line) !important;
      --nlm-stroke-focus: var(--ot-line-strong) !important;
      --nlm-ctas-buttons-primary: var(--ot-ink) !important;
      --nlm-cta-text-and-icon-primary: var(--ot-on-ink) !important;
      --nlm-states-on-primary-hover: light-dark(rgba(23,23,23,.06), rgba(245,245,245,.08)) !important;
      --nlm-brand-blue: var(--ot-ink) !important;
      --nlm-icons-blue: var(--ot-ink) !important;
      --nlm-icons-default: var(--ot-ink) !important;
      --mat-sys-primary: var(--ot-ink) !important;
      --mat-sys-on-primary: var(--ot-on-ink) !important;
      --mat-sys-surface: var(--ot-canvas) !important;
      --mat-sys-on-surface: var(--ot-ink) !important;
      --mat-sys-on-surface-variant: var(--ot-muted) !important;
      --mat-sys-surface-container-low: var(--ot-surface) !important;
      --mat-sys-surface-container: var(--ot-subtle) !important;
      --mat-sys-surface-container-high: var(--ot-subtle) !important;
      --mat-sys-surface-container-highest: var(--ot-subtle) !important;
      --mat-sys-outline: var(--ot-line-strong) !important;
      --mat-sys-outline-variant: var(--ot-line) !important;
      --mat-sys-secondary-container: var(--ot-subtle) !important;
      --mat-sys-on-secondary-container: var(--ot-ink) !important;
      font-family: var(--ot-sans) !important;
      background-color: var(--ot-canvas) !important;
    }
    html { background-color: var(--ot-canvas) !important; }
    html body textarea, html body button, html body input { font-family: var(--ot-sans) !important; }
    ::selection { background: light-dark(rgba(23,23,23,.14), rgba(245,245,245,.22)); }
    html body ::-webkit-scrollbar { width: 8px; height: 8px; }
    html body ::-webkit-scrollbar-thumb { background: var(--ot-line); border-radius: 8px; }
    html body ::-webkit-scrollbar-track { background: transparent; }

    /* ── Kolom baca: sejajar dengan kolom tanya ── */
    html body chat-message.individual-message {
      display: block !important;
      width: 100% !important;
      max-width: 720px !important;
      margin-inline: auto !important;
      padding-inline: 16px !important;
      box-sizing: border-box !important;
    }

    /* ── Pertanyaan: permukaan tonal, sudut ujung bawah dirapatkan (seperti chat native) ── */
    html body .from-user-container { padding-inline-start: 0 !important; }
    html body .from-user-message-card-content {
      background: var(--ot-subtle) !important;
      box-shadow: none !important;
      border: .8px solid var(--ot-line) !important;
      border-radius: 24px !important;
      border-end-end-radius: 8px !important;
      max-width: min(82%, 580px) !important;
    }
    html body .from-user-message-card-content::after { display: none !important; }
    html body .from-user-message-inner-content { padding: 12px 16px !important; }
    html body .from-user-message-card-content .md3-body-text,
    html body .from-user-message-card-content p {
      font-family: var(--ot-sans) !important;
      color: var(--ot-ink) !important;
    }

    /* ── Jawaban: aliran terbuka tanpa kartu ── */
    html body .to-user-message-card-content {
      background: transparent !important;
      box-shadow: none !important;
      border: none !important;
      border-radius: 0 !important;
    }
    html body .to-user-message-card-content::after { display: none !important; }
    html body .to-user-message-card-content .message-text-content,
    html body .to-user-message-card-content .paragraph,
    html body .to-user-message-card-content .paragraph span,
    html body .to-user-message-card-content li {
      font-family: var(--ot-sans) !important;
      color: var(--ot-ink) !important;
    }
    html body .to-user-message-card-content .paragraph,
    html body .to-user-message-card-content li {
      font-size: var(--ot-font-size, 15px) !important;
      line-height: 1.7 !important;
    }
    html body .to-user-message-card-content b,
    html body .to-user-message-card-content strong { font-weight: 600 !important; }
    html body .to-user-message-card-content :is(h1, h2, h3, h4) {
      font-family: var(--ot-sans) !important;
      font-weight: 600 !important;
      letter-spacing: -.01em !important;
      color: var(--ot-ink) !important;
    }
    html body .to-user-message-card-content a {
      color: inherit !important;
      text-decoration: underline !important;
      text-decoration-color: var(--ot-line-strong) !important;
      text-underline-offset: 3px !important;
    }
    html body .to-user-message-card-content ul { list-style-type: disc !important; }
    html body .to-user-message-card-content ul ul { list-style-type: "–  " !important; }
    html body .to-user-message-card-content li::marker { color: var(--ot-faint) !important; }

    /* Kepala bagian ("A. JAWABAN LANGSUNG:") menjadi label kapital kecil dengan garis tipis. */
    html body .to-user-message-card-content .paragraph.ot-section {
      margin-top: 28px !important;
      padding-top: 16px !important;
      border-top: 1px solid var(--ot-line-soft) !important;
    }
    html body .to-user-message-card-content .paragraph.ot-section > b:first-child {
      display: block !important;
      margin-bottom: 8px !important;
      font-size: 11px !important;
      font-weight: 600 !important;
      letter-spacing: .14em !important;
      text-transform: uppercase !important;
      color: var(--ot-muted) !important;
    }
    html body .to-user-message-card-content .paragraph.ot-section > b:first-child + span,
    html body .to-user-message-card-content .paragraph.ot-section > .ot-gap { display: none !important; }

    /* Mode jawaban ("▸Mode: Syarah Masalah") menjadi pil kecil. */
    html body .to-user-message-card-content .paragraph.ot-mode {
      display: inline-flex !important;
      width: fit-content !important;
      margin-bottom: 8px !important;
      padding: 4px 12px !important;
      border-radius: 999px !important;
      background: var(--ot-subtle) !important;
      font-size: 0 !important;
      line-height: 1 !important;
    }
    html body .to-user-message-card-content .paragraph.ot-mode * { display: none !important; }
    html body .to-user-message-card-content .paragraph.ot-mode::before {
      content: attr(data-ot-mode);
      font-family: var(--ot-sans);
      font-size: 12px;
      font-weight: 600;
      color: var(--ot-muted);
    }

    /* ── Arah teks cerdas (Bidi): kartu mengikuti bahasa utama, blok Arab di tengah LTR tetap RTL ── */
    html body .to-user-message-card-content.ot-dir-ltr,
    html body .from-user-message-card-content.ot-dir-ltr,
    html body .to-user-message-card-content .ot-ltr-block {
      direction: ltr !important;
      text-align: left !important;
      unicode-bidi: isolate !important;
    }
    html body .to-user-message-card-content.ot-dir-rtl,
    html body .from-user-message-card-content.ot-dir-rtl {
      direction: rtl !important;
      text-align: right !important;
      unicode-bidi: isolate !important;
      font-family: var(--ot-arabic) !important;
      line-height: 1.92 !important;
    }
    html body .to-user-message-card-content .ot-rtl-block {
      direction: rtl !important;
      text-align: right !important;
      unicode-bidi: isolate !important;
      font-family: var(--ot-arabic) !important;
      font-size: var(--ot-font-size, 15px) !important;
      line-height: 1.92 !important;
      letter-spacing: 0 !important;
      font-synthesis: none !important;
    }
    html body .to-user-message-card-content .ot-rtl-block * {
      font-family: var(--ot-arabic) !important;
      font-size: inherit !important;
      line-height: inherit !important;
      font-synthesis: none !important;
    }

    /* Penataan list stabil tanpa bullet/nomor menggantung atau lompat saat streaming */
    html body .to-user-message-card-content ul,
    html body .to-user-message-card-content ol {
      padding-inline-start: 22px !important;
      margin-block: 10px !important;
    }
    html body .to-user-message-card-content li {
      margin-block: 8px !important;
    }
    html body .to-user-message-card-content li > .paragraph:first-child,
    html body .to-user-message-card-content li > p:first-child {
      margin-top: 0 !important;
    }

    /* Kutipan ibarah Arab di tengah jawaban non-Arab: aksen garis editorial minimalis tanpa badge melayang */
    html body .to-user-message-card-content .ot-ibarah {
      position: relative !important;
      margin-block: 10px 6px !important;
      padding: 12px 16px !important;
      background: var(--ot-subtle) !important;
      border-radius: 10px !important;
      border-inline-start: 2.5px solid var(--ot-line-strong) !important;
      list-style: none !important;
      direction: rtl !important;
      text-align: right !important;
      unicode-bidi: isolate !important;
      font-family: var(--ot-arabic) !important;
      font-size: var(--ot-font-size, 15px) !important;
      line-height: 1.92 !important;
      letter-spacing: 0 !important;
      font-synthesis: none !important;
    }
    html body .to-user-message-card-content .ot-ibarah * {
      font-family: var(--ot-arabic) !important;
      font-size: inherit !important;
      line-height: inherit !important;
      font-synthesis: none !important;
    }
    html body .to-user-message-card-content .ot-ibarah::before,
    html body .to-user-message-card-content .ot-ibarah::after {
      content: none !important;
      display: none !important;
    }
    html body .to-user-message-card-content .ot-ibarah-trans {
      display: block !important;
      margin-top: 6px !important;
      margin-bottom: 12px !important;
      padding-inline: 2px !important;
      direction: ltr !important;
      text-align: left !important;
      unicode-bidi: isolate !important;
      font-family: var(--ot-sans) !important;
      font-size: var(--ot-font-size, 15px) !important;
      line-height: 1.7 !important;
      color: var(--ot-ink) !important;
    }
    html body .to-user-message-card-content .ot-ibarah-host {
      direction: ltr !important;
      text-align: left !important;
    }
    html body .to-user-message-card-content li.ot-ibarah-item {
      list-style: none !important;
    }
    html body .to-user-message-card-content.ot-dir-ltr li.ot-ibarah-item {
      margin-left: -18px !important;
      margin-right: 0 !important;
    }
    html body .to-user-message-card-content.ot-dir-rtl li.ot-ibarah-item {
      margin-right: -18px !important;
      margin-left: 0 !important;
    }
    html body .to-user-message-card-content li.ot-ibarah-item::marker { content: "" !important; }

    /* Pastikan list di kartu LTR selalu rata kiri dengan bullet di kiri */
    html body .to-user-message-card-content.ot-dir-ltr ul,
    html body .to-user-message-card-content.ot-dir-ltr ol {
      direction: ltr !important;
      text-align: left !important;
    }
    html body .to-user-message-card-content.ot-dir-rtl ul,
    html body .to-user-message-card-content.ot-dir-rtl ol {
      direction: rtl !important;
      text-align: right !important;
    }
    /* Tabel: responsif penuh, arah selalu ikut kartu, tidak pernah terpotong meski huruf diperbesar. */
    html body .to-user-message-card-content table-element-view {
      display: block !important;
      width: 100% !important;
      max-width: 100% !important;
      overflow-x: auto !important;
      -webkit-overflow-scrolling: touch !important;
      margin: 18px 0 22px !important;
      border: 1px solid var(--ot-line) !important;
      border-radius: 16px !important;
      box-sizing: border-box !important;
      direction: inherit !important;
    }
    html body .to-user-message-card-content table {
      border-collapse: collapse !important;
      width: 100% !important;
      min-width: 0 !important;
      table-layout: auto !important;
      direction: inherit !important;
    }
    html body .to-user-message-card-content th {
      text-align: start !important;
      padding: 10px 10px !important;
      background: light-dark(rgba(23,23,23,.06), rgba(245,245,245,.07)) !important;
      border: none !important;
      border-bottom: 1px solid var(--ot-line) !important;
      vertical-align: middle !important;
      white-space: normal !important;
      min-width: 72px !important;
      overflow-wrap: break-word !important;
      word-break: break-word !important;
      max-width: 240px !important;
    }
    html body .to-user-message-card-content td {
      padding: 10px 10px !important;
      vertical-align: top !important;
      border: none !important;
      border-bottom: 1px solid var(--ot-line-soft) !important;
      white-space: normal !important;
      min-width: 72px !important;
      overflow-wrap: break-word !important;
      word-break: break-word !important;
      max-width: 260px !important;
    }
    html body .to-user-message-card-content tr:last-child td { border-bottom: 0 !important; }
    html body .to-user-message-card-content th + th,
    html body .to-user-message-card-content td + td { border-inline-start: 1px solid var(--ot-line-soft) !important; }
    html body .to-user-message-card-content table td,
    html body .to-user-message-card-content table td *,
    html body .to-user-message-card-content .paragraph.table-paragraph,
    html body .to-user-message-card-content .paragraph.table-paragraph * {
      margin: 0 !important;
      font-size: clamp(12px, calc(var(--ot-font-size, 15px) * 0.86), 16.5px) !important;
      line-height: 1.55 !important;
      text-transform: none !important;
      letter-spacing: 0 !important;
    }
    html body .to-user-message-card-content table th,
    html body .to-user-message-card-content table th *,
    html body .to-user-message-card-content th .paragraph.table-paragraph,
    html body .to-user-message-card-content th .paragraph.table-paragraph * {
      font-size: clamp(11px, calc(var(--ot-font-size, 15px) * 0.76), 13.5px) !important;
      font-weight: 600 !important;
      letter-spacing: .04em !important;
      color: var(--ot-muted) !important;
      line-height: 1.4 !important;
    }

    /* Rujukan di dalam jawaban. */
    html body [class*="citation-marker" i],
    html body [class*="citation-button" i] {
      background: var(--ot-subtle) !important;
      color: var(--ot-muted) !important;
      border: .8px solid var(--ot-line) !important;
      border-radius: 999px !important;
      font-family: var(--ot-sans) !important;
    }

    /* ── Tahap berpikir: lengkung bersarang menyala bergantian ── */
    html body .thinking-chain__static-icon,
    html body .thinking-chain__lottie-icon { display: none !important; }
    html body .thinking-chain { margin-block-end: 10px !important; }
    html body .thinking-chain__header {
      gap: 8px !important;
      padding: 2px 0 !important;
      border-radius: 8px !important;
    }
    html body .thinking-chain__header:hover { background: transparent !important; }
    html body .thinking-chain__header::before {
      content: "";
      flex: none;
      width: 20px;
      height: 20px;
      background: var(--ot-muted);
      -webkit-mask: var(--ot-arch-sprite) 100% 0 / 400% 100% no-repeat;
      mask: var(--ot-arch-sprite) 100% 0 / 400% 100% no-repeat;
    }
    html body .thinking-chain.ot-thinking .thinking-chain__header::before {
      background: var(--ot-ink);
      animation: ot-arch-echo 1.5s steps(1, end) infinite;
    }
    @keyframes ot-arch-echo {
      0% { -webkit-mask-position: 0 0; mask-position: 0 0; }
      33.33% { -webkit-mask-position: 33.333% 0; mask-position: 33.333% 0; }
      66.66% { -webkit-mask-position: 66.667% 0; mask-position: 66.667% 0; }
      100% { -webkit-mask-position: 0 0; mask-position: 0 0; }
    }
    html body .thinking-chain__title {
      font-size: 0 !important;
      margin-inline-start: 0 !important;
      background: none !important;
      -webkit-text-fill-color: currentColor !important;
      animation: none !important;
    }
    html body .thinking-chain__title::after {
      content: var(--ot-label-thought, "Proses berpikir");
      font-family: var(--ot-sans);
      font-size: 13px;
      font-weight: 400;
      letter-spacing: .01em;
      color: var(--ot-muted);
    }
    html body .thinking-chain__title.is-loading::after {
      content: var(--ot-label-thinking, "Berpikir…");
      font-style: italic;
      color: var(--ot-ink);
    }
    html body .thinking-chain__expand-btn { opacity: .5 !important; transform: scale(.8); }

    /* ── Elemen khas Google yang tidak perlu ── */
    html body .date-separator,
    html body .selected-num-container,
    html body .chat-panel-top-fade,
    html body .chat-panel-bottom-fade { display: none !important; }

    /* ── Kolom tanya: kapsul permukaan seperti chat native ── */
    html body .input-group {
      background: var(--ot-surface) !important;
      border: 1.2px solid var(--ot-line) !important;
      border-radius: 24px !important;
      box-shadow: 0 4px 18px var(--ot-shadow) !important;
      padding-block: 6px !important;
      padding-inline: 14px !important;
    }
    html body .input-group:focus-within {
      border-color: light-dark(rgba(23,23,23,.63), rgba(245,245,245,.63)) !important;
      outline: none !important;
    }
    html body .query-box-input {
      font-family: var(--ot-sans) !important;
      font-size: 14px !important;
      color: var(--ot-ink) !important;
      caret-color: var(--ot-ink) !important;
    }
    /* Tombol kirim: lingkaran obsidian dengan panah lengkung (ciri khas arch OpenTurath).
       Ikon ligatur Google disembunyikan. Saat jawaban disusun tombol yang sama menjadi
       tombol berhenti (kotak membulat); kliknya dicegat dan memakai dialog OpenTurath. */
    html body .submit-button.nb-button-type-filled button {
      position: relative !important;
      background: var(--ot-ink) !important;
      color: transparent !important;
      border-radius: 999px !important;
      transition: background-color .25s ease, transform .2s cubic-bezier(.22,.61,.36,1) !important;
    }
    html body .submit-button.nb-button-type-filled button mat-icon,
    html body .submit-button.nb-button-type-filled button .mat-icon {
      font-size: 0 !important; width: 0 !important; height: 0 !important;
      overflow: hidden !important; opacity: 0 !important;
    }
    html body .submit-button.nb-button-type-filled button::after {
      content: "";
      width: 20px;
      height: 20px;
      background: var(--ot-on-ink);
      -webkit-mask: var(--ot-send-icon) center / contain no-repeat;
      mask: var(--ot-send-icon) center / contain no-repeat;
    }
    html body .submit-button.nb-button-type-filled button:active { transform: scale(.92) !important; }
    html body .submit-button.nb-button-disabled button {
      background: var(--ot-subtle) !important;
      box-shadow: inset 0 0 0 .8px var(--ot-line) !important;
    }
    html body .submit-button.nb-button-disabled button::after { background: var(--ot-faint); }
    /* Saat jawaban sedang disusun: panah diganti kotak berhenti membulat. */
    html body.ot-generating .submit-button.nb-button-type-filled button::after,
    html body.ot-generating .submit-button.nb-button-disabled button::after {
      width: 12px;
      height: 12px;
      border-radius: 3.5px;
      background: var(--ot-on-ink);
      -webkit-mask: none;
      mask: none;
    }
    html body.ot-generating .submit-button button {
      background: var(--ot-ink) !important;
      box-shadow: none !important;
      cursor: pointer !important;
    }
    /* Selagi konfirmasi berhenti diteruskan ke halaman, dialog Google tidak boleh terlihat. */
    html.ot-stopping .cdk-overlay-container { opacity: 0 !important; pointer-events: none !important; }

    /* Tombol turun ke bawah: kapsul bulat dengan panah gambar sendiri (ikon font Google tidak dipakai). */
    html body .jump-to-bottom-container,
    html body .jump-to-bottom-button-container { margin-bottom: 10px !important; }
    html body .jump-to-bottom-button {
      width: 36px !important;
      height: 36px !important;
      min-width: 0 !important;
      padding: 0 !important;
      border-radius: 999px !important;
      background: var(--ot-surface) !important;
      color: var(--ot-ink) !important;
      border: .8px solid var(--ot-line) !important;
      box-shadow: 0 4px 18px var(--ot-shadow) !important;
      display: inline-flex !important;
      align-items: center !important;
      justify-content: center !important;
    }
    html body .jump-to-bottom-button mat-icon,
    html body .jump-to-bottom-button .mat-icon,
    html body .jump-to-bottom-button .mdc-button__label {
      font-size: 0 !important;
      width: 0 !important;
      height: 0 !important;
      overflow: hidden !important;
      opacity: 0 !important;
    }
    html body .jump-to-bottom-button::after {
      content: "";
      width: 8px;
      height: 8px;
      border-right: 1.8px solid var(--ot-ink);
      border-bottom: 1.8px solid var(--ot-ink);
      transform: translateY(-2px) rotate(45deg);
    }

    /* Dasar kolom tanya: rata lurus di bawah transkrip, seperti bilah input chat native. */
    /* Tanpa kotak: pembungkus kolom tanya transparan, tanpa garis, bayangan, atau sudut,
       sehingga hanya kapsul input yang terlihat di atas halaman. */
    html body .ot-chat-composer-path,
    html body omnibar {
      background: transparent !important;
      background-color: transparent !important;
      border: 0 !important;
      border-top: 0 !important;
      border-radius: 0 !important;
      box-shadow: none !important;
      outline: 0 !important;
    }
    html body omnibar {
      display: block !important;
      padding-top: 10px !important;
    }
    html body .ot-chat-composer-path::before,
    html body .ot-chat-composer-path::after,
    html body omnibar::before,
    html body omnibar::after { content: none !important; display: none !important; }
    html body .ot-chat-composer { margin-bottom: 4px !important; }

    /* Catatan kaki: menggantikan teks Google. */
    html body omnibar .disclaimer {
      display: block !important;
      visibility: visible !important;
      height: auto !important;
      min-height: 0 !important;
      max-height: none !important;
      opacity: 1 !important;
      overflow: visible !important;
      margin: 0 !important;
      padding: 6px 16px max(10px, env(safe-area-inset-bottom, 0px)) !important;
      font-size: 0 !important;
      text-align: center !important;
      pointer-events: none !important;
    }
    html body omnibar .disclaimer::after {
      content: var(--ot-label-disclaimer, "");
      font-family: var(--ot-sans);
      font-size: 11px;
      font-weight: 400;
      line-height: 1.4;
      color: var(--ot-faint);
    }

    /* Tombol salin minimalis (hanya ikon) di ujung setiap jawaban selesai. */
    html body .ot-answer-actions { display: flex !important; margin-top: 6px !important; }
    html body .ot-copy-answer {
      display: inline-flex !important;
      align-items: center !important;
      justify-content: center !important;
      width: 32px !important;
      height: 32px !important;
      padding: 0 !important;
      border-radius: 999px !important;
      color: var(--ot-muted) !important;
      cursor: pointer !important;
      user-select: none !important;
      -webkit-user-select: none !important;
      transition: background-color 140ms ease, color 140ms ease !important;
    }
    html body .ot-copy-answer:hover,
    html body .ot-copy-answer:focus-visible { background: var(--ot-subtle) !important; color: var(--ot-ink) !important; outline: none !important; }
    html body .ot-copy-answer::before {
      content: "";
      width: 16px;
      height: 16px;
      background: currentColor;
      -webkit-mask: var(--ot-copy-icon) center / contain no-repeat;
      mask: var(--ot-copy-icon) center / contain no-repeat;
    }
    html body .ot-copy-answer.ot-copied {
      color: var(--ot-ink) !important;
    }
    html body .ot-copy-answer.ot-copied::before {
      -webkit-mask: var(--ot-check-icon) center / contain no-repeat;
      mask: var(--ot-check-icon) center / contain no-repeat;
    }

    /* ── Dialog dan menu Google yang sesekali tampil ── */
    html body .mat-mdc-dialog-surface {
      background: var(--ot-surface) !important;
      border-radius: 28px !important;
      box-shadow: 0 8px 32px var(--ot-shadow) !important;
    }
    html body .configure-user-settings-container .header-title { font-weight: 600 !important; }
    /* Tombol dialog Google (mis. "Stop generating?") hitam, hanya warna: perilaku tidak disentuh. */
    html body mat-dialog-container .mat-mdc-unelevated-button,
    html body mat-dialog-container .mat-mdc-raised-button,
    html body .mat-mdc-dialog-surface .mat-mdc-unelevated-button,
    html body .mat-mdc-dialog-surface .mat-mdc-raised-button {
      --mdc-filled-button-container-color: var(--ot-ink) !important;
      --mdc-filled-button-label-text-color: var(--ot-on-ink) !important;
      --mat-button-filled-container-color: var(--ot-ink) !important;
      --mat-button-filled-label-text-color: var(--ot-on-ink) !important;
      background-color: var(--ot-ink) !important;
      color: var(--ot-on-ink) !important;
      border-radius: 999px !important;
    }
    html body mat-dialog-container .mat-mdc-button,
    html body .mat-mdc-dialog-surface .mat-mdc-button {
      --mdc-text-button-label-text-color: var(--ot-ink) !important;
      --mat-button-text-label-text-color: var(--ot-ink) !important;
      color: var(--ot-ink) !important;
    }
    html body .configure-user-settings-container .submit-button {
      background: var(--ot-ink) !important;
      color: var(--ot-on-ink) !important;
      border-radius: 999px !important;
    }

    /* Pergantian tema dan bahasa: pudar halus (View Transitions bila didukung, transisi warna bila tidak). */
    ::view-transition-old(root), ::view-transition-new(root) {
      animation-duration: 420ms !important;
      animation-timing-function: cubic-bezier(.22,.61,.36,1) !important;
    }
    html.ot-theme-fade, html.ot-theme-fade body,
    html.ot-theme-fade body *:not(img):not(video):not(canvas):not(svg):not(svg *) {
      transition: background-color .45s cubic-bezier(.22,.61,.36,1), color .45s cubic-bezier(.22,.61,.36,1),
        border-color .45s cubic-bezier(.22,.61,.36,1), fill .45s ease, stroke .45s ease, box-shadow .45s ease !important;
    }

    /* Saat OpenTurath mengganti bahasa lewat lembar native, dialog Google tidak boleh terlihat. */
    html.ot-opening-language .cdk-overlay-container { opacity: 0 !important; pointer-events: none !important; }
  `;

  // Hitung HANYA huruf dasar Arab (tanpa harakat/tashkeel) agar nash berharakat tidak menggelembungkan rasio Arab kartu.
  const AR = /[\u0621-\u063A\u0641-\u064A\u0671-\u06D3]/g;
  const LAT = /[A-Za-z]/g;

  function toggle(el, name, on) {
    if (el.classList.contains(name) !== on) el.classList.toggle(name, on);
  }

  /* Menandai bagian jawaban lewat kelas saja; teks tidak diubah. */
  function tagAnswers() {
    document.querySelectorAll('.thinking-chain').forEach(chain => {
      toggle(chain, 'ot-thinking', !!chain.querySelector('.is-loading'));
    });
    if (document.body) {
      const stopLabeled = [...document.querySelectorAll('.submit-button button, app-chat-input button, .chat-input-container button')]
        .some(b => ((window.__otIsStopButton && window.__otIsStopButton(b)) || /stop|hentikan|berhenti|إيقاف/i.test(b.getAttribute('aria-label') || '')) && b.offsetParent !== null);
      toggle(document.body, 'ot-generating', !!document.querySelector('.thinking-chain.ot-thinking') || stopLabeled);
    }
    document.querySelectorAll('.to-user-container').forEach(box => {
      const done = !!box.querySelector('chat-actions, .chat-actions');
      let row = box.querySelector(':scope > .ot-answer-actions');
      if (done && !row) {
        row = document.createElement('div');
        row.className = 'ot-answer-actions';
        const btn = document.createElement('div');
        btn.className = 'ot-copy-answer';
        btn.setAttribute('role', 'button');
        btn.setAttribute('tabindex', '0');
        btn.setAttribute('aria-label', LABELS[lang()].copy);
        btn.setAttribute('title', LABELS[lang()].copy);
        btn.addEventListener('ot-copy-result', event => {
          btn.__otCopied = event.detail === true;
          btn.__otCopyFailed = event.detail !== true;
          toggle(btn, 'ot-copied', btn.__otCopied);
          const tip = btn.__otCopied ? LABELS[lang()].copied : LABELS[lang()].copyFailed;
          btn.setAttribute('aria-label', tip);
          btn.setAttribute('title', tip);
          clearTimeout(btn.__otTimer);
          btn.__otTimer = setTimeout(() => {
            btn.__otCopied = false;
            btn.__otCopyFailed = false;
            toggle(btn, 'ot-copied', false);
            btn.setAttribute('aria-label', LABELS[lang()].copy);
            btn.setAttribute('title', LABELS[lang()].copy);
          }, 1800);
        });
        btn.addEventListener('keydown', e => {
          if (e.key === 'Enter' || e.key === ' ') { e.preventDefault(); btn.click(); }
        });
        row.appendChild(btn);
        box.appendChild(row);
      } else if (!done && row) {
        row.remove();
      }
      const btn = box.querySelector(':scope > .ot-answer-actions .ot-copy-answer');
      if (btn && !btn.__otCopied && !btn.__otCopyFailed) {
        const want = LABELS[lang()].copy;
        if (btn.getAttribute('title') !== want) {
          btn.setAttribute('aria-label', want);
          btn.setAttribute('title', want);
        }
      }
    });

    // 1. Deteksi bahasa utama kartu (LTR vs RTL) yang kebal harakat & kebal kutipan ibarah panjang.
    //    Menghitung KATA prosa non-kutipan (membuang «...», ﴿...﴾, "..." Arab, dan referensi kitab dalam kurung),
    //    serta mempertimbangkan bahasa pertanyaan pasangan di atasnya bila prosa pembuka sangat singkat.
    const AR_WORD = /[\u0621-\u063A\u0641-\u064A\u0671-\u06D3]{2,}/g;
    const LAT_WORD = /[A-Za-z]{2,}/g;
    const LATIN_PROSE_HINT = /\b(artinya|arti\/intisari|intisari|terjemahan|kesimpulan|penjelasan|dalil|rujukan|ibarah|jawaban|mazhab|hukumnya|berikut|conclusion|meaning|translation|summary)\b/i;
    const ASKED_ARABIC = /(?:bahasa\s+arab|in\s+arabic|بالعربية|باللغة\s+العربية)/i;
    const QUOTED_ARABIC_ANY = /(?:«[^»]*[\u0621-\u064A]{3,}[^»]*»|﴿[^﴾]*[\u0621-\u064A]{3,}[^﴾]*﴾|["“][^"”]*[\u0621-\u064A]{8,}[^"”]*["”])/g;
    const STARTS_QUOTED_ARABIC = /^(?:[-–•]\s*)?(?:«([^»]+)»|﴿([^﴾]+)﴾|["“]([^"”]+)["”])/;
    const TRANS_PREFIX = /^\s*(?:Arti\s*\/\s*Intisari|Artinya|Arti|Intisari|Terjemahan|Terjemah|Makna|Maksud|Meaning|Translation)\s*[:：]/i;
    const TRANS_INLINE = /(?:\n|\s+)(?=(?:Arti\s*\/\s*Intisari|Artinya|Arti|Intisari|Terjemahan|Terjemah|Makna|Maksud|Meaning|Translation)\s*[:：])/i;
    const KITAB_REF = /(?:\([^)]*[\u0621-\u064A][^)]*(?:[٠-٩0-9]|ص|ج|سورة|آية|حديث)[^)]*\)|(?:ج\s*[٠-٩0-9]+|ص\s*[٠-٩0-9]+|[٠-٩0-9]+\s*\/\s*[٠-٩0-9]+))/;

    function pairedQuestionCard(answerCard) {
      const pair = answerCard.closest('.chat-message-pair, chat-turn, app-chat-turn');
      if (pair) {
        const q = pair.querySelector('.from-user-message-card-content');
        if (q) return q;
      }
      const all = [...document.querySelectorAll('.from-user-message-card-content, .to-user-message-card-content')];
      const idx = all.indexOf(answerCard);
      for (let i = idx - 1; i >= 0; i--) {
        if (all[i].classList.contains('from-user-message-card-content')) return all[i];
      }
      return null;
    }

    document.querySelectorAll('.from-user-message-card-content, .to-user-message-card-content').forEach(card => {
      const cTxt = card.textContent || '';
      if (card.__otDirLen === cTxt.length) return;
      card.__otDirLen = cTxt.length;
      const isAnswer = card.classList.contains('to-user-message-card-content');
      const proseTxt = isAnswer
        ? cTxt.replace(QUOTED_ARABIC_ANY, ' ').replace(/\([^)]*[\u0621-\u064A][^)]*\)/g, ' ')
        : cTxt;
      const arWords = (proseTxt.match(AR_WORD) || []).length;
      const latWords = (proseTxt.match(LAT_WORD) || []).length;
      const totalWords = arWords + latWords;
      if (totalWords === 0) return;
      let isCardRtl;
      if (isAnswer) {
        const hasLatinHint = LATIN_PROSE_HINT.test(proseTxt) && latWords >= 2;
        const strongLatinProse = latWords >= 12 && (latWords / totalWords) >= 0.30;
        const qCard = pairedQuestionCard(card);
        const qTxt = qCard ? (qCard.textContent || '') : '';
        const pairedLtrQuestion = !!(qCard && qCard.__otIsRtl === false && !ASKED_ARABIC.test(qTxt));
        const shortLtrLead = pairedLtrQuestion && latWords >= 2;
        isCardRtl = !hasLatinHint && !strongLatinProse && !shortLtrLead && arWords >= 6 && (arWords / totalWords) >= 0.72;
      } else {
        isCardRtl = arWords >= 2 && (arWords / totalWords) >= 0.55;
      }
      card.__otIsRtl = isCardRtl;
      card.setAttribute('dir', isCardRtl ? 'rtl' : 'ltr');
      toggle(card, 'ot-dir-rtl', isCardRtl);
      toggle(card, 'ot-dir-ltr', !isCardRtl);
    });

    // 2. Pastikan arah setiap sel tabel (th/td) mengikuti isi selnya sendiri agar tidak pernah terbalik
    document.querySelectorAll('.to-user-message-card-content th, .to-user-message-card-content td').forEach(cell => {
      const t = (cell.textContent || '').trim();
      if (cell.__otCellLen === t.length) return;
      cell.__otCellLen = t.length;
      const arW = (t.match(AR_WORD) || []).length;
      const latW = (t.match(LAT_WORD) || []).length;
      const cellRtl = arW > 0 && arW > latW * 1.5;
      cell.setAttribute('dir', cellRtl ? 'rtl' : 'ltr');
    });

    function isIbarahSegment(txt) {
      const trimmed = (txt || '').trim();
      if (!trimmed) return false;
      // Kutipan Arab eksplisit di awal baris («...», ﴿...﴾, "...") selalu ibarah meski sumber (...) di belakangnya berhuruf Latin
      const qMatch = STARTS_QUOTED_ARABIC.exec(trimmed);
      if (qMatch) {
        const inner = qMatch[1] || qMatch[2] || qMatch[3] || '';
        const innerAr = (inner.match(AR) || []).length;
        const innerLa = (inner.match(LAT) || []).length;
        if (innerAr >= 10 && innerAr > innerLa * 2) return true;
      }
      const ar = (trimmed.match(AR) || []).length;
      const la = (trimmed.match(LAT) || []).length;
      const total = ar + la;
      const arRatio = total > 0 ? ar / total : 0;
      const looksLikeHeading = trimmed.length < 24 || /^[أ-ي0-9١-٩]+[\.\-\)]\s+/.test(trimmed);
      const hasQuoteMarks = (/[«»﴿﴾]/.test(trimmed) || /["“][^"”]*[\u0621-\u064A]{8,}[^"”]*["”]/.test(trimmed)) && ar >= 10 && arRatio >= 0.45;
      const hasKitabRef = KITAB_REF.test(trimmed) && ar >= 12 && arRatio >= 0.45;
      const isSubstantialArabic = !looksLikeHeading && ar >= 22 && arRatio >= 0.62;
      return hasQuoteMarks || hasKitabRef || isSubstantialArabic;
    }

    // 3. Pemisah segmen universal untuk blok gabungan (ibarah Arab + Artinya/Arti/Intisari atau lead-in + ibarah).
    //    Hanya dijalankan pada jawaban yang sudah selesai streaming (done) agar tidak mengganggu Angular.
    function splitBlockSegments(el) {
      if (el.dataset.otSplit === '1' || el.querySelector('.ot-ibarah, .ot-ibarah-trans, ul, ol, table')) return false;
      let container = el;
      while (container.childNodes.length === 1 && container.firstChild.nodeType === 1 && container.firstChild.tagName === 'SPAN') {
        container = container.firstChild;
      }
      const rawNodes = Array.from(container.childNodes);
      if (!rawNodes.length) return false;

      const segments = [];
      let current = [];
      const pushCurrent = () => {
        const txt = current.map(n => n.textContent || '').join('').trim();
        if (txt) segments.push({ nodes: current, text: txt });
        current = [];
      };
      for (const n of rawNodes) {
        if (n.nodeType === 1 && n.tagName === 'BR') {
          pushCurrent();
          continue;
        }
        const nTxt = n.textContent || '';
        if (current.length > 0 && TRANS_PREFIX.test(nTxt)) {
          pushCurrent();
          current.push(n);
          continue;
        }
        if (n.nodeType === 3 && TRANS_INLINE.test(nTxt)) {
          const m = TRANS_INLINE.exec(nTxt);
          if (m && m.index > 0) {
            const tail = n.splitText(m.index);
            current.push(n);
            pushCurrent();
            current.push(tail);
            continue;
          }
        }
        current.push(n);
      }
      pushCurrent();
      if (segments.length < 2) return false;

      const classified = segments.map(seg => ({
        ...seg,
        kind: isIbarahSegment(seg.text) ? 'ibarah' : 'prose',
      }));
      const hasIbarah = classified.some(s => s.kind === 'ibarah');
      const hasProse = classified.some(s => s.kind === 'prose');
      if (!hasIbarah || !hasProse) return false;

      const groups = [];
      for (const seg of classified) {
        const last = groups[groups.length - 1];
        if (last && last.kind === seg.kind) {
          last.nodes.push(document.createElement('br'), ...seg.nodes);
        } else {
          groups.push({ kind: seg.kind, nodes: [...seg.nodes] });
        }
      }

      el.textContent = '';
      for (const g of groups) {
        const wrap = document.createElement('div');
        wrap.className = g.kind === 'ibarah' ? 'ot-ibarah' : 'ot-ibarah-trans ot-ltr-block';
        wrap.setAttribute('dir', g.kind === 'ibarah' ? 'rtl' : 'ltr');
        for (const node of g.nodes) wrap.appendChild(node);
        el.appendChild(wrap);
      }
      el.dataset.otSplit = '1';
      el.setAttribute('dir', 'ltr');
      toggle(el, 'ot-ibarah-host', true);
      toggle(el, 'ot-ibarah', false);
      toggle(el, 'ot-rtl-block', false);
      toggle(el, 'ot-ltr-block', true);
      const item = el.closest('li');
      if (item && groups[0].kind === 'ibarah') toggle(item, 'ot-ibarah-item', true);
      return true;
    }

    // Tangani <li> yang memiliki teks ibarah langsung di awal lalu diikuti sub-list <ul>/<ol>
    function wrapLeadingIbarahInList(li) {
      if (li.dataset.otLeadWrapped === '1' || li.querySelector(':scope > .ot-ibarah, :scope > .paragraph, :scope > p')) return;
      const subList = li.querySelector(':scope > ul, :scope > ol');
      if (!subList) return;
      const leadNodes = [];
      for (const child of Array.from(li.childNodes)) {
        if (child === subList) break;
        leadNodes.push(child);
      }
      const leadText = leadNodes.map(n => n.textContent || '').join('').trim();
      if (!isIbarahSegment(leadText)) return;
      const wrap = document.createElement('div');
      wrap.className = 'ot-ibarah';
      wrap.setAttribute('dir', 'rtl');
      for (const node of leadNodes) wrap.appendChild(node);
      li.insertBefore(wrap, subList);
      li.dataset.otLeadWrapped = '1';
      toggle(li, 'ot-ibarah-item', true);
    }

    function processBlock(el, cardDone) {
      if (el.closest('.ot-ibarah, .ot-ibarah-trans')) return;
      const card = el.closest('.to-user-message-card-content');
      const isWholeArabicCard = !!(card && card.__otIsRtl);
      const text = el.textContent || '';
      const stateKey = text.length + ':' + (cardDone ? '1' : '0') + ':' + (isWholeArabicCard ? 'R' : 'L');
      if (el.__otStateKey === stateKey) return;
      el.__otStateKey = stateKey;

      const trimmed = text.trim();
      const ar = (trimmed.match(AR) || []).length;
      const la = (trimmed.match(LAT) || []).length;
      const total = ar + la;
      const arRatio = total > 0 ? ar / total : 0;
      const hasListChild = !!el.querySelector('ul, ol, li');
      const isTableCell = el.classList.contains('table-paragraph') || !!el.closest('table');

      if (!isWholeArabicCard) {
        if (el.dataset.otSplit === '1') {
          el.setAttribute('dir', 'ltr');
          return;
        }
        // Saat jawaban selesai streaming, pisahkan segmen gabungan (ibarah Arab + Artinya/prosa LTR)
        if (cardDone && !hasListChild && !isTableCell && ar >= 10 && la >= 8 && splitBlockSegments(el)) {
          return;
        }
        const ibarah = !hasListChild && !isTableCell && isIbarahSegment(trimmed);
        const isArabicBlock = !hasListChild && !isTableCell && (ibarah || (ar >= 8 && arRatio >= 0.58));

        el.setAttribute('dir', isArabicBlock ? 'rtl' : 'ltr');
        toggle(el, 'ot-rtl-block', isArabicBlock && !ibarah);
        toggle(el, 'ot-ltr-block', !isArabicBlock);
        toggle(el, 'ot-ibarah', ibarah);
        const item = el.closest('li');
        if (item && ibarah) toggle(item, 'ot-ibarah-item', true);
      } else {
        el.setAttribute('dir', 'rtl');
        toggle(el, 'ot-rtl-block', false);
        toggle(el, 'ot-ltr-block', false);
        // Di kartu full-Arab, hanya kutipan eksplisit «...», ﴿...﴾, atau "..." Arab yang diberi aksen kotak halus
        const explicitQuote = !hasListChild && !isTableCell && (/[«»﴿﴾]/.test(trimmed) || /["“][^"”]*[\u0621-\u064A]{10,}[^"”]*["”]/.test(trimmed)) && ar >= 14;
        toggle(el, 'ot-ibarah', explicitQuote);
      }

      let section = false;
      const head = el.firstElementChild;
      if (!isWholeArabicCard && head && head.tagName === 'B' &&
          /^[A-Z]\.\s+[A-Z0-9 ,&'’\/()\-–]+$/.test((head.textContent || '').trim()) &&
          head.nextElementSibling && (head.nextElementSibling.textContent || '').trim() === ':') {
        section = true;
      }
      toggle(el, 'ot-section', section);
      if (section) {
        const gap = head.nextElementSibling.nextElementSibling;
        if (gap && (gap.textContent || '').trim() === '') toggle(gap, 'ot-gap', true);
      }

      const mode = /^\s*[▸▶►▷]?\s*Mode\s*:\s*(.+?)\s*$/i.exec(text);
      if (mode) {
        el.setAttribute('data-ot-mode', mode[1]);
        toggle(el, 'ot-mode', true);
      } else {
        toggle(el, 'ot-mode', false);
      }
    }

    document.querySelectorAll('.to-user-container').forEach(box => {
      const cardDone = !!box.querySelector('chat-actions, .chat-actions');
      const card = box.querySelector('.to-user-message-card-content');
      const isWholeArabicCard = !!(card && card.__otIsRtl);
      box.querySelectorAll('.to-user-message-card-content .paragraph, .to-user-message-card-content p').forEach(el => processBlock(el, cardDone));
      box.querySelectorAll('.to-user-message-card-content li').forEach(li => {
        if (!li.querySelector('.paragraph, p, ul, ol')) {
          processBlock(li, cardDone);
        } else if (cardDone && !isWholeArabicCard) {
          wrapLeadingIbarahInList(li);
        }
      });
    });
  }

  function applyStyle() {
    try {
      let style = document.getElementById('ot-skin');
      if (!style) {
        style = document.createElement('style');
        style.id = 'ot-skin';
        (document.head || document.documentElement).appendChild(style);
      }
      if (style.textContent !== CSS) style.textContent = CSS;
      const L = LABELS[lang()];
      const root = document.documentElement;
      root.style.setProperty('--ot-label-disclaimer', JSON.stringify(L.disclaimer));
      if (!stageStart || !root.style.getPropertyValue('--ot-label-thinking')) root.style.setProperty('--ot-label-thinking', JSON.stringify(L.stages[0]));
      if (!window.__otCopyIcon) window.__otCopyIcon = copyIcon();
      root.style.setProperty('--ot-copy-icon', window.__otCopyIcon);
      if (!window.__otCheckIcon) window.__otCheckIcon = checkIcon();
      root.style.setProperty('--ot-check-icon', window.__otCheckIcon);
      if (!window.__otSendIcon) window.__otSendIcon = sendIcon();
      root.style.setProperty('--ot-send-icon', window.__otSendIcon);
      root.style.setProperty('--ot-label-thought', JSON.stringify(L.thought));
      root.style.setProperty('--ot-label-ibarah', JSON.stringify(L.ibarah));
      if (!window.__otArchSprite) window.__otArchSprite = archSprite();
      root.style.setProperty('--ot-arch-sprite', window.__otArchSprite);
    } catch (_) {}
  }

  /* Status memuat bergilir selama jawaban disusun: kata-katanya menggambarkan tahap kerja,
     dan berhenti di tahap terakhir sampai jawaban selesai. */
  let stageStart = 0;
  function updateStage() {
    try {
      const active = document.querySelector('.thinking-chain.ot-thinking');
      const stages = LABELS[lang()].stages;
      if (!active) { stageStart = 0; return; }
      if (!stageStart) stageStart = Date.now();
      const index = Math.min(Math.floor((Date.now() - stageStart) / 3200), stages.length - 1);
      document.documentElement.style.setProperty('--ot-label-thinking', JSON.stringify(stages[index]));
    } catch (_) {}
  }
  if (!window.__otStageTimer) window.__otStageTimer = setInterval(updateStage, 700);

  /* Semua perubahan tampilan besar (tema terang/gelap, ganti bahasa) dijalankan lewat sini
     agar berpindah dengan pudar halus. Memakai View Transitions bila tersedia; bila tidak,
     memakai transisi warna CSS sementara. Menghormati prefers-reduced-motion. */
  window.otRun = function (fn) {
    const root = document.documentElement;
    const reduce = !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
    if (reduce) { fn(); return; }
    if (typeof document.startViewTransition === 'function') {
      try { document.startViewTransition(fn); return; } catch (_) {}
    }
    root.classList.add('ot-theme-fade');
    clearTimeout(window.__otFadeTimer);
    try { fn(); } catch (_) {}
    window.__otFadeTimer = setTimeout(() => root.classList.remove('ot-theme-fade'), 520);
  };

  function apply() {
    applyStyle();
    try { tagAnswers(); } catch (_) {}
    updateStage();
    try { if (window.__otWatchStop) window.__otWatchStop(); } catch (_) {}
  }
  window.otSkinApply = apply;

  /* Tombol berhenti: dialog "Stop generating?" milik Google diganti dialog OpenTurath.
     Klik dicegat; aplikasi bertanya ke pengguna; bila setuju, tombol asli ditekan dan
     dialog Google disembunyikan lalu dikonfirmasi otomatis (berdasarkan posisi tombol,
     bukan teks, supaya tidak bergantung pada bahasa antarmuka Google). Bila apa pun
     gagal, klik diteruskan apa adanya agar pengguna tidak terjebak. */
  (function () {
    /* Dimatikan sementara atas keputusan pemilik: tombol Stop memakai dialog bawaan Google. */
    if (true) return;
    if (window.__otStopGuard) return;
    window.__otStopGuard = true;
    const STOP_LABEL = /stop|hentikan|berhenti|إيقاف|detener|arrêter|stopp/i;
    let busy = false;
    let passThrough = false;

    /* Ikon tombol kirim berubah menjadi "stop" begitu jawaban disusun, bahkan pada tahap awal
       ("Analyzing your files...") sebelum elemen berpikir ada. Ikon itu ikut menentukan. */
    const STOP_ICON = /^(stop|stop_circle|stop_circle_outlined|square|stop_fill)$/i;
    function iconOf(btn) {
      const ic = btn.querySelector('mat-icon, .mat-icon, [data-mat-icon-name], [fonticon]');
      return ic ? (ic.getAttribute('data-mat-icon-name') || ic.getAttribute('fonticon') || ic.textContent || '').trim() : '';
    }
    window.__otIsStopButton = btn => !!btn && (STOP_ICON.test(iconOf(btn)) || STOP_LABEL.test(btn.getAttribute('aria-label') || ''));
    function stopButtonFrom(target) {
      const btn = target && target.closest && target.closest('button');
      if (!btn) return null;
      if (btn.closest('.submit-button') && (document.body.classList.contains('ot-generating') || window.__otIsStopButton(btn))) return btn;
      const label = btn.getAttribute('aria-label') || '';
      if (STOP_LABEL.test(label) && btn.closest('.ot-chat-composer, app-chat-input, .chat-input-container, form')) return btn;
      return null;
    }

    /* Dialog "Stop generating?" milik Google sendiri memuat kata "remove" ("remove it from the chat"),
       jadi deteksi kata saja tidak cukup. Dialog Stop dikenali dari pola jelas (stop/hentikan + generating/
       response/jawaban) DAN tidak memuat kata penghapusan yang kuat (delete/hapus/clear). Selain itu,
       dialog apa pun yang memuat penghapusan kuat tidak dikonfirmasi otomatis. */
    const STRONG_DESTRUCTIVE = /delet|clear|erase|discard|hapus|bersihkan|\u062d\u0630\u0641|\u0645\u0633\u062d/i;
    const STOP_DIALOG = /(stop|hentikan|berhenti|\u0625\u064a\u0642\u0627\u0641).{0,40}(generat|respons|answer|jawab|pembuat|\u0625\u0646\u0634\u0627\u0621)|(generat|respons|answer|jawab|pembuat).{0,40}(stop|hentikan)/i;
    function isDestructiveDialog(dialog) {
      const text = (dialog && (dialog.textContent || '')) || '';
      if (STRONG_DESTRUCTIVE.test(text)) return true;
      // "remove"/"buang" lemah: hanya aman bila jelas dialog Stop; selain itu anggap destruktif.
      if (/remov|buang|\u0625\u0632\u0627\u0644\u0629/i.test(text) && !STOP_DIALOG.test(text)) return true;
      return false;
    }
    window.__otIsDestructiveDialog = isDestructiveDialog;

    function confirmGoogleDialog(done) {
      const root = document.documentElement;
      const deadline = Date.now() + 2500;
      (function tick() {
        const dialog = document.querySelector('mat-dialog-container, .mat-mdc-dialog-container, [role="alertdialog"], [role="dialog"]');
        const buttons = dialog ? [...dialog.querySelectorAll('button')].filter(b => b.offsetParent !== null) : [];
        if (dialog && isDestructiveDialog(dialog)) {
          // Dialog lain yang tampak (mis. hapus riwayat): jangan disentuh. Biarkan terlihat untuk pengguna.
          root.classList.remove('ot-stopping');
          done();
          return;
        }
        if (buttons.length >= 2) {
          const primary = dialog.querySelector('button.mat-mdc-unelevated-button, button[class*="filled" i]') || buttons[buttons.length - 1];
          try { primary.click(); } catch (_) {}
          setTimeout(done, 150);
          return;
        }
        if (Date.now() > deadline) { root.classList.remove('ot-stopping'); done(); return; }
        setTimeout(tick, 40);
      })();
    }

    function proceed(btn) {
      const root = document.documentElement;
      root.classList.add('ot-stopping');
      passThrough = true;
      try { btn.click(); } catch (_) {}
      passThrough = false;
      confirmGoogleDialog(() => { root.classList.remove('ot-stopping'); busy = false; });
    }

    function passUntouched(btn) {
      passThrough = true;
      try { btn.click(); } catch (_) {}
      passThrough = false;
      busy = false;
    }

    /* Cadangan: bila dialog "Stop generating?" milik Google tetap muncul (klik tidak tercegat,
       tombol dari papan ketik, tahap awal jawaban), dialog itu disembunyikan seketika dan
       pertanyaannya diajukan oleh dialog OpenTurath. Jawaban pengguna diteruskan ke dialog Google. */
    let watching = false;
    window.__otWatchStop = function () {
      if (busy || watching) return;
      const dlg = [...document.querySelectorAll('mat-dialog-container, .mat-mdc-dialog-container, [role="alertdialog"], [role="dialog"]')]
        .find(d => !d.__otHandled && STOP_DIALOG.test(d.textContent || '') && !STRONG_DESTRUCTIVE.test(d.textContent || ''));
      if (!dlg) return;
      dlg.__otHandled = true;
      const root = document.documentElement;
      const btns = [...dlg.querySelectorAll('button')];
      if (btns.length < 2) return;
      const keep = btns.find(b => /keep|lanjut|continue|batal|cancel|\u0645\u062a\u0627\u0628\u0639\u0629/i.test(b.textContent || '')) || btns[0];
      const stop = btns.find(b => b !== keep) || btns[btns.length - 1];
      const bridge = window.flutter_inappwebview;
      if (!bridge || typeof bridge.callHandler !== 'function') return; // dialog Google tetap terlihat
      watching = true;
      root.classList.add('ot-stopping');
      const finish = () => { root.classList.remove('ot-stopping'); watching = false; };
      Promise.resolve(bridge.callHandler('otStopRequested')).then(ok => {
        try { (ok === true ? stop : keep).click(); } catch (_) {}
        setTimeout(finish, 250);
      }).catch(() => {
        try { keep.click(); } catch (_) {}
        finish();
      });
    };

    window.addEventListener('click', function (e) {
      if (passThrough) return;
      const btn = stopButtonFrom(e.target);
      if (!btn) return;
      e.preventDefault();
      e.stopPropagation();
      if (typeof e.stopImmediatePropagation === 'function') e.stopImmediatePropagation();
      if (busy) return;
      busy = true;
      const bridge = window.flutter_inappwebview;
      if (!bridge || typeof bridge.callHandler !== 'function') { passUntouched(btn); return; }
      let answered = false;
      const guard = setTimeout(() => { if (!answered) { answered = true; passUntouched(btn); } }, 120000);
      Promise.resolve(bridge.callHandler('otStopRequested')).then(ok => {
        if (answered) return;
        answered = true; clearTimeout(guard);
        if (ok === true) proceed(btn); else busy = false;
      }).catch(() => {
        if (answered) return;
        answered = true; clearTimeout(guard);
        passUntouched(btn);
      });
    }, true);
  })();
  /* Dipanggil aplikasi saat bahasa aplikasi berganti: label di halaman ikut berganti
     tanpa memuat ulang. Disimpan di sessionStorage agar tahan muat ulang halaman. */
  window.otSetLang = function (code) {
    if (!LABELS[code]) return false;
    window._otLang = code;
    try { sessionStorage.setItem('ot_lang', code); } catch (_) {}
    apply();
    return true;
  };
  apply();

  if (!window.__otSkinObserver) {
    let queued = false;
    window.__otSkinObserver = new MutationObserver(() => {
      if (window._otBackgroundPaused || queued) return;
      queued = true;
      const wait = Date.now() - (window.__otLastScroll || 0) < 250 ? 350 : 220;
      setTimeout(() => {
        queued = false;
        if (window._otBackgroundPaused) return;
        apply();
      }, wait);
    });
    window.addEventListener('scroll', () => { window.__otLastScroll = Date.now(); }, { capture: true, passive: true });
    const start = () => {
      if (document.body) window.__otSkinObserver.observe(document.body, { childList: true, subtree: true });
      else setTimeout(start, 50);
    };
    start();
  }

  /* Ganti bahasa jawaban tanpa menampilkan dialog Google: buka menu pengaturan,
     pilih bahasa di dialog "Configure settings", tekan Save, lalu bersihkan.
     Mengembalikan {ok, reason}; bila gagal, dialog dibiarkan terlihat agar
     pengguna masih bisa menyelesaikannya sendiri. */
  window.otSetOutputLanguage = function (aliases) {
    return new Promise(resolve => {
      const root = document.documentElement;
      const wanted = (aliases || []).map(a => String(a).trim().toLowerCase()).filter(Boolean);
      const norm = s => (s || '').replace(/\s+/g, ' ').trim().toLowerCase();
      const deadline = Date.now() + 15000;
      let finished = false;

      function finish(ok, reason) {
        if (finished) return;
        finished = true;
        root.classList.remove('ot-opening-language');
        resolve({ ok, reason: reason || '' });
      }
      function waitFor(find, next, reason) {
        (function tick() {
          if (finished) return;
          const found = find();
          if (found) { next(found); return; }
          if (Date.now() > deadline) { finish(false, reason); return; }
          setTimeout(tick, 60);
        })();
      }
      function click(el) { try { el.click(); return true; } catch (_) { return false; } }

      if (wanted.length === 0 || typeof window.otOpenLanguageSettings !== 'function') { finish(false, 'unsupported'); return; }
      root.classList.add('ot-opening-language');
      if (!window.otOpenLanguageSettings()) { finish(false, 'menu'); return; }

      waitFor(
        () => document.querySelector('configure-user-settings mat-select'),
        select => {
          click(select.querySelector('.mat-mdc-select-trigger') || select);
          waitFor(
            () => {
              const options = [...document.querySelectorAll('mat-option, .mat-mdc-option')];
              return options.length ? options : null;
            },
            options => {
              const labelOf = o => norm(o.innerText || o.textContent);
              let match = null;
              for (const alias of wanted) {
                match = options.find(o => labelOf(o) === alias) || options.find(o => labelOf(o).startsWith(alias));
                if (match) break;
              }
              if (!match) {
                const close = document.querySelector('configure-user-settings button[aria-label*="Close" i]');
                if (close) click(close);
                finish(false, 'option');
                return;
              }
              click(match);
              waitFor(
                () => document.querySelector('configure-user-settings .save-container button, configure-user-settings button[aria-label="Save settings"]'),
                save => {
                  setTimeout(() => {
                    click(save);
                    waitFor(() => (document.querySelector('configure-user-settings') ? null : true), () => {
                if (window.otRun) window.otRun(() => apply());
                finish(true);
              }, 'save');
                  }, 120);
                },
                'save-button'
              );
            },
            'options'
          );
        },
        'dialog'
      );
    });
  };
})();
''';
