const mysql = require('mysql2');
require('dotenv').config();

const connection = mysql.createConnection({
  host: process.env.DB_HOST || 'localhost',
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'mindcare'
});

connection.connect((err) => {
  if (err) {
    console.error('Koneksi gagal:', err.message);
    process.exit(1);
  }
  
  connection.query('DESCRIBE users', (err, results) => {
    if (err) {
      console.error('Gagal DESCRIBE:', err.message);
    } else {
      console.log('Kolom pada tabel users:');
      console.table(results);
    }
    connection.end();
  });
});
