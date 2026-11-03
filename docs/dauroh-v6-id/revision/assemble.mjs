import fs from 'node:fs/promises';
import path from 'node:path';
const ROOT='/Users/apple/Downloads/ramadhan/docs/dauroh-v6-id';
const originals=JSON.parse(await fs.readFile(path.join(ROOT,'slides-id.json'),'utf8'));
const old=new Map(originals.map(s=>[s.id,s]));
const all=[];let day=1,chapter='Pembukaan',chapterNo=0;
const promptSources=['https://help.openai.com/en/articles/10032626','https://learn.chatgpt.com/docs/prompting','https://support.claude.com/en/articles/7996857-my-prompt-isn-t-giving-me-a-helpful-answer'];
function add(d){all.push({day,chapter,...d});}
function section(title,subtitle,outcome){chapterNo++;chapter=`Bab ${String(chapterNo).padStart(2,'0')}  ${title}`;add({kind:'chapter',number:chapterNo,title,subtitle,outcome});}
function source(ids,kind,over={}){
 const a=ids.map(i=>old.get(i));
 add({kind,title:a[0].title,body:a.flatMap(s=>s.body),notes:a.map(s=>s.notes).join('\n\n'),sourceIds:ids,demo:a.filter(s=>s.demo&&s.demo!=='.'&&s.demo!=='?').map(s=>s.demo.replace(/^\.\s*/, '')).join('\n\n'),...over});
}
function exercise(title,minutes,steps,deliverable,notes='',ids=[]){add({kind:'exercise',title,minutes,steps,deliverable,notes:[...ids.map(i=>old.get(i).notes),notes].filter(Boolean).join('\n\n'),sourceIds:ids});}
async function load(name){return JSON.parse(await fs.readFile(path.join(ROOT,'revision',name),'utf8'));}
function flatChapters(o){return Array.isArray(o)?o:(o.chapters??o.sections??[]);}
function normalizedSlide(s){
 const out={...s};
 out.body=(s.body??s.points??s.explanation??[]);
 if(typeof out.body==='string')out.body=[out.body];
 out.body=out.body.map(v=>typeof v==='string'?v:v.text??v.description??v.label??'').filter(Boolean);
 out.kind=s.kind??s.layout??(s.screenshot?'screenshot':'explain');
 if(!['screenshot','explain','definition','quote','table','exercise','comparison','prompt','sequence'].includes(out.kind))out.kind=s.screenshot?'screenshot':s.minutes?'exercise':'explain';
 out.screenshot=s.screenshot??s.screenshotPath??s.imagePath;
 if(out.screenshot)out.kind='screenshot';
 out.sources=s.sources??s.sourceUrls??[];
 if(typeof out.sources==='string')out.sources=[out.sources];
 out.notes=typeof s.notes==='string'?s.notes:JSON.stringify(s.notes??'');
 if(out.kind==='exercise'){
  out.steps=s.steps??out.body;out.deliverable=s.deliverable??s.expectedOutput??s.output??'';
  out.minutes=s.minutes??15;
 }
 return out;
}
function product(c,key,oldIds){
 const titles={gemini:['Gemini','Mengenal masukan berkas, riset, dan Canvas','Hasil bab: satu bahan belajar yang sudah Anda periksa'],chatgpt:['ChatGPT','Percakapan, dokumen, pencarian, dan ruang kerja','Hasil bab: satu percakapan kerja yang bisa dilanjutkan'],perplexity:['Perplexity','Menelusuri pertanyaan dan memeriksa sumber','Hasil bab: daftar sumber awal yang sudah dibuka'],claude:['Claude','Membaca bahan dan mengembangkan pekerjaan','Hasil bab: satu draf atau artefak dengan alasan revisi']};
 section(...titles[key]);
 const slides=c.slides??c.content??[];
 slides.forEach((s,i)=>{const d=normalizedSlide(s);if(i===0){d.notes=[...oldIds.map(id=>old.get(id).notes),d.notes].filter(Boolean).join('\n\n');d.sourceIds=oldIds;}add(d);});
}

