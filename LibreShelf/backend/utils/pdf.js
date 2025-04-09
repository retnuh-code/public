import fs from 'fs';
import pdfParse from 'pdf-parse';

export async function parsePDF(filePath) {
  try {
    const data = await pdfParse(fs.readFileSync(filePath));
    return {
      title: data.info.Title || 'Untitled PDF',
      author: data.info.Author || 'Unknown Author',
      cover: null
    };
  } catch {
    return { title: 'Unknown PDF', author: 'Unknown', cover: null };
  }
}
