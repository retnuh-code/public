import express from 'express';
import fs from 'fs';
import path from 'path';
import cors from 'cors';
import pkg from 'pg';

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

const SOURCES = [
  { name: 'local', dir: '/app/books/local' },
  { name: 'shared', dir: '/app/books/shared' },
  { name: 'other', dir: '/app/books/other' }
];

app.get('/api/books', async (req, res) => {
  const allBooks = [];

  for (const source of SOURCES) {
    if (!fs.existsSync(source.dir)) continue;
    const files = fs.readdirSync(source.dir);

    for (const file of files) {
      const ext = path.extname(file);
      if (ext === '.epub') {
        allBooks.push({
          title: path.basename(file, ext),
          author: 'Unknown',
          file: file,
          source: source.name
        });
      }
    }
  }

  res.json(allBooks);
});

app.listen(port, () => {
  console.log(`LibreShelf backend running on port ${port}`);
});

