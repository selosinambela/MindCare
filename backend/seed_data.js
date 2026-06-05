const mysql = require('mysql2/promise');
require('dotenv').config();

async function seedData() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'mindcare',
        multipleStatements: true
    });

    try {
        console.log('⏳ Mencari akun pengguna...');
        const [users] = await connection.execute('SELECT id, name FROM users ORDER BY id DESC LIMIT 1');
        
        if (users.length === 0) {
            console.log('❌ Belum ada akun di database. Harap register di aplikasi terlebih dahulu!');
            process.exit(1);
        }

        const userId = users[0].id;
        const userName = users[0].name;
        console.log(`✅ Ditemukan akun: ${userName} (ID: ${userId})`);
        console.log('⏳ Menyuntikkan data simulasi 1 minggu terakhir...');

        // Hapus data lama untuk user ini (Opsional, agar data tidak menumpuk)
        // await connection.execute('DELETE FROM mood_entries WHERE user_id = ?', [userId]);
        // await connection.execute('DELETE FROM journal_entries WHERE user_id = ?', [userId]);
        // await connection.execute('DELETE FROM exercise_logs WHERE user_id = ?', [userId]);
        // await connection.execute('DELETE FROM meditation_sessions WHERE user_id = ?', [userId]);
        // await connection.execute('DELETE FROM chat_messages WHERE user_id = ?', [userId]);

        // Helper untuk mundur beberapa hari
        const getDateAgo = (days) => {
            const d = new Date();
            d.setDate(d.getDate() - days);
            return d.toISOString().slice(0, 19).replace('T', ' ');
        };

        // 1. Mood Entries (7 Hari)
        const moods = [
            [userId, 1, 'biasa', 'Agak bosan hari ini', getDateAgo(6)],
            [userId, 0, 'sedih', 'Banyak kerjaan', getDateAgo(5)],
            [userId, 3, 'senang', 'Makan enak sama teman', getDateAgo(4)],
            [userId, 1, 'biasa', 'Kegiatan rutin', getDateAgo(3)],
            [userId, 3, 'senang', 'Habis olahraga', getDateAgo(2)],
            [userId, 4, 'hebat', 'Weekend yay!', getDateAgo(1)],
            [userId, 3, 'senang', 'Siap mulai minggu baru', getDateAgo(0)],
        ];
        for (const m of moods) {
            await connection.execute('INSERT INTO mood_entries (user_id, mood_index, mood_label, note, timestamp) VALUES (?, ?, ?, ?, ?)', m);
        }

        // 2. Journal Entries (3 Hari)
        const journals = [
            [userId, 'Hari yang Berat', 'Hari ini cukup melelahkan, ada sedikit konflik di tempat kerja. Aku mencoba untuk diam dan mendengarkan.', '😔', getDateAgo(5)],
            [userId, 'Kembali Bangkit', 'Mulai merasa lebih baik setelah tidur cukup dan jalan pagi.', '😊', getDateAgo(2)],
            [userId, 'Rencana Baru', 'Menyusun resolusi untuk minggu depan. Aku ingin lebih rajin olahraga dan meditasi!', '🤩', getDateAgo(0)],
        ];
        for (const j of journals) {
            await connection.execute('INSERT INTO journal_entries (user_id, title, content, mood_emoji, created_at) VALUES (?, ?, ?, ?, ?)', j);
        }

        // 3. Exercise Logs (4 Sesi)
        const exercises = [
            [userId, 'Jalan Kaki', 20, 80, 'Jalan keliling komplek sore', getDateAgo(6)],
            [userId, 'Peregangan', 5, 20, 'Stretching ringan sebelum tidur', getDateAgo(4)],
            [userId, 'Cardio Ringan', 15, 120, 'Keringat lumayan banyak', getDateAgo(2)],
            [userId, 'Jalan Kaki', 30, 150, 'Jalan ke taman minggu pagi', getDateAgo(0)],
        ];
        for (const e of exercises) {
            await connection.execute('INSERT INTO exercise_logs (user_id, exercise_type, duration_minutes, calories, note, created_at) VALUES (?, ?, ?, ?, ?, ?)', e);
        }

        // 4. Meditation Sessions (3 Sesi)
        const meditations = [
            [userId, 300, 'breathing', 1, getDateAgo(5)], // 5 menit
            [userId, 600, 'sleep', 1, getDateAgo(3)],     // 10 menit
            [userId, 300, 'breathing', 1, getDateAgo(1)],
        ];
        for (const m of meditations) {
            await connection.execute('INSERT INTO meditation_sessions (user_id, duration_seconds, type, completed, created_at) VALUES (?, ?, ?, ?, ?)', m);
        }

        // 5. Chat History
        const chats = [
            [userId, 'user', 'Halo AI, akhir-akhir ini aku ngerasa gampang banget capek.', getDateAgo(2)],
            [userId, 'model', 'Halo 👋 Wajar banget ngerasa gitu. Kira-kira ada kejadian khusus yang bikin kamu kepikiran, atau emang kerjaan lagi padat?', getDateAgo(2)],
            [userId, 'user', 'Kerjaan lumayan padat sih, kadang susah tidur jam normal.', getDateAgo(2)],
            [userId, 'model', 'Pantesan kamu capek. Istirahat itu penting lho. Gimana kalau sebelum tidur kamu coba kurangin buka HP dan lakuin latihan napas 4-7-8? Itu bantu banget relaksasi.', getDateAgo(2)],
        ];
        for (const c of chats) {
            await connection.execute('INSERT INTO chat_messages (user_id, role, text, timestamp) VALUES (?, ?, ?, ?)', c);
        }

        console.log('🎉 Data simulasi berhasil dimasukkan!');
        console.log(`Silakan buka aplikasi dan login sebagai ${userName} untuk melihat datanya.`);
        process.exit(0);
    } catch (error) {
        console.error('❌ Gagal memasukkan data:', error);
        process.exit(1);
    }
}

seedData();
