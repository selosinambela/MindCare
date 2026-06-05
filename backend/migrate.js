const fs = require('fs');
const mysql = require('mysql2');
require('dotenv').config();

// Koneksi awal tanpa database untuk memicu CREATE DATABASE jika belum ada
const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  multipleStatements: true
});

connection.connect((err) => {
  if (err) {
    console.error('Gagal terhubung ke MySQL:', err.message);
    process.exit(1);
  }
  console.log('Terhubung ke MySQL, menjalankan migrasi...');

  const sql = fs.readFileSync('mindcare_migration.sql', 'utf8');

  connection.query(sql, (err, results) => {
    if (err) {
      console.error('Gagal menjalankan migrasi:', err.message);
      connection.end();
      process.exit(1);
    }
    console.log('Migrasi database berhasil dijalankan!');
    connection.end();
  });
});
