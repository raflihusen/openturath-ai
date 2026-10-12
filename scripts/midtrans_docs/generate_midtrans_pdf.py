import base64
import subprocess
import os

with open('/Users/apple/Downloads/ramadhan/openturath_ai/public/logo_cropped_sig.png', 'rb') as f:
    logo_b64 = base64.b64encode(f.read()).decode('utf-8')

html_content = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Katalog Produk & Alur Transaksi Midtrans - OpenTurath AI</title>
  <style>
    @page {{
      size: A4;
      margin: 14mm 15mm 14mm 15mm;
      @bottom-right {{
        content: "Halaman " counter(page) " dari " counter(pages);
        font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
        font-size: 8pt;
        color: #718096;
      }}
    }}
    * {{
      box-sizing: border-box;
    }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      color: #1A202C;
      margin: 0;
      padding: 0;
      background: #FFFFFF;
      font-size: 8.8pt;
      line-height: 1.4;
    }}
    .header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2px solid #0D201A;
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
      object-fit: contain;
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
      padding: 3px 8px;
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
    p {{
      margin: 0 0 6px 0;
    }}
    .info-box {{
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 8px 12px;
      margin-bottom: 12px;
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      margin: 8px 0 12px 0;
      font-size: 8.2pt;
    }}
    th, td {{
      border: 1px solid #CBD5E0;
      padding: 6px 9px;
      text-align: left;
    }}
    th {{
      background: #0D201A;
      color: #FFFFFF;
      font-weight: 600;
      font-size: 8.2pt;
    }}
    tr:nth-child(even) {{
      background: #F8FAFC;
    }}
    .price-tag {{
      font-weight: 700;
      color: #B45309;
      white-space: nowrap;
    }}
    .page-break {{
      page-break-after: always;
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
      margin-bottom: 4px;
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
    .footer-box {{
      font-size: 7.5pt;
      color: #4A5568;
      border-top: 1px solid #E2E8F0;
      padding-top: 8px;
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
        <p class="brand-subtitle">Platform Edukasi & Khazanah Kitab Kuning Berbasis Artificial Intelligence</p>
      </div>
    </div>
    <div class="doc-meta">
      <span class="badge">DOKUMEN ONBOARDING MIDTRANS</span><br>
      Website Resmi: <strong>open-turath.web.app</strong><br>
      Entitas: Perorangan (Rafli Maulana Husen)<br>
      Dokumen: <strong>Katalog Produk & Flow Transaksi</strong>
    </div>
  </div>

  <h2>1. Profil Bisnis & Deskripsi Layanan</h2>
  <div class="info-box">
    <p><strong>Nama Usaha/Platform:</strong> OpenTurath AI</p>
    <p><strong>Model Bisnis:</strong> Software as a Service (SaaS) / Platform Edukasi Riset Digital Keislaman</p>
    <p><strong>Website & Aplikasi:</strong> <a href="https://open-turath.web.app">https://open-turath.web.app</a> (PWA & Android APK)</p>
    <p><strong>Deskripsi Produk:</strong> OpenTurath AI adalah aplikasi asistensi riset keilmuan Islam interaktif yang membantu santri, akademisi, dan peneliti mengkaji korpus kitab kuning klasik (fikih, tafsir, hadis, nahwu). Pengguna berlangganan paket keanggotaan digital untuk mendapatkan kuota komputasi AI, pencarian ibarah akurat, dan konsultasi kitab klasik 24/7.</p>
  </div>

  <h2>2. Katalog Resmi Produk & Daftar Harga (IDR / Rupiah)</h2>
  <p>Berikut adalah daftar resmi paket langganan keanggotaan digital OpenTurath AI. Seluruh harga tertera dalam mata uang <strong>Indonesian Rupiah (IDR)</strong> tanpa biaya tersembunyi:</p>

  <table>
    <thead>
      <tr>
        <th style="width: 26%;">Paket Layanan</th>
        <th style="width: 19%;">Harga Resmi (IDR)</th>
        <th style="width: 15%;">Masa Aktif</th>
        <th style="width: 40%;">Fasilitas & Hak Akses</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Modul Spesialis: Thalib 1M</strong></td>
        <td class="price-tag">Rp 49.000</td>
        <td>1 Bulan</td>
        <td>Akses modul AI Asisten Spesialis terpilih (Fikih / Nahwu / Tafsir), riwayat pencarian matan, ekspor riset.</td>
      </tr>
      <tr>
        <td><strong>Modul Spesialis: Thalib 6M</strong></td>
        <td class="price-tag">Rp 299.000</td>
        <td>6 Bulan</td>
        <td>Akses modul AI Asisten selama 6 bulan, prioritas server riset tinggi, penyimpanan ibarah tanpa batas.</td>
      </tr>
      <tr>
        <td><strong>Modul Spesialis: Bahits 1Y</strong></td>
        <td class="price-tag">Rp 499.000</td>
        <td>1 Tahun</td>
        <td>Akses penuh 1 tahun kalender, modul komparasi lintas madzhab, dukungan konsultasi tesis/karya ilmiah.</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 1 Bulan</strong></td>
        <td class="price-tag">Rp 300.000</td>
        <td>1 Bulan</td>
        <td>Akses 4 Bilik Eksklusif: Al-Muhaqqiq (Matan), Al-Bayan (Konsep), Al-Mukhtabir (Ujian), Al-Habib (Arsip).</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 6 Bulan</strong></td>
        <td class="price-tag">Rp 1.500.000</td>
        <td>6 Bulan</td>
        <td>Akses 4 Bilik Keilmuan selama 6 bulan penuh + seluruh pembaharuan transkrip & sanad keilmuan.</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 1 Tahun</strong></td>
        <td class="price-tag">Rp 2.000.000</td>
        <td>1 Tahun</td>
        <td>Akses komprehensif 1 tahun penuh seluruh khazanah tanda-tanda akhir zaman dan metodologi ilmiah.</td>
      </tr>
    </tbody>
  </table>

  <h2>3. Ringkasan Rentang Harga & Metode Pembayaran</h2>
  <div class="info-box">
    <p><strong>Rentang Harga Jual:</strong> <strong>IDR 49.000 s.d. IDR 2.000.000</strong></p>
    <p><strong>Metode Pembayaran yang Diajukan (Midtrans):</strong></p>
    <ul style="margin: 3px 0 0 18px; padding: 0;">
      <li><strong>QRIS Dinamis (GoPay, ShopeePay, OVO, Dana, LinkAja, BCA QR, Mobile Banking seluruh Indonesia)</strong></li>
      <li><strong>Virtual Account Bank (BCA, Mandiri, BNI, BRI, Permata)</strong></li>
    </ul>
  </div>

  <div class="page-break"></div>

  <!-- ==================== HALAMAN 2 ==================== -->
  <div class="header">
    <div class="logo-area">
      <img src="data:image/png;base64,{logo_b64}" class="logo-img" alt="OpenTurath AI">
      <div>
        <h1 class="brand-title">OpenTurath AI</h1>
        <p class="brand-subtitle">Alur Transaksi End-to-End & Lampiran Screenshot Checkout Midtrans</p>
      </div>
    </div>
    <div class="doc-meta">
      <strong>Halaman 2: Alur Pembayaran & Bukti Visual</strong>
    </div>
  </div>

  <h2>4. Alur Transaksi End-to-End Pelanggan</h2>
  <div class="step-grid">
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">1</div>
        <div class="step-title">Pemilihan Paket di Aplikasi</div>
      </div>
      <p>Pengguna login ke aplikasi OpenTurath AI, membuka menu <strong>Langganan</strong>, melihat tabel rincian paket, dan memilih durasi langganan (1 Bulan / 6 Bulan / 1 Tahun) sesuai kebutuhan risetnya.</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">2</div>
        <div class="step-title">Inisiasi Pembayaran Midtrans</div>
      </div>
      <p>Pengguna menekan <strong>"Aktivasi Langganan"</strong>. Aplikasi meminta token pembayaran ke server backend yang memanggil API Midtrans (Snap/Core API). Total harga dalam IDR ditampilkan secara jelas.</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">3</div>
        <div class="step-title">Penyelesaian Pembayaran</div>
      </div>
      <p>Pengguna menyelesaikan pembayaran melalui pemindaian <strong>QRIS Dinamis</strong> (menggunakan m-banking / e-wallet apapun) atau transfer ke nomor <strong>Virtual Account Bank</strong> resmi yang disediakan Midtrans.</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">4</div>
        <div class="step-title">Verifikasi & Aktivasi Otomatis</div>
      </div>
      <p>Sistem Midtrans mengirim notifikasi HTTP Webhook secara real-time ke server OpenTurath. Status order seketika menjadi <code>settlement</code>, dan hak akses modul AI pengguna langsung aktif saat itu juga.</p>
    </div>
  </div>

  <h2>5. Bukti Visual Flow Transaksi Step-by-Step (Screenshot Checkout)</h2>
  <div class="mockup-container">
    <!-- STEP 1 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Langkah 1: Katalog</strong>
      <div class="mockup-phone">
        <span class="gold">● OpenTurath AI</span><br>
        -----------------<br>
        <strong>Pilih Paket:</strong><br>
        (•) 1 Bulan: Rp 49.000<br>
        ( ) 6 Bulan: Rp 299.000<br>
        ( ) 1 Tahun: Rp 499.000<br>
        -----------------<br>
        <span class="green">[ Pilih Paket Ini ]</span>
      </div>
      <span>User memilih paket & durasi</span>
    </div>

    <!-- STEP 2 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Langkah 2: Rincian</strong>
      <div class="mockup-phone">
        <span class="gold">● Konfirmasi Order</span><br>
        -----------------<br>
        Item: Modul Thalib 1M<br>
        Total: <span class="gold">Rp 49.000</span><br>
        Metode:<br>
        [•] QRIS (Semua E-Wallet)<br>
        [ ] Virtual Account<br>
        -----------------<br>
        <span class="green">[ Bayar Sekarang ]</span>
      </div>
      <span>Konfirmasi tagihan dalam IDR</span>
    </div>

    <!-- STEP 3 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Langkah 3: Midtrans</strong>
      <div class="mockup-phone">
        <span class="blue">● Midtrans Payment</span><br>
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
      <span>QRIS / VA Midtrans tampil</span>
    </div>

    <!-- STEP 4 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Langkah 4: Sukses</strong>
      <div class="mockup-phone">
        <span class="green">✔ Pembayaran Berhasil!</span><br>
        -----------------<br>
        Status: <span class="green">SETTLEMENT</span><br>
        Order: OT-202609-001<br>
        Masa Aktif:<br>
        <strong>16 Okt 2026</strong><br>
        -----------------<br>
        <span class="gold">[ Buka Modul AI ]</span>
      </div>
      <span>Akses fitur aktif instan</span>
    </div>
  </div>

  <h2>6. Layanan Bantuan, Kebijakan Privasi, dan Refund</h2>
  <div class="info-box">
    <p>OpenTurath AI berkomitmen penuh terhadap perlindungan konsumen dan regulasi Bank Indonesia:</p>
    <ul style="margin: 3px 0 0 18px; padding: 0;">
      <li><strong>Kebijakan Pengembalian Dana (Refund):</strong> <a href="https://open-turath.web.app/refund.html">https://open-turath.web.app/refund.html</a> (Proses refund jika terjadi kendala aktivasi dalam 3x24 jam).</li>
      <li><strong>Syarat & Ketentuan Layanan (Terms of Use):</strong> <a href="https://open-turath.web.app/terms.html">https://open-turath.web.app/terms.html</a></li>
      <li><strong>Kebijakan Privasi Data (Privacy Policy):</strong> <a href="https://open-turath.web.app/privacy.html">https://open-turath.web.app/privacy.html</a></li>
      <li><strong>Kontak Layanan Pelanggan (Customer Care):</strong> Email: <code>admin@openturath.com</code> | WhatsApp: <code>+62 812-9297-9189</code></li>
    </ul>
  </div>

  <div class="footer-box">
    Dokumen ini disusun untuk melengkapi verifikasi data susulan onboarding merchant Midtrans.<br>
    © 2026 OpenTurath AI. Seluruh hak cipta dilindungi undang-undang.
  </div>

</body>
</html>
"""

html_path = '/Users/apple/Downloads/ramadhan/DOKUMEN_ONBOARDING_MIDTRANS_OPENTURATH.html'
pdf_path = '/Users/apple/Downloads/ramadhan/DOKUMEN_ONBOARDING_MIDTRANS_OPENTURATH.pdf'

with open(html_path, 'w', encoding='utf-8') as f:
    f.write(html_content)

cmd = [
    '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome',
    '--headless',
    '--disable-gpu',
    '--no-pdf-header-footer',
    f'--print-to-pdf={pdf_path}',
    html_path
]

subprocess.run(cmd, check=True)

import fitz
doc = fitz.open(pdf_path)
print(f"SUCCESS: Generated PDF with exactly {len(doc)} pages! File size: {os.path.getsize(pdf_path)} bytes.")