add({kind:'cover',title:'AI untuk Belajar & Penelitian Ilmiah',notes:old.get(1).notes,sourceIds:[1]});
add({kind:'table',title:'Rencana dua hari praktik',values:[['Hari pertama','Hari kedua'],['Dasar AI dan empat aplikasi','Pengumpulan sumber dan identitas edisi'],['Gemini, ChatGPT, Perplexity, Claude','Pertanyaan penelitian dan catatan bacaan'],['Rumus SIAP dan latihan prompt','Analisis, tulisan, dan revisi'],['Hasil: satu pekerjaan belajar tersimpan','Hasil: satu proyek penelitian OpenTurath']],fontSize:28,notes:'Setiap hari berlangsung 240 menit termasuk istirahat 15 menit. Hari pertama: dasar AI 25 menit; Gemini 35 menit; ChatGPT 35 menit; Perplexity 20 menit; Claude 30 menit; prompt dan praktik 80 menit; istirahat 15 menit. Hari kedua: pengumpulan sumber 40 menit; rancangan penelitian 35 menit; membaca dan analisis 45 menit; menulis dan revisi 55 menit; proyek OpenTurath 50 menit; istirahat 15 menit. Durasi termasuk latihan pada bab masing-masing. Bila fitur akun berbeda, peserta mengerjakan bahan yang sama dengan fitur yang tersedia.'});
section('Dasar AI','Cara kerja, istilah, dan batas yang perlu dipahami','Pertanyaan awal: pekerjaan apa yang ingin Anda bantu dengan AI?');
source([2,3],'explain',{title:'Satu kebutuhan yang Anda bawa ke kelas',lead:'Pilih satu pekerjaan belajar atau penelitian yang sedang Anda hadapi.',detail:'Simpan kebutuhan itu selama dauroh. Kita akan memakainya untuk mencoba aplikasi, memperjelas prompt, lalu menilai hasil yang benar-benar berguna.',example:'Contoh: memahami satu halaman, merapikan catatan, atau memperbaiki satu paragraf.'});
source([4],'definition',{title:'Kecerdasan buatan',lead:'Sistem yang mengerjakan tugas yang biasanya memerlukan kemampuan manusia.'});
source([5,7],'explain',{title:'AI di sekitar kita',lead:'Percakapan hanyalah salah satu cara berinteraksi dengan AI.',detail:'Pengenalan suara, penerjemahan, rekomendasi, dan pembacaan gambar sudah dekat dengan keseharian. AI generatif juga dapat menghasilkan teks atau media dari masukan yang kita berikan.'});
source([6],'table',{title:'Sejarah singkat AI',values:[['Periode','Perubahan yang relevan bagi pengguna'],['1956','Dartmouth menjadi tonggak pembentukan bidang AI'],['Perkembangan berikutnya','Aturan, pembelajaran dari data, dan pembelajaran mendalam'],['2022','ChatGPT memperluas akses percakapan generatif']],sources:['https://home.dartmouth.edu/about/artificial-intelligence-ai-coined-dartmouth','https://openai.com/index/chatgpt/']});
source([8],'table',{title:'Perusahaan, model, aplikasi, dan fitur',values:[['Istilah','Yang dimaksud'],['Perusahaan','Pengembang layanan, misalnya Google atau OpenAI'],['Model','Sistem yang menjalankan kemampuan AI'],['Aplikasi','Tempat kita berinteraksi dan bekerja'],['Fitur','Pencarian, unggahan, atau ruang penyuntingan']]});
source([9,10],'sequence',{title:'Cara sebuah jawaban terbentuk',body:['Model belajar pola dari contoh dan data saat pelatihan.','Percakapan membawa instruksi dan konteks untuk pekerjaan saat ini.','Aplikasi dapat memakai alat tambahan, lalu menampilkan jawaban.'],sources:['https://help.openai.com/en/articles/7842364-how-chatgpt-and-our-foundation-models-are-developed']});
source([11],'quote',{title:'Penalaran dan pengalaman manusia',quote:'Nama “Thinking” tidak membuktikan kesadaran.',detail:'Kita dapat menguji kemampuan menyelesaikan tugas. Pengalaman subjektif manusia merupakan persoalan yang berbeda dari penilaian hasil komputasi.'});
source([12],'definition',{title:'Jawaban yang meyakinkan tetap perlu diperiksa',lead:'Bahasa yang lancar tidak menjamin informasi dan rujukannya benar.',detail:'Baca kembali permintaan, konteks, dan sumbernya. Nama pengarang, angka, kutipan, serta kesimpulan penting memerlukan pemeriksaan tersendiri.'});
source([13],'table',{title:'Konteks, memori, dan pencarian',values:[['Fungsi','Perannya dalam pekerjaan'],['Konteks','Bahan dan informasi yang tersedia dalam pekerjaan saat ini'],['Memori','Informasi tertentu yang disimpan jika fitur tersedia dan aktif'],['Pencarian','Pengambilan informasi dari sumber luar melalui alat aplikasi']]});

