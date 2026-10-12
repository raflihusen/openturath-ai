#!/usr/bin/env python3
"""
update_goakal_success_message.py
================================
Memperbarui pesan pasca-pembayaran (benefit message) di GoAkal dengan
redaksi resmi pilihan pengguna secara serentak untuk seluruh paket langganan.
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
    "<p><strong>Bismillah.</strong><br><strong>Assalamu’alaikum warahmatullahi wabarakatuh</strong></p>"
    "<p><br></p>"
    "<p><strong>Alhamdulillah, pembayaran Anda telah berhasil.</strong><br>"
    "Akses OpenTurath AI kini telah aktif dan Anda dapat mulai memasuki ruang kajian digital Turath Islami.</p>"
    "<p><br></p>"
    "<p>Terima kasih atas kepercayaan dan dukungan Anda dalam menghadirkan riset kitab, kajian ulama, dan khazanah keilmuan Islam melalui teknologi AI.</p>"
    "<p><br></p>"
    "<p>━━━━━━━━━━━━━━━━━━━━</p>"
    "<p><br></p>"
    "<p><strong>STATUS AKSES ANDA</strong></p>"
    "<p><br></p>"
    "<p>✓ Akun OpenTurath AI telah berhasil diaktifkan.<br>"
    "✓ Email Anda telah terhubung dengan akses korpus kitab dan fitur AI untuk membantu penelitian serta kajian Anda.</p>"
    "<p><br></p>"
    "<p>━━━━━━━━━━━━━━━━━━━━</p>"
    "<p><br></p>"
    "<p><strong>LANGKAH SELANJUTNYA</strong></p>"
    "<p><br></p>"
    "<p>Silakan kembali ke aplikasi <strong>OpenTurath AI</strong>:</p>"
    "<p><br></p>"
    "<p>1. Buka kembali aplikasi OpenTurath AI.<br>"
    "2. Pastikan Anda masuk menggunakan akun Google yang sama dengan akun saat melakukan pembayaran.<br>"
    "3. Akses kajian telah tersedia. Anda dapat mulai menelusuri ibarah, membaca referensi, mengajukan pertanyaan, dan mendalami kitab bersama OpenTurath AI.</p>"
    "<p><br></p>"
    "<p>Semoga OpenTurath AI menjadi wasilah yang membantu perjalanan thalabul ‘ilmi, penelitian, dan pengembangan khazanah keislaman Anda.</p>"
    "<p><br></p>"
    "<p><strong>جزاكم الله خيرًا وبارك الله فيكم</strong></p>"
    "<p><br></p>"
    "<p>Salam takzim,<br><strong>OpenTurath AI</strong></p>"
)

payload = {
    "type": "MESSAGE",
    "details": {
        "title": "Akses OpenTurath AI Aktif",
        "sender_name": "OpenTurath AI",
        "message": html_message,
    }
}

res = requests.patch(url, json=payload, headers=headers)
data = res.json()

if data.get("success"):
    schemes = data.get("data", {}).get("impactedPriceSchemes", [])
    print(f"🎉 SUKSES! Redaksi pesan resmi berhasil diperbarui!")
    print(f"Total skema paket harga yang terupdate serentak: {len(schemes)} paket.")
else:
    print("Gagal mengupdate pesan:", data)
