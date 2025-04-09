import fs from 'fs';
import path from 'path';
import { parsePDF } from './pdf.js';
import { parseEPUB } from './epub.js';

export async function scanBooks(dir) {
  const files = fs.readdirSync(dir);
  const books = [];

  for (const file of files) {
    const ext = path.extname(file).toLowerCase();
    const fullPath = path.join(dir, file);

    let metadata = null;

    if (ext === '.pdf') metadata = await parsePDF(fullPath);
    else if (ext === '.epub') metadata = await parseEPUB(fullPath);

    if (metadata) {
      books.push({
        ...metadata,
        filename: file
      });
    }
  }

  return books;
}
