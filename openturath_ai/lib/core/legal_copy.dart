/// LegalCopy: Sumber data dan teks kanonik hukum dan kebijakan OpenTurath.
/// Mengintegrasikan naskah resmi dari OpenTurath_Identitas_dan_Kebijakan.md.
/// Seluruh penanda placeholder [[...]] telah diselesaikan dengan nilai kanonik
/// dan mematuhi etika "The Quiet Scholar" (tanpa tanda seru, jujur, dan bersahaja).
library;

class LegalSection {
  final String title;
  final String content;

  const LegalSection({
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
  static const contactSupportEmail = 'bantuan@openturath.ai';
  static const contactPrivacyEmail = 'privasi@openturath.ai';
  static const contactCopyrightEmail = 'hakcipta@openturath.ai';
  static const serviceHours = 'Senin – Jumat, 09.00 – 17.00 WIB';
  static const supportSla = '2 (dua) hari kerja';
  static const refundSla = '7 (tujuh) hari kerja';

  // ── Bab 1.2: Tentang OpenTurath untuk Aplikasi ─────────────────
  static const aboutAppTitle = 'Tentang OpenTurath';
  static const aboutAppTagline = 'Membaca kitab, menelusuri ibarah.';

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
      title: '1. Pengelola dan Cakupan Ketentuan',
      content:
          'OpenTurath dikelola oleh $managerName, beralamat di $managerAddress, selanjutnya disebut "kami". '
          'Pengguna aplikasi disebut "Anda". Kontak layanan tersedia melalui $contactSupportEmail.\n\n'
          'Ketentuan ini mengatur penggunaan akun, asisten AI, katalog rujukan, Catatan, dan fitur berbayar yang disediakan melalui OpenTurath. '
          'Informasi paket yang ditampilkan sebelum pembelian, Kebijakan Pembayaran dan Pengembalian Dana, serta Panduan Penggunaan AI dan Pemeriksaan Rujukan menjadi bagian dari ketentuan penggunaan yang relevan.',
    ),
    LegalSection(
      title: '2. Persetujuan dan Persyaratan Pengguna',
      content:
          'Sebelum membuat akun atau membeli paket, Anda diberi kesempatan membaca ketentuan yang berlaku. '
          'Penggunaan mandiri OpenTurath ditujukan bagi pengguna berusia sekurang-kurangnya 18 tahun. '
          'Anda juga harus memiliki kecakapan atau kewenangan yang diperlukan untuk membuat perjanjian dan melakukan pembayaran.\n\n'
          'Akses bagi pengguna di bawah 18 tahun belum dibuka melalui pendaftaran mandiri. '
          'Jika bertindak untuk lembaga, Anda harus berwenang mewakilinya. Pembelian individu tidak otomatis memberikan hak penggunaan bersama untuk seluruh anggota lembaga.',
    ),
    LegalSection(
      title: '3. Akun dan Keamanan Akses',
      content:
          'Gunakan informasi akun yang benar dan akses masuk yang menjadi hak Anda. Akun bersifat pribadi, kecuali suatu paket secara tertulis menyediakan penggunaan untuk beberapa orang.\n\n'
          'Jaga perangkat dan akses masuk Anda. Jangan memberikan kata sandi atau kode sekali pakai kepada pihak lain. '
          'Laporkan dugaan penggunaan tanpa izin melalui $contactSupportEmail. '
          'Laporan pengambilalihan akun akan diperiksa berdasarkan keadaan dan bukti yang tersedia.',
    ),
    LegalSection(
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
      title: '5. Paket, Pembayaran, dan Masa Akses',
      content:
          'Harga, cakupan asisten, masa akses, batas penggunaan, kebutuhan akun pihak ketiga, serta biaya yang berlaku ditampilkan sebelum Anda membayar.\n\n'
          'Langganan diperpanjang secara manual. Kami tidak melakukan penagihan berulang otomatis (auto-debit) dari pembelian paket ini.\n\n'
          'Masa akses dimulai ketika aktivasi berhasil dan tanggal berakhir ditampilkan pada akun. '
          'Pembayaran diproses melalui DOKU menurut metode yang tersedia pada saat transaksi. '
          'Keberhasilan pembayaran dan aktivasi akses adalah dua status yang berbeda. Jika dana telah dibayarkan namun langganan belum aktif, hubungi bantuan dengan nomor transaksi.',
    ),
    LegalSection(
      title: '6. Layanan Pihak Ketiga (Google NotebookLM)',
      content:
          'Fitur percakapan menggunakan NotebookLM dari Google. Aksesnya dapat bergantung pada akun, wilayah, batas penggunaan, dan ketentuan penyedia yang berlaku untuk Anda. '
          'Pembelian OpenTurath tidak dengan sendirinya mengubah jenis langganan atau hak akses akun Google Anda.\n\n'
          'Jika perubahan layanan pihak ketiga menyebabkan fitur berbayar tidak dapat diberikan sesuai yang ditawarkan, kami akan menilai pemulihan akses, penggantian layanan yang Anda setujui, atau pengembalian dana sesuai hak Anda.',
    ),
    LegalSection(
      title: '7. Penggunaan yang Diperbolehkan dan Dilarang',
      content:
          'Anda dapat menggunakan layanan untuk belajar, menyiapkan pengajaran, dan melakukan penelusuran sesuai paket yang dimiliki. '
          'Penggunaan hasilnya tetap harus memperhatikan hak cipta, ketepatan atribusi, serta adab keilmuan.\n\n'
          'Dilarang menggunakan OpenTurath untuk mengambil alih akun, menghindari pembatasan akses secara tidak sah, menyebarkan perangkat lunak berbahaya, atau menjual kembali akses berbayar kepada pihak lain.\n\n'
          'Dilarang membuat atau menyebarkan kutipan yang sengaja dipalsukan dan diatasnamakan kepada ulama atau sumber tertentu. '
          'Pembahasan ilmiah yang sah, termasuk perbedaan pendapat dan kritik terhadap suatu penafsiran, tidak dengan sendirinya merupakan pelanggaran.',
    ),
    LegalSection(
      title: '8. Catatan dan Materi Pengguna',
      content:
          'Hak atas tulisan atau catatan yang Anda buat tetap berada pada Anda. Anda memberi izin terbatas kepada kami untuk memproses dan menyimpan materi tersebut semata-mata untuk menjalankan fitur yang Anda pilih. '
          'Izin ini tidak memindahkan kepemilikan dan kami tidak menjual atau menerbitkan catatan pribadi Anda.\n\n'
          'Catatan disimpan secara lokal pada perangkat Anda melalui basis data terenkripsi. Gunakan fitur salin atau berbagi yang tersedia untuk mencadangkan materi penting.',
    ),
    LegalSection(
      title: '9. Hak atas Aplikasi dan Kitab',
      content:
          'Hak atas perangkat lunak, tampilan, dan merek OpenTurath tetap berada pada pemegang haknya. '
          'Materi kitab, terjemahan, dan tahkik mengikuti status hak masing-masing.\n\n'
          'Akses berbayar tidak memindahkan hak cipta atas kitab atau memberi izin umum untuk menyebarluaskan seluruh isi kitab secara komersial. '
          'Penggunaan kutipan harus memperhatikan batas penggunaan wajar dan kewajiban atribusi.',
    ),
    LegalSection(
      title: '10. Ketersediaan dan Perubahan Fitur',
      content:
          'Layanan dapat mengalami pemeliharaan berkala atau pembaruan teknis. Kami berupaya memberi pemberitahuan mengenai pemeliharaan terencana.\n\n'
          'Perubahan yang secara material mengurangi manfaat paket berbayar akan disertai pilihan penyelesaian yang wajar. '
          'Kami tidak menggunakan perubahan ketentuan untuk menghapus hak yang sudah timbul dari pembelian Anda.',
    ),
    LegalSection(
      title: '11. Pembatasan dan Penutupan Akun',
      content:
          'Kami dapat membatasi akses jika terdapat dasar yang wajar mengenai pelanggaran serius, risiko keamanan, atau penggunaan tanpa hak. '
          'Tindakan disesuaikan dengan tingkat masalah, mulai dari peringatan, penghentian sementara, hingga penutupan akun.\n\n'
          'Jika keadaan memungkinkan, kami menyampaikan alasan dan memberi kesempatan klarifikasi melalui $contactSupportEmail.',
    ),
    LegalSection(
      title: '12. Tanggung Jawab dan Hak Pengguna',
      content:
          'Kami bertanggung jawab menyediakan layanan sesuai perjanjian dan hukum yang berlaku. '
          'Penjelasan mengenai keterbatasan AI tidak menghapus kewajiban kami untuk memberikan informasi yang benar, menangani keluhan, atau menyelesaikan layanan berbayar.\n\n'
          'Anda bertanggung jawab menilai kesesuaian hasil untuk tujuan penggunaannya dan memeriksa sumber sebelum mengambil kesimpulan. '
          'Tidak ada ketentuan yang meniadakan hak konsumen yang dilindungi undang-undang.',
    ),
    LegalSection(
      title: '13. Pengaduan dan Musyawarah',
      content:
          'Hubungi $contactSupportEmail dengan penjelasan masalah dan informasi yang relevan. '
          'Kami akan mencatat pengaduan, menyampaikan perkembangan penanganan dalam $supportSla, dan mengupayakan penyelesaian secara musyawarah.\n\n'
          'Ketentuan ini tunduk pada hukum Republik Indonesia.',
    ),
    LegalSection(
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
      title: '1. Pengelola Data dan Ruang Lingkup',
      content:
          'Kebijakan Privasi ini menjelaskan pemrosesan data pribadi saat Anda menggunakan aplikasi OpenTurath, pembayaran, dan bantuan layanan. '
          '$managerName ($managerAddress) bertanggung jawab atas pemrosesan data yang tujuan dan caranya ditentukan oleh OpenTurath, sesuai UU Nomor 27 Tahun 2022 tentang Pelindungan Data Pribadi.\n\n'
          'Untuk pertanyaan privasi, hubungi $contactPrivacyEmail.',
    ),
    LegalSection(
      title: '2. Data yang Diproses',
      content:
          'Kami memproses data sesuai fitur yang Anda gunakan:\n'
          '• Akun: Nama, alamat email, dan identitas profil publik dari akun Google untuk autentikasi dan personalisasi.\n'
          '• Langganan: Paket yang dipilih, status, masa aktif, dan penggunaan voucher.\n'
          '• Pembayaran: Nomor transaksi, jumlah pembayaran, metode, waktu, dan status dari penyedia DOKU.\n'
          '• Kontak Transaksi: Nomor WhatsApp/telepon yang Anda berikan saat pembayaran untuk pengiriman informasi aktivasi.\n'
          '• Percakapan: Pertanyaan, jawaban, dan konteks percakapan yang diproses melalui sesi Google NotebookLM.\n'
          '• Catatan: Catatan, kutipan, dan rujukan yang Anda simpan pada penyimpanan lokal perangkat.\n'
          '• Bantuan: Alamat kontak, isi pengaduan, nomor transaksi, dan lampiran tangkapan layar untuk penanganan masalah.\n'
          '• Sesi Teknis: Token sesi autentikasi yang aman untuk mempertahankan login di perangkat.',
    ),
    LegalSection(
      title: '3. Tujuan dan Dasar Pemrosesan',
      content:
          'Data akun dan transaksi diproses untuk menyediakan layanan yang Anda minta, mengelola langganan, dan melaksanakan perjanjian. '
          'Pencatatan transaksi juga diperlukan untuk memenuhi kewajiban hukum administrasi perpajakan dan transaksi keuangan.\n\n'
          'Kami tidak menjual data pribadi Anda kepada pihak ketiga manapun, dan tidak menggunakan percakapan Anda untuk iklan bertarget.',
    ),
    LegalSection(
      title: '4. Percakapan AI dan Peran Google',
      content:
          'Ketika Anda mengirim pertanyaan melalui fitur percakapan, teks dan konteks diproses melalui layanan Google NotebookLM. '
          'Kebijakan pemrosesan Google mengikuti Kebijakan Privasi Google dan ketentuan NotebookLM.\n\n'
          'Aplikasi OpenTurath tidak menggunakan isi percakapan atau catatan pribadi pengguna untuk melatih model kecerdasan buatan publik. '
          'Hindari memasukkan informasi pribadi sensitif atau rahasia ke dalam percakapan.',
    ),
    LegalSection(
      title: '5. Catatan dan Penyimpanan Perangkat',
      content:
          'Catatan, kutipan ibarah, dan penanda rujukan disimpan secara lokal di perangkat Anda menggunakan basis data SQLite terenkripsi. '
          'Jika Anda membersihkan data aplikasi atau mencopot pemasangan aplikasi, catatan lokal dapat terhapus. '
          'Gunakan fitur salin teks atau bagikan catatan untuk mencadangkan catatan penting Anda ke tempat penyimpanan lain.',
    ),
    LegalSection(
      title: '6. Penerima dan Penyedia Layanan',
      content:
          'Data dibagikan hanya sebatas yang diperlukan untuk menjalankan layanan:\n'
          '• Google: Untuk proses masuk autentikasi dan pemrosesan sesi percakapan NotebookLM.\n'
          '• DOKU: Lembaga pembayaran resmi untuk memproses transaksi perbankan, dompet digital, atau QRIS.\n'
          '• Firebase / Google Cloud: Pengelolaan database transaksi dan status hak akses akun yang aman.\n\n'
          'Seluruh penyedia bekerja berdasarkan standar keamanan dan enkripsi industri.',
    ),
    LegalSection(
      title: '7. Kebijakan Iklan, Analitik, dan Promosi',
      content:
          'OpenTurath bebas dari iklan pihak ketiga dan tidak menjual data pribadi Anda. '
          'Pemberitahuan transaksi dan pembaruan layanan dikirimkan semata-mata untuk keperluan operasional akun Anda.',
    ),
    LegalSection(
      title: '8. Pemrosesan Data Lintas Wilayah',
      content:
          'Infrastruktur autentikasi Google dan basis data cloud dapat memproses sebagian data teknis di pusat data yang aman di dalam maupun luar wilayah Indonesia, dengan perlindungan enkripsi transit dan at-rest berstandar global.',
    ),
    LegalSection(
      title: '9. Masa Penyimpanan Data (Retensi)',
      content:
          '• Data Akun: Disimpan selama akun aktif, dan dihapus setelah permohonan penutupan akun disetujui.\n'
          '• Data Transaksi: Disimpan selama batas waktu yang diwajibkan oleh ketentuan perpajakan dan hukum transaksi keuangan Republik Indonesia.\n'
          '• Catatan Pengguna: Disimpan di perangkat Anda hingga Anda menghapusnya sendiri atau mencopot aplikasi.\n'
          '• Pengaduan Bantuan: Disimpan selama proses penyelesaian masalah dan pengarsipan layanan.',
    ),
    LegalSection(
      title: '10. Keamanan dan Perlindungan Data',
      content:
          'Kami menerapkan langkah-langkah pengamanan teknis, termasuk komunikasi terenkripsi SSL/TLS, pembatasan akses data, dan perlindungan token sesi. '
          'Kata sandi akun Google Anda tidak pernah disimpan di server OpenTurath.',
    ),
    LegalSection(
      title: '11. Hak Subjek Data Pengguna',
      content:
          'Sesuai UU Perlindungan Data Pribadi, Anda berhak:\n'
          '• Mengakses dan memperoleh informasi mengenai data pribadi yang diproses.\n'
          '• Memperbarui atau memperbaiki data profil yang keliru.\n'
          '• Meminta penghapusan akun dan data pribadi Anda kapan saja melalui aplikasi.\n'
          '• Menyampaikan keberatan atau pertanyaan seputar privasi ke $contactPrivacyEmail.',
    ),
    LegalSection(
      title: '12. Pengguna di Bawah Umur',
      content:
          'Pendaftaran akun mandiri ditujukan bagi pengguna berusia 18 tahun ke atas. '
          'Jika Anda orang tua atau wali dan mendapati akun dibuka tanpa izin yang diperlukan, hubungi $contactPrivacyEmail untuk penanganan dan penghapusan data.',
    ),
    LegalSection(
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
      title: '1. Informasi Sebelum Pembelian',
      content:
          'Sebelum melakukan pembayaran, rincian harga total, cakupan modul asisten, durasi masa akses, dan metode pembayaran ditampilkan secara jelas pada halaman langganan.\n\n'
          'Durasi paket 30 hari dihitung sebagai 30 hari kalender penuh sejak aktivasi berhasil. '
          'Perubahan harga di masa mendatang tidak akan memengaruhi paket yang sedang berjalan.',
    ),
    LegalSection(
      title: '2. Pembayaran dan Aktivasi Akses',
      content:
          'Pembayaran diproses melalui gerbang pembayaran resmi DOKU dengan metode QRIS, transfer bank (virtual account), maupun dompet digital.\n\n'
          'Bukti pembayaran resmi dikirimkan melalui notifikasi DOKU dan email akun Anda. '
          'Masa akses aktif seketika transaksi dinyatakan berhasil dan tersinkronisasi. '
          'Jika dana telah terpotong namun status belum aktif, jangan melakukan pembayaran ulang; hubungi $contactSupportEmail dengan menyertakan nomor transaksi.',
    ),
    LegalSection(
      title: '3. Perpanjangan Manual (Tanpa Auto-Debit)',
      content:
          'Seluruh paket langganan OpenTurath diperpanjang secara manual. '
          'Kami tidak melakukan penagihan berulang otomatis (recurring auto-debit). '
          'Setelah masa aktif berakhir, akses berbayar akan berhenti dengan sendirinya kecuali Anda memilih untuk memperpanjang secara sadar.',
    ),
    LegalSection(
      title: '4. Ketentuan Voucher',
      content:
          'Voucher promosi atau mitra mengikuti masa berlaku, cakupan asisten, dan batas penukaran yang tercantum saat diterbitkan. '
          'Voucher tidak dapat diuangkan dan berlaku untuk satu kali penukaran pada akun yang berhak.',
    ),
    LegalSection(
      title: '5. Dasar Pengajuan Pengembalian Dana (Refund)',
      content:
          'Anda berhak mengajukan pemeriksaan dan pengembalian dana apabila terjadi:\n'
          '• Pembayaran ganda akibat kendala teknis pada sistem transaksi.\n'
          '• Dana telah terpotong namun hak akses tidak aktif setelah dilakukan verifikasi.\n'
          '• Gangguan teknis berkepanjangan pada layanan inti berbayar yang tidak dapat dipulihkan.\n\n'
          'Penyelesaian dapat berupa pemulihan akses, penyesuaian masa aktif yang Anda setujui, atau pengembalian dana penuh.',
    ),
    LegalSection(
      title: '6. Alur dan Waktu Penanganan Refund',
      content:
          'Kirim permohonan ke $contactSupportEmail dengan menyertakan:\n'
          '1. Alamat email akun OpenTurath.\n'
          '2. Nomor transaksi / invoice pembayaran.\n'
          '3. Bukti pembayaran resmi dari bank/e-wallet.\n'
          '4. Penjelasan kendala yang dialami.\n\n'
          'Konfirmasi penerimaan dikirimkan maksimal dalam $supportSla. '
          'Pemeriksaan dan keputusan pengembalian dana diselesaikan dalam $refundSla. '
          'Jika disetujui, pengembalian dana diproses ke rekening atau dompet asal sesuai ketentuan perbankan ($refundSla).',
    ),
    LegalSection(
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
      title: '1. Peran OpenTurath dalam Belajar',
      content:
          'OpenTurath membantu menelusuri pembahasan dalam kitab dan menyusun penjelasan awal berdasarkan sumber yang tersedia. '
          'Gunakan hasilnya untuk memperluas pembacaan, menyiapkan pertanyaan kepada guru, atau menemukan rujukan yang perlu diperiksa.\n\n'
          'Jawaban AI dapat keliru meskipun disampaikan dengan kalimat yang meyakinkan. '
          'Kehadiran judul kitab atau nomor halaman belum membuktikan bahwa seluruh isi jawaban bebas dari kekeliruan.',
    ),
    LegalSection(
      title: '2. Membaca Kutipan Bersama Konteks',
      content:
          'Periksa judul kitab, nama pengarang, edisi, jilid, dan halaman yang dirujuk. '
          'Baca bagian sebelum dan sesudah kutipan untuk memahami hubungan pembahasan secara utuh. '
          'Syarat, pengecualian, dan konteks pembahasan sangat memengaruhi maksud ibarah hukum.\n\n'
          'Jika penomoran halaman berbeda, cocokkan dengan cetakan atau edisi yang Anda gunakan.',
    ),
    LegalSection(
      title: '3. Menjaga Adab Perbedaan Pendapat',
      content:
          'Penjelasan tentang mazhab atau kedudukan suatu pendapat perlu dibaca sesuai bidang dan rujukannya. '
          'Ringkasan perbandingan tidak otomatis mencakup seluruh pandangan ulama.\n\n'
          'Istilah khusus seperti mu\'tamad, sanad, dan derajat hadis memiliki metodologi ilmiah yang ketat. '
          'Untuk pemahaman agama yang mendalam dan penetapan hukum, tetaplah merujuk kepada guru dan ulama yang berkompeten.',
    ),
    LegalSection(
      title: '4. Mengutip dan Membagikan Hasil',
      content:
          'Bedakan dengan jujur antara naskah kitab asli, kutipan terjemahan, dan sintesis penjelasan AI. '
          'Cantumkan sumber yang benar-benar Anda periksa pada naskah aslinya. '
          'Jangan memberi kesan telah membaca kitab secara utuh apabila penelusuran baru dilakukan melalui ringkasan AI.',
    ),
    LegalSection(
      title: '5. Melaporkan Kesalahan Teks atau Rujukan',
      content:
          'Apabila Anda menemukan kekeliruan kutipan teks Arab, salah atribusi pengarang, atau kesalahan jilid dan halaman, '
          'kirimkan laporan ke $contactSupportEmail dengan menyertakan nama kitab, pertanyaan, dan usulan koreksi yang benar.',
    ),
  ];

  // ── Bab 9: Bantuan dan Kontak Resmi ───────────────────────────
  static const contactTitle = 'Bantuan dan Kontak';

  static const List<LegalSection> contactSections = [
    LegalSection(
      title: '1. Layanan Bantuan dan Pengaduan',
      content:
          'Tim OpenTurath siap membantu kendala akun, aktivasi langganan, pembayaran, penggunaan Catatan, serta laporan koreksi naskah kitab rujukan.',
    ),
    LegalSection(
      title: '2. Saluran Komunikasi Resmi',
      content:
          '• Bantuan & Transaksi: $contactSupportEmail\n'
          '• Permintaan Privasi & Data: $contactPrivacyEmail\n'
          '• Laporan Hak Cipta: $contactCopyrightEmail\n'
          '• Alamat Usaha: $managerAddress\n'
          '• Waktu Operasional: $serviceHours\n'
          '• Target Tanggapan: Maksimal $supportSla',
    ),
    LegalSection(
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
