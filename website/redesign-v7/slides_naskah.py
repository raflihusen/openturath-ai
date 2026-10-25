#!/usr/bin/env python3
"""Menyusun assets/data/slides_mengenal.json dari naskah Mengenal Fikih Tahawwulat.

Sumber: naskah_tahawwulat_blocks.json (hasil penguraian naskah storyboard
84 slide milik Pemilik; slide 55-57 dan 69 memang sengaja dihapus Pemilik,
jadi urutan di sini dinomori ulang berurutan) ditambah penyuntingan di bawah.
Kunci "scene" mengacu ke adegan di lib/widgets/tahawwulat_scenes.dart.
"""
import json
import re
from pathlib import Path

HERE = Path(__file__).resolve().parent
OUT = HERE.parent.parent / "openturath_ai" / "assets" / "data" / "slides_mengenal.json"
SRC = json.loads((HERE / "naskah_tahawwulat_blocks.json").read_text("utf8"))

BAB = [
    {"id": "Pembuka", "en": "Opening", "ar": "تمهيد"},
    {"id": "Hadis Jibril", "en": "The Hadith of Jibril", "ar": "حديث جبريل"},
    {"id": "Kesatuan agama", "en": "One religion, one whole", "ar": "وحدة الدين"},
    {"id": "Fikih Tahawwulat", "en": "Fiqh al-Tahawwulat", "ar": "فقه التحولات"},
    {"id": "Lima cabang ilmu", "en": "Five branches", "ar": "الفروع الخمسة"},
    {"id": "Jalan selamat", "en": "The safe path", "ar": "منهج السلامة"},
    {"id": "Lima asisten", "en": "Five assistants", "ar": "المساعدون الخمسة"},
]


def bab_of(n):
    if n <= 3:
        return 0
    if n <= 20:
        return 1
    if n <= 39:
        return 2
    if n <= 54:
        return 3
    if n <= 70:
        return 4
    if n <= 76:
        return 5
    return 6


def P(t): return {"p": t}
def UL(*a): return {"ul": list(a)}
def OL(*a): return {"ol": list(a)}
def AR(t): return {"ar": t}
def CAP(t): return {"cap": t}


