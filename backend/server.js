const express = require('express');
const mysql = require('mysql2');
const cors = require('cors');
const bcrypt = require('bcryptjs');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

// ── Koneksi Database MySQL ──────────────────────────────────────────────────
const db = mysql.createPool({
    host: process.env.DB_HOST || 'localhost',
    user: process.env.DB_USER || 'root',
    password: process.env.DB_PASSWORD || '',
    database: process.env.DB_NAME || 'mindcare',
    waitForConnections: true,
    connectionLimit: 10,
    queueLimit: 0
});

// Verifikasi Koneksi Database
db.getConnection((err, connection) => {
    if (err) {
        console.error('Koneksi database gagal:', err.message);
    } else {
        console.log('Terhubung ke database MySQL (XAMPP)');
        connection.release();
    }
});

// Endpoint Health Check untuk Deteksi Server Otomatis dari Flutter
app.get('/api/health', (req, res) => {
    res.status(200).json({ status: 'ok', service: 'mindcare-backend' });
});


// Helper: promisify db.query
const query = (sql, params) => {
    return new Promise((resolve, reject) => {
        db.query(sql, params, (err, results) => {
            if (err) reject(err);
            else resolve(results);
        });
    });
};

// ════════════════════════════════════════════════════════════════════════════
// AUTH ENDPOINTS
// ════════════════════════════════════════════════════════════════════════════

// POST /api/auth/register
app.post('/api/auth/register', async (req, res) => {
    try {
        const { name, email, password } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ error: 'Nama, email, dan password harus diisi.' });
        }

        // Cek apakah email sudah terdaftar
        const existing = await query('SELECT id FROM users WHERE email = ?', [email]);
        if (existing.length > 0) {
            return res.status(409).json({ error: 'Email sudah terdaftar.' });
        }

        // Hash password
        const salt = await bcrypt.genSalt(10);
        const hashedPassword = await bcrypt.hash(password, salt);

        const result = await query(
            'INSERT INTO users (name, email, password_hash) VALUES (?, ?, ?)',
            [name, email, hashedPassword]
        );

        res.status(201).json({
            message: 'Registrasi berhasil!',
            user: {
                id: result.insertId,
                name,
                email
            }
        });
    } catch (err) {
        console.error('Error register:', err);
        res.status(500).json({ error: 'Gagal melakukan registrasi.' });
    }
});

// POST /api/auth/login
app.post('/api/auth/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Email dan password harus diisi.' });
        }

        const users = await query('SELECT * FROM users WHERE email = ?', [email]);
        if (users.length === 0) {
            return res.status(401).json({ error: 'Email atau password salah.' });
        }

        const user = users[0];
        const isMatch = await bcrypt.compare(password, user.password_hash);
        if (!isMatch) {
            return res.status(401).json({ error: 'Email atau password salah.' });
        }

        res.status(200).json({
            message: 'Login berhasil!',
            user: {
                id: user.id,
                name: user.name,
                email: user.email
            }
        });
    } catch (err) {
        console.error('Error login:', err);
        res.status(500).json({ error: 'Gagal melakukan login.' });
    }
});

// ════════════════════════════════════════════════════════════════════════════
// MOOD ENDPOINTS
// ════════════════════════════════════════════════════════════════════════════

// POST /api/moods — Simpan data mood
app.post('/api/moods', (req, res) => {
    const { user_id, mood_index, mood, note } = req.body;

    if (!user_id || mood_index === undefined || !mood) {
        return res.status(400).json({ error: 'Field user_id, mood_index, dan mood harus diisi.' });
    }

    const sql = 'INSERT INTO mood_entries (user_id, mood_index, mood_label, note) VALUES (?, ?, ?, ?)';
    db.query(sql, [user_id, mood_index, mood, note || null], (err, result) => {
        if (err) {
            console.error('Error saat menyimpan mood:', err);
            return res.status(500).json({ error: 'Gagal menyimpan ke database' });
        }
        res.status(201).json({ message: 'Mood berhasil disimpan!', id: result.insertId });
    });
});

