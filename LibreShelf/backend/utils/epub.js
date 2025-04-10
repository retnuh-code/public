import fs from 'fs';
import path from 'path';
import unzipper from 'unzipper';
import { v4 as uuidv4 } from 'uuid';

export async function parseEPUB(epubPath) {
  const stream = fs.createReadStream(epubPath).pipe(unzipper.Parse({ forceStream: true }));
  const metadata = {
    title: path.basename(epubPath),
    author: 'Unknown',
    cover: null,
  };

  let foundCover = null;
  let coverBuffer = null;

  for await (const entry of stream) {
    const filePath = entry.path.toLowerCase();

    if (filePath.endsWith('content.opf')) {
      const content = await entry.buffer();
      const opf = content.toString();

      const titleMatch = opf.match(/<dc:title[^>]*>([^<]+)<\/dc:title>/);
      if (titleMatch) metadata.title = titleMatch[1];

      const authorMatch = opf.match(/<dc:creator[^>]*>([^<]+)<\/dc:creator>/);
      if (authorMatch) metadata.author = authorMatch[1];

      const coverIdMatch = opf.match(/<meta[^>]*name=["']cover["'][^>]*content=["']([^"']+)["']/);
      if (coverIdMatch) {
        const coverId = coverIdMatch[1];
        const coverHrefMatch = new RegExp(`<item[^>]*id=["']${coverId}["'][^>]*href=["']([^"']+)["']`, 'i').exec(opf);
        if (coverHrefMatch) {
          foundCover = coverHrefMatch[1];
        }
      }

      entry.autodrain();
    } else if (foundCover && filePath.endsWith(foundCover.toLowerCase())) {
      coverBuffer = await entry.buffer();
    } else {
      entry.autodrain();
    }
  }

  if (coverBuffer) {
    const encoded = coverBuffer.toString('base64');
    metadata.cover = `data:image/jpeg;base64,${encoded}`;
  }

  return metadata;
}
