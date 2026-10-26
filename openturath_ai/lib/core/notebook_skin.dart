/// Kulit OpenTurath untuk halaman obrolan NotebookLM di WebView.
///
/// Murni aditif: satu blok `<style id="ot-skin">` yang menimpa token warna
/// (`--nlm-*`, `--mat-sys-*`) dan tipografi bawaan halaman, ditambah beberapa
/// label tahap berpikir lewat variabel CSS. Aturan
/// penyembunyian inti, polling kesiapan, dan siklus hidup WebView di
/// `notebook_ui_script.dart` dan `agent_multi_tab_room.dart` tidak disentuh.
///
/// Selektor diambil dari DOM langsung NotebookLM (Angular, Okt 2026); lihat
/// `docs/DOKUMEN_STRUKTUR_DOM_LENGKAP_NOTEBOOKLM.md`. Dilarang menggabungkan
/// `:has(...)` ke dalam daftar selektor berkoma (STANDAR_IDEAL_WEBVIEW.md).
const notebookSkinScript = r'''
(function () {
  if (window.top !== window || !['notebooklm.google.com', 'notebook.google.com'].includes(location.hostname)) return;

  const LABELS = {
    id: { thinking: 'Berpikir…', thought: 'Proses berpikir' },
    en: { thinking: 'Thinking…', thought: 'Reasoning' },
    ar: { thinking: 'جارٍ التفكير…', thought: 'مسار التفكير' }
  };
  function lang() { return LABELS[window._otLang] ? window._otLang : 'id'; }

  const CSS = `
    @font-face {
      font-family: "OT Arabic";
      src: local("Scheherazade New"), local("Geeza Pro"), local("Noto Naskh Arabic"), local("Amiri"), local("Al Nile");
      unicode-range: U+0600-06FF, U+0750-077F, U+08A0-08FF, U+FB50-FDFF, U+FE70-FEFF;
    }

    /* Token warna dan huruf: satu sumber untuk seluruh halaman. */
    html body, html body.luminous-ui {
      --ot-sans: "OT Arabic", "Outfit", "Inter", "SF Pro Text", -apple-system, system-ui, "Segoe UI", sans-serif;
      --ot-serif: "OT Arabic", "Newsreader", "Iowan Old Style", "New York", ui-serif, Georgia, "Times New Roman", serif;
      --nlm-font-family-sans: var(--ot-sans) !important;
      --chat-panel-bg: light-dark(#FFFFFF, #18181B) !important;
      --nlm-fills-surface-page: light-dark(#FFFFFF, #18181B) !important;
      --nlm-fills-surface-panel: light-dark(#FFFFFF, #27272A) !important;
      --nlm-fills-surface-container: light-dark(#F6F6F6, #27272A) !important;
      --nlm-fills-ui-grey-fill: light-dark(#F0F0F0, #27272A) !important;
      --nlm-fills-ui-blue-fill: light-dark(#F0F0F0, #27272A) !important;
      --nlm-text-body-text: light-dark(#171717, #E4E4E7) !important;
      --nlm-text-titles-and-labels: light-dark(#171717, #FAFAFA) !important;
      --nlm-text-secondary-text: light-dark(#606060, #A1A1AA) !important;
      --nlm-text-ghost-text: light-dark(#6B6B6B, #8A8A93) !important;
      --nlm-stroke-default: light-dark(#DADADA, #3F3F46) !important;
      --nlm-stroke-focus: light-dark(#767676, #71717A) !important;
      --nlm-ctas-buttons-primary: light-dark(#171717, #FAFAFA) !important;
      --nlm-cta-text-and-icon-primary: light-dark(#FFFFFF, #18181B) !important;
      --nlm-states-on-primary-hover: light-dark(rgba(23,23,23,.06), rgba(250,250,250,.08)) !important;
      --nlm-brand-blue: light-dark(#171717, #FAFAFA) !important;
      --nlm-icons-blue: light-dark(#171717, #FAFAFA) !important;
      --nlm-icons-default: light-dark(#171717, #E4E4E7) !important;
      --mat-sys-primary: light-dark(#171717, #FAFAFA) !important;
      --mat-sys-on-primary: light-dark(#FFFFFF, #18181B) !important;
      --mat-sys-surface: light-dark(#FFFFFF, #18181B) !important;
      --mat-sys-on-surface: light-dark(#171717, #E4E4E7) !important;
      --mat-sys-on-surface-variant: light-dark(#606060, #A1A1AA) !important;
      --mat-sys-surface-container-low: light-dark(#FFFFFF, #1F1F23) !important;
      --mat-sys-surface-container: light-dark(#F6F6F6, #27272A) !important;
      --mat-sys-surface-container-high: light-dark(#F0F0F0, #2E2E33) !important;
      --mat-sys-surface-container-highest: light-dark(#EDEDED, #353535) !important;
      --mat-sys-outline: light-dark(#767676, #71717A) !important;
      --mat-sys-outline-variant: light-dark(#DADADA, #3F3F46) !important;
      --mat-sys-secondary-container: light-dark(#F0F0F0, #353535) !important;
      --mat-sys-on-secondary-container: light-dark(#171717, #FAFAFA) !important;
      font-family: var(--ot-sans) !important;
    }
    html body textarea, html body button, html body input { font-family: var(--ot-sans) !important; }
    ::selection { background: light-dark(rgba(23,23,23,.14), rgba(250,250,250,.22)); }

    /* Kolom baca: satu lebar untuk pertanyaan dan jawaban, sejajar dengan kolom tanya. */
    html body chat-message.individual-message {
      display: block !important;
      width: 100% !important;
      max-width: 720px !important;
      margin-inline: auto !important;
      padding-inline: 16px !important;
      box-sizing: border-box !important;
    }

    /* Pertanyaan pengguna: kartu bergaris tipis, bukan gelembung abu. */
    html body .from-user-container { padding-inline-start: 0 !important; }
    html body .from-user-message-card-content {
      background: transparent !important;
      box-shadow: none !important;
      border: 1px solid var(--nlm-stroke-default) !important;
      border-radius: 14px !important;
      max-width: min(88%, 560px) !important;
    }
    html body .from-user-message-card-content::after { display: none !important; }
    html body .from-user-message-inner-content { padding: 10px 14px !important; }
    html body .from-user-message-card-content .md3-body-text,
    html body .from-user-message-card-content p {
      font-family: var(--ot-sans) !important;
      color: var(--nlm-text-secondary-text) !important;
    }

    /* Jawaban: teks bersambung ala naskah, tanpa kartu. */
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
      font-family: var(--ot-serif) !important;
      color: var(--nlm-text-body-text) !important;
    }
    html body .to-user-message-card-content b,
    html body .to-user-message-card-content strong {
      font-weight: 600 !important;
      color: var(--nlm-text-titles-and-labels) !important;
    }
    html body .to-user-message-card-content a {
      color: inherit !important;
      text-decoration: underline !important;
      text-underline-offset: 3px !important;
    }
    html body .to-user-message-card-content table { border-collapse: collapse !important; }
    html body .to-user-message-card-content th,
    html body .to-user-message-card-content td {
      border: 1px solid var(--nlm-stroke-default) !important;
      padding: 8px 12px !important;
      font-family: var(--ot-sans) !important;
    }

    /* Rujukan di dalam jawaban: kapsul netral. */
    html body [class*="citation-marker" i],
    html body [class*="citation-button" i] {
      background: light-dark(#F0F0F0, #353535) !important;
      color: var(--nlm-text-secondary-text) !important;
      border: 1px solid var(--nlm-stroke-default) !important;
      border-radius: 999px !important;
      font-family: var(--ot-sans) !important;
    }

    /* Tahap berpikir: satu baris tenang, tanpa ikon dan kilau Google. */
    html body .thinking-chain__static-icon,
    html body .thinking-chain__lottie-icon { display: none !important; }
    html body .thinking-chain { margin-block-end: .5rem !important; }
    html body .thinking-chain__header { padding: 2px 0 !important; border-radius: 6px !important; }
    html body .thinking-chain__header:hover { background: transparent !important; }
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
      letter-spacing: .02em;
      color: var(--nlm-text-secondary-text);
    }
    html body .thinking-chain__title.is-loading::after {
      content: var(--ot-label-thinking, "Berpikir…");
      animation: ot-breathe 1.8s ease-in-out infinite;
    }
    @keyframes ot-breathe { 0%, 100% { opacity: .35; } 50% { opacity: .95; } }
    html body .thinking-chain__expand-btn { opacity: .55 !important; transform: scale(.85); }

    /* Elemen khas Google yang tidak perlu. */
    html body .date-separator,
    html body .selected-num-container,
    html body .chat-panel-top-fade,
    html body .chat-panel-bottom-fade { display: none !important; }

    /* Kolom tanya. */
    html body .input-group {
      background: var(--nlm-fills-surface-panel) !important;
      border: 1px solid var(--nlm-stroke-default) !important;
      border-radius: 18px !important;
      box-shadow: none !important;
    }
    html body .input-group:focus-within { border-color: var(--nlm-stroke-focus) !important; outline: none !important; }
    html body .query-box-input {
      font-family: var(--ot-sans) !important;
      color: var(--nlm-text-body-text) !important;
      caret-color: var(--nlm-text-titles-and-labels) !important;
    }
    html body .submit-button.nb-button-type-filled button {
      background: var(--nlm-ctas-buttons-primary) !important;
      color: var(--nlm-cta-text-and-icon-primary) !important;
      border-radius: 999px !important;
    }
    html body .submit-button.nb-button-type-filled button mat-icon { color: var(--nlm-cta-text-and-icon-primary) !important; }
    html body .submit-button.nb-button-disabled button { opacity: .28 !important; }

    /* Tombol turun ke bawah. */
    html body .jump-to-bottom-button {
      background: var(--nlm-fills-surface-panel) !important;
      color: var(--nlm-text-titles-and-labels) !important;
      border: 1px solid var(--nlm-stroke-default) !important;
      box-shadow: none !important;
    }

    /* Dialog dan menu bawaan Google yang sesekali tampil: serasi dengan aplikasi. */
    html body .mat-mdc-dialog-surface { border-radius: 20px !important; box-shadow: none !important; border: 1px solid var(--nlm-stroke-default) !important; }
    html body .configure-user-settings-container .header-title { font-family: var(--ot-serif) !important; }
    html body .configure-user-settings-container .submit-button {
      background: var(--nlm-ctas-buttons-primary) !important;
      color: var(--nlm-cta-text-and-icon-primary) !important;
      border-radius: 999px !important;
    }

    /* Saat OpenTurath mengganti bahasa lewat lembar native, dialog Google tidak boleh terlihat. */
    html.ot-opening-language .cdk-overlay-container { opacity: 0 !important; pointer-events: none !important; }
  `;

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
      root.style.setProperty('--ot-label-thinking', JSON.stringify(L.thinking));
      root.style.setProperty('--ot-label-thought', JSON.stringify(L.thought));
    } catch (_) {}
  }

  function apply() { applyStyle(); }
  window.otSkinApply = apply;
  apply();

  if (!window.__otSkinObserver) {
    let queued = false;
    window.__otSkinObserver = new MutationObserver(() => {
      if (queued) return;
      queued = true;
      requestAnimationFrame(() => { queued = false; apply(); });
    });
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
                    waitFor(() => (document.querySelector('configure-user-settings') ? null : true), () => finish(true), 'save');
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
