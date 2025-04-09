import express from 'express';
import cors from 'cors';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { parsePDF } from './utils/pdf.js';
import { parseEPUB } from './utils/epub.js';
import { scanBooks } from './utils/scanner.js';

const __dirname = path.dirname(fileURLToPath(import.meta.url));

const app = express();
const PORT = 3001;
const BOOKS_DIR = '/books';

app.use(cors());
app.use(express.json());

app.get('/api/books', async (req, res) => {
  const books = await scanBooks(BOOKS_DIR);
  res.json(books);
});

app.get('/api/read/:filename', (req, res) => {
  const filePath = path.join(BOOKS_DIR, req.params.filename);
  res.sendFile(filePath);
});

app.get('/health', (req, res) => {
  res.send('OK');
});


app.listen(PORT, () => {
  console.log(`Backend running on port ${PORT}`);
});
