import express from 'express';
import fs from 'fs';
import path from 'path';
import cors from 'cors';
import pkg from 'pg';
import { readMetadata } from 'epub-metadata';

const { Pool } = pkg;
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

const BOOKS_DIR = path.join('/app', 'books');

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
