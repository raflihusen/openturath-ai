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
            logger.info(f"✅ Siklus selesai. User aktif: {result['authorized_count']}, Dicabut: {result['revoked_count']}")
            
            # 2. Cek apakah waktunya Heartbeat Laporan Tengah Malam (Jam 00:00 - 01:00 WIB)
            if wib_now.hour == 0 and wib_now.day != last_heartbeat_day:
                logger.info("📡 Mengirim Laporan Harian Dead-Man's Switch ke Telegram...")
                await reaper.send_midnight_heartbeat()
                last_heartbeat_day = wib_now.day
                
        except Exception as e:
            logger.error(f"❌ Unhandled error di daemon loop: {e}")
            
        logger.info(f"💤 Tidur selama {INTERVAL_SECONDS // 60} menit hingga siklus berikutnya...\n")
        await asyncio.sleep(INTERVAL_SECONDS)

if __name__ == "__main__":
    asyncio.run(main())