// GET /api/moods/:userId — Riwayat mood (default 7, bisa pakai ?days=30)
app.get('/api/moods/:userId', (req, res) => {
    const userId = req.params.userId;
    const days = parseInt(req.query.days) || 7;
    const sql = `SELECT id, mood_index, mood_label, note, timestamp 
                 FROM mood_entries 
                 WHERE user_id = ? AND timestamp >= DATE_SUB(NOW(), INTERVAL ? DAY)
                 ORDER BY timestamp DESC`;

    db.query(sql, [userId, days], (err, results) => {
        if (err) {
            console.error('Error saat mengambil riwayat mood:', err);
            return res.status(500).json({ error: 'Gagal mengambil data dari database' });
        }
        res.status(200).json(results);
    });
});

// ════════════════════════════════════════════════════════════════════════════
// JOURNAL ENDPOINTS
// ════════════════════════════════════════════════════════════════════════════

// GET /api/journals/:userId
app.get('/api/journals/:userId', async (req, res) => {
    try {
        const results = await query(
            'SELECT * FROM journal_entries WHERE user_id = ? ORDER BY created_at DESC',
            [req.params.userId]
        );
        res.status(200).json(results);
    } catch (err) {
        console.error('Error fetch journals:', err);
        res.status(500).json({ error: 'Gagal mengambil data jurnal.' });
    }
});

// POST /api/journals
app.post('/api/journals', async (req, res) => {
    try {
        const { user_id, title, content, mood_emoji } = req.body;

        if (!user_id || !title || !content) {
            return res.status(400).json({ error: 'user_id, title, dan content harus diisi.' });
        }

        const result = await query(
            'INSERT INTO journal_entries (user_id, title, content, mood_emoji) VALUES (?, ?, ?, ?)',
            [user_id, title, content, mood_emoji || '😊']
        );

        res.status(201).json({ message: 'Jurnal berhasil disimpan!', id: result.insertId });
    } catch (err) {
        console.error('Error create journal:', err);
        res.status(500).json({ error: 'Gagal menyimpan jurnal.' });
    }
});

// PUT /api/journals/:id
app.put('/api/journals/:id', async (req, res) => {
    try {
        const { title, content, mood_emoji } = req.body;
        await query(
            'UPDATE journal_entries SET title = ?, content = ?, mood_emoji = ? WHERE id = ?',
            [title, content, mood_emoji || '😊', req.params.id]
        );
        res.status(200).json({ message: 'Jurnal berhasil diperbarui!' });
    } catch (err) {
        console.error('Error update journal:', err);
        res.status(500).json({ error: 'Gagal memperbarui jurnal.' });
    }
});

// DELETE /api/journals/:id
app.delete('/api/journals/:id', async (req, res) => {
    try {
        await query('DELETE FROM journal_entries WHERE id = ?', [req.params.id]);
        res.status(200).json({ message: 'Jurnal berhasil dihapus!' });
    } catch (err) {
        console.error('Error delete journal:', err);
        res.status(500).json({ error: 'Gagal menghapus jurnal.' });
    }
});

// ════════════════════════════════════════════════════════════════════════════
// EXERCISE ENDPOINTS
// ════════════════════════════════════════════════════════════════════════════

// GET /api/exercises/:userId
app.get('/api/exercises/:userId', async (req, res) => {
    try {
        const results = await query(
            'SELECT * FROM exercise_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT 50',
            [req.params.userId]
        );
        res.status(200).json(results);
    } catch (err) {
        console.error('Error fetch exercises:', err);
        res.status(500).json({ error: 'Gagal mengambil data olahraga.' });
    }
});

// POST /api/exercises
app.post('/api/exercises', async (req, res) => {
    try {
        const { user_id, exercise_type, duration_minutes, calories, note } = req.body;

        if (!user_id || !exercise_type || !duration_minutes) {
            return res.status(400).json({ error: 'user_id, exercise_type, dan duration_minutes harus diisi.' });
        }

        const result = await query(
            'INSERT INTO exercise_logs (user_id, exercise_type, duration_minutes, calories, note) VALUES (?, ?, ?, ?, ?)',
            [user_id, exercise_type, duration_minutes, calories || 0, note || null]
        );

        res.status(201).json({ message: 'Aktivitas berhasil disimpan!', id: result.insertId });
    } catch (err) {
        console.error('Error create exercise:', err);
        res.status(500).json({ error: 'Gagal menyimpan aktivitas.' });
    }
});

