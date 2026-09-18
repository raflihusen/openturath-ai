#!/usr/bin/env python3
"""
update_goakal_success_message.py
================================
Memperbarui pesan pasca-pembayaran (benefit message) secara serentak
untuk seluruh paket langganan OpenTurath AI di GoAkal.
"""

import os
import requests
import json

# Ambil API KEY
api_key = ""
env_paths = [
    "/Users/apple/Downloads/ramadhan/openturath_ai/functions/.env",
    "/Users/apple/Downloads/ramadhan/ecosystem/openturath_subscription/.env",
]
for ep in env_paths:
    if os.path.exists(ep):
        with open(ep, "r") as f:
            for line in f:
                if line.strip().startswith("AKAL_API_KEY="):
                    api_key = line.strip().split("=", 1)[1].strip().strip('"').strip("'")
                    break
    if api_key:
        break

if not api_key:
    print("Error: AKAL_API_KEY tidak ditemukan!")
    exit(1)

headers = {
    "X-Api-Key": api_key,
    "Content-Type": "application/json",
}

url = "https://goakal.com/service/api/v1/benefits/2506"

html_message = (
    "<p><strong>Bismillah. Assalamu’alaikum warahmatullahi wabarakatuh 🤍</strong></p>"
    "<p><br></p>"
    "<p><strong>✅ ALHAMDULILLAH! PEMBAYARAN BERHASIL &amp; AKSES TELAH DIBERIKAN</strong></p>"
    "<p><br></p>"
    "<p>Terima kasih atas keikutsertaan dan dukungan Anda dalam ekosistem riset digital Turath Islami <strong>OpenTurath AI</strong>.</p>"
    "<p><br></p>"
    "<p>━━━━━━━━━━━━━━━━━━━━━━━━━━</p>"
    "<p><strong>STATUS HAK AKSES:</strong></p>"
    "<p>✓ Akses akun Anda telah <strong>diaktifkan secara otomatis &amp; instan</strong> detik ini juga.</p>"
    "<p>✓ Email Anda telah tersambung langsung ke korpus kitab dan engine Super AI.</p>"
    "<p>━━━━━━━━━━━━━━━━━━━━━━━━━━</p>"
    "<p><br></p>"
    "<p><strong>📲 LANGKAH SELANJUTNYA:</strong></p>"
    "<p>Silakan <strong>kembali ke aplikasi OpenTurath AI</strong> di ponsel Anda:</p>"
    "<p>1. Buka kembali aplikasi <strong>OpenTurath AI</strong>.</p>"
    "<p>2. Pastikan Anda telah login menggunakan email Google yang sama dengan saat pembayaran.</p>"
    "<p>3. Anda dapat langsung mulai meneliti ibarah, bertanya, dan mengkaji kitab bersama Super AI.</p>"
    "<p><em>(Tip: Jika status belum berubah otomatis di layar, cukup tekan tombol <strong>'Cek Akses GoAkal'</strong> pada menu langganan).</em></p>"
    "<p><br></p>"
    "<p>Semoga riset dan thalabul 'ilmi Anda senantiasa dimudahkan dan diberkahi Allah SWT.</p>"
    "<p><br></p>"
    "<p><em>جزاكم الله خيرا وبارك الله فيكم 🤍</em></p>"
    "<p><br></p>"
    "<p>Salam takzim,<br><strong>Tim Pengembang OpenTurath AI</strong></p>"
)

payload = {
    "type": "MESSAGE",
    "details": {
        "title": "✅ Pembayaran Berhasil - Akses OpenTurath AI Aktif",
        "sender_name": "OpenTurath AI",
        "message": html_message,
    }
}

res = requests.patch(url, json=payload, headers=headers)
data = res.json()

if data.get("success"):
    schemes = data.get("data", {}).get("impactedPriceSchemes", [])
    print(f"🎉 SUKSES BESAR! Pesan konfirmasi pembayaran berhasil diperbarui serentak!")
    print(f"Total skema paket harga yang terupdate otomatis di GoAkal: {len(schemes)} paket.")
else:
    print("Gagal mengupdate pesan:", data)
