import fs from 'fs';
import unzipper from 'unzipper';

export async function parseEPUB(filePath) {
  const stream = fs.createReadStream(filePath).pipe(unzipper.Parse({ forceStream: true }));

  for await (const entry of stream) {
    if (entry.path.match(/\.opf$/)) {
      const content = await entry.buffer();
      const xml = content.toString();
      const titleMatch = xml.match(/<dc:title[^>]*>([^<]+)<\/dc:title>/);
      const authorMatch = xml.match(/<dc:creator[^>]*>([^<]+)<\/dc:creator>/);
      return {
        title: titleMatch?.[1] ?? 'Unknown Title',
        author: authorMatch?.[1] ?? 'Unknown Author'
      };
    } else {
      entry.autodrain();
    }
  }

  return { title: 'Unknown Title', author: 'Unknown Author' };
}
