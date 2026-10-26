# DOKUMENTASI LENGKAP STRUKTUR DOM GOOGLE NOTEBOOKLM (LIVE EXTRACTION)

Dokumen ini berisi pemetaan hierarki DOM (Document Object Model) lengkap dari sesi aktif Google NotebookLM (Angular SPA) yang diekstraksi langsung dari browser.

---

## 1. Berkas DOM Mentah (File HTML Asli)
Tersimpan di folder Downloads pengguna untuk diserahkan ke tim developer/pihak yang meminta:
1. **`/Users/apple/Downloads/NOTEBOOKLM_FULL_LIVE_DOM.html`** (1.86 MB)  
   *Seluruh struktur HTML halaman penuh dari `<html>` sampai `</html>`, termasuk `chat-panel`, `omnibar`, `query-box`, riwayat transkrip pesan pengguna dan model, serta seluruh CSS Angular.*
2. **`/Users/apple/Downloads/NOTEBOOKLM_LANGUAGE_DIALOG_DOM.html`** (3.3 KB)  
   *Struktur DOM modal dialog "Configure settings" (Output Language), mencakup elemen dropdown bahasa dan tombol `Save`.*
3. **`/Users/apple/Downloads/NOTEBOOKLM_SETTINGS_MODAL_DOM.html`** (6.8 KB)  
   *Struktur DOM menu panel pengaturan.*

---

## 2. Peta Selektor & Hierarki Komponen Utama

### A. Wadah Obrolan & Transkrip (Chat Panel)
```html
<chat-panel>
  <div class="chat-panel-content">
    <!-- Daftar pesan (Individual Message) -->
    <chat-message class="individual-message">
      <!-- PESAN DARI PENGGUNA (USER) -->
      <div class="from-user-container">
        <mat-card class="mat-mdc-card mdc-card from-user-message-card-content">
          <mat-card-content class="mat-mdc-card-content from-user-message-inner-content message-content">
            <div class="message-text-content mat-body-medium">
              <div class="md3-body-text">
                <p>Teks Pertanyaan Pengguna</p>
              </div>
            </div>
          </mat-card-content>
        </mat-card>
      </div>

      <!-- PESAN BALASAN DARI AI / MODEL -->
      <div class="to-user-container">
        <mat-card class="mat-mdc-card mdc-card to-user-message-card-content">
          <mat-card-content class="mat-mdc-card-content message-content to-user-message-inner-content">
            <div class="message-text-content mat-body-medium">
              
              <!-- Container Renderer Markdown -->
              <labs-tailwind-doc-viewer>
                <element-list-renderer>
                  
                  <!-- Blok Thinking Process (Rantai Berpikir) -->
                  <thinking-chain-view>
                    <div class="thinking-chain thinking-chain--collapsed">
                      <button class="thinking-chain__header">
                        <div class="thinking-chain__static-icon"></div>
                        <div class="thinking-chain__title-wrapper">
                          <span class="thinking-chain__title mat-body-medium">Thought for Xs</span>
                        </div>
                        <span class="thinking-chain__expand-btn">
                          <mat-icon class="google-symbols luminous-icon">expand_more</mat-icon>
                        </span>
                      </button>
                    </div>
                  </thinking-chain-view>

                  <!-- Paragraf Jawaban AI -->
                  <labs-tailwind-structural-element-view-v2>
                    <paragraph-element-view>
                      <div class="paragraph normal">
                        <span>Teks jawaban AI...</span>
                      </div>
                    </paragraph-element-view>
                  </labs-tailwind-structural-element-view-v2>

                </element-list-renderer>
              </labs-tailwind-doc-viewer>

            </div>
          </mat-card-content>
        </mat-card>

        <!-- Bilah Aksi Pesan (Salin, Jempol Baik/Buruk) -->
        <chat-actions>
          <button aria-label="Select this message" class="action-button kortex-select-button"></button>
          <button aria-label="Copy model response to clipboard" class="mdc-icon-button"></button>
          <button aria-label="Rate response as good" class="mdc-icon-button"></button>
          <button aria-label="Rate response as bad" class="mdc-icon-button"></button>
        </chat-actions>

      </div>
    </chat-message>
  </div>
</chat-panel>
```

---

### B. Wadah Input Pertanyaan (Composer / Query Box)
```html
<omnibar>
  <query-box>
    <div class="query-box-container">
      <!-- Input Textarea -->
      <textarea 
        class="cdk-textarea-autosize mat-mdc-autocomplete-trigger query-box-input chat-bidi-enabled field-sizing-enabled" 
        aria-label="Query box" 
        placeholder="Ask a question or create something"
        rows="1">
      </textarea>

      <!-- Tombol Kirim (Submit) -->
      <button 
        aria-label="Submit" 
        class="mdc-icon-button mat-mdc-icon-button submit-button" 
        type="button">
      </button>
    </div>
  </query-box>
</omnibar>
```

---