const g=flatChapters(await load('gemini-chatgpt.json'));
const pc=flatChapters(await load('perplexity-claude.json'));
for(const key of ['gemini','chatgpt']){
 const c=g.find(x=>(x.key??x.id??x.title??'').toLowerCase().includes(key));if(!c)throw Error('Missing chapter '+key);product(c,key,key==='gemini'?[16,17]:[14,15]);
}
add({kind:'break',title:'Istirahat',minutes:15,subtitle:'Simpan hasil latihan Gemini dan ChatGPT. Setelah jeda kita belajar pencarian dan pembacaan sumber.'});
for(const key of ['perplexity','claude']){
 const c=pc.find(x=>(x.key??x.id??x.title??'').toLowerCase().includes(key));if(!c)throw Error('Missing chapter '+key);product(c,key,key==='claude'?[18,19]:[]);
}
source([22,23],'table',{title:'Pemilihan alat mengikuti pekerjaan',values:[['Pekerjaan','Yang perlu diperiksa'],['Memahami atau mengolah dokumen','Keterbacaan berkas dan kesetiaan hasil terhadap isinya'],['Mencari informasi luar','Tautan sumber, relevansi, dan akses ke teks lengkap'],['Mengembangkan tulisan','Kemudahan revisi, penyimpanan, dan penjelasan perubahan'],['Belajar mandiri','Kesesuaian bahasa dan pertanyaan dengan tingkat peserta']]});

