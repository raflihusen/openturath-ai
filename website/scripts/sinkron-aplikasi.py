#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""V7: bangun content/catalog.json dan content/katalog/<slug>.json dari aset aplikasi OpenTurath.
Sumber angka: 03_APLIKASI_OPENTURATH_DEV/assets/data/info_ai.json (sama dengan tombol info aplikasi).
Nama dan deskripsi: teks live openturath.id (_referensi_live/deskripsi_live.json) dengan koreksi V7 di bawah.
Tidak ada angka yang diketik tangan."""
import json, os, shutil
R = os.path.dirname(os.path.dirname(os.path.abspath(__file__))) + '/'
APP = os.path.normpath(R + '../03_APLIKASI_OPENTURATH_DEV/assets/data') + '/'
INFO = {e['id']: e for e in json.load(open(APP + 'info_ai.json', encoding='utf-8'))}
LIVE = json.load(open(R + '_referensi_live/deskripsi_live.json', encoding='utf-8'))
AR = str.maketrans('0123456789', '٠١٢٣٤٥٦٧٨٩')

# slug website (dipertahankan demi tautan lama) -> id aplikasi, rumpun filter, varian kartu
URUT = [
    ('fiqh-tahawwulat', 'fiqh_tahawwulat', 'special', 'sovereign'),
    ('fiqh-syafii', 'fiqh_syafii', 'fiqh', 'featured'),
    ('hadits', 'hadits', 'hadith', 'featured'),
    ('tafsir', 'tafsir', 'quran', 'standard'),
    ('ushul-fiqh', 'ushul_fiqh', 'fiqh', 'standard'),
    ('bahasa-arab', 'nahwu_sharaf', 'language', 'standard'),
    ('fiqh-hanafi', 'fiqh_hanafi', 'fiqh', 'standard'),
    ('fiqh-maliki', 'fiqh_maliki', 'fiqh', 'standard'),
    ('fiqh-hanbali', 'fiqh_hanbali', 'fiqh', 'standard'),
    ('fiqh-muqaran', 'fiqh_muqaran', 'fiqh', 'standard'),
    ('syarah-hadits', 'syarah_hadits', 'hadith', 'standard'),
    ('musthalah-hadits', 'musthalah_hadits', 'hadith', 'standard'),
    ('thabaqat-tarajim', 'thabaqat_tarajim', 'history', 'standard'),
    ('tarikh-sirah', 'tarikh', 'history', 'standard'),
    ('aqidah', 'aqidah', 'theology', 'standard'),
    ('tasawwuf', 'tasawwuf', 'spirituality', 'standard'),
    ('tajwid-qiraat', 'tajwid_qiraat', 'quran', 'standard'),
    ('bibliografi-faharis', 'bibliografi_faharis', 'language', 'standard'),
]
# AI yang dilebur: slug lama -> slug tujuan (untuk pengalihan)
DILEBUR = {'fatawa-masail': 'fiqh-muqaran', 'qawaid-fiqhiyyah': 'ushul-fiqh'}

NAMA_EN = {
    'fiqh-tahawwulat': 'AI Fiqh al-Tahawwulat', 'fiqh-syafii': 'AI Shāfiʿī Fiqh', 'hadits': 'AI Hadith', 'tafsir': 'AI Tafsir',
    'ushul-fiqh': 'AI Uṣūl & Legal Maxims', 'bahasa-arab': 'AI Arabic Language', 'fiqh-hanafi': 'AI Ḥanafī Fiqh', 'fiqh-maliki': 'AI Mālikī Fiqh',
    'fiqh-hanbali': 'AI Ḥanbalī Fiqh', 'fiqh-muqaran': 'AI Comparative Fiqh & Fatwa', 'syarah-hadits': 'AI Hadith Commentary',
    'musthalah-hadits': 'AI Hadith Sciences', 'thabaqat-tarajim': 'AI Narrators & Biographies', 'tarikh-sirah': 'AI History & Sīra',
    'aqidah': 'AI ʿAqīda', 'tasawwuf': 'AI Taṣawwuf', 'tajwid-qiraat': "AI Tajwīd & Qirāʾāt", 'bibliografi-faharis': 'AI Bibliography',
}
# Deskripsi: teks live, kecuali yang dikoreksi atau dilebur
DESK = {
    'syarah-hadits': {
        'id': 'Dalami kandungan hadis melalui Fathul Bari, Umdatul Qari, dan Syarah Shahih Muslim karya an-Nawawi. Temukan penjelasan lafaz, faedah hukum, dan perbedaan pembacaan para pensyarah.',
        'en': 'Study the meanings of hadith through Fatḥ al-Bārī, ʿUmdat al-Qārī, and al-Nawawī’s commentary on Ṣaḥīḥ Muslim. Explore word explanations, legal benefits, and the readings of different commentators.',
        'ar': 'تعمّق في معاني الحديث من خلال فتح الباري وعمدة القاري وشرح النووي على صحيح مسلم، وتتبّع بيان الألفاظ والفوائد الفقهية واختلاف أنظار الشراح.'},
    'fiqh-muqaran': {
        'id': 'Bandingkan dalil dan konstruksi hukum antarmazhab melalui Al-Isyraf dan Al-Awsath karya Ibnu al-Mundzir serta Al-Fiqh al-Islami wa Adillatuh. Telusuri fatwa dan nawazil, siyasah syar’iyyah, serta pembagian faraidh.',
        'en': 'Compare evidence and legal reasoning across the schools through Ibn al-Mundhir’s al-Ishrāf and al-Awsaṭ and al-Fiqh al-Islāmī wa-Adillatuh. Trace fatwas and new cases, Islamic governance, and inheritance shares.',
        'ar': 'قارن الأدلة وبناء الأحكام بين المذاهب من خلال الإشراف والأوسط لابن المنذر والفقه الإسلامي وأدلته، وتتبّع الفتاوى والنوازل والسياسة الشرعية وقسمة الفرائض.'},
    'ushul-fiqh': {
        'id': 'Kaji dalalatul alfaz, qiyas, dan metode istinbath lintas empat mazhab melalui Al-Mustashfa, Al-Luma’, dan Al-Burhan. Hubungkan dengan kaidah fikih dan al-asybah wan-nazha’ir beserta pengecualiannya.',
        'en': 'Study linguistic indications, analogy, and methods of derivation across the four schools through al-Mustaṣfā, al-Lumaʿ, and al-Burhān, together with legal maxims, al-ashbāh wa-l-naẓāʾir, and their exceptions.',
        'ar': 'ادرس دلالات الألفاظ والقياس ومناهج الاستنباط عند المذاهب الأربعة من خلال المستصفى واللمع والبرهان، واربطها بالقواعد الفقهية والأشباه والنظائر ومستثنياتها.'},
}

katalog_dir = R + 'content/katalog/'; os.makedirs(katalog_dir, exist_ok=True)
out = []
for i, (slug, aid, grup, varian) in enumerate(URUT, 1):
    info = INFO[aid]; isi = info['isi']; cara = info['cara_disusun']; lv = LIVE.get(slug, {})
    r = isi.get('rentang_wafat_pengarang') or {}
    if r and r.get('sebelum_hijrah'):   # penyair jahili: wafat sebelum Hijrah (lihat 32_koreksi_wafat.py)
        periode = {'id': 'pra-Hijrah – w. %d H' % r['akhir'], 'en': 'pre-Hijra – d. %d AH' % r['akhir'], 'ar': 'قبل الهجرة – ت %s هـ' % str(r['akhir']).translate(AR)}
    elif r and r.get('awal'):
        periode = {'id': 'w. %d – %d H' % (r['awal'], r['akhir']), 'en': 'd. %d–%d AH' % (r['awal'], r['akhir']), 'ar': 'ت %s–%s هـ' % (str(r['awal']).translate(AR), str(r['akhir']).translate(AR))}
    else:
        periode = {'id': 'w. 1443 H', 'en': 'd. 1443 AH', 'ar': 'ت ١٤٤٣ هـ'}
    desk = DESK.get(slug) or {l: lv[l][1] for l in ('id', 'en', 'ar')}
    out.append({
        'id': slug, 'sourceId': aid, 'index': i, 'appAgentId': aid, 'metadataKey': aid, 'group': grup, 'variant': varian, 'status': 'active',
        'name': {'id': info['judul'], 'en': NAMA_EN[slug], 'ar': info['nama_arab']}, 'arabic': info['nama_arab'],
        'description': desk, 'countsPublished': True,
        'source': 'assets/data/info_ai.json aplikasi OpenTurath (V9.2)',
        'metadata': {'books': isi['jumlah_kitab'], 'words': isi['jumlah_kata'], 'lectures': isi.get('jumlah_muhadharah') or 0,
                     'partitions': cara['berkas_notebooklm'], 'volumes': isi.get('jumlah_jilid'), 'period': periode},
        'info': info,
    })
    shutil.copy(APP + 'katalog/%s.json' % aid, katalog_dir + slug + '.json')
json.dump(out, open(R + 'content/catalog.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
shutil.copy(APP + 'info_ai.json', R + 'content/metadata/info_ai.json')
json.dump(DILEBUR, open(R + 'content/pengalihan.json', 'w', encoding='utf-8'), ensure_ascii=False, indent=1)
tot = {k: sum(c['metadata'][k] for c in out) for k in ('books', 'words', 'lectures', 'partitions')}
print('AI:', len(out), '| total:', tot)
