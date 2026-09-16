"""
OpenTurath AI — NotebookLM API Stress Test & Limit Benchmark
===========================================================
Menguji limit kuota, concurrency, latency, rate-limiting (429),
dan batasan harian API NotebookLM pada akun Google.
"""

import asyncio
import time
import json
import os
import sys
from datetime import datetime
from notebooklm import NotebookLMClient

NOTEBOOK_ID = "483d0291-0a70-411c-bff0-f1ea4b83b2fd" # SUPER AI FIKIH TAHAWWULAT (AL-BAYAN)
STORAGE_PATH = "storage_state.json"

TEST_PROMPTS = [
    "Jelaskan konsep dasar Sunnah Mawaqif dalam Fikih Tahawwulat secara singkat.",
    "Apa perbedaan antara tanda-tanda kiamat besar dan kecil menurut manhaj ini?",
    "Sebutkan 3 rukun agama dan apa yang dimaksud rukun keempat menurut Habib Abu Bakar?",
    "Bagaimana pandangan fikih tahawwulat terhadap perubahan zaman di era digital?",
    "Jelaskan kaidah fiqhiyah yang menjadi pondasi dalam menyikapi fitnah akhir zaman.",
    "Apa arti istilah Al-Ahadits Al-Musaqah fi 'ilmi at-tahawwulat?",
    "Bagaimana metodologi takhrij hadits-hadits tentang nubuat akhir zaman?",
    "Jelaskan pentingnya menjaga lisan dan sikap netral dalam menyikapi konflik fitnah.",
    "Apa peran ulama mutaqaddimin dalam meletakkan dasar ushul fiqh tahawwulat?",
    "Sebutkan kitab-kitab rujukan utama yang dikarang oleh Al-Allamah Habib Abu Bakar Al-Masyhur."
]

async def run_stress_test():
    print("=" * 70)
    print("🚀 MEMULAI BENCHMARK & STRESS TEST NOTEBOOKLM API")
    print(f"Target Notebook: {NOTEBOOK_ID}")
    print(f"Waktu Mulai: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 70)

    results = {
        "sequential_test": [],
        "concurrency_test": [],
        "summary": {}
    }

    async with NotebookLMClient.from_storage(path=STORAGE_PATH) as client:
        print("\n--- PHASE 1: SEQUENTIAL RAPID-FIRE TEST (10 Pertanyaan Berturut-turut) ---")
        seq_success = 0
        seq_failed = 0
        total_time = 0
        
        for i, prompt in enumerate(TEST_PROMPTS, 1):
            t0 = time.time()
            print(f"[{i}/10] Mengirim: '{prompt[:45]}...'")
            try:
                # Ask query
                resp = await client.chat.ask(notebook_id=NOTEBOOK_ID, question=prompt)
                elapsed = time.time() - t0
                total_time += elapsed
                seq_success += 1
                
                answer_text = getattr(resp, 'answer', str(resp))
                sources_count = len(getattr(resp, 'citations', [])) if hasattr(resp, 'citations') else 0
                
                print(f"    ✅ Sukses ({elapsed:.2f}s) | Panjang Jawaban: {len(answer_text)} char | Sumber: {sources_count}")
                results["sequential_test"].append({
                    "turn": i,
                    "prompt": prompt,
                    "latency_sec": round(elapsed, 2),
                    "char_count": len(answer_text),
                    "status": "SUCCESS"
                })
            except Exception as e:
                elapsed = time.time() - t0
                seq_failed += 1
                err_msg = str(e)
                print(f"    ❌ GAGAL ({elapsed:.2f}s) | Error: {err_msg}")
                results["sequential_test"].append({
                    "turn": i,
                    "prompt": prompt,
                    "latency_sec": round(elapsed, 2),
                    "status": "FAILED",
                    "error": err_msg
                })
                # Jika terkena 429 atau rate limit, catat khusus
                if "429" in err_msg or "RESOURCE_EXHAUSTED" in err_msg or "quota" in err_msg.lower():
                    print("    🚨 PERINGATAN: TERDETEKSI RATE LIMIT / 429 DARI GOOGLE!")
            
            # Beri jeda sangat singkat (0.5 detik) untuk menguji rapid-fire
            await asyncio.sleep(0.5)

        print("\n--- PHASE 2: CONCURRENCY TEST (3 Pertanyaan Paralel Bersamaan) ---")
        concur_prompts = [
            "Apa definisi Al-Bayan dalam konteks fikih ini?",
            "Jelaskan sanad keilmuan Habib Abu Bakar Al-Masyhur secara ringkas.",
            "Apa yang dimaksud dengan Fiqh Da'wah dalam Tahawwulat?"
        ]

        async def ask_single(idx, p):
            t_start = time.time()
            try:
                r = await client.chat.ask(notebook_id=NOTEBOOK_ID, question=p)
                t_el = time.time() - t_start
                return {
                    "worker": idx,
                    "prompt": p,
                    "latency_sec": round(t_el, 2),
                    "char_count": len(getattr(r, 'answer', str(r))),
                    "status": "SUCCESS"
                }
            except Exception as ex:
                t_el = time.time() - t_start
                return {
                    "worker": idx,
                    "prompt": p,
                    "latency_sec": round(t_el, 2),
                    "status": "FAILED",
                    "error": str(ex)
                }

        t_concur_start = time.time()
        tasks = [ask_single(i, p) for i, p in enumerate(concur_prompts, 1)]
        concur_results = await asyncio.gather(*tasks)
        total_concur_time = time.time() - t_concur_start

        for cr in concur_results:
            if cr["status"] == "SUCCESS":
                print(f"    Worker {cr['worker']}: ✅ Sukses ({cr['latency_sec']}s) | {cr['char_count']} char")
            else:
                print(f"    Worker {cr['worker']}: ❌ Gagal ({cr['latency_sec']}s) | {cr.get('error')}")
        
        results["concurrency_test"] = concur_results

    # ── Summary Calculation ──
    avg_seq_latency = (total_time / seq_success) if seq_success > 0 else 0
    results["summary"] = {
        "sequential_total": len(TEST_PROMPTS),
        "sequential_success": seq_success,
        "sequential_failed": seq_failed,
        "average_latency_sec": round(avg_seq_latency, 2),
        "concurrency_total": len(concur_prompts),
        "concurrency_success": sum(1 for c in concur_results if c["status"] == "SUCCESS"),
        "concurrency_wall_time_sec": round(total_concur_time, 2)
    }

    # Save results to JSON
    with open("stress_test_report.json", "w") as f:
        json.dump(results, f, indent=2)

    print("\n" + "=" * 70)
    print("📊 RINGKASAN HASIL STRESS TEST:")
    print(f"- Total Query Beruntun: {seq_success}/{len(TEST_PROMPTS)} Berhasil")
    print(f"- Rata-rata Latensi Jawaban: {avg_seq_latency:.2f} detik / pertanyaan")
    print(f"- Concurrency 3x Paralel: {results['summary']['concurrency_success']}/3 Berhasil (Total {total_concur_time:.2f}s)")
    print("=" * 70)

if __name__ == "__main__":
    asyncio.run(run_stress_test())