section('Prompt dengan rumus SIAP','Sasaran, Informasi, Aturan, Penyajian','Hasil bab: prompt yang bisa diuji dan diperbaiki');
source([24,25],'comparison',{title:'Percakapan dapat dikembangkan',leftLabel:'Permintaan pertama',rightLabel:'Tindak lanjut',left:'Jelaskan perbedaan topik penelitian dan pertanyaan penelitian dengan dua contoh sederhana.',right:'Contoh kedua belum dekat dengan kebutuhan saya. Ganti dengan contoh kajian kitab, lalu tunjukkan mana topik dan mana pertanyaannya.'});
source([26,27],'explain',{title:'Percakapan dan berkas kerja',lead:'Satu pekerjaan yang berlanjut dapat tetap memakai konteks percakapan yang sama.',detail:'Pisahkan pekerjaan yang berbeda. Simpan bahan asal, prompt, dan hasil yang dipilih dengan nama serta versi yang mudah dikenali.'});
source([28],'definition',{title:'Prompt sebagai penjelasan pekerjaan',lead:'Instruksi yang baik membantu AI memahami apa yang ingin kita selesaikan.',detail:'Panjang prompt mengikuti kebutuhan tugas. Kita memakai SIAP agar informasi penting mudah diingat dan hasilnya mudah diperiksa.',sources:promptSources});
add({kind:'formula',title:'Rumus SIAP',body:['Apa yang ingin diselesaikan?','Konteks dan bahan apa yang tersedia?','Batas apa yang wajib dijaga?','Bagaimana bentuk hasilnya?'],sources:promptSources,notes:'SIAP adalah alat bantu mengingat yang kita gunakan dalam dauroh ini. Ini bukan nama standar ilmiah atau jaminan jawaban benar. Empat unsur ini menerapkan anjuran instruksi jelas, konteks yang cukup, batas tugas, dan bentuk keluaran. Peran khusus boleh ditambahkan jika membantu tugas, tetapi tidak wajib menjadi pembuka setiap prompt.'});
add({kind:'comparison',title:'Sasaran dan informasi',leftLabel:'S  Sasaran',rightLabel:'I  Informasi',left:'Susun jadwal mengulang tiga bab selama enam hari.',right:'Saya punya 45 menit per hari. Bab kedua paling sulit. Bab ketiga belum selesai dibaca.',takeaway:'Tujuan dan keadaan peserta menentukan rancangan jadwal.',sources:promptSources,notes:'Mintalah peserta menunjukkan bagian mana yang menyatakan tugas, lalu bagian mana yang mengubah keputusan penyusunan jadwal. Tanpa informasi waktu dan tingkat kesulitan, jawaban mungkin terlihat rapi tetapi tidak cocok untuk dipakai.'});
add({kind:'comparison',title:'Aturan dan penyajian',leftLabel:'A  Aturan',rightLabel:'P  Penyajian',left:'Jumlah waktu harian maksimal 45 menit. Sertakan latihan mengingat tanpa buku. Tanyakan informasi yang belum cukup.',right:'Tampilkan tabel hari, kegiatan, alokasi menit, dan cara mengecek pemahaman.',takeaway:'Aturan membatasi isi. Penyajian menentukan bagaimana peserta menggunakan hasil.',sources:promptSources,notes:'Bandingkan aturan yang berkaitan dengan isi dengan permintaan bentuk tabel. Meminta tabel tidak otomatis membuat isi jadwal benar. Peserta tetap menjumlahkan menit pada tiap hari dan menilai apakah latihan mengingat benar-benar hadir.'});
add({kind:'prompt',title:'Satu prompt lengkap dengan SIAP',promptParts:[{key:'Sasaran',value:'Susun jadwal mengulang tiga bab selama enam hari.'},{key:'Informasi',value:'Waktu saya 45 menit per hari. Bab kedua paling sulit dan bab ketiga belum selesai.'},{key:'Aturan',value:'Maksimal 45 menit per hari. Sertakan latihan mengingat. Tanyakan informasi yang belum cukup.'},{key:'Penyajian',value:'Tabel berisi hari, kegiatan, menit, dan cara mengecek pemahaman.'}],sources:promptSources,notes:'Bacakan prompt sebagai satu permintaan biasa. Empat label dipakai untuk latihan dan dapat dihapus ketika peserta sudah terbiasa. Jalankan permintaan, lalu periksa total menit dan pembagian beban. Hasil yang terlihat rapi masih dapat melanggar syarat; penilaian dilakukan pada hasil nyata.'});
source([29],'comparison',{title:'Permintaan awal dan permintaan SIAP',left:'Bantu saya belajar.',right:'Susun jadwal mengulang tiga bab dalam enam hari. Saya punya 45 menit per hari dan paling kesulitan pada bab kedua. Batasi waktu harian, sertakan latihan mengingat, dan sajikan tabel kegiatan.',takeaway:'Perubahan utamanya adalah informasi yang memengaruhi keputusan.',sources:promptSources});
source([30,31],'prompt',{title:'Prompt untuk memperjelas topik',prompt:'Saya mahasiswa yang baru menyusun proposal. Bantu saya memperjelas topik. Sebelum mengusulkan judul, tanyakan bidang, minat, sumber yang dapat saya akses, dan waktu penelitian. Ajukan pertanyaan satu per satu.',takeaway:'Sasaran ada, tetapi informasi belum lengkap. Percakapan dapat dimulai dengan klarifikasi.',sources:promptSources});
source([32],'sequence',{title:'Pekerjaan besar dalam tahap yang dapat diperiksa',body:['Pertanyaan dan bahan yang akan dipakai.','Rencana kerja dan hasil antara untuk diperiksa.','Draf, pembacaan ulang, dan keputusan revisi.']});
source([33],'table',{title:'Kesalahan prompt dan perbaikannya',values:[['Masalah','Perbaikan yang dapat dicoba'],['Tujuan kabur','Sebutkan hasil konkret yang dibutuhkan'],['Bahan tidak tersedia','Lampirkan bahan atau batasi pada informasi yang ada'],['Instruksi bertentangan','Tentukan prioritas dan ukuran hasil'],['Pertanyaan menggiring','Minta bukti serta kemungkinan penjelasan lain']]});
exercise('Latihan prompt SIAP',15,['Pilih kebutuhan belajar atau penelitian Anda.','Tulis empat unsur SIAP dan jalankan prompt.','Periksa hasil, lalu perbaiki satu unsur.','Tukar hasil dengan teman dan jelaskan revisinya.'],'Dua versi prompt dan satu alasan perubahan.','Alokasi: 3 menit merumuskan, 4 menit mencoba, 4 menit menilai dan memperbaiki, 4 menit saling meninjau. Nilai kejelasan sasaran, kecukupan bahan, ketegasan aturan, dan kegunaan bentuk hasil. Contoh jawaban tidak harus seragam. Gunakan catatan latihan jika peserta belum membawa bahan.',[34]);
source([35,36],'comparison',{title:'Bahan dokumen menentukan cara bekerja',leftLabel:'PDF berisi teks',rightLabel:'Gambar hasil pindai',left:'Periksa apakah teks dapat dipilih atau disalin. Tunjuk halaman serta bagian yang harus dibaca.',right:'Periksa huruf, nama, angka, dan letak halaman. Cocokkan bagian yang akan dipakai dengan gambar asal.',takeaway:'Nama berkas PDF belum menjelaskan keterbacaan isinya.'});
source([37,38],'table',{title:'Fitur yang sesuai dengan tugas',values:[['Kebutuhan','Fitur yang dapat dipertimbangkan'],['Menemukan informasi luar','Pencarian web dan penelusuran sumber'],['Mengumpulkan beberapa sumber secara bertahap','Fitur riset mendalam jika tersedia'],['Menyunting satu hasil kerja','Canvas atau Artifacts'],['Menjaga bahan dan percakapan satu pekerjaan','Projects atau ruang kerja sejenis']]});
exercise('Praktik mandiri sebelum hari kedua',15,['Pilih satu kebutuhan Anda.','Gunakan aplikasi dan fitur yang sesuai.','Lanjutkan percakapan berdasarkan hasil pertama.','Simpan bahan, prompt, dan hasil yang dipilih.'],'Satu folder kerja yang siap dibawa ke sesi penelitian.','Peserta dapat memakai alat yang tersedia pada akunnya. Bahas alasan memilih fitur, hal yang diterima dari jawaban, dan bagian yang masih harus diperiksa. Hindari penilaian berdasarkan kecepatan atau panjang jawaban saja.',[39]);
source([40],'quote',{title:'Hasil kerja hari pertama',quote:'Anda sudah mempunyai satu pekerjaan yang dapat dijelaskan kembali.',detail:'Besok kita membawa kemampuan ini ke pencarian sumber, rancangan penelitian, pembacaan, dan tulisan.'});

