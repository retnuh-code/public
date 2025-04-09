import fs from 'fs';
import { getDocument } from 'pdfjs-dist';

export async function parsePDF(filePath) {
  try {
    const data = new Uint8Array(fs.readFileSync(filePath));
    const pdf = await getDocument({ data }).promise;
    const metadata = await pdf.getMetadata();
    const info = metadata.info || {};

    return {
      title: info.Title || 'Unknown',
      author: info.Author || 'Unknown',
      text: '', // Add text parsing if needed later
    };
  } catch (err) {
    console.error(`Error parsing PDF at ${filePath}:`, err.message);
    return {
      title: 'Error',
      author: 'Error',
      text: ''
    };
  }
}
