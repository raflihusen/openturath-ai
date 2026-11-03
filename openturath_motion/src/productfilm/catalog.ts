// All 18 parent agents from AgentModel.defaultAgents, not Tahawwulat sub-agents.
// Editorial grouping only; live availability follows account/configuration.
export const CATALOG = [
  { id: "fiqh_tahawwulat", name: "Fikih Tahawwulat", arabic: "فقه التحولات" },
  { id: "fiqh_syafii", name: "Fikih Syafi'i", arabic: "الفقه الشافعي" },
  { id: "fiqh_hanafi", name: "Fikih Hanafi", arabic: "الفقه الحنفي" },
  { id: "fiqh_maliki", name: "Fikih Maliki", arabic: "الفقه المالكي" },
  { id: "fiqh_hanbali", name: "Fikih Hanbali", arabic: "الفقه الحنبلي" },
  {
    id: "fiqh_muqaran",
    name: "Perbandingan Mazhab & Fatwa",
    arabic: "الفقه المقارن والفتاوى",
  },
  { id: "hadits", name: "Hadits", arabic: "الحديث الشريف" },
  { id: "syarah_hadits", name: "Syarah Hadits", arabic: "شروح الحديث النبوي" },
  { id: "musthalah_hadits", name: "Ilmu Hadits", arabic: "مصطلح الحديث" },
  {
    id: "thabaqat_rijal",
    name: "Rijal & Biografi Ulama",
    arabic: "طبقات المحدثين ورجال الأسانيد",
  },
  { id: "tafsir", name: "Tafsir", arabic: "التفسير وعلوم القرآن" },
  {
    id: "tajwid_qiraat",
    name: "Tajwid & Qira'at",
    arabic: "التجويد والقراءات",
  },
  {
    id: "ushul_fiqh",
    name: "Ushul & Kaidah Fikih",
    arabic: "أصول الفقه والقواعد الفقهية",
  },
  { id: "nahwu_sharaf", name: "Bahasa Arab", arabic: "علوم العربية" },
  { id: "aqidah", name: "Aqidah", arabic: "العقيدة والتوحيد" },
  { id: "tasawwuf", name: "Tasawuf", arabic: "التصوف والأذكار" },
  { id: "tarikh", name: "Sejarah & Sirah", arabic: "السيرة والتاريخ" },
  {
    id: "bibliografi_faharis",
    name: "Bibliografi Kitab",
    arabic: "فهارس التراث والببليوغرافيا",
  },
] as const;
