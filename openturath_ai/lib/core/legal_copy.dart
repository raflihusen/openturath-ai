/// LegalCopy: Sumber data dan teks kanonik hukum dan kebijakan OpenTurath.
/// Mengintegrasikan naskah resmi dari OpenTurath_Identitas_dan_Kebijakan.md.
/// Seluruh penanda placeholder [[...]] telah diselesaikan dengan nilai kanonik
/// dan mematuhi etika "The Quiet Scholar" (tanpa tanda seru, jujur, dan bersahaja).
library;

class LegalSection {
  final String id;
  final String title;
  final String content;

  const LegalSection({
    this.id = '',
    required this.title,
    required this.content,
  });
}

abstract final class LegalCopy {
  // ── Identitas & Versi Kebijakan ────────────────────────────────
  static const documentVersion = '1.0';
  static const effectiveDate = '13 September 2026';
  static const managerName = 'Pengelola OpenTurath';
  static const managerAddress = 'Indonesia';
  static const contactSupportEmail = 'support@openturath.id';
  static const contactPrivacyEmail = 'support@openturath.id';
  static const contactCopyrightEmail = 'support@openturath.id';
  static const serviceHours = 'Senin – Jumat, 09.00 – 17.00 WIB';
  static const supportSla = '2 (dua) hari kerja';
  static const refundSla = '7 (tujuh) hari kerja';

  // ── Bab 1.2: Tentang OpenTurath untuk Aplikasi ─────────────────
  static const aboutAppTitle = 'Tentang OpenTurath';
  static const aboutAppTagline = 'AI for Islamic Scholarship';

  static const aboutAppParagraph1 =
      'OpenTurath membantu Anda menelusuri pembahasan dan rujukan dalam kitab-kitab Islam dengan bantuan AI. '
      'Pilih bidang yang ingin dipelajari, ajukan pertanyaan, lalu baca kutipan dan keterangan kitab yang tersedia. '
      'Simpan jawaban atau kutipan ke Catatan untuk dipelajari kembali.';

  static const aboutAppParagraph2 =
      'Kami ingin membuat proses mencari rujukan lebih mudah, sambil menjaga kebiasaan membaca sumber dengan teliti. '
      'Jawaban AI tetap perlu diperiksa pada kitab yang dirujuk, terutama sebelum digunakan untuk mengajar, menulis, atau mengambil kesimpulan. '
      'Pemahaman agama dan penetapan hukum tetap memerlukan bimbingan guru serta ulama yang berkompeten.';

  // ── Bab 2: Ketentuan Layanan (Terms of Service) ───────────────
  static const termsTitle = 'Ketentuan Layanan';