MANUAL = {
    26: dict(blocks=[
        P("Imam al-Bukhari menempatkan Hadis Jibril di *Kitab al-Iman*, Bab 37, "
          "dan memberinya judul bab yang sangat bermakna. Para ahli hadis berkata:"),
        AR("«فِقْهُ البُخَارِيِّ فِي تَرَاجِمِهِ»"),
        P("*Kedalaman fikih Imam al-Bukhari tersimpan dalam judul-judul bab yang beliau tetapkan.*"),
        P("Judul babnya menyebut Islam, Iman, dan Ihsan, **lalu menambahkan:**"),
        AR("«وَعِلْمِ السَّاعَةِ»"),
        P("Beliau menutup bab itu dengan kesimpulan:"),
        AR("«فَجَعَلَ ذَلِكَ كُلَّهُ دِينًا»"),
        P("Ilmu tentang Kiamat dan tanda-tandanya disejajarkan dengan Islam, Iman, dan Ihsan, "
          "dan **semuanya dijadikan satu kesatuan agama**."),
        CAP("Shahih al-Bukhari, Kitab al-Iman, Bab 37 · at-Talid wa ath-Tharif, hlm. 25 · "
            "at-Tabshirah ad-Da‘wiyyah, hlm. 12"),
    ]),
    61: dict(blocks=[
        P("**Peta lima cabang ilmu Fikih Tahawwulat**"),
        OL("**Penyimpangan dan pencegahan:** *Nawaqidh*, *Naqa'idh*, *Mudhillat al-Fitan*, dan *Fiqh al-Wiqayah*.",
           "**Isyarat dan benteng:** *Isyarat*, *Basyarat*, *Nadzarat*, *Hishanat*, serta kemuliaan keadilan dan sanad.",
           "**Sains dan teknologi:** perkembangan ilmu, teknologi, dan isu kemajuan zaman.",
           "**Tanda alam dan peristiwa besar:** tanda-tanda alam dan peristiwa besar akhir zaman.",
           "**Agama dan sejarah:** hubungan agama dengan sejarah di bawah takdir Allah."),
        CAP("al-Iqlid, hlm. 11-12"),
    ]),
    62: dict(blocks=[
        P("**Cabang 1 (Bagian A): *Nawaqidh* dan *Naqa'idh***"),
        UL("**Nawaqidh** (النَّوَاقِضُ): pemikiran atau gerakan yang meruntuhkan ikatan-ikatan agama, "
           "ilmu, hukum, dan nilai dari dasarnya, dimulai dari runtuhnya kedaulatan hukum hingga ditinggalkannya salat.",
           "**Naqa'idh** (النَّقَائِضُ): sikap tandingan yang membalas dengan argumen dan pemahaman yang berlawanan, "
           "sehingga terjadi bentrokan pemikiran di tubuh umat.",
           "**Penggeraknya:** ambisi bersaing dunia (*al-munafasah*) dan adu domba setan di antara sesama ahli salat "
           "(*at-tahrisy*, HR. Muslim no. 2812)."),
        CAP("al-Iqlid, hlm. 22 · an-Nubdzah ash-Shughra, hlm. 21"),
    ]),
    63: dict(blocks=[
        P("**Cabang 1 (Bagian B): fitnah yang menyesatkan dan fikih pencegahan**"),
        UL("**Mudhillat al-Fitan** (مُضِلَّاتُ الفِتَنِ): penyimpangan terstruktur pada dua pusat keputusan, "
           "yaitu keputusan ilmu dan akidah serta keputusan hukum dan ekonomi, yang menyeret masyarakat "
           "menjadi pelayan agenda Dajjal dan Iblis.",
           "**Fiqh al-Wiqayah** (فِقْهُ الوِقَايَةِ): cara menjaga diri dari arus fitnah, yaitu menahan anggota badan, "
           "berhenti dari konflik lisan dan tangan, melindungi keluarga (*al-khuwayshah*), dan berpegang teguh "
           "pada *‘urwah wutsqa*."),
        CAP("al-Iqlid, hlm. 21-26"),
    ]),
    64: dict(blocks=[
        P("**Cabang 2 (Bagian A): empat bentuk petunjuk nubuwwah**"),
        UL("**Isyarat** (الإِشَارَاتُ): kode nubuwwah tentang dinamika masa depan dan tanda perubahan zaman.",
           "**Basyarat** (البَشَارَاتُ): kabar gembira tentang terjaganya Islam, hadirnya pembaharu (*mujaddid*), "
           "dan keberkahan orang, tempat, serta masa tertentu.",
           "**Nadzarat** (النَّذَارَاتُ): peringatan dini akan krisis dan bencana akibat kemaksiatan kolektif.",
           "**Hishanat** (الحِصَانَاتُ): benteng nubuwwah yang menjaga orang (seperti *Ahlu Badr* dan *Ahlul Bait*), "
           "tempat (Haramain), dan masa dari celaan."),
        CAP("al-Iqlid, hlm. 31-37 · an-Nubdzah ash-Shughra, hlm. 24-28"),
    ]),
    65: dict(blocks=[
        P("**Cabang 2 (Bagian B): empat syarat selamat dalam memilih guru dan majelis**"),
        OL("**Sanad ilmu bersambung** (*at-talaqqi wa at-taraqqi ‘an al-‘udul*): ilmu diterima tatap muka dari ulama Ahlussunnah yang teruji.",
           "**Selamat lisan dari mencela** (*salamah al-lisan min adz-dzamm*): tidak mengafirkan, menyesatkan, atau mencaci sesama Muslim.",
           "**Selamat tangan dari darah** (*salamah al-yad min ad-dam*): tidak terlibat konflik fisik dan pertumpahan darah.",
           "**Selamat wadah dari politisasi** (*salamah al-wi'a' min at-tasyis*): majelis dan lembaga bebas dari tumpangan politik praktis."),
        CAP("Dawa'ir al-I'adah, hlm. 30 · an-Nubdzah ash-Shughra, hlm. 28-30"),
    ]),
    66: dict(blocks=[
        P("**Cabang 3: sains, teknologi, dan kemajuan zaman**"),
        UL("**Hakikatnya:** seluruh ilmu teori dan terapan dimasukkan ke dalam Rukun Keempat agama, "
           "merebut hasil sains dari saluran ateisme kembali ke naungan wahyu.",
           "**Pemisahan syar'i:** teknologi dan alat terapan wajib dimanfaatkan untuk dakwah dan kemaslahatan, "
           "sedangkan filsafat sekuler dan materialisme yang merusak akidah harus dibedakan.",
           "**Isyarat nubuwwah:** energi, penjelajahan antariksa, dan AI dibaca sebagai pembenaran isyarat Nabi ﷺ di akhir zaman."),
        AR("﴿اقْرَأْ بِاسْمِ رَبِّكَ﴾ [العلق: ١]"),
        CAP("al-Iqlid, hlm. 45 · an-Nubdzah ash-Shughra, hlm. 30"),
    ]),
    67: dict(blocks=[
        P("**Cabang 4: tanda alam dan peristiwa besar akhir zaman**"),
        P("Tanda-tanda ini disusun agar kita terhindar dari tebakan liar (*at-takhmin wal-isqath*)."),
        UL("**Tanda alam luar biasa** (*asyrat kawniyyah*): terbit matahari dari barat, asap, tiga penelanan bumi, kembalinya tanah Arab menjadi hijau.",
           "**Peringatan dari masa lalu** (*asyrat istiqra'iyyah*): peristiwa alam terdahulu sebagai pelajaran.",
           "**Malahim** (المَلَاحِمُ): perang besar akhir zaman, termasuk era Sufyani, Mahdi, Dajjal, dan Ya'juj-Ma'juj.",
           "**Tiga lingkaran tanda:** Tanda Kecil (moral dan sosial), Tanda Tengah (peralihan kepemimpinan), Tanda Besar (sepuluh peristiwa luar biasa)."),
        CAP("al-Iqlid, hlm. 51 · an-Nubdzah ash-Shughra, hlm. 31"),
    ]),
    68: dict(blocks=[
        P("**Cabang 5 (Bagian A): agama dan sejarah**"),
        P("Sejarah bukan sekadar urutan kejadian materi, tetapi bergerak di bawah takdir Allah melalui **empat alam**:"),
        OL("**Alam Azal** (عَالَمُ الأَزَلِ): ketetapan takdir dan skenario penciptaan.",
           "**Alam Ajal dan Amal** (عَالَمُ الأَجَلِ وَالأَمَلِ): sejarah hidup manusia di bumi, dari Nabi Adam hingga akhir zaman.",
           "**Alam Amad** (عَالَمُ الأَمَدِ): barzakh, kebangkitan, Mahsyar, dan hisab.",
           "**Alam Abad** (عَالَمُ الأَبَدِ): kehidupan abadi di surga atau neraka."),
        CAP("al-Iqlid, hlm. 56 · Ighatsat ash-Sharikh, hlm. 10"),
    ]),
    70: dict(blocks=[
        P("**Muara lima cabang: keselamatan dan jalan tengah**"),
        P("Lima cabang ini dirumuskan bukan untuk berdebat, melainkan sebagai perisai bagi empat pilar agama, agar lahir:"),
        UL("**Selamat lisan** dari mencela, takfir, tabdi', dan ujaran kebencian.",
           "**Selamat tangan** dari pertumpahan darah dan kekerasan sosial.",
           "**Selamat hati** dari penyakit umat terdahulu: dengki, hasad, dan merasa lebih baik dari orang lain.",
           "**Selamat wadah** dari politisasi praktis, bagi individu, lembaga, pesantren, dan majelis taklim.",
           "**Fokus pada *al-khuwayshah*** (الخُوَيْصَةُ): iman pribadi, ketahanan keluarga, dan majelis ilmu bersanad sebagai benteng terakhir di era *Ghutsaiyyah*."),
        CAP("an-Nubdzah ash-Shughra, hlm. 60 · Dawa'ir al-I'adah, hlm. 36"),
    ]),
    10: dict(blocks=[
        P("**Tiga pertanyaan pertama telah terjawab.**"),
        {"trio": [
            {"t": "Islam", "b": "Kepatuhan amal anggota tubuh lahiriah.", "tag": "Syariah"},
            {"t": "Iman", "b": "Keyakinan kokoh di dalam akal dan hati.", "tag": "Akidah"},
            {"t": "Ihsan", "b": "Kebersihan jiwa dan kesadaran diawasi Allah.", "tag": "Tazkiyah"},
        ]},
    ]),
    78: dict(blocks=[
        P("**Catatan penting sebelum memulai:** Kelima asisten AI ini **tidak mengeluarkan fatwa baru** dan "
          "**tidak menggantikan peran guru atau ulama bersanad**. Tugasnya menjadi **pemandu perpustakaan** "
          "yang memudahkan Anda mencari, memahami, dan menguji pelajaran dari **58 kitab tertulis** dan "
          "**arsip ceramah dan daurah** Al-Habib Abu Bakar Al-‘Adni Al-Masyhur."),
    ]),
}

