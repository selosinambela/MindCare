-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1:3306
-- Waktu pembuatan: 05 Jun 2026 pada 21.02
-- Versi server: 10.4.32-MariaDB
-- Versi PHP: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `mindcare`
--

-- --------------------------------------------------------

--
-- Struktur dari tabel `chat_messages`
--

CREATE TABLE `chat_messages` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `role` varchar(10) NOT NULL,
  `text` text NOT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `chat_messages`
--

INSERT INTO `chat_messages` (`id`, `user_id`, `role`, `text`, `timestamp`) VALUES
(1, 1, 'user', 'Saya merasa cemas & overthinking...', '2026-06-05 17:27:42'),
(2, 1, 'model', 'Waduh, server AI sedang sangat sibuk saat ini 😓 Coba kirim pesanmu lagi nanti ya!', '2026-06-05 17:28:04'),
(3, 2, 'user', 'Halo AI, akhir-akhir ini aku ngerasa gampang banget capek.', '2026-06-03 10:30:47'),
(4, 2, 'model', 'Halo 👋 Wajar banget ngerasa gitu. Kira-kira ada kejadian khusus yang bikin kamu kepikiran, atau emang kerjaan lagi padat?', '2026-06-03 10:30:47'),
(5, 2, 'user', 'Kerjaan lumayan padat sih, kadang susah tidur jam normal.', '2026-06-03 10:30:47'),
(6, 2, 'model', 'Pantesan kamu capek. Istirahat itu penting lho. Gimana kalau sebelum tidur kamu coba kurangin buka HP dan lakuin latihan napas 4-7-8? Itu bantu banget relaksasi.', '2026-06-03 10:30:47'),
(7, 1, 'user', 'Halo AI, akhir-akhir ini aku ngerasa gampang banget capek.', '2026-06-03 10:30:47'),
(8, 1, 'model', 'Halo 👋 Wajar banget ngerasa gitu. Kira-kira ada kejadian khusus yang bikin kamu kepikiran, atau emang kerjaan lagi padat?', '2026-06-03 10:30:47'),
(9, 1, 'user', 'Kerjaan lumayan padat sih, kadang susah tidur jam normal.', '2026-06-03 10:30:47'),
(10, 1, 'model', 'Pantesan kamu capek. Istirahat itu penting lho. Gimana kalau sebelum tidur kamu coba kurangin buka HP dan lakuin latihan napas 4-7-8? Itu bantu banget relaksasi.', '2026-06-03 10:30:47');

-- --------------------------------------------------------

--
-- Struktur dari tabel `emergency_contacts`
--

CREATE TABLE `emergency_contacts` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `contact_name` varchar(100) NOT NULL,
  `phone_number` varchar(20) NOT NULL,
  `is_primary` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `exercise_logs`
--

CREATE TABLE `exercise_logs` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `exercise_type` varchar(50) NOT NULL,
  `duration_minutes` int(11) NOT NULL DEFAULT 0,
  `calories` int(11) DEFAULT 0,
  `note` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `exercise_logs`
--

INSERT INTO `exercise_logs` (`id`, `user_id`, `exercise_type`, `duration_minutes`, `calories`, `note`, `created_at`) VALUES
(1, 1, 'Pernapasan', 2, 5, 'Sesi guided: Latihan Pernapasan', '2026-06-05 16:58:52'),
(2, 2, 'Jalan Kaki', 20, 80, 'Jalan keliling komplek sore', '2026-05-30 10:30:47'),
(3, 2, 'Peregangan', 5, 20, 'Stretching ringan sebelum tidur', '2026-06-01 10:30:47'),
(4, 2, 'Cardio Ringan', 15, 120, 'Keringat lumayan banyak', '2026-06-03 10:30:47'),
(5, 2, 'Jalan Kaki', 30, 150, 'Jalan ke taman minggu pagi', '2026-06-05 10:30:47'),
(6, 1, 'Jalan Kaki', 20, 80, 'Jalan keliling komplek sore', '2026-05-30 10:30:47'),
(7, 1, 'Peregangan', 5, 20, 'Stretching ringan sebelum tidur', '2026-06-01 10:30:47'),
(8, 1, 'Cardio Ringan', 15, 120, 'Keringat lumayan banyak', '2026-06-03 10:30:47'),
(9, 1, 'Jalan Kaki', 30, 150, 'Jalan ke taman minggu pagi', '2026-06-05 10:30:47');

