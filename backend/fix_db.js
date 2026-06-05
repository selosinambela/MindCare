const mysql = require('mysql2/promise');
require('dotenv').config();

async function run() {
    const connection = await mysql.createConnection({
        host: process.env.DB_HOST || 'localhost',
        user: process.env.DB_USER || 'root',
        password: process.env.DB_PASSWORD || '',
        database: process.env.DB_NAME || 'mindcare'
    });

    try {
        console.log('Menyalin data dari user 2 ke user 1...');
        
        // Helper
        const copyTable = async (table, cols) => {
            await connection.execute(`INSERT INTO ${table} (user_id, ${cols.join(', ')}) SELECT 1, ${cols.join(', ')} FROM ${table} WHERE user_id = 2`);
        };

        await copyTable('mood_entries', ['mood_index', 'mood_label', 'note', 'timestamp']);
        await copyTable('journal_entries', ['title', 'content', 'mood_emoji', 'created_at']);
        await copyTable('exercise_logs', ['exercise_type', 'duration_minutes', 'calories', 'note', 'created_at']);
        await copyTable('meditation_sessions', ['duration_seconds', 'type', 'completed', 'created_at']);
        await copyTable('chat_messages', ['role', 'text', 'timestamp']);
        
        console.log('✅ Selesai.');
        process.exit(0);
    } catch (e) {
        console.error(e);
        process.exit(1);
    }
}
run();