NEW = {
    "N1": dict(bab=3, lvl="●", blocks=[
        P("**Dua cara membaca peristiwa.**"),
        {"table": {"head": ["", "Pembacaan positivistik", "Pembacaan syar'i"], "rows": [
            ["**Waktu bersikap**", "Mengekor: mencari pembenaran *setelah* peristiwa terjadi",
             "**Antisipatif:** menentukan sikap dengan wahyu *sebelum* peristiwa terjadi"],
            ["**Hasilnya**", "Bingung dan ikut arus", "**Siap, tenang, dan terarah**"],
        ]}},
        P("Karena itu Fikih Tahawwulat mendesak dipelajari di tengah upaya memisahkan agama dari ekonomi dan media."),
        CAP("Ighatsat ash-Sharikh"),
    ]),
    "N3": dict(bab=4, lvl="●", blocks=[
        P("**Ilmu tidak berlawanan dengan agama.**"),
        UL("Pintu ilmu empiris terbuka bagi siapa saja yang menempuh sebab-sebabnya, mukmin maupun kafir, sesuai sunnatullah.",
           "Karena itu kaum Muslimin wajib membangkitkan sains dan menggali isyaratnya dari Al-Qur'an.",
           "Penemuan seperti pesawat terbang berdiri di atas hukum alam yang Allah titipkan pada ciptaan-Nya."),
        CAP("Ighatsat ash-Sharikh"),
    ]),
    "N2": dict(bab=4, lvl="●", blocks=[
        P("**Cabang 5 (Bagian B): wahyu didahulukan atas klaim sejarah.**"),
        UL("Teks Al-Qur'an terjaga dari perubahan, sedangkan kitab-kitab terdahulu berlaku sementara.",
           "Contohnya, Nabi Ibrahim tidak bisa disebut Yahudi atau Nasrani, sebab Taurat dan Injil turun berabad-abad setelah beliau.",
           "Bila klaim sejarah bertentangan dengan nash wahyu yang terjaga, **nash didahulukan** dan klaim itu dihukumi batal."),
        CAP("Ighatsat ash-Sharikh"),
    ]),
    "N4": dict(bab=5, lvl="●", blocks=[
        P("**Saat umat lemah seperti buih, benahi lingkaran terdekat.**"),
        P("Bila keputusan bersama umat sudah hilang, tugas kita adalah memperbaiki *al-khuwayshah*: diri sendiri, "
          "keluarga, dan murid. Larut dalam slogan besar hanya menguras tenaga tanpa hasil nyata."),
        CAP("Ighatsat ash-Sharikh"),
    ]),
}

