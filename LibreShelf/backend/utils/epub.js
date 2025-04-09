import fs from 'fs';
import unzipper from 'unzipper';
import path from 'path';
import { v4 as uuidv4 } from 'uuid';

export async function parseEPUB(filePath) {
  let title = 'Unknown Title';
  let author = 'Unknown Author';
  let coverImage = null;
  const tempDir = `/tmp/cover-${uuidv4()}`;

  await fs.promises.mkdir(tempDir, { recursive: true });

  const stream = fs.createReadStream(filePath).pipe(unzipper.Extract({ path: tempDir }));

  await new Promise((resolve, reject) => {
    stream.on('close', resolve);
    stream.on('error', reject);
  });

  const containerPath = path.join(tempDir, 'META-INF', 'container.xml');
  if (!fs.existsSync(containerPath)) return { title, author };

  const containerXML = fs.readFileSync(containerPath, 'utf-8');
  const opfPathMatch = containerXML.match(/full-path="([^"]+)"/);
  if (!opfPathMatch) return { title, author };

  const opfPath = path.join(tempDir, opfPathMatch[1]);
  if (!fs.existsSync(opfPath)) return { title, author };

  const opfXML = fs.readFileSync(opfPath, 'utf-8');
  const titleMatch = opfXML.match(/<dc:title[^>]*>([^<]+)<\/dc:title>/);
  const authorMatch = opfXML.match(/<dc:creator[^>]*>([^<]+)<\/dc:creator>/);
  const coverIdMatch = opfXML.match(/<meta[^>]+name=["']cover["'][^>]+content=["']([^"']+)["']/);

  title = titleMatch?.[1] ?? title;
  author = authorMatch?.[1] ?? author;

  if (coverIdMatch) {
    const coverId = coverIdMatch[1];
    const imageIdMatch = opfXML.match(
      new RegExp(`<item[^>]+id=["']${coverId}["'][^>]+href=["']([^"']+)["']`, 'i')
    );

    if (imageIdMatch) {
      const imagePath = path.join(path.dirname(opfPath), imageIdMatch[1]);
      const imageBase64 = fs.readFileSync(imagePath).toString('base64');
      const mimeType = imagePath.endsWith('.png') ? 'image/png' : 'image/jpeg';
      coverImage = `data:${mimeType};base64,${imageBase64}`;
    }
  }

  return { title, author, cover: coverImage };
}
