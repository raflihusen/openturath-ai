import base64
import subprocess
import os
import fitz

with open('/Users/apple/Downloads/ramadhan/openturath_ai/public/logo_cropped_sig.png', 'rb') as f:
    logo_b64 = base64.b64encode(f.read()).decode('utf-8')

# ==================== DOKUMEN 1: KATALOG PRODUK & HARGA ====================
html_katalog = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Katalog Produk & Layanan - OpenTurath AI</title>
  <style>
    @page {{
      size: A4;
      margin: 16mm 16mm 16mm 16mm;
      @bottom-right {{
        content: "Katalog Resmi OpenTurath AI";
        font-family: -apple-system, sans-serif;
        font-size: 8pt;
        color: #718096;
      }}
    }}
    * {{ box-sizing: border-box; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      color: #1A202C;
      margin: 0; padding: 0;
      font-size: 9.2pt;
      line-height: 1.45;
    }}
    .header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2.5px solid #0D201A;
      padding-bottom: 12px;
      margin-bottom: 16px;
    }}
    .logo-area {{
      display: flex;
      align-items: center;
      gap: 12px;
    }}
    .logo-img {{
      width: 52px;
      height: 52px;
      border-radius: 8px;
      background: #0D201A;
      padding: 3px;
    }}
    .brand-title {{
      font-size: 19pt;
      font-weight: 800;
      color: #0D201A;
      margin: 0;
      letter-spacing: -0.5px;
    }}
    .brand-subtitle {{
      font-size: 8.5pt;
      color: #4A5568;
      margin: 2px 0 0 0;
    }}
    .doc-meta {{
      text-align: right;
      font-size: 8.2pt;
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
      font-size: 11.5pt;
      font-weight: 700;
      color: #0D201A;
      border-left: 3.5px solid #D97706;
      padding-left: 8px;
      margin: 16px 0 8px 0;
    }}
    .info-box {{
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 10px 14px;
      margin-bottom: 14px;
    }}
    table {{
      width: 100%;
      border-collapse: collapse;
      margin: 10px 0 14px 0;
      font-size: 8.5pt;
    }}
    th, td {{
      border: 1px solid #CBD5E0;
      padding: 8px 10px;
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
      font-size: 9.5pt;
      white-space: nowrap;
    }}
    .product-card {{
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 10px 12px;
      margin-bottom: 10px;
      background: #FFFFFF;
    }}
    .footer-box {{
      font-size: 7.8pt;
      color: #718096;
      border-top: 1px solid #E2E8F0;
      padding-top: 10px;
      margin-top: 18px;
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
        <p class="brand-subtitle">Platform Edukasi & Khazanah Kitab Kuning Berbasis Artificial Intelligence</p>
      </div>
    </div>
    <div class="doc-meta">
      <span class="badge">LAMPIRAN: KATALOG PRODUK</span><br>
      Website: <strong>open-turath.web.app</strong><br>
      Kategori: Software as a Service (SaaS)<br>
      Mata Uang: <strong>Indonesian Rupiah (IDR)</strong>
    </div>
  </div>

  <h2>1. Identitas Usaha & Karakteristik Produk</h2>
  <div class="info-box">
    <p style="margin:0 0 6px 0;"><strong>Nama Usaha:</strong> OpenTurath AI (Perorangan: Rafli Maulana Husen)</p>
    <p style="margin:0 0 6px 0;"><strong>Jenis Produk / Jasa:</strong> Langganan Akses Perangkat Lunak Digital (SaaS) untuk Pembelajaran & Riset Khazanah Keislaman.</p>
    <p style="margin:0 0 6px 0;"><strong>Deskripsi Layanan:</strong> OpenTurath AI menyediakan sarana riset interaktif berbantuan AI bagi akademisi, santri, dan penuntut ilmu untuk menelaah ribuan teks kitab kuning klasik (matan, syarah, hasyiyah). Seluruh produk dijual secara resmi dengan skema langganan berkala tanpa biaya tersembunyi.</p>
    <p style="margin:0;"><strong>Aksesibilitas Platform:</strong> Dapat diakses melalui Web App (PWA) di <code>https://open-turath.web.app</code> dan aplikasi mobile Android.</p>
  </div>

  <h2>2. Daftar Resmi Paket Langganan & Harga (IDR / Rupiah)</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 28%;">Nama Paket Layanan</th>
        <th style="width: 20%;">Harga Resmi (IDR)</th>
        <th style="width: 14%;">Durasi</th>
        <th style="width: 38%;">Spesifikasi Fasilitas</th>
      </tr>
    </thead>
    <tbody>
      <tr>
        <td><strong>Modul Riset: Thalib 1M</strong></td>
        <td class="price-tag">Rp 49.000</td>
        <td>1 Bulan</td>
        <td>Akses AI Asisten Spesialis terpilih (Fikih, Nahwu, Tafsir, Hadis), pencarian ibarah kitab cepat.</td>
      </tr>
      <tr>
        <td><strong>Modul Riset: Thalib 6M</strong></td>
        <td class="price-tag">Rp 299.000</td>
        <td>6 Bulan</td>
        <td>Akses modul spesialis 6 bulan, prioritas server riset tinggi, ekspor kutipan ilmiah tanpa batas.</td>
      </tr>
      <tr>
        <td><strong>Modul Riset: Bahits 1Y</strong></td>
        <td class="price-tag">Rp 499.000</td>
        <td>1 Tahun</td>
        <td>Akses 1 tahun penuh, fitur pembanding ibarah lintas madzhab, dukungan konsultasi karya ilmiah.</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 1 Bulan</strong></td>
        <td class="price-tag">Rp 300.000</td>
        <td>1 Bulan</td>
        <td>Akses 4 Bilik: Al-Muhaqqiq (Matan), Al-Bayan (Konsep), Al-Mukhtabir (Ujian), Al-Habib (Arsip).</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 6 Bulan</strong></td>
        <td class="price-tag">Rp 1.500.000</td>
        <td>6 Bulan</td>
        <td>Akses 4 Bilik Keilmuan selama 6 bulan + pembaruan berkala korpus tanda-tanda akhir zaman.</td>
      </tr>
      <tr>
        <td><strong>Fikih Tahawwulat: 1 Tahun</strong></td>
        <td class="price-tag">Rp 2.000.000</td>
        <td>1 Tahun</td>
        <td>Akses komprehensif 1 tahun penuh seluruh khazanah ilmiah dan rekaman muhadharah bersanad.</td>
      </tr>
    </tbody>
  </table>

  <h2>3. Rincian Fitur Utama yang Diterima Pelanggan</h2>
  <div class="product-card">
    <p style="margin:0 0 4px 0;"><strong>A. Asistensi Riset Kitab 24/7:</strong> Penelusuran bab fikih dan ibarah rumit secara instan dengan rujukan kitab induk yang terverifikasi.</p>
    <p style="margin:0 0 4px 0;"><strong>B. Empat Bilik Spesialis Tahawwulat:</strong> Khusus paket Fikih Tahawwulat, pengguna mendapatkan akses simultan ke 4 bilik studi (tahkik teks, penyederhanaan konsep, evaluasi interaktif, dan arsip muhadharah).</p>
    <p style="margin:0;"><strong>C. Hak Akses Instan:</strong> Akun diaktivasi seketika setelah pembayaran sukses tanpa perlu konfirmasi manual.</p>
  </div>

  <h2>4. Informasi Pembayaran & Layanan Pelanggan</h2>
  <div class="info-box">
    <p style="margin:0 0 4px 0;"><strong>Rentang Harga Jual:</strong> IDR 49.000 s.d. IDR 2.000.000</p>
    <p style="margin:0 0 4px 0;"><strong>Kanal Pembayaran Resmi:</strong> QRIS Dinamis & Virtual Account Bank melalui Payment Gateway Midtrans.</p>
    <p style="margin:0 0 4px 0;"><strong>Kebijakan Pengembalian Dana:</strong> Tersedia di <a href="https://open-turath.web.app/refund.html">https://open-turath.web.app/refund.html</a></p>
    <p style="margin:0;"><strong>Kontak Bantuan:</strong> Email: <code>admin@openturath.com</code> | WhatsApp: <code>+62 812-9297-9189</code></p>
  </div>

  <div class="footer-box">
    Dokumen Katalog Produk Resmi — OpenTurath AI © 2026. Disusun untuk verifikasi onboarding merchant Midtrans.
  </div>
</body>
</html>
"""

# ==================== DOKUMEN 2: FLOW TRANSAKSI CHECKOUT MIDTRANS ====================
html_flow = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Dokumen Flow Transaksi Midtrans - OpenTurath AI</title>
  <style>
    @page {{
      size: A4;
      margin: 16mm 16mm 16mm 16mm;
      @bottom-right {{
        content: "Alur Transaksi & Integrasi Midtrans";
        font-family: -apple-system, sans-serif;
        font-size: 8pt;
        color: #718096;
      }}
    }}
    * {{ box-sizing: border-box; }}
    body {{
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
      color: #1A202C;
      margin: 0; padding: 0;
      font-size: 9pt;
      line-height: 1.45;
    }}
    .header {{
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2.5px solid #0D201A;
      padding-bottom: 12px;
      margin-bottom: 16px;
    }}
    .logo-area {{
      display: flex;
      align-items: center;
      gap: 12px;
    }}
    .logo-img {{
      width: 52px;
      height: 52px;
      border-radius: 8px;
      background: #0D201A;
      padding: 3px;
    }}
    .brand-title {{
      font-size: 19pt;
      font-weight: 800;
      color: #0D201A;
      margin: 0;
      letter-spacing: -0.5px;
    }}
    .brand-subtitle {{
      font-size: 8.5pt;
      color: #4A5568;
      margin: 2px 0 0 0;
    }}
    .doc-meta {{
      text-align: right;
      font-size: 8.2pt;
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
      font-size: 11.5pt;
      font-weight: 700;
      color: #0D201A;
      border-left: 3.5px solid #D97706;
      padding-left: 8px;
      margin: 16px 0 8px 0;
    }}
    .step-grid {{
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 10px;
      margin: 10px 0 16px 0;
    }}
    .step-card {{
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 9px 12px;
      background: #F8FAFC;
    }}
    .step-header {{
      display: flex;
      align-items: center;
      gap: 6px;
      margin-bottom: 4px;
    }}
    .step-num {{
      width: 22px;
      height: 22px;
      background: #0D201A;
      color: #F59E0B;
      font-weight: 800;
      font-size: 8.5pt;
      border-radius: 50%;
      display: flex;
      align-items: center;
      justify-content: center;
      text-align: center;
      line-height: 22px;
    }}
    .step-title {{
      font-weight: 700;
      font-size: 9.2pt;
      color: #0D201A;
    }}
    .mockup-container {{
      display: grid;
      grid-template-columns: repeat(4, 1fr);
      gap: 8px;
      margin: 10px 0 16px 0;
    }}
    .mockup-item {{
      border: 1px solid #CBD5E0;
      border-radius: 6px;
      padding: 8px 6px;
      background: #FFFFFF;
      text-align: center;
      font-size: 7.8pt;
    }}
    .mockup-phone {{
      background: #0D201A;
      color: #FFFFFF;
      border-radius: 6px;
      padding: 10px 6px;
      margin: 6px 0;
      font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
      font-size: 7pt;
      text-align: left;
      line-height: 1.4;
      box-shadow: 0 2px 4px rgba(0,0,0,0.1);
    }}
    .mockup-phone .gold {{ color: #F59E0B; font-weight: bold; }}
    .mockup-phone .green {{ color: #10B981; font-weight: bold; }}
    .mockup-phone .blue {{ color: #60A5FA; }}
    .info-box {{
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 10px 14px;
      margin-bottom: 12px;
    }}
    .footer-box {{
      font-size: 7.8pt;
      color: #718096;
      border-top: 1px solid #E2E8F0;
      padding-top: 10px;
      margin-top: 18px;
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
        <p class="brand-subtitle">Platform Edukasi & Khazanah Kitab Kuning Berbasis Artificial Intelligence</p>
      </div>
    </div>
    <div class="doc-meta">
      <span class="badge">LAMPIRAN: FLOW TRANSAKSI</span><br>
      Website: <strong>open-turath.web.app</strong><br>
      Tipe Dokumen: <strong>Flow Transaksi Step-by-Step</strong><br>
      Integrasi: <strong>Midtrans Snap & Core API</strong>
    </div>
  </div>

  <h2>1. Penjelasan Alur Transaksi Pemesanan (End-to-End)</h2>
  <div class="step-grid">
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">1</div>
        <div class="step-title">Pilih Paket di Aplikasi</div>
      </div>
      <p style="margin:0;">Pengguna membuka menu <strong>Langganan</strong> di aplikasi OpenTurath AI, melihat daftar paket resmi, dan memilih durasi keanggotaan (1 Bulan, 6 Bulan, atau 1 Tahun). Total tagihan dalam IDR langsung ditampilkan transparan.</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">2</div>
        <div class="step-title">Inisiasi Pembayaran Midtrans</div>
      </div>
      <p style="margin:0;">Pengguna menekan <strong>"Aktivasi Langganan"</strong>. Aplikasi meminta Snap Token ke server OpenTurath yang terhubung ke API Midtrans. Pengguna memilih metode: <strong>QRIS</strong> atau <strong>Virtual Account Bank</strong>.</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">3</div>
        <div class="step-title">Proses Pembayaran User</div>
      </div>
      <p style="margin:0;">Jika memilih QRIS, kode QR dinamis berlogo QRIS resmi akan tampil di layar untuk dipindai melalui m-banking/e-wallet. Jika memilih VA, nomor rekening unik bank (BCA/Mandiri/BNI/BRI) akan ditampilkan.</p>
    </div>
    <div class="step-card">
      <div class="step-header">
        <div class="step-num">4</div>
        <div class="step-title">Aktivasi Instan via Webhook</div>
      </div>
      <p style="margin:0;">Server Midtrans secara instan mengirim notifikasi HTTP Webhook (status <code>settlement</code>) ke backend OpenTurath. Akun pengguna saat itu juga langsung mendapatkan hak akses penuh tanpa verifikasi manual.</p>
    </div>
  </div>

  <h2>2. Bukti Visual Tangkapan Layar (Screenshot Step-by-Step)</h2>
  <div class="mockup-container">
    <!-- STEP 1 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Tahap 1: Pilih Paket</strong>
      <div class="mockup-phone">
        <span class="gold">● OpenTurath AI</span><br>
        -----------------<br>
        <strong>Katalog Paket:</strong><br>
        (•) 1 Bulan: Rp 49.000<br>
        ( ) 6 Bulan: Rp 299.000<br>
        ( ) 1 Tahun: Rp 499.000<br>
        -----------------<br>
        <span class="green">[ Pilih Paket Ini ]</span>
      </div>
      <span>Pilih paket & durasi</span>
    </div>

    <!-- STEP 2 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Tahap 2: Rincian Order</strong>
      <div class="mockup-phone">
        <span class="gold">● Konfirmasi Tagihan</span><br>
        -----------------<br>
        Modul: Thalib 1M<br>
        Total: <span class="gold">Rp 49.000</span><br>
        Metode:<br>
        [•] QRIS Dinamis<br>
        [ ] Virtual Account<br>
        -----------------<br>
        <span class="green">[ Bayar Sekarang ]</span>
      </div>
      <span>Verifikasi nominal IDR</span>
    </div>

    <!-- STEP 3 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Tahap 3: Midtrans Snap</strong>
      <div class="mockup-phone">
        <span class="blue">● Midtrans Payment</span><br>
        -----------------<br>
        Tagihan: <strong>Rp 49.000</strong><br>
        <div style="background:#FFF; color:#000; padding:4px; text-align:center; margin:3px 0; font-size:6pt; font-weight:bold;">
          [ QRIS CODE DINAMIS ]<br>
          ■■■■■■■■■■■■■■■<br>
          ■■   ■■   ■■<br>
          ■■■■■■■■■■■■■■■
        </div>
        Sisa Waktu: 14:59
      </div>
      <span>Pop-up QRIS / VA resmi</span>
    </div>

    <!-- STEP 4 -->
    <div class="mockup-item">
      <strong style="color:#0D201A;">Tahap 4: Sukses Aktif</strong>
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
      <span>Hak akses aktif instan</span>
    </div>
  </div>

  <h2>3. Penanganan Transaksi & Perlindungan Pengguna</h2>
  <div class="info-box">
    <p style="margin:0 0 4px 0;"><strong>Keamanan Transaksi:</strong> Menggunakan tokenisasi Midtrans Snap dan tanda tangan HMAC SHA-512 untuk memvalidasi setiap callback transaksi.</p>
    <p style="margin:0 0 4px 0;"><strong>Kebijakan Pengembalian Dana:</strong> Jika terjadi kendala jaringan atau kegagalan aktivasi modul lebih dari 3x24 jam, dana akan dikembalikan penuh sesuai prosedur di <a href="https://open-turath.web.app/refund.html">open-turath.web.app/refund.html</a>.</p>
    <p style="margin:0;"><strong>Kontak Dukungan Pengguna:</strong> Email: <code>admin@openturath.com</code> | WhatsApp: <code>+62 812-9297-9189</code></p>
  </div>

  <div class="footer-box">
    Dokumen Alur Transaksi & Integrasi Checkout Midtrans — OpenTurath AI © 2026.
  </div>
</body>
</html>
"""

# Write HTML files
p1_html = '/Users/apple/Downloads/ramadhan/01_KATALOG_PRODUK_OPENTURATH.html'
p2_html = '/Users/apple/Downloads/ramadhan/02_DOKUMEN_FLOW_TRANSAKSI_MIDTRANS.html'
p1_pdf = '/Users/apple/Downloads/ramadhan/01_KATALOG_PRODUK_OPENTURATH.pdf'
p2_pdf = '/Users/apple/Downloads/ramadhan/02_DOKUMEN_FLOW_TRANSAKSI_MIDTRANS.pdf'

with open(p1_html, 'w', encoding='utf-8') as f:
    f.write(html_katalog)
with open(p2_html, 'w', encoding='utf-8') as f:
    f.write(html_flow)

# Compile to PDF
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
    print(f"Generated {pdf}: {len(d)} page(s), {os.path.getsize(pdf)} bytes")

print("Both separate documents generated successfully!")