  static const List<LegalSection> termsSections = [
    LegalSection(
      id: 'terms_01',
      title: '1. Pengelola dan Cakupan Ketentuan',
      content:
          'OpenTurath dikelola oleh $managerName, beralamat di $managerAddress, selanjutnya disebut "kami". '
          'Pengguna aplikasi disebut "Anda". Kontak layanan tersedia melalui $contactSupportEmail.\n\n'
          'Ketentuan ini mengatur penggunaan akun, AI, katalog rujukan, Catatan, dan fitur berbayar yang disediakan melalui OpenTurath. '
          'Informasi paket yang ditampilkan sebelum pembelian, Kebijakan Pembayaran dan Pengembalian Dana, serta Panduan Penggunaan AI dan Pemeriksaan Rujukan menjadi bagian dari ketentuan penggunaan yang relevan.',
    ),
    LegalSection(
      id: 'terms_02',
      title: '2. Persetujuan dan Persyaratan Pengguna',
      content:
          'Sebelum membuat akun atau membeli paket, Anda diberi kesempatan membaca ketentuan yang berlaku. '
          'Penggunaan mandiri OpenTurath ditujukan bagi pengguna berusia sekurang-kurangnya 18 tahun. '
          'Anda juga harus memiliki kecakapan atau kewenangan yang diperlukan untuk membuat perjanjian dan melakukan pembayaran.\n\n'
          'Akses bagi pengguna di bawah 18 tahun belum dibuka melalui pendaftaran mandiri. '
          'Jika bertindak untuk lembaga, Anda harus berwenang mewakilinya. Pembelian individu tidak otomatis memberikan hak penggunaan bersama untuk seluruh anggota lembaga.',
    ),
    LegalSection(
      id: 'terms_03',
      title: '3. Akun dan Keamanan Akses',
      content:
          'Gunakan informasi akun yang benar dan akses masuk yang menjadi hak Anda. Akun bersifat pribadi, kecuali suatu paket secara tertulis menyediakan penggunaan untuk beberapa orang.\n\n'
          'Jaga perangkat dan akses masuk Anda. Jangan memberikan kata sandi atau kode sekali pakai kepada pihak lain. '
          'Laporkan dugaan penggunaan tanpa izin melalui $contactSupportEmail. '
          'Laporan pengambilalihan akun akan diperiksa berdasarkan keadaan dan bukti yang tersedia.',
    ),
    LegalSection(
      id: 'terms_04',
      title: '4. Fungsi Layanan dan Batas Jawaban AI',
      content:
          'OpenTurath membantu penelusuran literatur, pembacaan kutipan, dan penyusunan bahan belajar. '
          'Jawaban dapat mengandung kesalahan pada penjelasan, atribusi, terjemahan, atau keterangan rujukan.\n\n'
          'Periksa kutipan pada kitab dan edisi yang digunakan sebelum menjadikannya dasar tulisan, pengajaran, keputusan, atau penyampaian hukum kepada orang lain. '
          'Nomor halaman pada satu edisi tidak selalu sama dengan edisi lain.\n\n'
          'Jawaban AI bukan merupakan fatwa resmi, penetapan hukum yang mengikat, atau pengganti bimbingan guru dan ulama yang berkompeten. '
          'Tidak ditemukannya rujukan dalam hasil pencarian berarti layanan belum menemukannya pada penelusuran tersebut, bukan bukti bahwa pembahasannya tidak ada.',
    ),
    LegalSection(
      id: 'terms_05',
      title: '5. Paket, Pembayaran, dan Masa Akses',
      content:
          'Harga, cakupan AI, masa akses, batas penggunaan, kebutuhan akun pihak ketiga, serta biaya yang berlaku ditampilkan sebelum Anda membayar.\n\n'
          'Langganan diperpanjang secara manual. Kami tidak melakukan penagihan berulang otomatis (auto-debit) dari pembelian paket ini.\n\n'
          'Masa akses dimulai ketika aktivasi berhasil dan tanggal berakhir ditampilkan pada akun. '
          'Pembayaran diproses melalui Midtrans menurut metode yang tersedia pada saat transaksi. '
          'Keberhasilan pembayaran dan aktivasi akses adalah dua status yang berbeda. Jika dana telah dibayarkan namun langganan belum aktif, hubungi bantuan dengan nomor transaksi.',
    ),
    LegalSection(
      id: 'terms_06',
      title: '6. Layanan Pihak Ketiga (Infrastruktur Google)',
      content:
          'Fitur percakapan menggunakan teknologi komputasi riset dari Google. Aksesnya dapat bergantung pada akun, wilayah, batas penggunaan, dan ketentuan penyedia yang berlaku untuk Anda. '
          'Pembelian OpenTurath tidak dengan sendirinya mengubah jenis langganan atau hak akses akun Google Anda.\n\n'
          'Jika perubahan layanan pihak ketiga menyebabkan fitur berbayar tidak dapat diberikan sesuai yang ditawarkan, kami akan menilai pemulihan akses, penggantian layanan yang Anda setujui, atau pengembalian dana sesuai hak Anda.',
    ),
    LegalSection(
      id: 'terms_07',
      title: '7. Penggunaan yang Diperbolehkan dan Dilarang',
      content:
          'Anda dapat menggunakan layanan untuk belajar, menyiapkan pengajaran, dan melakukan penelusuran sesuai paket yang dimiliki. '
          'Penggunaan hasilnya tetap harus memperhatikan hak cipta, ketepatan atribusi, serta adab keilmuan.\n\n'
          'Dilarang menggunakan OpenTurath untuk mengambil alih akun, menghindari pembatasan akses secara tidak sah, menyebarkan perangkat lunak berbahaya, atau menjual kembali akses berbayar kepada pihak lain.\n\n'
          'Dilarang membuat atau menyebarkan kutipan yang sengaja dipalsukan dan diatasnamakan kepada ulama atau sumber tertentu. '
          'Pembahasan ilmiah yang sah, termasuk perbedaan pendapat dan kritik terhadap suatu penafsiran, tidak dengan sendirinya merupakan pelanggaran.',
    ),
    LegalSection(
      id: 'terms_08',
      title: '8. Catatan dan Materi Pengguna',
      content:
          'Hak atas tulisan atau catatan yang Anda buat tetap berada pada Anda. Anda memberi izin terbatas kepada kami untuk memproses dan menyimpan materi tersebut semata-mata untuk menjalankan fitur yang Anda pilih. '
          'Izin ini tidak memindahkan kepemilikan dan kami tidak menjual atau menerbitkan catatan pribadi Anda.\n\n'
          'Catatan disimpan secara lokal pada perangkat Anda melalui penyimpanan aplikasi. Gunakan fitur salin atau berbagi yang tersedia untuk mencadangkan materi penting.',
    ),
    LegalSection(
      id: 'terms_09',
      title: '9. Hak atas Aplikasi dan Kitab',
      content:
          'Hak atas perangkat lunak, tampilan, dan merek OpenTurath tetap berada pada pemegang haknya. '
          'Materi kitab, terjemahan, dan tahkik mengikuti status hak masing-masing.\n\n'
          'Akses berbayar tidak memindahkan hak cipta atas kitab atau memberi izin umum untuk menyebarluaskan seluruh isi kitab secara komersial. '
          'Penggunaan kutipan harus memperhatikan batas penggunaan wajar dan kewajiban atribusi.',
    ),
    LegalSection(
      id: 'terms_10',
      title: '10. Ketersediaan dan Perubahan Fitur',
      content:
          'Layanan dapat mengalami pemeliharaan berkala atau pembaruan teknis. Kami berupaya memberi pemberitahuan mengenai pemeliharaan terencana.\n\n'
          'Perubahan yang secara material mengurangi manfaat paket berbayar akan disertai pilihan penyelesaian yang wajar. '
          'Kami tidak menggunakan perubahan ketentuan untuk menghapus hak yang sudah timbul dari pembelian Anda.',
    ),
    LegalSection(
      id: 'terms_11',
      title: '11. Pembatasan dan Penutupan Akun',
      content:
          'Kami dapat membatasi akses jika terdapat dasar yang wajar mengenai pelanggaran serius, risiko keamanan, atau penggunaan tanpa hak. '
          'Tindakan disesuaikan dengan tingkat masalah, mulai dari peringatan, penghentian sementara, hingga penutupan akun.\n\n'
          'Jika keadaan memungkinkan, kami menyampaikan alasan dan memberi kesempatan klarifikasi melalui $contactSupportEmail.',
    ),
    LegalSection(
      id: 'terms_12',
      title: '12. Tanggung Jawab dan Hak Pengguna',
      content:
          'Kami bertanggung jawab menyediakan layanan sesuai perjanjian dan hukum yang berlaku. '
          'Penjelasan mengenai keterbatasan AI tidak menghapus kewajiban kami untuk memberikan informasi yang benar, menangani keluhan, atau menyelesaikan layanan berbayar.\n\n'
          'Anda bertanggung jawab menilai kesesuaian hasil untuk tujuan penggunaannya dan memeriksa sumber sebelum mengambil kesimpulan. '
          'Tidak ada ketentuan yang meniadakan hak konsumen yang dilindungi undang-undang.',
    ),
    LegalSection(
      id: 'terms_13',
      title: '13. Pengaduan dan Musyawarah',
      content:
          'Hubungi $contactSupportEmail dengan penjelasan masalah dan informasi yang relevan. '
          'Kami akan mencatat pengaduan, menyampaikan perkembangan penanganan dalam $supportSla, dan mengupayakan penyelesaian secara musyawarah.\n\n'
          'Ketentuan ini tunduk pada hukum Republik Indonesia.',
    ),
    LegalSection(
      id: 'terms_14',
      title: '14. Perubahan Ketentuan dan Kontak',
      content:
          'Versi dokumen: $documentVersion (Berlaku sejak $effectiveDate).\n\n'
          'Perubahan penting akan diberitahukan sebelum berlaku dan tidak berlaku surut untuk menghilangkan hak yang telah timbul.\n\n'
          'Pengelola: $managerName\n'
          'Alamat: $managerAddress\n'
          'Bantuan: $contactSupportEmail\n'
          'Privasi: $contactPrivacyEmail\n'
          'Hak Cipta: $contactCopyrightEmail',
    ),
  ];

