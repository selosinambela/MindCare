# 🌿 MindCare 

MindCare adalah aplikasi kesehatan mental komprehensif yang dirancang untuk membantu pengguna melacak suasana hati (*mood*), menulis jurnal rasa syukur, melakukan meditasi terpandu, mencatat aktivitas olahraga, serta mencurahkan perasaan kepada **AI Companion** yang aman dan privat.

Aplikasi ini dibangun menggunakan **Flutter** untuk antarmuka pengguna (Frontend) dan **Node.js (Express)** berserta **MySQL** untuk sisi server (Backend).

---

## ✨ Fitur Utama
- **AI Teman Curhat**: Ngobrol secara privat dengan AI yang suportif dan empatik. Riwayat percakapan dikelompokkan otomatis berdasarkan hari.
- **Mood Tracker**: Lacak emosi harian Anda dan lihat pola suasana hati dalam bentuk grafik statistik mingguan/bulanan.
- **Jurnal Rasa Syukur**: Tuliskan hal-hal baik yang terjadi setiap hari untuk menjaga pikiran tetap positif.
- **Meditasi & Relaksasi**: Sesi pernapasan 4-7-8 dan panduan audio untuk mengurangi stres.
- **Catatan Olahraga**: Catat durasi dan kalori aktivitas fisik harian Anda.
- **Sistem *Streak***: Pertahankan konsistensi harian Anda dengan fitur runtun waktu (*streak*).

---

## 🛠️ Teknologi yang Digunakan
- **Frontend**: Flutter (Dart)
- **Backend**: Node.js, Express.js, Google Generative AI (Gemini API)
- **Database**: MySQL (XAMPP/MAMP)
- **Komunikasi Data**: RESTful API (JSON)

---

## ⚙️ Persyaratan Sistem (*Prerequisites*)
Sebelum menjalankan proyek ini, pastikan Anda (atau *collaborator*) sudah menginstal:
1. **Flutter SDK** (versi stabil terbaru) & Dart.
2. **Node.js** (v16 atau lebih baru) & NPM.
3. **XAMPP** (atau aplikasi sejenis seperti MAMP/WAMP) untuk menjalankan server MySQL lokal.
4. **Git** untuk *version control*.

---

## 🚀 Panduan Instalasi & Menjalankan Aplikasi

Ikuti langkah-langkah di bawah ini secara berurutan agar aplikasi dapat berjalan dengan sempurna.

### 1. Kloning Repositori
```bash
git clone https://github.com/selosinambela/MindCare.git
cd MindCare
```

### 2. Setup Database (Sangat Penting)
Aplikasi membutuhkan database MySQL untuk menyimpan data user.
1. Buka aplikasi **XAMPP** dan klik **Start** pada modul **Apache** dan **MySQL**.
2. Buka browser dan akses [http://localhost/phpmyadmin](http://localhost/phpmyadmin).
3. Buat database baru dengan nama `mindcare`.
4. Klik database `mindcare` tersebut, lalu pilih tab **Import**.
5. Unggah file **`mindcare.sql`** yang terletak di dalam folder `backend/mindcare.sql`.
6. Klik **Go** / **Import** di bagian bawah. Semua tabel dan struktur akan otomatis dibuat dengan rapi!

### 3. Setup Backend (Node.js)
```bash
# Pindah ke direktori backend
cd backend

# Instal semua dependensi Node.js
npm install

# Jalankan server
npm start
```
> Server akan berjalan di `http://localhost:3000`. Biarkan terminal ini tetap terbuka.

### 4. Setup Frontend (Flutter)
Buka terminal baru (*tab* baru) untuk menjalankan Flutter:
```bash
# Kembali ke root folder, lalu masuk ke folder app
cd ../app

# Unduh semua package Flutter
flutter pub get

# Jalankan aplikasi (pilih Windows, Chrome, atau Emulator Android)
flutter run
```

---

## 📁 Struktur Direktori

```text
mindcare/
├── app/                  # Kode sumber Frontend (Flutter)
│   ├── assets/           # Gambar, ikon, logo
│   ├── lib/
│   │   ├── controllers/  # State Management & logika UI
│   │   ├── models/       # Struktur Data / Class
│   │   ├── screens/      # Seluruh Halaman Antarmuka
│   │   ├── services/     # Koneksi API ke Backend
│   │   ├── theme/        # Konfigurasi Warna (Sage Green) & Tipografi
│   │   └── widgets/      # Komponen kustom yang bisa dipakai ulang
│   └── pubspec.yaml      # Dependensi Flutter
│
└── backend/              # Kode sumber Backend (Node.js)
    ├── mindcare.sql      # File Database (Silakan di-import!)
    ├── package.json      # Dependensi Node.js
    ├── .env              # Konfigurasi Environment & API Keys
    └── server.js         # REST API & Konfigurasi Server
```

---

## 🤝 Kontribusi (Untuk Kolaborator)
1. Lakukan `git pull origin main` terlebih dahulu sebelum mulai mengedit kode untuk menghindari *conflict*.
2. Kerjakan bagian Anda dan pastikan kode sudah berjalan dengan baik (tidak ada *error*).
3. Lakukan *commit* dan langsung *push* ke *branch* `main` (`git push origin main`).
4. Jika ada penambahan struktur tabel database baru, harap *export* ulang database lokal Anda lalu timpa file `backend/mindcare.sql` agar struktur database untuk tim tetap mutakhir (*up-to-date*) saat mereka melakukan *pull*!

***Dibuat dengan ❤️ untuk Kesehatan Mental yang Lebih Baik.***
