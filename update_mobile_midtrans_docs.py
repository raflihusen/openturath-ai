import base64
import subprocess
import os
import fitz

with open('/Users/apple/Downloads/ramadhan/openturath_ai/public/logo_cropped_sig.png', 'rb') as f:
    logo_b64 = base64.b64encode(f.read()).decode('utf-8')

with open('/Users/apple/Downloads/ramadhan/app_screenshot_beranda.jpg', 'rb') as f:
    ss_beranda_b64 = base64.b64encode(f.read()).decode('utf-8')

with open('/Users/apple/Downloads/ramadhan/app_screenshot_tahawwulat.jpg', 'rb') as f:
    ss_tahawwulat_b64 = base64.b64encode(f.read()).decode('utf-8')

# ==================== DOKUMEN 1: KATALOG APLIKASI MOBILE & LAYANAN DIGITAL ====================
html_katalog = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Katalog Aplikasi Mobile & Layanan Digital - OpenTurath AI</title>
  <style>
    @page {{
      size: A4;
      margin: 12mm 14mm 12mm 14mm;
      @bottom-right {{
        content: "Halaman " counter(page) " dari " counter(pages) " — Katalog Aplikasi Mobile OpenTurath AI";
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 7.5pt;
        color: #718096;
      }}
    }}
    * {{ box-sizing: border-box; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      color: #1A202C;
      margin: 0; padding: 0;
      font-size: 8.6pt;
      line-height: 1.4;
    }}
    .header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2.5px solid #0D201A;
      padding-bottom: 8px;
      margin-bottom: 12px;
    }}
    .logo-area {{
      display: flex;
      align-items: center;
      gap: 10px;
    }}
    .logo-img {{
      width: 44px;
      height: 44px;
      border-radius: 8px;
      background: #0D201A;
      padding: 3px;
    }}
    .brand-title {{
      font-size: 16pt;
      font-weight: 800;
      color: #0D201A;
      margin: 0;
      letter-spacing: -0.5px;
    }}
    .brand-subtitle {{
      font-size: 8pt;
      color: #4A5568;
      margin: 2px 0 0 0;
    }}
    .doc-meta {{
      text-align: right;
      font-size: 7.8pt;
      color: #4A5568;
    }}
    .badge {{
      display: inline-block;
      background: #0D201A;
      color: #F59E0B;
      font-weight: 700;
      font-size: 7.2pt;
      padding: 2px 7px;
      border-radius: 4px;
      margin-bottom: 2px;
    }}
    h2 {{
      font-size: 10.5pt;
      font-weight: 700;
      color: #0D201A;
      border-left: 3.5px solid #D97706;
      padding-left: 7px;
      margin: 12px 0 6px 0;
    }}
    .info-box {{
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 8px 12px;
      margin-bottom: 10px;
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      margin: 6px 0 10px 0;
      font-size: 8pt;
    }}
    th, td {{
      border: 1px solid #CBD5E0;
      padding: 5px 8px;
      text-align: left;
    }}
    th {{
      background: #0D201A;
      color: #FFFFFF;
      font-weight: 600;
    }}
    tr:nth-child(even) {{ background: #F8FAFC; }}
    .price-tag {{
      font-weight: 700;
      color: #B45309;
      font-size: 8.8pt;
      white-space: nowrap;
    }}
    .app-preview-grid {{
      display: grid;
      grid-template-columns: 1.2fr 1fr 1fr;
      gap: 12px;
      align-items: start;
      margin: 8px 0 12px 0;
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 10px;
    }}
    .ss-frame {{
      border: 2px solid #0D201A;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 4px 6px rgba(0,0,0,0.1);
      background: #000;
    }}
    .ss-frame img {{
      width: 100%;
      display: block;
    }}
    .caption {{
      font-size: 7.2pt;
      color: #4A5568;
      text-align: center;
      margin-top: 4px;
      font-weight: 600;
    }}
    .page-break {{ page-break-after: always; }}
    .footer-box {{
      font-size: 7.2pt;
      color: #718096;
      border-top: 1px solid #E2E8F0;
      padding-top: 6px;
      margin-top: 10px;
      text-align: center;
    }}
  </style>
</head>
<body>

  <!-- ==================== HALAMAN 1 ==================== -->
  <div class="header">
    <div class="logo-area">
      <img src="data:image/png;base64,{logo_b64}" class="logo-img" alt="OpenTurath AI">
      <div>
        <h1 class="brand-title">OpenTurath AI</h1>
        <p class="brand-subtitle">Aplikasi Mobile Android & Khazanah Kitab Kuning Berbasis Artificial Intelligence</p>
      </div>
    </div>
    <div class="doc-meta">
      <span class="badge">LAMPIRAN 1: KATALOG APLIKASI</span><br>
      Produk: <strong>Aplikasi Mobile Android (APK & PWA)</strong><br>
      Portal Resmi: <strong>open-turath.web.app</strong><br>
      Mata Uang: <strong>Indonesian Rupiah (IDR)</strong>
    </div>
  </div>

  <h2>1. Profil Produk Utama: Aplikasi Mobile OpenTurath AI</h2>
  <div class="info-box">
    <p style="margin:0 0 4px 0;"><strong>Bentuk Produk:</strong> Aplikasi Mobile Android (Native Flutter) & Layanan Cloud AI Syariah (SaaS).</p>
    <p style="margin:0 0 4px 0;"><strong>Pengembang / Pemilik:</strong> Rafli Maulana Husen (OpenTurath AI Dev Team).</p>
    <p style="margin:0 0 4px 0;"><strong>Deskripsi Aplikasi:</strong> OpenTurath AI adalah aplikasi smartphone yang dirancang khusus untuk mempermudah santri, ustadz, dan akademisi dalam menelaah, mencari ibarah, serta memahami kitab-kitab kuning klasik secara cepat dengan asistensi kecerdasan buatan (AI). Aplikasi ini didistribusikan secara resmi melalui unduhan berkas APK di <code>https://open-turath.web.app/download.html</code> serta Web App.</p>
    <p style="margin:0;"><strong>Model Monetisasi:</strong> Pengguna dapat mengunduh dan mencoba aplikasi, kemudian membeli <em>In-App Membership</em> (Paket Langganan Akses Modul AI) dengan durasi 1 Bulan, 6 Bulan, atau 1 Tahun menggunakan pembayaran resmi Midtrans.</p>
  </div>

  <h2>2. Tampilan Nyata Antarmuka Aplikasi Mobile (Smartphone Screenshots)</h2>
  <div class="app-preview-grid">
    <div>
      <h3 style="font-size:9pt; margin:0 0 6px 0; color:#0D201A;">Fitur Utama di Layar Smartphone:</h3>
      <ul style="margin:0 0 0 14px; padding:0; font-size:8pt; line-height:1.45;">
        <li><strong>Layar Beranda (Dashboard):</strong> Menampilkan jadwal kajian, kalender Hijriah, pencarian matan cepat, dan navigasi bidang keilmuan (Fikih, Hadis, Tafsir, Akidah).</li>
        <li><strong>Bilik Asisten AI Spesialis:</strong> Chatbot pintar berbasis korpus kitab induk Syafi'iyah, Nahwu-Sharaf, dan Hadis dengan fitur salin ibarah instan.</li>
        <li><strong>Korpus Eksklusif Fikih Tahawwulat:</strong> Terdiri dari 4 Bilik Keilmuan: Al-Muhaqqiq (Teks Matan), Al-Bayan (Konsep), Al-Mukhtabir (Ujian Interaktif), dan Al-Habib (Arsip Muhadharah).</li>
        <li><strong>Mode Baca Hening (The Quiet Scholar):</strong> Desain antarmuka malam bernuansa Deep Emerald Twilight yang nyaman dan bebas dari iklan komersial.</li>
      </ul>
    </div>

    <div>
      <div class="ss-frame">
        <img src="data:image/jpeg;base64,{ss_beranda_b64}" alt="Layar Beranda Aplikasi">
      </div>
      <div class="caption">Layar Beranda Aplikasi Mobile</div>
    </div>

    <div>
      <div class="ss-frame">
        <img src="data:image/jpeg;base64,{ss_tahawwulat_b64}" alt="Layar Asisten & Tahawwulat">
      </div>
      <div class="caption">Bilik Riset & Tahawwulat</div>
    </div>
  </div>

  <h2>3. Katalog Resmi Paket Langganan In-App (IDR / Rupiah)</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 27%;">Nama Paket Layanan</th>
        <th style="width: 19%;">Harga Resmi (IDR)</th>
        <th style="width: 14%;">Masa Aktif</th>
        <th style="width: 40%;">Fasilitas yang Didapatkan di Aplikasi</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Modul Riset: Thalib 1M</strong></td>
        <td class="price-tag">Rp 49.000</td>
        <td>1 Bulan</td>
        <td>Membuka gembok AI Spesialis terpilih di aplikasi, pencarian ibarah kitab cepat, riwayat konsultasi.</td>
      </tr>
      <tr>
        <td><strong>Modul Riset: Thalib 6M</strong></td>
        <td class="price-tag">Rp 299.000</td>
        <td>6 Bulan</td>
        <td>Akses modul spesialis 6 bulan penuh di aplikasi, prioritas server riset tinggi, ekspor catatan riset.</td>
      </tr>
      <tr>
        <td><strong>Modul Riset: Bahits 1Y</strong></td>
        <td class="price-tag">Rp 499.000</td>
        <td>1 Tahun</td>
        <td>Akses 1 tahun penuh, fitur pembanding ibarah lintas madzhab, dukungan konsultasi karya ilmiah/skripsi.</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 1 Bulan</strong></td>
        <td class="price-tag">Rp 300.000</td>
        <td>1 Bulan</td>
        <td>Membuka seluruh 4 Bilik: Al-Muhaqqiq (Matan), Al-Bayan (Konsep), Al-Mukhtabir (Ujian), Al-Habib (Arsip).</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 6 Bulan</strong></td>
        <td class="price-tag">Rp 1.500.000</td>
        <td>6 Bulan</td>
        <td>Akses 4 Bilik Keilmuan selama 6 bulan + pembaruan berkala korpus tanda-tanda akhir zaman di aplikasi.</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 1 Tahun</strong></td>
        <td class="price-tag">Rp 2.000.000</td>
        <td>1 Tahun</td>
        <td>Akses komprehensif 1 tahun penuh seluruh khazanah ilmiah dan rekaman muhadharah bersanad di aplikasi.</td>
      </tr>
    </tbody>
  </table>

  <h2>4. Informasi Pembayaran & Layanan Pelanggan</h2>
  <div class="info-box">
    <p style="margin:0 0 3px 0;"><strong>Rentang Harga Jual Aplikasi:</strong> <strong>IDR 49.000 s.d. IDR 2.000.000</strong></p>
    <p style="margin:0 0 3px 0;"><strong>Metode Pembayaran Resmi:</strong> Terintegrasi langsung di aplikasi via Midtrans (QRIS Dinamis & Virtual Account Bank).</p>
    <p style="margin:0 0 3px 0;"><strong>Kebijakan Pengembalian Dana:</strong> Berlaku 3x24 jam jika terjadi kegagalan aktivasi in-app (<a href="https://open-turath.web.app/refund.html">open-turath.web.app/refund.html</a>).</p>
    <p style="margin:0;"><strong>Kontak Bantuan Pengguna:</strong> Email: <code>admin@openturath.com</code> | WhatsApp: <code>+62 812-9297-9189</code></p>
  </div>

  <div class="footer-box">
    Dokumen Resmi Lampiran 1: Katalog Aplikasi Mobile — OpenTurath AI © 2026. Disusun untuk verifikasi onboarding merchant Midtrans.
  </div>
</body>
</html>
"""

# ==================== DOKUMEN 2: FLOW TRANSAKSI IN-APP CHECKOUT MIDTRANS ====================
html_flow = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Dokumen Flow Transaksi In-App Midtrans - OpenTurath AI</title>
  <style>
    @page {{
      size: A4;
      margin: 12mm 14mm 12mm 14mm;
      @bottom-right {{
        content: "Halaman 1 dari 1 — Alur Transaksi In-App Checkout Midtrans";
        font-family: -apple-system, sans-serif;
        font-size: 7.5pt;
        color: #718096;
      }}
    }}
    * {{ box-sizing: border-box; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      color: #1A202C;
      margin: 0; padding: 0;
      font-size: 8.6pt;
      line-height: 1.4;
    }}
    .header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2.5px solid #0D201A;
      padding-bottom: 8px;
      margin-bottom: 12px;
    }}
    .logo-area {{
      display: flex;
      align-items: center;
      gap: 10px;
    }}
    .logo-img {{
      width: 44px;
      height: 44px;
      border-radius: 8px;
      background: #0D201A;
      padding: 3px;
    }}
    .brand-title {{
      font-size: 16pt;
      font-weight: 800;
      color: #0D201A;
      margin: 0;
      letter-spacing: -0.5px;
    }}
    .brand-subtitle {{
      font-size: 8pt;
      color: #4A5568;
      margin: 2px 0 0 0;
    }}
    .doc-meta {{
      text-align: right;
      font-size: 7.8pt;
      color: #4A5568;
    }}
    .badge {{
      display: inline-block;
      background: #0D201A;
      color: #F59E0B;
      font-weight: 700;
      font-size: 7.2pt;
      padding: 2px 7px;
      border-radius: 4px;
      margin-bottom: 2px;
    }}
    h2 {{
      font-size: 10.5pt;
      font-weight: 700;
      color: #0D201A;
      border-left: 3.5px solid #D97706;
      padding-left: 7px;
      margin: 12px 0 6px 0;
    }}
    .step-grid {{
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 8px;
      margin: 8px 0 12px 0;
    }}
    .step-card {{
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 8px 10px;
      background: #F8FAFC;
    }}
    .step-header {{
      display: flex;
      align-items: center;
      gap: 6px;
      margin-bottom: 3px;
    }}
    .step-num {{
      width: 20px;
      height: 20px;
      background: #0D201A;
      color: #F59E0B;
      font-weight: 800;
      font-size: 8pt;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      text-align: center;
      line-height: 20px;
    }}
    .step-title {{
      font-weight: 700;
      font-size: 8.8pt;
      color: #0D201A;
    }}
    .mockup-container {{
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 8px;
      margin: 8px 0 12px 0;
    }}
    .mockup-item {{
      border: 1px solid #CBD5E0;
      border-radius: 6px;
      padding: 8px 6px;
      background: #FFFFFF;
      text-align: center;
      font-size: 7.5pt;
    }}
    .mockup-phone {{
      background: #0D201A;
      color: #FFFFFF;
      border-radius: 6px;
      padding: 8px 6px;
      margin: 6px 0;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      font-size: 6.8pt;
      text-align: left;
      line-height: 1.35;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }}
    .mockup-phone .gold {{ color: #F59E0B; font-weight: bold; }}
    .mockup-phone .green {{ color: #10B981; font-weight: bold; }}
    .mockup-phone .blue {{ color: #60A5FA; }}
    .info-box {{
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 8px 12px;
      margin-bottom: 10px;
    }}
    .footer-box {{
      font-size: 7.2pt;
      color: #718096;
      border-top: 1px solid #E2E8F0;
      padding-top: 6px;
      margin-top: 10px;
      text-align: center;
    }}
  </style>
</head>
<body>
  <div class="header">
    <div class="logo-area">
      <img src="data:image/png;base64,{logo_b64}" class="logo-img" alt="OpenTurath AI">
      <div>
        <h1 class="brand-title">OpenTurath AI</h1>
        <p class="brand-subtitle">Alur Transaksi In-App Checkout Midtrans pada Aplikasi Smartphone Android</p>
      </div>
    </div>
    <div class="doc-meta">
      <span class="badge">LAMPIRAN 2: FLOW TRANSAKSI IN-APP</span><br>
      Aplikasi: <strong>OpenTurath AI (Android APK)</strong><br>
      Tipe Dokumen: <strong>Flow Transaksi Step-by-Step</strong><br>
      Integrasi: <strong>Midtrans Snap Webview / In-App SDK</strong>
    </div>
  </div>

  <h2>1. Penjelasan Alur Transaksi In-App Pemesanan (End-to-End di Smartphone)</h2>
  <div class="step-grid">
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">1</div>
        <div class="step-title">Pilih Paket di Layar Smartphone</div>
      </div>
      <p style="margin:0;">Pengguna membuka aplikasi OpenTurath AI di HP Android, membuka menu <strong>Langganan</strong> atau mengklik bilik AI yang terkunci, lalu memilih durasi keanggotaan (1 Bulan, 6 Bulan, atau 1 Tahun). Rincian fitur dan harga resmi IDR tampil langsung di layar HP.</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">2</div>
        <div class="step-title">Inisiasi Pembayaran Midtrans In-App</div>
      </div>
      <p style="margin:0;">Pengguna menekan tombol <strong>"Aktivasi Langganan"</strong> di dalam aplikasi. Aplikasi memanggil server backend OpenTurath untuk membuat token transaksi Midtrans Snap resmi dengan nominal yang terkunci.</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">3</div>
        <div class="step-title">Pop-up Midtrans di Dalam Aplikasi</div>
      </div>
      <p style="margin:0;">Jendela pembayaran Midtrans Snap muncul langsung di dalam aplikasi (in-app view). Pengguna memilih metode: <strong>QRIS Dinamis</strong> (tampil kode QR untuk di-screenshot/scan) atau <strong>Virtual Account Bank</strong> (tampil nomor VA bank resmi).</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">4</div>
        <div class="step-title">Verifikasi Real-Time & Gembok Terbuka</div>
      </div>
      <p style="margin:0;">Setelah user membayar, Midtrans mengirimkan sinyal HTTP Webhook secara real-time ke backend. Aplikasi Android mendeteksi perubahan status pembayaran secara instan dan langsung membuka seluruh gembok bilik AI!</p>
    </div>
  </div>

  <h2>2. Bukti Visual Tangkapan Layar Smartphone (In-App Step-by-Step)</h2>
  <div class="mockup-container">
    <!-- STEP 1 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Tahap 1: Di Aplikasi HP</strong>
      <div class="mockup-phone">
        <span class="gold">● OpenTurath Android</span><br>
        -----------------<br>
        <strong>Menu Langganan:</strong><br>
        (•) 1 Bulan: Rp 49.000<br>
        ( ) 6 Bulan: Rp 299.000<br>
        ( ) 1 Tahun: Rp 499.000<br>
        -----------------<br>
        <span class="green">[ Pilih Paket Ini ]</span>
      </div>
      <span>User pilih paket di smartphone</span>
    </div>

    <!-- STEP 2 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Tahap 2: Rincian Order</strong>
      <div class="mockup-phone">
        <span class="gold">● Konfirmasi Tagihan</span><br>
        -----------------<br>
        Paket: Thalib 1M<br>
        Total: <span class="gold">Rp 49.000</span><br>
        Metode:<br>
        [•] QRIS Dinamis<br>
        [ ] Virtual Account<br>
        -----------------<br>
        <span class="green">[ Bayar Sekarang ]</span>
      </div>
      <span>Verifikasi nominal IDR di HP</span>
    </div>

    <!-- STEP 3 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Tahap 3: Midtrans In-App</strong>
      <div class="mockup-phone">
        <span class="blue">● Midtrans Snap UI</span><br>
        -----------------<br>
        Tagihan: <strong>Rp 49.000</strong><br>
        <div style="background:#FFF; color:#000; padding:4px; text-align:center; margin:3px 0; font-size:6pt; font-weight:bold;">
          [ QRIS CODE AKTIF ]<br>
          ■■■■■■■■■■■■■■■<br>
          ■■   ■■   ■■<br>
          ■■■■■■■■■■■■■■■
        </div>
        Sisa Waktu: 14:59
      </div>
      <span>Pop-up Midtrans di dalam HP</span>
    </div>

    <!-- STEP 4 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Tahap 4: Sukses di HP</strong>
      <div class="mockup-phone">
        <span class="green">✔ Pembayaran Berhasil!</span><br>
        -----------------<br>
        Status: <span class="green">SETTLEMENT</span><br>
        Order: OT-202609-001<br>
        Masa Aktif:<br>
        <strong>16 Okt 2026</strong><br>
        -----------------<br>
        <span class="gold">[ Masuk Modul AI ]</span>
      </div>
      <span>Gembok fitur terbuka instan</span>
    </div>
  </div>

  <h2>3. Keamanan Transaksi In-App & Hak Konsumen</h2>
  <div class="info-box">
    <p style="margin:0 0 3px 0;"><strong>Enkripsi & Keamanan:</strong> Komunikasi data dari aplikasi mobile menggunakan protokol HTTPS TLS 1.3 dan verifikasi signature token Midtrans HMAC SHA-512.</p>
    <p style="margin:0 0 3px 0;"><strong>Kebijakan Pengembalian Dana:</strong> Jika terjadi kendala aktivasi pada aplikasi lebih dari 3x24 jam, dana dikembalikan penuh melalui prosedur resmi di <a href="https://open-turath.web.app/refund.html">open-turath.web.app/refund.html</a>.</p>
    <p style="margin:0;"><strong>Kontak Customer Support:</strong> Email: <code>admin@openturath.com</code> | WhatsApp: <code>+62 812-9297-9189</code></p>
  </div>

  <div class="footer-box">
    Dokumen Alur Transaksi In-App Checkout Midtrans — OpenTurath AI © 2026.
  </div>
</body>
</html>
"""

p1_html = '/Users/apple/Downloads/ramadhan/01_KATALOG_PRODUK_OPENTURATH.html'
p2_html = '/Users/apple/Downloads/ramadhan/02_DOKUMEN_FLOW_TRANSAKSI_MIDTRANS.html'
p1_pdf = '/Users/apple/Downloads/ramadhan/01_KATALOG_PRODUK_OPENTURATH.pdf'
p2_pdf = '/Users/apple/Downloads/ramadhan/02_DOKUMEN_FLOW_TRANSAKSI_MIDTRANS.pdf'

with open(p1_html, 'w', encoding='utf-8') as f:
    f.write(html_katalog)
with open(p2_html, 'w', encoding='utf-8') as f:
    f.write(html_flow)

for html, pdf in [(p1_html, p1_pdf), (p2_html, p2_pdf)]:
    cmd = [
        '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
        '--headless',
        '--disable-gpu',
        '--no-pdf-header-footer',
        f'--print-to-pdf={pdf}',
        html
    ]
    subprocess.run(cmd, check=True)
    d = fitz.open(pdf)
    print(f"Generated {pdf}: {len(d)} page(s)!")

print("Both mobile-app-centric documents compiled successfully!")