  // ── Bab 3: Kebijakan Privasi (Privacy Policy) ──────────────────
  static const privacyTitle = 'Kebijakan Privasi';

  static const List<LegalSection> privacySections = [
    LegalSection(
      id: 'privacy_01',
      title: '1. Pengelola Data dan Ruang Lingkup',
      content:
          'Kebijakan Privasi ini menjelaskan pemrosesan data pribadi saat Anda menggunakan aplikasi OpenTurath, pembayaran, dan bantuan layanan. '
          '$managerName ($managerAddress) bertanggung jawab atas pemrosesan data yang tujuan dan caranya ditentukan oleh OpenTurath, sesuai UU Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi.\n\n'
          'Untuk pertanyaan privasi, hubungi $contactPrivacyEmail.',
    ),
    LegalSection(
      id: 'privacy_02',
      title: '2. Data yang Diproses',
      content: 'Kami memproses data sesuai fitur yang Anda gunakan:\n'
          '• Akun: Nama, alamat email, dan identitas profil publik dari akun Google untuk autentikasi dan personalisasi.\n'
          '• Langganan: Paket yang dipilih, status, masa aktif, dan penggunaan voucher.\n'
          '• Pembayaran: Nomor transaksi, jumlah pembayaran, metode, waktu, dan status dari penyedia Midtrans.\n'
          '• Kontak Transaksi: Nomor WhatsApp/telepon yang Anda berikan saat pembayaran untuk pengiriman informasi aktivasi.\n'
          '• Percakapan: Pertanyaan, jawaban, dan konteks percakapan yang diproses melalui sesi komputasi riset Google.\n'
          '• Catatan: Catatan, kutipan, dan rujukan yang Anda simpan pada penyimpanan lokal perangkat.\n'
          '• Bantuan: Alamat kontak, isi pengaduan, nomor transaksi, dan lampiran tangkapan layar untuk penanganan masalah.\n'
          '• Sesi Teknis: Token sesi autentikasi yang aman untuk mempertahankan login di perangkat.',
    ),
    LegalSection(
      id: 'privacy_03',
      title: '3. Tujuan dan Dasar Pemrosesan',
      content:
          'Data akun dan transaksi diproses untuk menyediakan layanan yang Anda minta, mengelola langganan, dan melaksanakan perjanjian. '
          'Pencatatan transaksi juga diperlukan untuk memenuhi kewajiban hukum administrasi perpajakan dan transaksi keuangan.\n\n'
          'Kami tidak menjual data pribadi Anda kepada pihak ketiga manapun, dan tidak menggunakan percakapan Anda untuk iklan bertarget.',
    ),
    LegalSection(
      id: 'privacy_04',
      title: '4. Percakapan AI dan Peran Google',
      content:
          'Ketika Anda mengirim pertanyaan melalui fitur percakapan, teks dan konteks diproses melalui teknologi komputasi riset Google. '
          'Kebijakan pemrosesan Google mengikuti Kebijakan Privasi Google dan ketentuan layanannya.\n\n'
          'Aplikasi OpenTurath tidak menggunakan isi percakapan atau catatan pribadi pengguna untuk melatih model kecerdasan buatan publik. '
          'Hindari memasukkan informasi pribadi sensitif atau rahasia ke dalam percakapan.',
    ),
    LegalSection(
      id: 'privacy_05',
      title: '5. Catatan dan Penyimpanan Perangkat',
      content:
          'Catatan, kutipan ibarah, dan penanda rujukan disimpan secara lokal di perangkat Anda menggunakan penyimpanan aplikasi. '
          'Jika Anda membersihkan data aplikasi atau mencopot pemasangan aplikasi, catatan lokal dapat terhapus. '
          'Gunakan fitur salin teks atau bagikan catatan untuk mencadangkan catatan penting Anda ke tempat penyimpanan lain.',
    ),
    LegalSection(
      id: 'privacy_06',
      title: '6. Penerima dan Penyedia Layanan',
      content:
          'Data dibagikan hanya sebatas yang diperlukan untuk menjalankan layanan:\n'
          '• Google: Untuk proses masuk autentikasi dan pemrosesan sesi percakapan komputasi riset Google.\n'
          '• Midtrans: Lembaga pembayaran resmi untuk memproses transaksi perbankan, dompet digital, atau QRIS.\n'
          '• Firebase / Google Cloud: Pengelolaan database transaksi dan status hak akses akun yang aman.\n\n'
          'Seluruh penyedia bekerja berdasarkan standar keamanan dan enkripsi industri.',
    ),
    LegalSection(
      id: 'privacy_07',
      title: '7. Kebijakan Iklan, Analitik, dan Promosi',
      content:
          'OpenTurath bebas dari iklan pihak ketiga dan tidak menjual data pribadi Anda. '
          'Pemberitahuan transaksi dan pembaruan layanan dikirimkan semata-mata untuk keperluan operasional akun Anda.',
    ),
    LegalSection(
      id: 'privacy_08',
      title: '8. Pemrosesan Data Lintas Wilayah',
      content:
          'Infrastruktur autentikasi Google dan basis data cloud dapat memproses sebagian data teknis di pusat data yang aman di dalam maupun luar wilayah Indonesia, dengan perlindungan enkripsi transit dan at-rest berstandar global.',
    ),
    LegalSection(
      id: 'privacy_09',
      title: '9. Masa Penyimpanan Data (Retensi)',
      content:
          '• Data Akun: Disimpan selama akun aktif, dan dihapus setelah permohonan penutupan akun disetujui.\n'
          '• Data Transaksi: Disimpan selama batas waktu yang diwajibkan oleh ketentuan perpajakan dan hukum transaksi keuangan Republik Indonesia.\n'
          '• Catatan Pengguna: Disimpan di perangkat Anda hingga Anda menghapusnya sendiri atau mencopot aplikasi.\n'
          '• Pengaduan Bantuan: Disimpan selama proses penyelesaian masalah dan pengarsipan layanan.',
    ),
    LegalSection(
      id: 'privacy_10',
      title: '10. Keamanan dan Perlindungan Data',
      content:
          'Kami menerapkan langkah-langkah pengamanan teknis, termasuk komunikasi terenkripsi SSL/TLS, pembatasan akses data, dan perlindungan token sesi. '
          'Kata sandi akun Google Anda tidak pernah disimpan di server OpenTurath.',
    ),
    LegalSection(
      id: 'privacy_11',
      title: '11. Hak Subjek Data Pengguna',
      content: 'Sesuai UU Perlindungan Data Pribadi, Anda berhak:\n'
          '• Mengakses dan memperoleh informasi mengenai data pribadi yang diproses.\n'
          '• Memperbarui atau memperbaiki data profil yang keliru.\n'
          '• Meminta penghapusan akun dan data pribadi Anda kapan saja melalui aplikasi.\n'
          '• Menyampaikan keberatan atau pertanyaan seputar privasi ke $contactPrivacyEmail.',
    ),
    LegalSection(
      id: 'privacy_12',
      title: '12. Pengguna di Bawah Umur',
      content:
          'Pendaftaran akun mandiri ditujukan bagi pengguna berusia 18 tahun ke atas. '
          'Jika Anda orang tua atau wali dan mendapati akun dibuka tanpa izin yang diperlukan, hubungi $contactPrivacyEmail untuk penanganan dan penghapusan data.',
    ),
    LegalSection(
      id: 'privacy_13',
      title: '13. Kontak dan Pembaruan Kebijakan',
      content:
          'Versi dokumen: $documentVersion (Berlaku sejak $effectiveDate).\n\n'
          'Untuk pertanyaan atau permohonan hak privasi, hubungi:\n'
          'Email: $contactPrivacyEmail\n'
          'Pengelola: $managerName ($managerAddress)',
    ),
  ];

