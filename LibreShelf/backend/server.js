import express from 'express';
import cors from 'cors';
import path from 'path';
import fs from 'fs';
import { fileURLToPath } from 'url';
import { parsePDF } from './utils/pdf.js';
import { parseEPUB } from './utils/epub.js';
import { scanBooks } from './utils/scanner.js';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// Match mounted volume path (./books:/app/books)
const BOOKS_DIR = path.join(__dirname, 'books');

const app = express();
const PORT = 4000;

app.use(cors());
app.use(express.json());

app.get('/api/books', async (req, res) => {
  try {
    const books = await scanBooks(BOOKS_DIR);
    res.json(books);
  } catch (err) {
    console.error('Failed to scan books:', err.message);
    res.status(500).json({ error: 'Failed to scan books' });
  }
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
