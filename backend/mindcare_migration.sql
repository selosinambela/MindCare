-- ============================================================
-- MindCare Database Migration
-- Jalankan script ini di phpMyAdmin atau MySQL CLI
-- ============================================================

CREATE DATABASE IF NOT EXISTS mindcare;
USE mindcare;

-- ── Tabel Users ─────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- ── Tabel Mood Entries (sudah ada, pastikan struktur) ───────
CREATE TABLE IF NOT EXISTS mood_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    mood_index INT NOT NULL,
    mood_label VARCHAR(20) NOT NULL,
    note TEXT,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── Tabel Journal Entries ───────────────────────────────────
CREATE TABLE IF NOT EXISTS journal_entries (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    content TEXT NOT NULL,
    mood_emoji VARCHAR(10) DEFAULT '😊',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── Tabel Exercise Logs ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS exercise_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    exercise_type VARCHAR(50) NOT NULL,
    duration_minutes INT NOT NULL DEFAULT 0,
    calories INT DEFAULT 0,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── Tabel Meditation Sessions ───────────────────────────────
CREATE TABLE IF NOT EXISTS meditation_sessions (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    duration_seconds INT NOT NULL DEFAULT 0,
    type VARCHAR(30) NOT NULL DEFAULT 'breathing',
    completed TINYINT(1) DEFAULT 1,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── Tabel Chat Messages (Riwayat Curhat) ────────────────────
CREATE TABLE IF NOT EXISTS chat_messages (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    role VARCHAR(10) NOT NULL, -- 'user' atau 'model'
    text TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── Tabel Notifications ─────────────────────────────────────
CREATE TABLE IF NOT EXISTS notifications (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    is_read TINYINT(1) DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- ── Tabel FAQs (Dinamis Bantuan & FAQ) ──────────────────────
CREATE TABLE IF NOT EXISTS faqs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    question VARCHAR(255) NOT NULL,
    answer TEXT NOT NULL
);

-- Insert Dummy FAQs
INSERT INTO faqs (question, answer) 
SELECT * FROM (SELECT 'Bagaimana cara mereset password?', 'Saat ini fitur reset password sedang dalam tahap pengembangan. Pastikan kamu mengingat email dan password yang digunakan saat registrasi.') AS tmp
WHERE NOT EXISTS (SELECT question FROM faqs WHERE question = 'Bagaimana cara mereset password?') LIMIT 1;

INSERT INTO faqs (question, answer) 
SELECT * FROM (SELECT 'Apakah chat AI aman dan privat?', 'Ya, semua obrolan dengan AI disimpan secara aman di database dengan enkripsi standar industri dan tidak akan dibagikan kepada pihak ketiga.') AS tmp
WHERE NOT EXISTS (SELECT question FROM faqs WHERE question = 'Apakah chat AI aman dan privat?') LIMIT 1;

INSERT INTO faqs (question, answer) 
SELECT * FROM (SELECT 'Apa yang terjadi jika saya menekan SOS?', 'Kamu akan diberikan opsi segera untuk menghubungi bantuan profesional (119 ext 8), berinteraksi darurat dengan AI, atau melakukan relaksasi pernapasan 4-7-8.') AS tmp
WHERE NOT EXISTS (SELECT question FROM faqs WHERE question = 'Apa yang terjadi jika saya menekan SOS?') LIMIT 1;

-- ── Tabel User Settings (Privasi & Keamanan) ────────────────
CREATE TABLE IF NOT EXISTS user_settings (
    user_id INT PRIMARY KEY,
    allow_notifications TINYINT(1) DEFAULT 1,
    is_private_account TINYINT(1) DEFAULT 1,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
