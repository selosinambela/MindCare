@echo off
echo ==============================================
echo 🧠 Memulai MindCare (Backend + Frontend) ...
echo ==============================================

:: Cek apakah folder backend ada
if not exist backend (
    echo [ERROR] Folder backend tidak ditemukan!
    pause
    exit /b 1
)

:: Cek apakah folder app ada
if not exist app (
    echo [ERROR] Folder app tidak ditemukan!
    pause
    exit /b 1
)

:: Jalankan backend di command prompt baru
echo [*] Menjalankan server backend di jendela baru...
start "MindCare Backend" cmd /c "cd backend && npm start"

:: Tunggu 2 detik agar backend siap
timeout /t 2 /nobreak >nul

:: Jalankan Flutter di jendela saat ini
echo [*] Menjalankan aplikasi Flutter (Frontend)...
cd app
flutter run