ORDER = (list(range(1, 55)) + ["N1"] + list(range(58, 67)) + ["N3", 67, 68, "N2", 70]
         + list(range(71, 75)) + ["N4", 75, 76] + list(range(77, 85)))


def clean(s):
    s = s.replace(" :Rusaknya", ": Rusaknya")
    s = s.replace(" (*muhadharah*)", "").replace("rekaman resmi", "arsip resmi")
    s = s.replace("rekaman aslinya", "sumber aslinya")
    s = re.sub(r"\s+ﷺ", " ﷺ", s)
    return s


def walk(o):
    if isinstance(o, str):
        return clean(o)
    if isinstance(o, list):
        return [walk(x) for x in o]
    if isinstance(o, dict):
        return {k: walk(v) for k, v in o.items()}
    return o


def title_parts(p):
    m = re.match(r"^\*\*(.+?)\*\*\s+\*\*(.+?)\*\*\s+\*(.+)\*$", p)
    return m.groups() if m else None


slides = []
for key in ORDER:
    if isinstance(key, int):
        s = SRC[str(key)]
        blocks = MANUAL.get(key, {}).get("blocks", s["blocks"])
        if key == 2:
            blocks = [{"lines": blocks[0]["ol"]}]
        lvl = s["lvl"] or "●"
        bab = bab_of(key)
        scene = f"s{key}"
    else:
        s = NEW[key]
        blocks, lvl, bab, scene = s["blocks"], s["lvl"], s["bab"], key.lower()
    d = {"scene": scene, "bab": bab, "lvl": {"●": "full", "◐": "still", "○": "text"}[lvl]}
    first = blocks[0].get("p") if blocks else None
    tp = title_parts(first) if first else None
    if tp:
        d["kind"] = "title"
        d["kicker"], d["title"], d["sub"] = tp
        if key == 1:
            d["kicker"], d["title"] = "Mengenal", "Fikih Tahawwulat"
    else:
        d["kind"] = "body"
        d["blocks"] = blocks
    slides.append(walk(d))

