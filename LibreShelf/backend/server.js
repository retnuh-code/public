const express = require('express');
const fs = require('fs');
const path = require('path');
const cors = require('cors');
const { Pool } = require('pg');
const { readMetadata } = require('epub-metadata');

const app = express();
const port = 4000;
app.use(cors());

const pool = new Pool({
  user: 'admin',
  host: 'libreshelf-db',
  database: 'libreshelf',
  password: 'changeme',
  port: 5432,
});

const BOOKS_DIR = path.join(__dirname, 'books');

// --- GET: All scanned books ---
app.get('/api/books', async (req, res) => {
  const files = fs.readdirSync(BOOKS_DIR);
  const books = [];

  for (const file of files) {
    const fullPath = path.join(BOOKS_DIR, file);
    if (path.extname(file) === '.epub') {
      try {
        const meta = await readMetadata(fullPath);
        books.push({
          title: meta.title || file,
          author: meta.creator || 'Unknown',
          file: file
        });
      } catch (err) {
        books.push({ title: file, author: 'Unknown', file });
      }
    }
  }

  res.json(books);
});

app.listen(port, () => {
  console.log(`LibreShelf backend running on port ${port}`);
});