day=2;chapter='Pembukaan hari kedua';
source([41],'explain',{title:'Pekerjaan yang Anda simpan kemarin',lead:'Tunjukkan permintaan, hasil, dan satu keputusan Anda setelah membaca jawabannya.',detail:'Jelaskan fitur yang dipakai dan bagian yang masih perlu diperiksa. Pilih satu kebutuhan yang akan dikembangkan menjadi pekerjaan penelitian hari ini.'});
const so=flatChapters(await load('sources-openturath.json'));
const sources=so.find(c=>(c.key??c.id??c.title??'').toLowerCase().includes('source'));
if(!sources)throw Error('Missing source chapter');
section('Pengumpulan sumber','Telegram, Internet Archive, NoorBook, dan identitas bahan','Hasil bab: satu sumber yang terbuka dan catatan bibliografinya');
source([49],'prompt',{title:'Kata kunci untuk penelusuran sumber',prompt:'Dari pertanyaan penelitian saya, susun istilah utama dan variasi penelusuran dalam bahasa Arab serta bahasa lain yang relevan. Jelaskan istilah yang berkaitan tetapi tidak identik. Jangan membuat daftar referensi.'});
source([50],'table',{title:'Jenis bahan dalam pekerjaan penelitian',values:[['Bahan','Perannya'],['Sumber primer','Objek atau dasar yang dikaji sesuai pertanyaan'],['Penelitian terdahulu','Kajian peneliti lain yang perlu dibaca dan dibandingkan'],['Ringkasan AI','Bantuan memahami bahan yang tetap harus ditelusuri asalnya']]});
for(const [i,s] of (sources.slides??[]).entries()){
 const d=normalizedSlide(s);if(i===0){d.notes=[old.get(51).notes,old.get(52).notes,d.notes].join('\n\n');d.sourceIds=[51,52];}add(d);
}

