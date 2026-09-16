import base64
import subprocess
import os
import fitz

with open('/Users/apple/Downloads/ramadhan/openturath_ai/public/logo_cropped_sig.png', 'rb') as f:
    logo_b64 = base64.b64encode(f.read()).decode('utf-8')

# ==================== DOKUMEN 1: KATALOG PRODUK & HARGA (1 HALAMAN PAS) ====================
html_katalog = f"""<!DOCTYPE html>
<html lang="id">
<head>
  <meta charset="UTF-8">
  <title>Katalog Produk & Layanan - OpenTurath AI</title>
  <style>
    @page {{
      size: A4;
      margin: 11mm 13mm 11mm 13mm;
      @bottom-right {{
        content: "Halaman 1 dari 1 — Katalog Resmi OpenTurath AI";
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
      font-size: 8.5pt;
      line-height: 1.38;
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
      margin: 10px 0 6px 0;
    }}
    .info-box {{
      background: #F8FAFC;
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 7px 10px;
      margin-bottom: 8px;
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
    .product-card {{
      border: 1px solid #E2E8F0;
      border-radius: 6px;
      padding: 7px 10px;
      margin-bottom: 8px;
      background: #FFFFFF;
    }}
    .footer-box {{
      font-size: 7.2pt;
      color: #718096;
      border-top: 1px solid #E2E8F0;
      padding-top: 6px;
      margin-top: 8px;
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
      <span class="badge">LAMPIRAN 1: KATALOG PRODUK</span><br>
      Website: <strong>open-turath.web.app</strong><br>
      Kategori: Software as a Service (SaaS)<br>
      Mata Uang: <strong>Indonesian Rupiah (IDR)</strong>
    </div>
  </div>

  <h2>1. Identitas Usaha & Karakteristik Produk</h2>
  <div class="info-box">
    <p style="margin:0 0 3px 0;"><strong>Nama Usaha:</strong> OpenTurath AI (Perorangan: Rafli Maulana Husen)</p>
    <p style="margin:0 0 3px 0;"><strong>Jenis Produk / Jasa:</strong> Langganan Akses Perangkat Lunak Digital (SaaS) untuk Pembelajaran & Riset Khazanah Keislaman.</p>
    <p style="margin:0 0 3px 0;"><strong>Deskripsi Layanan:</strong> OpenTurath AI menyediakan sarana riset interaktif berbantuan AI bagi akademisi, santri, dan penuntut ilmu untuk menelaah ribuan teks kitab kuning klasik (matan, syarah, hasyiyah). Seluruh produk dijual secara resmi dengan skema langganan berkala tanpa biaya tersembunyi.</p>
    <p style="margin:0;"><strong>Aksesibilitas Platform:</strong> Web App di <code>https://open-turath.web.app</code> dan aplikasi mobile Android.</p>
  </div>

  <h2>2. Daftar Resmi Paket Langganan & Harga (IDR / Rupiah)</h2>
  <table>
    <thead>
      <tr>
        <th style="width: 27%;">Nama Paket Layanan</th>
        <th style="width: 19%;">Harga Resmi (IDR)</th>
        <th style="width: 14%;">Durasi</th>
        <th style="width: 40%;">Spesifikasi Fasilitas</th>
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

  <h2>3. Rincian Fasilitas & Hak Akses</h2>
  <div class="product-card">
    <p style="margin:0 0 3px 0;"><strong>• Asistensi Riset Kitab 24/7:</strong> Penelusuran bab fikih dan ibarah rumit secara instan dengan rujukan kitab induk terverifikasi.</p>
    <p style="margin:0 0 3px 0;"><strong>• Empat Bilik Spesialis Tahawwulat:</strong> Khusus paket Fikih Tahawwulat, pengguna mendapatkan akses simultan ke 4 bilik studi (tahkik teks, penyederhanaan konsep, evaluasi interaktif, dan arsip muhadharah).</p>
    <p style="margin:0;"><strong>• Aktivasi Instan:</strong> Akun diaktivasi seketika setelah pembayaran sukses tanpa perlu konfirmasi manual.</p>
  </div>

  <h2>4. Ketentuan Pembayaran & Layanan Konsumen</h2>
  <div class="info-box">
    <p style="margin:0 0 2px 0;"><strong>Rentang Harga Jual:</strong> <strong>IDR 49.000 s.d. IDR 2.000.000</strong></p>
    <p style="margin:0 0 2px 0;"><strong>Kanal Pembayaran Resmi:</strong> QRIS Dinamis & Virtual Account Bank melalui Payment Gateway Midtrans.</p>
    <p style="margin:0 0 2px 0;"><strong>Kebijakan Pengembalian Dana:</strong> Tersedia di <a href="https://open-turath.web.app/refund.html">https://open-turath.web.app/refund.html</a></p>
    <p style="margin:0;"><strong>Kontak Dukungan:</strong> Email: <code>admin@openturath.com</code> | WhatsApp: <code>+62 812-9297-9189</code></p>
  </div>

  <div class="footer-box">
    Dokumen Resmi Lampiran 1: Katalog Produk — OpenTurath AI © 2026. Disusun untuk verifikasi onboarding merchant Midtrans.
  </div>
</body>
</html>
"""

# Write HTML and re-compile
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
print(f"NEW 01_KATALOG_PRODUK_OPENTURATH.pdf: EXACTLY {len(d1)} page(s)!")
