// Illustrative answer authored for the film, checked against Safinat al-Naja.
// This is not a recording of a live model response. See PRODUCT_TRUTH.md.
export const DEMO = {
  question: "Apa saja rukun wudu dalam mazhab Syafi’i?",
  title: "Rukun wudu",
  introduction: "Fardu wudu ada enam:",
  items: [
    "Niat",
    "Membasuh wajah",
    "Membasuh kedua tangan hingga siku",
    "Mengusap sebagian kepala",
    "Membasuh kedua kaki hingga mata kaki",
    "Tertib",
  ],
  excerpt: "فُرُوضُ الوُضُوءِ سِتَّةٌ",
  book: "Safinatun Najah",
  section: "Fasal fardu wudu",
  qualifier: "Contoh ilustratif · proses dipersingkat",
} as const;

export const FIELDS = [
  ["AI Fikih", "الفقه"],
  ["AI Hadis", "الحديث"],
  ["AI Tafsir", "التفسير"],
  ["AI Akidah", "العقيدة"],
  ["AI Usul Fikih", "أصول الفقه"],
  ["AI Bahasa Arab", "علوم العربية"],
] as const;

export const ASSISTANTS = [
  ["Fikih Syafi’i", "الشافعي"],
  ["Fikih Hanafi", "الحنفي"],
  ["Fikih Maliki", "المالكي"],
  ["Fikih Hanbali", "الحنبلي"],
  ["Perbandingan Mazhab & Fatwa", "الفقه المقارن"],
] as const;