-- --------------------------------------------------------

--
-- Struktur dari tabel `faqs`
--

CREATE TABLE `faqs` (
  `id` int(11) NOT NULL,
  `question` varchar(255) NOT NULL,
  `answer` text NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `faqs`
--

INSERT INTO `faqs` (`id`, `question`, `answer`) VALUES
(1, 'Bagaimana cara mereset password?', 'Saat ini fitur reset password sedang dalam tahap pengembangan. Pastikan kamu mengingat email dan password yang digunakan saat registrasi.'),
(2, 'Apakah chat AI aman dan privat?', 'Ya, semua obrolan dengan AI disimpan secara aman di database dengan enkripsi standar industri dan tidak akan dibagikan kepada pihak ketiga.'),
(3, 'Apa yang terjadi jika saya menekan SOS?', 'Kamu akan diberikan opsi segera untuk menghubungi bantuan profesional (119 ext 8), berinteraksi darurat dengan AI, atau melakukan relaksasi pernapasan 4-7-8.');

-- --------------------------------------------------------

--
-- Struktur dari tabel `journal_entries`
--

CREATE TABLE `journal_entries` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `mood_emoji` varchar(10) DEFAULT '?',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `journal_entries`
--

INSERT INTO `journal_entries` (`id`, `user_id`, `title`, `content`, `mood_emoji`, `created_at`, `updated_at`) VALUES
(1, 2, 'Ujian minggu pertama', 'saya bersyukur karena hari ini, jumat 5 juni 2026 saya telah menyelesaikan ujian akhir semester genap (semester 4).', '😇', '2026-06-05 09:36:58', '2026-06-05 09:36:58'),
(2, 1, 'Mati Lampu', 'Hari ini saaya sangat lelah fisik dan mental, karena saya pergi ke kopken untuk ngerjain tugas, namun tiba2 lampu mati dan hujan turun. Tidak ada jaringan untuk memesan taksi online dan baterai saya hampir habis.', '🤯', '2026-06-05 16:17:05', '2026-06-05 16:17:05'),
(3, 2, 'Hari yang Berat', 'Hari ini cukup melelahkan, ada sedikit konflik di tempat kerja. Aku mencoba untuk diam dan mendengarkan.', '😔', '2026-05-31 10:30:47', '2026-06-05 17:30:47'),
(4, 2, 'Kembali Bangkit', 'Mulai merasa lebih baik setelah tidur cukup dan jalan pagi.', '😊', '2026-06-03 10:30:47', '2026-06-05 17:30:47'),
(5, 2, 'Rencana Baru', 'Menyusun resolusi untuk minggu depan. Aku ingin lebih rajin olahraga dan meditasi!', '🤩', '2026-06-05 10:30:47', '2026-06-05 17:30:47'),
(6, 1, 'Ujian minggu pertama', 'saya bersyukur karena hari ini, jumat 5 juni 2026 saya telah menyelesaikan ujian akhir semester genap (semester 4).', '😇', '2026-06-05 09:36:58', '2026-06-05 18:15:32'),
(7, 1, 'Hari yang Berat', 'Hari ini cukup melelahkan, ada sedikit konflik di tempat kerja. Aku mencoba untuk diam dan mendengarkan.', '😔', '2026-05-31 10:30:47', '2026-06-05 18:15:32'),
(8, 1, 'Kembali Bangkit', 'Mulai merasa lebih baik setelah tidur cukup dan jalan pagi.', '😊', '2026-06-03 10:30:47', '2026-06-05 18:15:32'),
(9, 1, 'Rencana Baru', 'Menyusun resolusi untuk minggu depan. Aku ingin lebih rajin olahraga dan meditasi!', '🤩', '2026-06-05 10:30:47', '2026-06-05 18:15:32');

-- --------------------------------------------------------

--
-- Struktur dari tabel `meditation_sessions`
--

CREATE TABLE `meditation_sessions` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `duration_seconds` int(11) NOT NULL DEFAULT 0,
  `type` varchar(30) NOT NULL DEFAULT 'breathing',
  `completed` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `meditation_sessions`
--

INSERT INTO `meditation_sessions` (`id`, `user_id`, `duration_seconds`, `type`, `completed`, `created_at`) VALUES
(1, 2, 300, 'breathing', 1, '2026-05-31 10:30:47'),
(2, 2, 600, 'sleep', 1, '2026-06-02 10:30:47'),
(3, 2, 300, 'breathing', 1, '2026-06-04 10:30:47'),
(4, 1, 300, 'breathing', 1, '2026-05-31 10:30:47'),
(5, 1, 600, 'sleep', 1, '2026-06-02 10:30:47'),
(6, 1, 300, 'breathing', 1, '2026-06-04 10:30:47');

-- --------------------------------------------------------

--
-- Struktur dari tabel `mood_entries`
--

CREATE TABLE `mood_entries` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `mood_index` int(11) NOT NULL CHECK (`mood_index` between 0 and 4),
  `mood_label` varchar(20) NOT NULL CHECK (`mood_label` in ('sedih','biasa','oke','senang','hebat')),
  `note` text DEFAULT NULL,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `mood_entries`
--

INSERT INTO `mood_entries` (`id`, `user_id`, `mood_index`, `mood_label`, `note`, `timestamp`) VALUES
(1, 2, 4, 'Biasa', 'Agak bosan hari ini', '2026-05-30 10:29:51'),
(2, 2, 3, 'Sedih', 'Banyak kerjaan', '2026-05-31 10:29:51'),
(3, 2, 1, 'biasa', 'Agak bosan hari ini', '2026-05-30 10:30:47'),
(4, 2, 0, 'sedih', 'Banyak kerjaan', '2026-05-31 10:30:47'),
(5, 2, 3, 'senang', 'Makan enak sama teman', '2026-06-01 10:30:47'),
(6, 2, 1, 'biasa', 'Kegiatan rutin', '2026-06-02 10:30:47'),
(7, 2, 3, 'senang', 'Habis olahraga', '2026-06-03 10:30:47'),
(8, 2, 4, 'hebat', 'Weekend yay!', '2026-06-04 10:30:47'),
(9, 2, 3, 'senang', 'Siap mulai minggu baru', '2026-06-05 10:30:47'),
(10, 1, 4, 'Biasa', 'Agak bosan hari ini', '2026-05-30 10:29:51'),
(11, 1, 3, 'Sedih', 'Banyak kerjaan', '2026-05-31 10:29:51'),
(12, 1, 1, 'biasa', 'Agak bosan hari ini', '2026-05-30 10:30:47'),
(13, 1, 0, 'sedih', 'Banyak kerjaan', '2026-05-31 10:30:47'),
(14, 1, 3, 'senang', 'Makan enak sama teman', '2026-06-01 10:30:47'),
(15, 1, 1, 'biasa', 'Kegiatan rutin', '2026-06-02 10:30:47'),
(16, 1, 3, 'senang', 'Habis olahraga', '2026-06-03 10:30:47'),
(17, 1, 4, 'hebat', 'Weekend yay!', '2026-06-04 10:30:47'),
(18, 1, 3, 'senang', 'Siap mulai minggu baru', '2026-06-05 10:30:47');

-- --------------------------------------------------------

--
-- Struktur dari tabel `notifications`
--

CREATE TABLE `notifications` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL,
  `body` text NOT NULL,
  `is_read` tinyint(1) DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `reminders`
--

CREATE TABLE `reminders` (
  `id` int(11) NOT NULL,
  `user_id` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `schedule_time` time NOT NULL,
  `is_enabled` tinyint(1) DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

-- --------------------------------------------------------

--
-- Struktur dari tabel `users`
--

CREATE TABLE `users` (
  `id` int(11) NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(150) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `avatar_url` varchar(255) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `users`
--

INSERT INTO `users` (`id`, `name`, `email`, `password_hash`, `avatar_url`, `created_at`, `updated_at`) VALUES
(1, 'Vaidon', 'vaidon@gmail.com', '$2a$10$ekImhrBY7vpbdULPwys6Petstj21/XGvBq26zxiEG6LqV.MsscOFy', NULL, '2026-06-04 20:13:28', '2026-06-04 20:13:28'),
(2, 'Rael', 'rael@gmail.com', '$2a$10$zjOinysxy9dMBPmdNn7rpe/3fgzdym7kKgbcICHpWlqJvFg/Qpngu', NULL, '2026-06-05 09:33:24', '2026-06-05 09:33:24');

-- --------------------------------------------------------

--
-- Struktur dari tabel `user_settings`
--

CREATE TABLE `user_settings` (
  `user_id` int(11) NOT NULL,
  `allow_notifications` tinyint(1) DEFAULT 1,
  `is_private_account` tinyint(1) DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data untuk tabel `user_settings`
--

INSERT INTO `user_settings` (`user_id`, `allow_notifications`, `is_private_account`) VALUES
(1, 1, 1),
(2, 1, 1);

--
-- Indexes for dumped tables
--

--
-- Indeks untuk tabel `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_chat_timestamp` (`timestamp`);

--
-- Indeks untuk tabel `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `exercise_logs`
--
ALTER TABLE `exercise_logs`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_exercise_created` (`created_at`);

--
-- Indeks untuk tabel `faqs`
--
ALTER TABLE `faqs`
  ADD PRIMARY KEY (`id`);

--
-- Indeks untuk tabel `journal_entries`
--
ALTER TABLE `journal_entries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_journal_created` (`created_at`);

--
-- Indeks untuk tabel `meditation_sessions`
--
ALTER TABLE `meditation_sessions`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`),
  ADD KEY `idx_meditation_created` (`created_at`);

--
-- Indeks untuk tabel `mood_entries`
--
ALTER TABLE `mood_entries`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_moods_user_timestamp` (`user_id`,`timestamp`);

--
-- Indeks untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `reminders`
--
ALTER TABLE `reminders`
  ADD PRIMARY KEY (`id`),
  ADD KEY `user_id` (`user_id`);

--
-- Indeks untuk tabel `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indeks untuk tabel `user_settings`
--
ALTER TABLE `user_settings`
  ADD PRIMARY KEY (`user_id`);

--
-- AUTO_INCREMENT untuk tabel yang dibuang
--

--
-- AUTO_INCREMENT untuk tabel `chat_messages`
--
ALTER TABLE `chat_messages`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=14;

--
-- AUTO_INCREMENT untuk tabel `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `exercise_logs`
--
ALTER TABLE `exercise_logs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `faqs`
--
ALTER TABLE `faqs`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT untuk tabel `journal_entries`
--
ALTER TABLE `journal_entries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT untuk tabel `meditation_sessions`
--
ALTER TABLE `meditation_sessions`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT untuk tabel `mood_entries`
--
ALTER TABLE `mood_entries`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=25;

--
-- AUTO_INCREMENT untuk tabel `notifications`
--
ALTER TABLE `notifications`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `reminders`
--
ALTER TABLE `reminders`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT untuk tabel `users`
--
ALTER TABLE `users`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- Ketidakleluasaan untuk tabel pelimpahan (Dumped Tables)
--

--
-- Ketidakleluasaan untuk tabel `chat_messages`
--
ALTER TABLE `chat_messages`
  ADD CONSTRAINT `chat_messages_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `emergency_contacts`
--
ALTER TABLE `emergency_contacts`
  ADD CONSTRAINT `emergency_contacts_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `exercise_logs`
--
ALTER TABLE `exercise_logs`
  ADD CONSTRAINT `exercise_logs_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `journal_entries`
--
ALTER TABLE `journal_entries`
  ADD CONSTRAINT `journal_entries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `meditation_sessions`
--
ALTER TABLE `meditation_sessions`
  ADD CONSTRAINT `meditation_sessions_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `mood_entries`
--
ALTER TABLE `mood_entries`
  ADD CONSTRAINT `mood_entries_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `notifications`
--
ALTER TABLE `notifications`
  ADD CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `reminders`
--
ALTER TABLE `reminders`
  ADD CONSTRAINT `reminders_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;

--
-- Ketidakleluasaan untuk tabel `user_settings`
--
ALTER TABLE `user_settings`
  ADD CONSTRAINT `user_settings_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
