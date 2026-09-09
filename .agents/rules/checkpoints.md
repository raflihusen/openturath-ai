# Rule: Automatic Checkpoints on Every Change

Setiap perubahan sekecil apapun (perbaikan bug, penyesuaian teks, styling, penambahan widget, atau konfigurasi) WAJIB langsung dibuatkan check point berupa Git commit secara otomatis.

Langkah wajib setelah setiap perubahan:
1. Stage file terkait: `git add <files>`
2. Commit dengan deskripsi jelas: `git commit -m "<type>(<scope>): <pesan perubahan>"`
