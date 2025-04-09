import fs from 'fs';
import epubMetadata from 'epub-metadata';

export async function parseEPUB(filePath) {
  try {
    const metadata = await epubMetadata(fs.createReadStream(filePath));
    return {
      title: metadata.title || 'Unknown Title',
      author: metadata.creator || 'Unknown Author',
      cover: null
    };
  } catch {
    return { title: 'Unknown EPUB', author: 'Unknown', cover: null };
  }
}
