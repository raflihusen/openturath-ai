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

# ==================== DOKUMEN 1: KATALOG APLIKASI MOBILE (2 HALAMAN SEMPURNA) ====================
html_katalog = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Katalog Aplikasi Mobile & Layanan Digital - OpenTurath AI</title>
  <style>
    @page {{
      size: A4;
      margin: 14mm 15mm 14mm 15mm;
      @bottom-right {{
        content: "Halaman " counter(page) " dari " counter(pages) " — Katalog Aplikasi Mobile OpenTurath AI";
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 7.8pt;
        color: #718096;
      }}
    }}
    * {{ box-sizing: border-box; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      color: #1A202C;
      margin: 0; padding: 0;
      font-size: 8.8pt;
      line-height: 1.45;
    }}
    .header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2.5px solid #0D201A;
      padding-bottom: 10px;
      margin-bottom: 14px;
    }}
    .logo-area {{
      display: flex;
      align-items: center;
      gap: 12px;
    }}
    .logo-img {{
      width: 48px;
      height: 48px;
      border-radius: 8px;
      background: #0D201A;
      padding: 3px;
    }}
    .brand-title {{
      font-size: 17pt;
      font-weight: 800;
      color: #0D201A;
      margin: 0;
      letter-spacing: -0.5px;
    }}
    .brand-subtitle {{
      font-size: 8.2pt;
      color: #4A5568;
      margin: 2px 0 0 0;
    }}
    .doc-meta {{
      text-align: right;
      font-size: 8pt;
      color: #4A5568;
    }}
    .badge {{
      display: inline-block;
      background: #0D201A;
      color: #F59E0B;
      font-weight: 700;
      font-size: 7.5pt;
      padding: 2.5px 8px;
      border-radius: 4px;
      margin-bottom: 3px;
    }}
    h2 {{
      font-size: 11pt;
      font-weight: 700;
      color: #0D201A;
      border-left: 3.5px solid #D97706;
      padding-left: 8px;
      margin: 14px 0 8px 0;
    }}
    .info-box {{
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 9px 12px;
      margin-bottom: 12px;
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      margin: 10px 0 14px 0;
      font-size: 8.4pt;
    }}
    th, td {{
      border: 1px solid #CBD5E0;
      padding: 7px 9px;
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
      font-size: 9pt;
      white-space: nowrap;
    }}
    .app-preview-grid {{
      display: grid;
      grid-template-columns: 1.15fr 1fr 1fr;
      gap: 14px;
      align-items: start;
      margin: 10px 0 14px 0;
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 12px;
    }}
    .ss-frame {{
      border: 2px solid #0D201A;
      border-radius: 8px;
      overflow: hidden;
      box-shadow: 0 4px 6px rgba(0,0,0,0.15);
      background: #000;
    }}
    .ss-frame img {{
      width: 100%;
      display: block;
    }}
    .caption {{
      font-size: 7.5pt;
      color: #4A5568;
      text-align: center;
      margin-top: 5px;
      font-weight: 600;
    }}
    .feature-card {{
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 9px 12px;
      margin-bottom: 10px;
      background: #FFFFFF;
    }}
    .page-break {{ page-break-after: always; }}
    .footer-box {{
      font-size: 7.5pt;
      color: #718096;
      border-top: 1px solid #E2E8F0;
      padding-top: 8px;
      margin-top: 14px;
      text-align: center;
    }}
  </style>
