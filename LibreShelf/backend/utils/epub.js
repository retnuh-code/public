import fs from 'fs';
import path from 'path';
import unzipper from 'unzipper';
import { v4 as uuidv4 } from 'uuid';

export async function parseEPUB(filePath) {
  try {
    const directory = await unzipper.Open.file(filePath);
    const container = directory.files.find(f => f.path === 'META-INF/container.xml');
    const containerXml = await container.buffer();
    const rootFileMatch = containerXml.toString().match(/full-path="(.+?)"/);
    const rootFilePath = rootFileMatch?.[1];

    const rootFile = directory.files.find(f => f.path === rootFilePath);
    const rootContent = await rootFile.buffer();

    const titleMatch = rootContent.toString().match(/<dc:title[^>]*>(.*?)<\/dc:title>/);
    const authorMatch = rootContent.toString().match(/<dc:creator[^>]*>(.*?)<\/dc:creator>/);
    const coverIdMatch = rootContent.toString().match(/<meta[^>]*name="cover"[^>]*content="(.*?)"/);

    const coverId = coverIdMatch?.[1];
    let coverFile = null;

    if (coverId) {
      const coverHrefMatch = rootContent.toString().match(
        new RegExp(`<item[^>]*id="${coverId}"[^>]*href="(.*?)"`, 'i')
      );
      const coverHref = coverHrefMatch?.[1];
      if (coverHref) {
        const coverFullPath = path.join(path.dirname(rootFilePath), coverHref);
        const coverEntry = directory.files.find(f => f.path === coverFullPath);
        if (coverEntry) {
          const coverBuffer = await coverEntry.buffer();
          const base64 = coverBuffer.toString('base64');
          coverFile = `data:image/jpeg;base64,${base64}`;
        }
      }
    }

    return {
      title: titleMatch?.[1] || 'Unknown Title',
      author: authorMatch?.[1] || 'Unknown Author',
      cover: coverFile,
    };
  } catch (err) {
    console.error(`Failed to parse EPUB "${filePath}":`, err.message);
    return {
      title: 'Unknown',
      author: 'Unknown',
      cover: null,
    };
  }
}