  // ── Bab 4: Langganan, Pembayaran, dan Pengembalian Dana ────────
  static const refundTitle = 'Pembayaran dan Pengembalian Dana';

  static const List<LegalSection> refundSections = [
    LegalSection(
      id: 'refund_01',
      title: '1. Informasi Sebelum Pembelian',
      content:
          'Sebelum melakukan pembayaran, rincian harga total, cakupan modul AI, durasi masa akses, dan metode pembayaran ditampilkan secara jelas pada halaman langganan.\n\n'
          'Durasi paket 30 hari dihitung sebagai 30 hari kalender penuh sejak aktivasi berhasil. '
          'Perubahan harga di masa mendatang tidak akan memengaruhi paket yang sedang berjalan.',
    ),
    LegalSection(
      id: 'refund_02',
      title: '2. Pembayaran dan Aktivasi Akses',
      content:
          'Pembayaran diproses melalui gerbang pembayaran resmi Midtrans dengan metode QRIS, transfer bank (virtual account), maupun dompet digital.\n\n'
          'Bukti pembayaran resmi dikirimkan melalui notifikasi Midtrans dan email akun Anda. '
          'Masa akses aktif seketika transaksi dinyatakan berhasil dan tersinkronisasi. '
          'Jika dana telah terpotong namun status belum aktif, jangan melakukan pembayaran ulang; hubungi $contactSupportEmail dengan menyertakan nomor transaksi.',
    ),
    LegalSection(
      id: 'refund_03',
      title: '3. Perpanjangan Manual (Tanpa Auto-Debit)',
      content:
          'Seluruh paket langganan OpenTurath diperpanjang secara manual tanpa penagihan berulang otomatis (tanpa auto-debit). '
          'Setelah masa aktif berakhir, akses berbayar akan berhenti dengan sendirinya kecuali Anda memilih untuk memperpanjang secara sadar.',
    ),
    LegalSection(
      id: 'refund_04',
      title: '4. Ketentuan Voucher',
      content:
          'Voucher promosi atau mitra mengikuti masa berlaku, cakupan AI, dan batas penukaran yang tercantum saat diterbitkan. '
          'Voucher tidak dapat diuangkan dan berlaku untuk satu kali penukaran pada akun yang berhak.',
    ),
    LegalSection(
      id: 'refund_05',
      title: '5. Dasar Pengajuan Pengembalian Dana (Refund)',
      content:
          'Anda berhak mengajukan pemeriksaan dan pengembalian dana apabila terjadi:\n'
          '• Pembayaran ganda akibat kendala teknis pada sistem transaksi.\n'
          '• Dana telah terpotong namun hak akses tidak aktif setelah dilakukan verifikasi.\n'
          '• Gangguan teknis berkepanjangan pada layanan inti berbayar yang tidak dapat dipulihkan.\n\n'
          'Penyelesaian dapat berupa pemulihan akses, penyesuaian masa aktif yang Anda setujui, atau pengembalian dana penuh.',
    ),
    LegalSection(
      id: 'refund_06',
      title: '6. Alur dan Waktu Penanganan Refund',
      content: 'Kirim permohonan ke $contactSupportEmail dengan menyertakan:\n'
          '1. Alamat email akun OpenTurath.\n'
          '2. Nomor transaksi / invoice pembayaran.\n'
          '3. Bukti pembayaran resmi dari bank/e-wallet.\n'
          '4. Penjelasan kendala yang dialami.\n\n'
          'Konfirmasi penerimaan dikirimkan maksimal dalam $supportSla. '
          'Pemeriksaan dan keputusan pengembalian dana diselesaikan dalam $refundSla. '
          'Jika disetujui, pengembalian dana diproses ke rekening atau dompet asal sesuai ketentuan perbankan ($refundSla).',
    ),
    LegalSection(
      id: 'refund_07',
      title: '7. Saluran Bantuan Transaksi',
      content:
          'Kendala pembayaran dan transaksi dipantau setiap hari kerja ($serviceHours).\n'
          'Email layanan transaksi: $contactSupportEmail',
    ),
  ];