</head>
<body>

  <!-- ==================== HALAMAN 1: SHOWCASE APLIKASI SMARTPHONE ==================== -->
  <div class="header">
    <div class="logo-area">
      <img src="data:image/png;base64,{logo_b64}" class="logo-img" alt="OpenTurath AI">
      <div>
        <h1 class="brand-title">OpenTurath AI</h1>
        <p class="brand-subtitle">Aplikasi Smartphone Android & Khazanah Kitab Kuning Berbasis Artificial Intelligence</p>
      </div>
    </div>
    <div class="doc-meta">
      <span class="badge">LAMPIRAN 1: KATALOG APLIKASI</span><br>
      Produk Utama: <strong>Aplikasi Mobile Android (APK)</strong><br>
      Portal Unduhan: <strong>open-turath.web.app</strong><br>
      Mata Uang: <strong>Indonesian Rupiah (IDR)</strong>
    </div>
  </div>

  <h2>1. Profil Produk Utama: Aplikasi Mobile OpenTurath AI</h2>
  <div class="info-box">
    <p style="margin:0 0 5px 0;"><strong>Bentuk Produk:</strong> Aplikasi Mobile Smartphone Android (Native Flutter) & Layanan Cloud AI Syariah.</p>
    <p style="margin:0 0 5px 0;"><strong>Pemilik / Pengembang:</strong> Rafli Maulana Husen (OpenTurath AI Team).</p>
    <p style="margin:0 0 5px 0;"><strong>Deskripsi Aplikasi:</strong> OpenTurath AI adalah aplikasi mobile yang dirancang khusus untuk mempermudah santri, ustadz, dan akademisi dalam menelaah, mencari ibarah, serta memahami literatur kitab kuning klasik (fikih, hadis, tafsir, nahwu) menggunakan kecerdasan buatan (AI) terkurasi. Berkas installer aplikasi Android resmi didistribusikan melalui <code>https://open-turath.web.app/download.html</code>.</p>
    <p style="margin:0;"><strong>Model Monetisasi:</strong> Pengguna dapat memasang aplikasi di ponsel secara cuma-cuma, kemudian mengaktifkan <em>In-App Membership</em> (Paket Akses Modul AI) melalui pembayaran resmi Midtrans.</p>
  </div>

  <h2>2. Tampilan Nyata Antarmuka Aplikasi di Smartphone (Android Screenshots)</h2>
  <div class="app-preview-grid">
    <div>
      <h3 style="font-size:9.2pt; margin:0 0 8px 0; color:#0D201A;">Fitur Unggulan pada Aplikasi:</h3>
      <ul style="margin:0 0 0 14px; padding:0; font-size:8.2pt; line-height:1.5;">
        <li><strong>Layar Beranda (Dashboard):</strong> Menampilkan kalender Hijriah otomatis, jadwal kajian, kolom pencarian matan cepat, dan navigasi kajian lintas madzhab.</li>
        <li><strong>Bilik Asisten AI Spesialis:</strong> Asisten riset berbasis korpus kitab induk Syafi'iyah, Nahwu-Sharaf, dan Hadis dengan kemampuan salin kutipan instan.</li>
        <li><strong>Bilik Eksklusif Fikih Tahawwulat:</strong> Terdiri dari 4 Bilik Keilmuan: Al-Muhaqqiq (Matan), Al-Bayan (Konsep), Al-Mukhtabir (Ujian Interaktif), dan Al-Habib (Arsip Muhadharah).</li>
        <li><strong>Desain Ramah Mata (The Quiet Scholar):</strong> Nuansa Deep Emerald Twilight yang hening, elegan, dan bebas gangguan iklan.</li>
      </ul>
    </div>

    <div>
      <div class="ss-frame">
        <img src="data:image/jpeg;base64,{ss_beranda_b64}" alt="Layar Beranda Smartphone">
      </div>
      <div class="caption">Layar Beranda Aplikasi Android</div>
    </div>

    <div>
      <div class="ss-frame">
        <img src="data:image/jpeg;base64,{ss_tahawwulat_b64}" alt="Layar Riset Smartphone">
      </div>
      <div class="caption">Bilik Riset & Tahawwulat di HP</div>
    </div>
  </div>

  <div class="page-break"></div>

  <!-- ==================== HALAMAN 2: DAFTAR HARGA IN-APP RESMI ==================== -->
  <div class="header">
    <div class="logo-area">
      <img src="data:image/png;base64,{logo_b64}" class="logo-img" alt="OpenTurath AI">
      <div>
        <h1 class="brand-title">OpenTurath AI</h1>
        <p class="brand-subtitle">Daftar Resmi Paket Langganan In-App Membership (Aplikasi Android)</p>
      </div>
    </div>
    <div class="doc-meta">
      <strong>Halaman 2: Rincian Paket & Harga IDR</strong>
    </div>
  </div>

  <h2>3. Katalog Resmi Paket Langganan In-App (IDR / Rupiah)</h2>
  <p style="margin:0 0 8px 0;">Pengguna dapat memilih durasi langganan langsung dari menu Langganan di aplikasi smartphone. Seluruh tagihan tertera secara transparan dalam mata uang <strong>Indonesian Rupiah (IDR)</strong>:</p>

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
        <td>Membuka akses AI Spesialis terpilih di aplikasi, pencarian ibarah kitab cepat, riwayat konsultasi.</td>
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

  <h2>4. Spesifikasi Teknis & Hak Akses Pengguna Aplikasi</h2>
  <div class="feature-card">
    <p style="margin:0 0 5px 0;"><strong>A. Integrasi In-App Checkout:</strong> Pembayaran dilakukan langsung dari dalam aplikasi mobile via Midtrans Snap (QRIS Dinamis & Virtual Account Bank) tanpa harus meninggalkan smartphone.</p>
    <p style="margin:0 0 5px 0;"><strong>B. Sinkronisasi Akun Otomatis:</strong> Hak akses terikat pada akun Google pengguna dan tersinkronisasi secara real-time melalui cloud database.</p>
    <p style="margin:0;"><strong>C. Pembaruan Rutin:</strong> Pengguna aktif secara berkala menerima pembaruan database kitab dan penambahan asisten ilmiah tanpa biaya tambahan.</p>
  </div>

  <h2>5. Informasi Pembayaran & Layanan Konsumen</h2>
  <div class="info-box">
    <p style="margin:0 0 4px 0;"><strong>Rentang Harga Jual Aplikasi:</strong> <strong>IDR 49.000 s.d. IDR 2.000.000</strong></p>
    <p style="margin:0 0 4px 0;"><strong>Kanal Pembayaran Resmi:</strong> QRIS Dinamis (GoPay, OVO, ShopeePay, BCA QR) & Virtual Account Bank (BCA, Mandiri, BNI, BRI, Permata) via Midtrans.</p>
    <p style="margin:0 0 4px 0;"><strong>Kebijakan Pengembalian Dana:</strong> Tersedia di <a href="https://open-turath.web.app/refund.html">https://open-turath.web.app/refund.html</a></p>
    <p style="margin:0;"><strong>Kontak Customer Support:</strong> Email: <code>admin@openturath.com</code> | WhatsApp: <code>+62 812-9297-9189</code></p>
  </div>

  <div class="footer-box">
    Dokumen Resmi Lampiran 1: Katalog Aplikasi Mobile — OpenTurath AI © 2026. Disusun untuk verifikasi onboarding merchant Midtrans.
  </div>
</body>
</html>
"""

p1_html = '/Users/apple/Downloads/ramadhan/01_KATALOG_PRODUK_OPENTURATH.html'
p1_pdf = '/Users/apple/Downloads/ramadhan/01_KATALOG_PRODUK_OPENTURATH.pdf'

with open(p1_html, 'w', encoding='utf-8') as f:
    f.write(html_katalog)

cmd = [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '--headless',
    '--disable-gpu',
    '--no-pdf-header-footer',
    f'--print-to-pdf={p1_pdf}',
    p1_html
]
subprocess.run(cmd, check=True)
d1 = fitz.open(p1_pdf)
print(f"NEW 01_KATALOG_PRODUK_OPENTURATH.pdf: EXACTLY {len(d1)} pages!")