section('Rancangan penelitian','Minat, pertanyaan, tujuan, dan batas pekerjaan','Hasil bab: kartu rancangan awal untuk dibicarakan dengan pembimbing');
source([42],'sequence',{title:'Peta pekerjaan penelitian',body:['Rancangan: pertanyaan, tujuan, dan batas.','Bahan: sumber, bacaan, dan metode.','Tulisan: analisis, draf, dan pembacaan ulang.']});
source([43,44],'prompt',{title:'Minat yang dapat dikembangkan',prompt:'Bantu saya mengembangkan minat menjadi topik. Tanyakan bidang, persoalan yang menarik, sumber yang dapat saya baca, dan waktu yang tersedia. Setelah cukup jelas, usulkan beberapa fokus beserta bahan dan kesulitannya. Jangan menyatakan topik belum pernah diteliti.'});
source([45,46],'comparison',{title:'Topik dan pertanyaan penelitian',leftLabel:'Topik masih luas',rightLabel:'Pertanyaan yang terarah',left:'Pembahasan ‘urf dalam khazanah Islam.',right:'Bagaimana dua sumber yang saya pilih menjelaskan satu persoalan ‘urf dalam cakupan yang sudah saya batasi?',takeaway:'Contoh rumusan latihan. Judul final mengikuti bahan yang benar-benar dibaca.'});
source([47],'explain',{title:'Tujuan dan batas penelitian',lead:'Tujuan mengikuti pertanyaan yang ingin dijawab.',detail:'Jelaskan manfaat sesuai hasil yang mungkin dicapai. Batasi bahan, istilah, dan jangkauan pembahasan agar pekerjaan dapat dilaksanakan.'});
exercise('Kartu rancangan awal',15,['Tuliskan topik sementara dan satu pertanyaan utama.','Tentukan tujuan serta batas pembahasan.','Catat sumber yang sudah ditemukan dan yang masih dicari.','Tandai satu hal yang perlu dibahas dengan pembimbing.'],'Satu kartu rancangan penelitian.','Alokasi: 5 menit menulis, 5 menit mencoba pertanyaan klarifikasi dengan AI, dan 5 menit meninjau berpasangan. Penilaian berfokus pada hubungan pertanyaan, tujuan, batas, dan bahan; bukan keindahan judul.',[48]);