### C. Modal Dialog "Configure Settings" (Pilihan Bahasa Output)
```html
<div class="cdk-overlay-container">
  <div class="cdk-overlay-pane">
    <mat-dialog-container class="mat-mdc-dialog-container mdc-dialog" role="dialog">
      <div class="mat-mdc-dialog-inner-container">
        <div class="mat-mdc-dialog-surface">
          <configure-user-settings class="mat-mdc-dialog-component-host">
            <div class="configure-user-settings-container">
              
              <!-- Header Modal -->
              <div class="header">
                <div class="header-title mat-title-large">Configure settings</div>
                <button aria-label="Close user settings" class="mdc-icon-button">
                  <mat-icon>close</mat-icon>
                </button>
              </div>

              <!-- Konten Pemilihan Bahasa -->
              <form class="form">
                <div class="style-section">
                  <div class="style-section-title section-title mat-body-medium">
                    Choose your language override
                  </div>
                  <mat-select role="combobox" class="language-override-select">
                    <!-- Dropdown pilihan bahasa (Indonesia, Arab, English, dll) -->
                  </mat-select>
                </div>
              </form>

              <!-- Wadah Tombol Simpan (Save Button) -->
              <div class="save-container">
                <button 
                  type="submit" 
                  aria-label="Save settings" 
                  class="mdc-button mat-mdc-button-base submit-button mdc-button--unelevated mat-mdc-unelevated-button">
                  <span class="mdc-button__label">Save</span>
                </button>
              </div>

            </div>
          </configure-user-settings>
        </div>
      </div>
    </mat-dialog-container>
  </div>
</div>
```

---

## 3. Penyebab Pasti Tombol "Save" Hilang (terbukti dari DOM, 26 Okt 2026)
- Tombol di dialog berlabel `aria-label="Save settings"` dan tombol tutup berlabel `aria-label="Close user settings"`.
- Aturan penyembunyi di `notebook_ui_script.dart` (CSS `ensureStyles` dan daftar `removeTopToolbars` yang memberi gaya inline `!important`) memakai `button[aria-label*="Settings" i]`. Pencocokan "mengandung" itu ikut mengenai kedua tombol dialog, sehingga dialog tampil tanpa Save.
- Perbaikan: keempat selektor (`Settings`, `Setelan`, `Pengaturan`, `Notebook settings`) kini memakai pencocokan tepat (`="..." i`). Tombol gigi di header Google berlabel persis `Settings`, jadi tetap tersembunyi.
- Pencarian tombol pengaturan di `findSettingsButton()` tetap memakai `*=` karena hanya membaca, tidak menyembunyikan.

## 4. Kulit OpenTurath (`lib/core/notebook_skin.dart`, `notebook_fonts.dart`)
Mengikuti DESIGN.md: token warna `OTColors` (kanvas, permukaan, tonal, tinta, garis), Outfit untuk Latin, Scheherazade New untuk Arab, tanpa warna lain.
- **Token:** satu `<style id="ot-skin">` menimpa `--nlm-*` dan `--mat-sys-*` dengan `light-dark()` mengikuti `color-scheme` yang diatur skrip tema.
- **Huruf:** `notebook_fonts.dart` (dibuat oleh `tool/make_notebook_fonts.py`) menanam Outfit 400/600 dan Scheherazade New (subset woff2, ±130 KB) sebagai `@font-face` data URI dengan nama "OT Outfit" dan "OT Scheherazade". Outfit tidak punya glyph Arab, sehingga huruf Arab otomatis jatuh ke Scheherazade.
- **Pertanyaan:** permukaan tonal, garis 0,8, sudut 24 dengan sudut bawah-ujung 8 (sama dengan chat native).
- **Jawaban:** aliran terbuka tanpa kartu, Outfit `font-size-skala + 1`, mengikuti `--ot-font-size` dari penggeser ukuran huruf.
- **Ibarah:** `tagAnswers()` menandai `.paragraph` yang ≥ 60% huruf Arab dengan kelas `ot-ibarah` (kelas saja, teks tidak diubah). Tampil sebagai lembar naskah: latar tonal, bingkai ganda tipis (jadwal), Scheherazade 1,45× dengan tinggi baris 1,9, label "Ibarah" di tepi atas. Penanda butir bawaan Google dimatikan.
- **Kepala bagian** ("A. JAWABAN LANGSUNG:") menjadi label kapital kecil dengan garis pemisah (`ot-section`); **mode** ("▸Mode: …") menjadi pil (`ot-mode`).
- **Tahap berpikir:** lengkung bersarang yang sama dengan logo, splash, dan situs, menyala bergantian saat `.is-loading` (kelas `ot-thinking`); label "Berpikir…" lalu "Proses berpikir".
- **Kolom tanya** dan **tombol turun:** kapsul permukaan, garis 1,2, bayangan lembut seperti kolom tanya native. Penanda tanggal, hitungan sumber, dan fade atas-bawah disembunyikan.
- Placeholder kolom tanya sengaja tidak diubah: skrip inti menghapusnya dan mengamati atributnya, sehingga menimpanya membuat dua pengamat saling bertabrakan.
- Bahasa label dibaca dari `window._otLang` (diisi `_buildCloakScript`), bawaan `id`.

## 5. Penggantian Bahasa Jawaban Lewat Lembar Native
- `window.otSetOutputLanguage(aliases)` membuka menu pengaturan, memilih opsi bahasa di `configure-user-settings mat-select`, menekan Save, lalu mengembalikan `{ok, reason}`. Selama berjalan, `html.ot-opening-language` menyembunyikan seluruh `.cdk-overlay-container`.
- Bila gagal (menu, opsi, atau Save tidak ditemukan dalam 15 detik), kelas penyembunyi dilepas sehingga dialog Google terlihat (kini lengkap dengan Save), dan aplikasi menampilkan pesan.
- Sisi Flutter: `lib/widgets/output_language_sheet.dart` (Indonesia, English, العربية) dan `_showOutputLanguage` di `agent_multi_tab_room.dart` (memakai `callAsyncJavaScript`). Pilihan terakhir disimpan di `SharedPreferences` kunci `ot_output_language`.
