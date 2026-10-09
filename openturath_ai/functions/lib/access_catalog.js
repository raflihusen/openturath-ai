"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ENTITY_SCOPES = exports.AGENT_ENTITLEMENTS = void 0;
const notebook_catalog_1 = require("./notebook_catalog");
exports.AGENT_ENTITLEMENTS = {
    // Fikih Tahawwulat (Sovereign Flagship)
    fiqh_tahawwulat: "fiqh_tahawwulat",
    fiqh_tahawwulat_muhaqqiq: "fiqh_tahawwulat",
    fiqh_tahawwulat_bayan: "fiqh_tahawwulat",
    fiqh_tahawwulat_mukhtabir: "fiqh_tahawwulat",
    fiqh_tahawwulat_habib: "fiqh_tahawwulat",
    fiqh_tahawwulat_khatib: "fiqh_tahawwulat",
    // 4 Mazhab Fikih & Muqaran
    fiqh_syafii: "fiqh_syafii",
    fiqh_syafii_muhaqqiq: "fiqh_syafii",
    fiqh_hanafi: "fiqh_hanafi",
    fiqh_hanafi_muhaqqiq: "fiqh_hanafi",
    fiqh_maliki: "fiqh_maliki",
    fiqh_maliki_muhaqqiq: "fiqh_maliki",
    fiqh_hanbali: "fiqh_hanbali",
    fiqh_hanbali_muhaqqiq: "fiqh_hanbali",
    fiqh_hambali: "fiqh_hanbali",
    fiqh_muqaran: "fiqh_muqaran",
    fiqh_muqaran_muhaqqiq: "fiqh_muqaran",
    fatawa_masail: "fiqh",
    fatawa_dan_masail: "fiqh",
    fatawa: "fiqh",
    // Kaidah & Ushul Fikih
    qawaid_fiqhiyyah: "ushul_fiqh",
    usul_qawaid: "ushul_fiqh",
    qawaid: "ushul_fiqh",
    ushul_fiqh: "ushul_fiqh",
    ushul_muhaqqiq: "ushul_fiqh",
    usul_maqashid: "ushul_fiqh",
    usul_istinbath: "ushul_fiqh",
    // Bahasa & Sastra Arab
    nahwu_sharaf: "nahwu",
    nahwu_sharaf_muerib: "nahwu",
    nahwu_sharaf_tashrif: "nahwu",
    bahasa_arab: "nahwu",
    lughah_nahwu: "nahwu",
    lughah_sharaf: "nahwu",
    lughah_balaghah: "nahwu",
    lughah_mujam: "nahwu",
    // Tafsir & Al-Qur'an
    tafsir: "tafsir",
    tafsir_muhaqqiq: "tafsir",
    tafsir_ahkam: "tafsir",
    tafsir_matsur: "tafsir",
    tafsir_ulumul_quran: "tafsir",
    tajwid_qiraat: "tafsir",
    tajwid: "tafsir",
    qiraat: "tafsir",
    // Hadits & Syarah
    hadits: "hadits",
    hadits_muhaqqiq: "hadits",
    hadits_syarah: "hadits",
    syarah_hadits: "hadits",
    hadits_takhrij: "hadits",
    hadits_ilal: "hadits",
    musthalah_hadits: "hadits",
    // Akidah & Teologi
    aqidah: "aqidah",
    aqidah_kalam: "aqidah",
    aqidah_ushuluddin: "aqidah",
    ushuluddin: "aqidah",
    // Sejarah, Sirah & Biografi
    tarikh: "tarikh",
    tarikh_khulafa: "tarikh",
    sirah: "tarikh",
    tarikh_thabaqat: "tarikh",
    thabaqat_rijal: "tarikh",
    // Tasawwuf & Ulama
    tasawwuf: "tasawwuf",
    tasawwuf_adzkar: "tasawwuf",
    tasawwuf_ihya: "tasawwuf",
    tasawwuf_adab: "tasawwuf",
    habib_umar: "tasawwuf",
    imam_ghazali: "tasawwuf",
    // Bibliografi & Faharis
    bibliografi_faharis: "bibliografi_faharis",
    faharis: "bibliografi_faharis",
    bibliografi: "bibliografi_faharis",
    all_ai: "all_access",
};
exports.ENTITY_SCOPES = {};
for (const [agent, entity] of Object.entries(notebook_catalog_1.AGENT_TO_ENTITY)) {
    const scope = exports.AGENT_ENTITLEMENTS[agent];
    if (!scope)
        continue;
    if (exports.ENTITY_SCOPES[entity] && exports.ENTITY_SCOPES[entity] !== scope)
        throw new Error(`Conflicting scope for ${entity}`);
    exports.ENTITY_SCOPES[entity] = scope;
}
for (const [agent, entity] of Object.entries(notebook_catalog_1.AGENT_TO_ENTITY)) {
    if (!exports.ENTITY_SCOPES[entity])
        throw new Error(`Missing scope for ${entity}`);
    exports.AGENT_ENTITLEMENTS[agent] = exports.ENTITY_SCOPES[entity];
}
//# sourceMappingURL=access_catalog.js.map