// GET /api/exercises/:userId/stats — Ringkasan statistik mingguan
app.get('/api/exercises/:userId/stats', async (req, res) => {
    try {
        const results = await query(
            `SELECT 
                COUNT(*) as total_sessions,
                COALESCE(SUM(duration_minutes), 0) as total_minutes,
                COALESCE(SUM(calories), 0) as total_calories
             FROM exercise_logs 
             WHERE user_id = ? AND created_at >= DATE_SUB(NOW(), INTERVAL 7 DAY)`,
            [req.params.userId]
        );
        res.status(200).json(results[0]);
    } catch (err) {
        console.error('Error fetch exercise stats:', err);
        res.status(500).json({ error: 'Gagal mengambil statistik.' });
    }
});

// ════════════════════════════════════════════════════════════════════════════
// MEDITATION ENDPOINTS
// ════════════════════════════════════════════════════════════════════════════

// GET /api/meditations/:userId
app.get('/api/meditations/:userId', async (req, res) => {
    try {
        const results = await query(
            'SELECT * FROM meditation_sessions WHERE user_id = ? ORDER BY created_at DESC LIMIT 30',
            [req.params.userId]
        );
        res.status(200).json(results);
    } catch (err) {
        console.error('Error fetch meditations:', err);
        res.status(500).json({ error: 'Gagal mengambil data meditasi.' });
    }
});

// POST /api/meditations
app.post('/api/meditations', async (req, res) => {
    try {
        const { user_id, duration_seconds, type, completed } = req.body;

        if (!user_id || !duration_seconds || !type) {
            return res.status(400).json({ error: 'user_id, duration_seconds, dan type harus diisi.' });
        }

        const result = await query(
            'INSERT INTO meditation_sessions (user_id, duration_seconds, type, completed) VALUES (?, ?, ?, ?)',
            [user_id, duration_seconds, type, completed ? 1 : 0]
        );

        res.status(201).json({ message: 'Sesi meditasi berhasil disimpan!', id: result.insertId });
    } catch (err) {
        console.error('Error create meditation:', err);
        res.status(500).json({ error: 'Gagal menyimpan sesi meditasi.' });
    }
});

// GET /api/user/:userId/stats — Statistik umum user
app.get('/api/user/:userId/stats', async (req, res) => {
    try {
        const userId = req.params.userId;

        const [moodCount] = await query(
            'SELECT COUNT(*) as count FROM mood_entries WHERE user_id = ?', [userId]
        );
        const [journalCount] = await query(
            'SELECT COUNT(*) as count FROM journal_entries WHERE user_id = ?', [userId]
        );
        const [exerciseCount] = await query(
            'SELECT COUNT(*) as count FROM exercise_logs WHERE user_id = ?', [userId]
        );
        const [meditationCount] = await query(
            'SELECT COUNT(*) as count FROM meditation_sessions WHERE user_id = ?', [userId]
        );

        // Hitung streak mood (berapa hari berturut-turut ada mood entry)
        const streakData = await query(
            `SELECT DATE(timestamp) as entry_date 
             FROM mood_entries 
             WHERE user_id = ? 
             GROUP BY DATE(timestamp) 
             ORDER BY entry_date DESC`,
            [userId]
        );

        let streak = 0;
        if (streakData.length > 0) {
            const today = new Date();
            today.setHours(0, 0, 0, 0);
            
            let expectedDate = new Date(streakData[0].entry_date);
            expectedDate.setHours(0, 0, 0, 0);
            
            // Allow streak if the latest entry is today or yesterday
            const daysSinceLatest = Math.floor((today.getTime() - expectedDate.getTime()) / (1000 * 60 * 60 * 24));
            
            if (daysSinceLatest <= 1) {
                for (let i = 0; i < streakData.length; i++) {
                    const entryDate = new Date(streakData[i].entry_date);
                    entryDate.setHours(0, 0, 0, 0);
                    
                    if (entryDate.getTime() === expectedDate.getTime()) {
                        streak++;
                        expectedDate.setDate(expectedDate.getDate() - 1);
                    } else {
                        break;
                    }
                }
            }
        }

        res.status(200).json({
            mood_entries: moodCount.count,
            journal_entries: journalCount.count,
            exercise_sessions: exerciseCount.count,
            meditation_sessions: meditationCount.count,
            streak: streak
        });
    } catch (err) {
        console.error('Error fetch user stats:', err);
        res.status(500).json({ error: 'Gagal mengambil statistik user.' });
    }
});

