import fs from 'fs';
import { getDocument } from 'pdfjs-dist/legacy/build/pdf.js';
import { createCanvas } from 'canvas';

export async function parsePDF(filePath) {
  const fileData = fs.readFileSync(filePath);
  const pdf = await getDocument({ data: fileData }).promise;
  const meta = await pdf.getMetadata();

  let title = meta.info?.Title || 'Untitled PDF';
  let author = meta.info?.Author || 'Unknown Author';

  // Render first page for cover
  const page = await pdf.getPage(1);
  const viewport = page.getViewport({ scale: 1 });
  const canvas = createCanvas(viewport.width, viewport.height);
  const context = canvas.getContext('2d');

  await page.render({ canvasContext: context, viewport }).promise;
  const cover = canvas.toDataURL('image/png');

  return { title, author, cover };
}
