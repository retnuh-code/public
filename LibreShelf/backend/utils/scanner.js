import fs from 'fs';
import path from 'path';
import { parsePDF } from './pdf.js';
import { parseEPUB } from './epub.js';

export async function scanBooks(dirPath) {
  const files = fs.readdirSync(dirPath);
  const books = [];

  for (const file of files) {
    const filePath = path.join(dirPath, file);
    const stat = fs.statSync(filePath);

    if (!stat.isFile()) continue;

    const ext = path.extname(file).toLowerCase();

    try {
      let metadata = null;

      if (ext === '.epub') {
        metadata = await parseEPUB(filePath);
      } else if (ext === '.pdf') {
        metadata = await parsePDF(filePath);
      }

      if (metadata) {
        metadata.filename = file;
        books.push(metadata);
      }
    } catch (err) {
      console.error(`Failed to parse ${file}:`, err.message);
    }
  }

  return books;
}