  // ── Bab 7: Panduan Penggunaan AI dan Rujukan (Adab) ───────────
  static const aiGuidelineTitle = 'Panduan Penggunaan AI & Rujukan';

  static const List<LegalSection> aiGuidelineSections = [
    LegalSection(
      id: 'guideline_01',
      title: "Prinsip dan Adab Menuntut Ilmu",
      content:
          "Teknologi kecerdasan buatan hadir sebagai sarana penunjang bacaan dan pemetaan pembahasan turats. "
          "AI adalah alat bantu penelusuran teks, sedangkan pemahaman agama yang mendalam, ketersambungan sanad, "
          "dan penyucian jiwa hanya diperoleh melalui tradisi talaqqi kepada guru dan ulama yang berkompeten.\n\n"
          "Berikut adalah pedoman adab yang perlu dijaga oleh setiap penuntut ilmu saat menelaah naskah bersama OpenTurath.",
    ),
    LegalSection(
      id: 'guideline_02',
      title: "Adab 1 · AI adalah alat bantu, bukan guru",
      content:
          "Gunakan AI untuk memperluas pembacaan, memetakan letak bab pembahasan, dan merumuskan pertanyaan sebelum diajukan kepada guru. "
          "AI bukan syekh murabbi, tidak berwenang berfatwa, dan tidak menggantikan kehadiran di majelis ilmu.\n\n"
          "Kesimpulan atau penjelasan dari AI adalah bahan kajian awal yang perlu diteliti kembali kepada ulama yang berkompeten.",
    ),
    LegalSection(
      id: 'guideline_03',
      title: "Adab 2 · Meneliti teks dan konteksnya",
      content:
          "Ketika menemukan suatu kutipan ibarah, bacalah bagian sebelum dan sesudahnya secara utuh untuk memahami konteks permasalahan (siyaq an-nash). "
          "Perhatikan syarat, pengecualian, serta batasan hukum pada naskah aslinya.\n\n"
          "Bedakan secara cermat antara tiga perkara: naskah asli kitab, terjemahan makna, dan kesimpulan bahasa mesin.",
    ),
    LegalSection(
      id: 'guideline_04',
      title: "Adab 3 · Menghormati mazhab dan para ahli",
      content:
          "Jangan mempergunakan jawaban AI untuk memicu perdebatan (jidal), menyudutkan pihak lain, atau menghakimi pandangan ulama. "
          "Penjelasan perbandingan pendapat yang ditampilkan AI tidak otomatis merangkum seluruh kekayaan khazanah fukaha.\n\n"
          "Penetapan hukum dan penilaian derajat riwayat merupakan wewenang para pakar yang memiliki keahlian ilmiah mendalam.",
    ),
    LegalSection(
      id: 'guideline_05',
      title: "Adab 4 · Kejujuran dan amanah ilmiah",
      content:
          "Jangan memberi kesan telah membaca suatu kitab secara utuh apabila penelusuran baru dilakukan melalui ringkasan mesin pencari. "
          "Nisbatkan dan kutip hanya naskah yang telah Anda periksa dan baca sendiri secara langsung.\n\n"
          "Kejujuran ilmiah adalah mahkota bagi penuntut ilmu dan penjaga keberkahan belajar turats.",
    ),
    LegalSection(
      id: 'guideline_06',
      title: "Adab 5 · Waspada terhadap kekeliruan mesin",
      content:
          "Susunan kalimat yang terdengar fasih, rapi, dan meyakinkan tidak menjadi jaminan atas kebenaran hakiki. "
          "Kehadiran judul kitab atau penomoran bab belum membuktikan bahwa seluruh uraian bebas dari kesalahan tafsir.\n\n"
          "Timbang setiap jawaban dengan kaidah Al-Qur'an, sunnah, dan penjelasan para ulama; jangan tergesa-gesa mengambil kesimpulan hanya karena kecepatan mesin.",
    ),
    LegalSection(
      id: 'guideline_07',
      title: "Adab 6 · Menjaga kemuliaan sanad dan talaqqi",
      content:
          "Ilmu agama diwariskan dari generasi ke generasi oleh para ulama yang terpercaya dan memiliki integritas moral. "
          "Kecerdasan buatan mengolah data secara mekanis tanpa ruh: ia tidak memiliki sanad keilmuan, sifat adil ('adalah), maupun ijazah pengajaran.\n\n"
          "Posisikan teknologi ini semata-mata sebagai sarana pembantu penelusuran di perpustakaan, bukan sebagai pemikul amanah agama.",
    ),
    LegalSection(
      id: 'guideline_08',
      title: "Adab 7 · Menjaga lisan dan tangan",
      content:
          "Sesuai manhaj keselamatan (salamatus shadr wal lisan), jangan menggunakan kutipan untuk mencela ulama, merendahkan sesama muslim, menyebarkan prasangka, atau menyalakan permusuhan.\n\n"
          "Jadikanlah ilmu sebagai sarana yang menyejukkan hati, menyatukan umat, dan menambah rasa takut kepada Allah.",
    ),
    LegalSection(
      id: 'guideline_09',
      title: "Adab 8 · Sikap santun dalam menyampaikan koreksi",
      content:
          "Apabila Anda mendapati kekeliruan teks Arab, salah atribusi pengarang, atau ketidaktepatan informasi dalam naskah yang ditampilkan, sampaikan koreksi secara santun dan ilmiah.\n\n"
          "Laporan perbaikan dapat dikirimkan melalui saluran resmi ($contactSupportEmail) agar khazanah kitab tetap terjaga keasliannya.",
    ),
  ];