section('Membaca dan menganalisis','Menghubungkan hasil bacaan dengan pertanyaan penelitian','Hasil bab: satu catatan bacaan dengan lokasi sumber yang jelas');
source([53,54],'table',{title:'Matriks penelitian terdahulu',values:[['Unsur yang dibaca','Catatan yang dicari'],['Pertanyaan dan tujuan','Apa yang hendak dijelaskan peneliti'],['Bahan dan metode','Apa yang diperiksa serta bagaimana caranya'],['Hasil dan keterbatasan','Temuan penulis dan batas yang dinyatakannya'],['Hubungan dengan topik saya','Relevansi yang dapat dijelaskan dari bacaan']]});
source([55],'quote',{title:'Kebaruan penelitian',quote:'Sedikit hasil pencarian belum membuktikan kebaruan.',detail:'Periksa variasi istilah dan tempat penelusuran. Jelaskan kontribusi sementara dari penelitian terdahulu yang sudah Anda baca.'});
source([56],'prompt',{title:'Bantuan untuk membaca teks sulit',prompt:'Jelaskan ungkapan yang saya tandai dalam teks dan konteks yang saya sertakan. Pisahkan penjelasan yang langsung tampak dari teks dan kemungkinan yang masih perlu diteliti. Pertahankan istilah ilmiahnya.'});
source([57,58],'comparison',{title:'Ringkasan dan perbandingan',leftLabel:'Merangkum satu bahan',rightLabel:'Membandingkan dua bahan',left:'Tentukan pertanyaan yang hendak dibantu. Pertahankan pengecualian dan penanda lokasi sumber.',right:'Pisahkan sumber A dan B. Ambil unsur yang sama dari masing-masing, lalu jelaskan persamaan serta perbedaannya.'});
source([59],'sequence',{title:'Kutipan, ringkasan, dan analisis',body:['Kutipan mempertahankan kata-kata sumber dan lokasinya.','Ringkasan menyampaikan makna sumber dengan rujukan.','Analisis menjelaskan hubungan atau pemahaman yang dibangun peneliti.']});
source([60],'table',{title:'Bentuk catatan bacaan',values:[['Bagian catatan','Isi yang disimpan'],['Identitas sumber','Pengarang, judul, versi, dan lokasi'],['Petikan atau informasi','Teks dan bagian sumber yang dibutuhkan'],['Ringkasan saya','Pemahaman singkat yang tetap menjaga maksud'],['Analisis dan pertanyaan','Komentar peneliti dan hal yang belum terjawab']]});
add({kind:'break',title:'Istirahat',minutes:15,subtitle:'Simpan catatan bacaan beserta sumbernya. Setelah jeda kita menyusun tulisan dan proyek akhir.'});

