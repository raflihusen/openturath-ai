"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.PROVISIONABLE_SCOPES = exports.SCOPE_LABELS = exports.AKAL_SERVICES = exports.ENTITY_SCOPES = exports.AGENT_ENTITLEMENTS = void 0;
exports.resolveAkalScopes = resolveAkalScopes;
exports.sharedCatalog = sharedCatalog;
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
// ================================================================
// GoAkal product catalog — single source for Cloud Functions, the VPS
// worker and (via `npm run export-shared`) the Python automation.
// Every scope here must be a scope an agent actually requires.
// ================================================================
const SULTAN_SCOPES = [
    "all_access", "fiqh_tahawwulat", "fiqh_syafii", "fiqh_hanafi", "fiqh_maliki", "fiqh_hanbali",
    "fiqh_muqaran", "fiqh", "ushul_fiqh", "nahwu", "tafsir", "hadits", "aqidah", "tasawwuf",
    "tarikh", "bibliografi_faharis",
];
exports.AKAL_SERVICES = [
    { cuid: "cmln2i27k0000jx047oabzw8p", fallbacks: [], name: "AI Fikih Tahawwulat (5 Bilik AI)", scopes: ["fiqh_tahawwulat"] },
    { cuid: "cms4ls3j60001l20439k1nqh4", fallbacks: ["cms4ls3j60001l20439k1nph4"], name: "Super AI Fikih Syafi'i", scopes: ["fiqh_syafii"] },
    { cuid: "cmnd7l4o60002l504ab6qq31x", fallbacks: [], name: "Super AI Bahasa Arab", scopes: ["nahwu"] },
    { cuid: "cmu6hf53s000mkx04jc3vrj02", fallbacks: [], name: "Super AI Ushul Fikih", scopes: ["ushul_fiqh"] },
    { cuid: "cmu6hfbkn0015kx04d87j1b11", fallbacks: [], name: "Super AI Hadits Nabawi", scopes: ["hadits"] },
    { cuid: "cmu6hfi5o000cjt04xziipmr2", fallbacks: [], name: "Super AI Tafsir & Ulumul Qur'an", scopes: ["tafsir"] },
    { cuid: "cmu6hfq7m000cjm0414zlr67i", fallbacks: [], name: "Super AI Qawaid Fiqhiyyah", scopes: ["ushul_fiqh"] },
    { cuid: "cmu6hfx13000xjm04np32pb64", fallbacks: [], name: "Super AI Musthalah & Ulumul Hadits", scopes: ["hadits"] },
    { cuid: "cmu6hg3bh001gjm043hjueyh5", fallbacks: [], name: "Super AI Aqidah & Ushuluddin", scopes: ["aqidah"] },
    { cuid: "cmu6hg9wl001zjm04lyds535x", fallbacks: [], name: "Super AI Fikih Hanafi", scopes: ["fiqh_hanafi"] },
    { cuid: "cmu6hgh6r002ijm040qddnmph", fallbacks: [], name: "Super AI Fikih Maliki", scopes: ["fiqh_maliki"] },
    { cuid: "cmu6hgo4z0031jm04bpdj07ki", fallbacks: [], name: "Super AI Fikih Hanbali", scopes: ["fiqh_hanbali"] },
    { cuid: "cmu6hgv6n003kjm04tit1vsh8", fallbacks: [], name: "Super AI Fikih Muqaran & Siyasah", scopes: ["fiqh_muqaran"] },
    { cuid: "cmu6hh1nn0043jm04r4h40wdb", fallbacks: [], name: "Super AI Fatawa & Masail", scopes: ["fiqh"] },
    { cuid: "cmu6hh86n004mjm04ejgkhlg1", fallbacks: [], name: "Super AI Tasawwuf & Adzkar", scopes: ["tasawwuf"] },
    { cuid: "cmu6hhet70055jm04ew3lb6wq", fallbacks: [], name: "Super AI Tajwid & Qiraat", scopes: ["tafsir"] },
    { cuid: "cmu6hhl7a005ojm04pgptpegm", fallbacks: [], name: "Super AI Tarikh & Sirah Nabawiyyah", scopes: ["tarikh"] },
    { cuid: "cmu6hhrvz0067jm04ljdfmycu", fallbacks: [], name: "Super AI Syarah Hadits", scopes: ["hadits"] },
    { cuid: "cmu6hhyby006qjm04e0l3p11r", fallbacks: [], name: "Super AI Thabaqat & Tarajim Rijal", scopes: ["tarikh"] },
    { cuid: "cmu6hi4lr0079jm0462vczjdm", fallbacks: [], name: "Super AI Bibliografi & Faharis Turath", scopes: ["bibliografi_faharis"] },
    // Thematic bundles
    { cuid: "cmu6rsq7z001gjn044acg1ke4", fallbacks: [], name: "Paket Fikih Pesantren & Santri Salaf", scopes: ["fiqh_syafii", "ushul_fiqh", "fiqh", "tasawwuf"] },
    { cuid: "cmu6rst3y001xjn0468aypvd0", fallbacks: [], name: "Paket Samudra Hadits & Sirah Nabawiyyah", scopes: ["hadits", "tarikh"] },
    { cuid: "cmu6rswk0002ejn04s90o870l", fallbacks: [], name: "Paket Mufassir & Khazanah Bahasa Arab", scopes: ["tafsir", "nahwu", "bibliografi_faharis"] },
    { cuid: "cmu6rt0ja002vjn04pimuyd84", fallbacks: [], name: "Paket Mufti, Mazhab Akbar & Pemikiran", scopes: ["fiqh_hanafi", "fiqh_maliki", "fiqh_hanbali", "fiqh_muqaran", "aqidah", "fiqh"] },
    { cuid: "cmu6rt3i6003cjn04wp9v6tqt", fallbacks: [], name: "Paket Khusus Fikih Tahawwulat", scopes: ["fiqh_tahawwulat"] },
    { cuid: "cmu6rt6aa003tjn04psx42goy", fallbacks: [], name: "Paket Sultan All-Access (Semua 24 AI)", scopes: SULTAN_SCOPES },
];
// Labels the legacy sharing server and older transactions use for a scope.
exports.SCOPE_LABELS = {
    all_access: "Paket Semua AI",
    fiqh_tahawwulat: "AI Fikih Tahawwulat",
    fiqh_syafii: "AI Fikih Syafi'i",
    fiqh_hanafi: "AI Fikih Hanafi",
    fiqh_maliki: "AI Fikih Maliki",
    fiqh_hanbali: "AI Fikih Hanbali",
    fiqh_muqaran: "AI Fikih Perbandingan Mazhab",
    fiqh: "AI Fatawa & Masail",
    ushul_fiqh: "AI Ushul Fiqih",
    tafsir: "AI Tafsir",
    hadits: "AI Hadits",
    nahwu: "AI Bahasa Arab",
    aqidah: "AI Aqidah & Ushuluddin",
    tarikh: "AI Tarikh & Sirah Nabawiyah",
    tasawwuf: "AI Tasawwuf & Tazkiyatun Nafs",
    bibliografi_faharis: "AI Bibliografi & Faharis",
};
// Ordered most-specific first. A title matching nothing is NOT guessed:
// callers must quarantine it for operator review.
const SERVICE_KEYWORDS = [
    [/sultan|all[- ]access|semua (24 )?ai|paket semua/, SULTAN_SCOPES],
    [/tahaww?ulat/, ["fiqh_tahawwulat"]],
    [/syafi/, ["fiqh_syafii"]],
    [/hanafi/, ["fiqh_hanafi"]],
    [/maliki/, ["fiqh_maliki"]],
    [/han[bm]ali/, ["fiqh_hanbali"]],
    [/muqaran|perbandingan mazhab/, ["fiqh_muqaran"]],
    [/fatawa|masail/, ["fiqh"]],
    [/a[qk]idah|ushuluddin/, ["aqidah"]],
    [/qawaid|ushul fi[kq]/, ["ushul_fiqh"]],
    [/hadi[ts]|musthalah/, ["hadits"]],
    [/tafsir|tajwid|qiraat/, ["tafsir"]],
    [/bahasa arab|nahwu|sharaf/, ["nahwu"]],
    [/tasaww?uf|adzkar/, ["tasawwuf"]],
    [/tarikh|sirah|thabaqat|tarajim|rijal/, ["tarikh"]],
    [/bibliografi|faharis/, ["bibliografi_faharis"]],
];
function resolveAkalScopes(serviceTitle) {
    const title = typeof serviceTitle === "string" ? serviceTitle.trim().toLowerCase() : "";
    if (!title)
        return [];
    const exact = exports.AKAL_SERVICES.find(s => s.name.toLowerCase() === title);
    if (exact)
        return [...exact.scopes];
    const label = Object.entries(exports.SCOPE_LABELS).find(([, name]) => name.toLowerCase() === title);
    if (label)
        return label[0] === "all_access" ? [...SULTAN_SCOPES] : [label[0]];
    for (const [pattern, scopes] of SERVICE_KEYWORDS)
        if (pattern.test(title))
            return [...scopes];
    return [];
}
// Every scope that maps to at least one notebook entity can be provisioned.
exports.PROVISIONABLE_SCOPES = [...new Set(Object.values(exports.ENTITY_SCOPES))].sort();
for (const service of exports.AKAL_SERVICES)
    for (const scope of service.scopes) {
        if (scope !== "all_access" && !exports.PROVISIONABLE_SCOPES.includes(scope))
            throw new Error(`Unprovisionable GoAkal scope ${scope}`);
    }
// Serialized for the Python automation (ecosystem/openturath_subscription/shared).
function sharedCatalog() {
    const scopes = {};
    for (const scope of exports.PROVISIONABLE_SCOPES) {
        scopes[scope] = { label: exports.SCOPE_LABELS[scope] || scope, notebooks: Object.entries(exports.ENTITY_SCOPES)
                .filter(([, s]) => s === scope).map(([entity]) => entity).sort()
                .map(entity => ({ entity, master: notebook_catalog_1.NOTEBOOK_ENTITIES[entity].masterId, legacy: notebook_catalog_1.NOTEBOOK_ENTITIES[entity].legacyIds || [] })) };
    }
    return { scopes, all_access_scopes: SULTAN_SCOPES.filter(s => s !== "all_access"),
        akal_services: exports.AKAL_SERVICES, keywords: SERVICE_KEYWORDS.map(([pattern, s]) => [pattern.source, s]) };
}
//# sourceMappingURL=access_catalog.js.map