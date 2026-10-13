"""
OpenTurath 24/7 Autonomous Reaper Daemon
==========================================
Menjalankan siklus reaper secara otomatis setiap 1 jam,
dan mengirim laporan Dead-Man's Switch setiap malam jam 00:00 WIB.
"""

import os
import sys
import asyncio
import logging
from datetime import datetime, timezone, timedelta

# Add path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from autonomous_reaper import AutonomousReaper

logger = logging.getLogger("reaper_daemon")
logging.basicConfig(
    level=logging.INFO,
    format="%(asctime)s [%(levelname)s] [DAEMON] %(message)s",
    handlers=[
        logging.FileHandler("reaper_daemon.log"),
        logging.StreamHandler(),
    ],
)

INTERVAL_SECONDS = 3600 # 1 Jam

async def main():
    logger.info("=" * 80)
    logger.info("🤖 OPENTURATH 24/7 AUTONOMOUS REAPER DAEMON STARTED")
    logger.info(f"⏱️  Interval Pemindaian: Setiap {INTERVAL_SECONDS // 60} Menit")
    logger.info("=" * 80)
    
    reaper = AutonomousReaper()
    last_heartbeat_day = -1
    
    while True:
        try:
            now = datetime.now(timezone.utc)
            wib_now = now + timedelta(hours=7)
            
            # 1. Jalankan Siklus Pemindaian & Pencabutan Expired
            logger.info("🔄 Menjalankan siklus pemindaian...")
            result = await reaper.run_cycle()
            vip_count = result.get('vip_count', 0)
            revoked_count = result.get('revoked_count', 0)
            logger.info(f"✅ Siklus selesai. VIP permanen: {vip_count}, Dicabut: {revoked_count}, "
                        f"Dry-run: {result.get('dry_run_count', 0)}, Error: {result.get('errors', 0)}")
            
            # 2. Cek apakah waktunya Heartbeat Laporan Tengah Malam (Jam 00:00 - 01:00 WIB)
            if wib_now.hour == 0 and wib_now.day != last_heartbeat_day:
                logger.info("📡 Mengirim Laporan Harian Dead-Man's Switch ke Telegram...")
                from autonomous_reaper import send_telegram
                msg = (
                    "💚 <b>[HEARTBEAT REAPER DAEMON]</b>\n"
                    "🕌 <b>OpenTurath AI Engine</b>\n"
                    f"⏰ Waktu: <code>{wib_now.strftime('%Y-%m-%d %H:%M:%S WIB')}</code>\n"
                    f"🛡️ Status: <b>Online & Aktif Memindai Tiap Jam</b>\n"
                    f"👑 VIP Dilindungi: <b>{vip_count} akun</b>\n"
                    f"🧹 Total Dicabut Siklus Terakhir: <b>{revoked_count} akun</b>"
                )
                send_telegram(msg)
                last_heartbeat_day = wib_now.day
                
        except Exception as e:
            logger.error(f"❌ Unhandled error di daemon loop: {e}", exc_info=True)
            
        logger.info(f"💤 Tidur selama {INTERVAL_SECONDS // 60} menit hingga siklus berikutnya...\n")
        await asyncio.sleep(INTERVAL_SECONDS)

if __name__ == "__main__":
    asyncio.run(main())