section('Menulis dan merevisi','Metode, kerangka, paragraf, dan keputusan penulis','Hasil bab: satu paragraf pembahasan yang mempunyai dasar bacaan');
source([61,62],'prompt',{title:'Metode mengikuti pertanyaan dan bahan',prompt:'Berdasarkan pertanyaan, sumber, dan batas penelitian yang saya berikan, jelaskan pendekatan yang mungkin sesuai, langkah kerja, serta keterbatasannya. Tunjukkan informasi yang belum cukup. Jangan menganggap saya sudah mengumpulkan data atau menjalankan prosedur.'});
exercise('Pemeriksaan kerangka',5,['Tunjuk bagian yang menjawab pertanyaan utama.','Cari pengulangan atau urutan yang membingungkan.','Tandai bagian yang belum mempunyai bahan.'],'Satu kerangka singkat dengan catatan perbaikan.','Tanyakan fungsi setiap bab dan subbab. Peserta dapat meminta AI menilai hubungan kerangka dengan pertanyaan, lalu memutuskan sendiri perubahan yang masuk akal.',[63,64]);
source([65,66],'explain',{title:'Catatan yang menjadi bahan pembahasan',lead:'Kelompokkan bacaan menurut pertanyaan yang ingin dijawab.',detail:'Ringkasan menyatakan isi sumber. Perbandingan memperlihatkan persamaan dan perbedaan. Analisis menjelaskan arti hubungan itu bagi pertanyaan penelitian.'});
source([67],'prompt',{title:'Kemungkinan penjelasan dan keberatan',prompt:'Dari dua petikan yang saya lampirkan, usulkan kemungkinan penjelasan atas perbedaannya. Untuk tiap kemungkinan, bedakan bukti yang tersedia dan bukti tambahan yang diperlukan. Sertakan satu keberatan yang masuk akal.'});
source([68,69],'sequence',{title:'Susunan satu paragraf pembahasan',body:['Gagasan yang menjawab bagian dari pertanyaan.','Kutipan atau informasi yang relevan beserta rujukan.','Penjelasan peneliti tentang hubungan bahan dan gagasan.']});
exercise('Satu paragraf dan satu keputusan revisi',15,['Gunakan catatan bacaan yang sudah Anda buat.','Tulis satu paragraf untuk satu bagian pertanyaan.','Minta masukan yang menunjuk kalimat tertentu.','Putuskan revisi dan catat alasannya.'],'Satu paragraf, satu komentar, dan keputusan penulis.','Alokasi: 6 menit menulis, 4 menit meminta serta membaca masukan, dan 5 menit menilai revisi. Teks harus tetap mempertahankan istilah, atribusi, dan tingkat kepastian sumber. Jika bahan belum cukup, nyatakan kekurangannya.',[70]);
source([71,72],'comparison',{title:'Koreksi bahasa dan keputusan penulis',leftLabel:'Masukan yang bisa diperiksa',rightLabel:'Keputusan yang perlu Anda ambil',left:'Tunjukkan kalimat, jelaskan masalahnya, dan usulkan perbaikan tanpa mengubah maksud.',right:'Bandingkan komentar dengan tulisan dan sumber. Terima, tolak, atau teliti lebih lanjut dengan alasan.'});
source([73,74],'explain',{title:'Kesimpulan dan abstrak',lead:'Kesimpulan berasal dari analisis yang benar-benar dikerjakan.',detail:'Setelah isi dan hasil jelas, abstrak merangkum persoalan, bahan, metode, dan hasil utama. Tingkat kepastian tulisan mengikuti bukti yang tersedia.'});
source([75,76],'explain',{title:'Rujukan dan tanggung jawab penulis',lead:'Pahami setiap bagian tulisan yang Anda serahkan.',detail:'Cocokkan sitasi dengan daftar pustaka dan format lembaga. Jaga atribusi serta hak akses bahan. Ikuti ketentuan lembaga mengenai penggunaan dan pelaporan bantuan AI.'});

const ot=so.find(c=>(c.key??c.id??c.title??'').toLowerCase().includes('openturath'));
if(!ot)throw Error('Missing OpenTurath chapter');
section('Proyek OpenTurath','Menerapkan keterampilan pada kebutuhan kajian turats','Hasil akhir: bahan yang dapat Anda jelaskan dan periksa');
for(const [i,s] of (ot.slides??[]).entries()){
 const d=normalizedSlide(s);if(i===0){d.notes=[old.get(77).notes,old.get(78).notes,d.notes].join('\n\n');d.sourceIds=[77,78];}add(d);
}
source([79],'table',{title:'Hasil proyek yang dipresentasikan',values:[['Bagian','Bukti kerja yang ditunjukkan'],['Rancangan','Pertanyaan dan batas pembahasan'],['Sumber','Teks yang dibuka dan identitasnya'],['Pembacaan','Catatan dengan kutipan, ringkasan, dan analisis terpisah'],['Tulisan','Paragraf dan alasan keputusan revisinya']]});
source([80],'closing',{title:'Proyek Anda berlanjut\nsetelah dauroh',detail:'Ulangi satu tugas pada bahan yang sedang Anda pelajari. Bawa pertanyaan yang jelas kepada pembimbing dan jelaskan keputusan penelitian dengan sumbernya.'});

all.forEach((s,i)=>{s.number=i+1;});
await fs.writeFile(path.join(ROOT,'revision/deck-spec.json'),JSON.stringify(all,null,2));
console.log(JSON.stringify({slides:all.length,day1:all.filter(s=>s.day===1).length,day2:all.filter(s=>s.day===2).length,chapters:chapterNo,exercises:all.filter(s=>s.kind==='exercise').map(s=>({title:s.title,minutes:s.minutes})),screenshots:all.filter(s=>s.screenshot).length}));