  // ── Bab 9: Bantuan dan Kontak Resmi ───────────────────────────
  static const contactTitle = 'Bantuan dan Kontak';

  static const List<LegalSection> contactSections = [
    LegalSection(
      id: 'contact_01',
      title: '1. Layanan Bantuan dan Pengaduan',
      content:
          'Tim OpenTurath siap membantu kendala akun, aktivasi langganan, pembayaran, penggunaan Catatan, serta laporan koreksi naskah kitab rujukan.',
    ),
    LegalSection(
      id: 'contact_02',
      title: '2. Saluran Komunikasi Resmi',
      content: '• Bantuan & Transaksi: $contactSupportEmail\n'
          '• Permintaan Privasi & Data: $contactPrivacyEmail\n'
          '• Laporan Hak Cipta: $contactCopyrightEmail\n'
          '• Alamat Usaha: $managerAddress\n'
          '• Waktu Operasional: $serviceHours\n'
          '• Target Tanggapan: Maksimal $supportSla',
    ),
    LegalSection(
      id: 'contact_03',
      title: '3. Keamanan Informasi',
      content:
          'Jangan pernah mengirimkan kata sandi, kode OTP, atau informasi kartu pembayaran rahasia kepada siapapun, termasuk pihak yang mengaku sebagai tim OpenTurath. '
          'Gunakan hanya saluran email resmi yang tercantum di atas.',
    ),
  ];

  // ── Bab 6 & 10.5: Teks Konfirmasi Penghapusan Akun Kanonik ─────
  static const deleteAccountConfirmationBody =
      'Akun OpenTurath akan dihapus dan akses akun berakhir. '
      'Data yang masih perlu disimpan untuk kewajiban hukum mengikuti Kebijakan Privasi. '
      'Simpan catatan penting sebelum melanjutkan.';

  static const deleteAccountConfirmationCancel = 'Batal';
  static const deleteAccountConfirmationConfirm = 'Hapus akun';
}