# Terjemahan EN/AR (i18n/t*.py: indeks unit -> (en, ar); i18n/units.json: urutan unit Indonesia).
import importlib.util
UNITS = json.loads((HERE / "i18n" / "units.json").read_text("utf8"))
TR = {}
for n in range(4):
    spec = importlib.util.spec_from_file_location(f"t{n}", HERE / "i18n" / f"t{n}.py")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    TR.update(mod.T)
assert len(TR) == len(UNITS), (len(TR), len(UNITS))
BY = {u: TR[i] for i, u in enumerate(UNITS)}
SKIP = {"scene", "bab", "lvl", "kind", "ar"}


def tr(o, k):
    if isinstance(o, str):
        if o not in BY:
            raise SystemExit("unit tanpa terjemahan: " + o[:60])
        return clean(BY[o][k])
    if isinstance(o, list):
        return [tr(x, k) for x in o]
    if isinstance(o, dict):
        return {a: (b if a in SKIP else tr(b, k)) for a, b in o.items()}
    return o


for d in slides:
    d["i18n"] = {
        lang: {a: tr(b, k) for a, b in d.items() if a not in SKIP | {"i18n"}}
        for lang, k in (("en", 0), ("ar", 1))
    }

OUT.write_text(json.dumps({"bab": BAB, "slides": slides}, ensure_ascii=False, indent=1), "utf8")
print(len(slides), "slide ->", OUT)