// POST /api/chat — Chat dengan AI Companion (Gemini)
// Mendukung retry otomatis dan fallback ke model lain jika model utama overload.
const GEMINI_MODELS = [
    'gemini-2.5-flash-lite',   // Paling stabil, jarang overload
    'gemini-2.0-flash',        // Fallback model stabil
    'gemini-2.5-flash',        // Model terbaru (sering overload)
];

const SYSTEM_PROMPT = "Anda adalah AI Teman Curhat bernama MindCare Companion. Aturan WAJIB:\n1. Jawab dengan detail, ramah, dan membantu.\n2. Gunakan bahasa Indonesia santai, hangat, penuh empati. Panggil 'kamu'.\n3. Boleh gunakan emoji secukupnya untuk kehangatan.\n4. Jangan menghakimi, jangan memberi nasihat medis formal.\n5. Tanyakan balik perasaan atau cerita mereka agar percakapan mengalir.\n6. Gunakan format **bold** untuk kata-kata penting atau penekanan.\n7. Jadilah sahabat curhat yang peduli, bukan robot.\n8. Jika perlu, jelaskan dengan contoh sederhana dan tanyakan apakah pengguna ingin lanjut.";

async function callGemini(apiKey, model, contents) {
    const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${apiKey}`;
    const response = await fetch(url, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
            contents: contents,
            systemInstruction: { parts: [{ text: SYSTEM_PROMPT }] },
            generationConfig: {
                maxOutputTokens: 250,
                temperature: 0.8,
            }
        })
    });
    return response;
}

// GET /api/chat/:userId — Ambil riwayat chat
app.get('/api/chat/:userId', async (req, res) => {
    try {
        const results = await query(
            'SELECT role, text, timestamp FROM chat_messages WHERE user_id = ? ORDER BY timestamp ASC',
            [req.params.userId]
        );
        res.status(200).json(results);
    } catch (err) {
        console.error('Error fetch chat history:', err);
        res.status(500).json({ error: 'Gagal mengambil riwayat chat.' });
    }
});

app.post('/api/chat', async (req, res) => {
    try {
        const { user_id, messages } = req.body; // Butuh user_id sekarang
        
        if (!messages || !Array.isArray(messages) || !user_id) {
            return res.status(400).json({ error: 'Format pesan tidak valid atau user_id kosong.' });
        }

        // Ambil pesan terakhir dari user (yang baru saja dikirim)
        const lastUserMessage = messages[messages.length - 1];
        if (lastUserMessage && lastUserMessage.isUser) {
            await query('INSERT INTO chat_messages (user_id, role, text) VALUES (?, ?, ?)', [user_id, 'user', lastUserMessage.text]);
        }

        const apiKey = process.env.GEMINI_API_KEY;
        if (!apiKey) {
            const fallbackReply = "Halo! Saya adalah AI Teman Curhat. Namun API Key Gemini belum diatur di server.";
            await query('INSERT INTO chat_messages (user_id, role, text) VALUES (?, ?, ?)', [user_id, 'model', fallbackReply]);
            return res.status(200).json({ reply: fallbackReply });
        }

        const contents = messages.map(msg => ({
            role: msg.isUser ? 'user' : 'model',
            parts: [{ text: msg.text }]
        }));

        // Coba semua model secara bergantian sampai ada yang berhasil
        let lastError = null;
        for (const model of GEMINI_MODELS) {
            try {
                console.log(`[Chat] Mencoba model: ${model}`);
                const response = await callGemini(apiKey, model, contents);

                if (response.ok) {
                    const data = await response.json();
                    const replyText = data.candidates?.[0]?.content?.parts?.[0]?.text || 'Aku mendengarkan...';
                    console.log(`[Chat] Berhasil dengan model: ${model}`);
                    
                    // Simpan balasan AI ke database
                    await query('INSERT INTO chat_messages (user_id, role, text) VALUES (?, ?, ?)', [user_id, 'model', replyText]);

                    return res.status(200).json({ reply: replyText });
                }

                const errBody = await response.text();
                console.error(`[Chat] Model ${model} gagal (${response.status}):`, errBody);
                lastError = { status: response.status, body: errBody };

                if (response.status !== 503 && response.status !== 429) break;
            } catch (fetchErr) {
                console.error(`[Chat] Fetch error untuk model ${model}:`, fetchErr.message);
                lastError = { status: 0, body: fetchErr.message };
            }
        }

        // Semua model gagal
        const failReply = "Waduh, server AI sedang sangat sibuk saat ini 😓 Coba kirim pesanmu lagi nanti ya!";
        await query('INSERT INTO chat_messages (user_id, role, text) VALUES (?, ?, ?)', [user_id, 'model', failReply]);
        return res.status(200).json({ reply: failReply });

    } catch (err) {
        console.error('Error in chat endpoint:', err);
        res.status(200).json({ reply: "Terjadi gangguan koneksi ke server AI." });
    }
});

// ════════════════════════════════════════════════════════════════════════════
// NOTIFICATIONS, FAQS & SETTINGS
// ════════════════════════════════════════════════════════════════════════════

// GET /api/notifications/:userId
app.get('/api/notifications/:userId', async (req, res) => {
    try {
        const results = await query(
            'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT 20',
            [req.params.userId]
        );
        res.status(200).json(results);
    } catch (err) {
        res.status(500).json({ error: 'Gagal mengambil notifikasi.' });
    }
});

// POST /api/notifications
app.post('/api/notifications', async (req, res) => {
    try {
        const { user_id, title, body } = req.body;
        await query('INSERT INTO notifications (user_id, title, body) VALUES (?, ?, ?)', [user_id, title, body]);
        res.status(201).json({ message: 'Notifikasi dibuat.' });
    } catch (err) {
        res.status(500).json({ error: 'Gagal membuat notifikasi.' });
    }
});

// PUT /api/notifications/:id/read
app.put('/api/notifications/:id/read', async (req, res) => {
    try {
        await query('UPDATE notifications SET is_read = 1 WHERE id = ?', [req.params.id]);
        res.status(200).json({ message: 'Notifikasi ditandai terbaca.' });
    } catch (err) {
        res.status(500).json({ error: 'Gagal update notifikasi.' });
    }
});

// GET /api/faqs
app.get('/api/faqs', async (req, res) => {
    try {
        const results = await query('SELECT * FROM faqs');
        res.status(200).json(results);
    } catch (err) {
        res.status(500).json({ error: 'Gagal mengambil FAQ.' });
    }
});

// GET /api/settings/:userId
app.get('/api/settings/:userId', async (req, res) => {
    try {
        let results = await query('SELECT * FROM user_settings WHERE user_id = ?', [req.params.userId]);
        if (results.length === 0) {
            // Auto create default settings
            await query('INSERT INTO user_settings (user_id) VALUES (?)', [req.params.userId]);
            results = await query('SELECT * FROM user_settings WHERE user_id = ?', [req.params.userId]);
        }
        res.status(200).json(results[0]);
    } catch (err) {
        res.status(500).json({ error: 'Gagal mengambil pengaturan.' });
    }
});

// PUT /api/settings/:userId
app.put('/api/settings/:userId', async (req, res) => {
    try {
        const { allow_notifications, is_private_account } = req.body;
        await query(
            'UPDATE user_settings SET allow_notifications = ?, is_private_account = ? WHERE user_id = ?',
            [allow_notifications ? 1 : 0, is_private_account ? 1 : 0, req.params.userId]
        );
        res.status(200).json({ message: 'Pengaturan diperbarui.' });
    } catch (err) {
        res.status(500).json({ error: 'Gagal update pengaturan.' });
    }
});

// ── Jalankan Server ─────────────────────────────────────────────────────────
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`Backend API berjalan di http://localhost:${PORT}`);
});
