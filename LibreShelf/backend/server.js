import express from 'express';
import fs from 'fs';
import path from 'path';
import cors from 'cors';
import AdmZip from 'adm-zip';
import { XMLParser } from 'fast-xml-parser';

const app = express();
const port = 4000;
app.use(cors());

const SOURCES = [
  { name: 'local', dir: '/app/books/local' },
  { name: 'shared', dir: '/app/books/shared' },
  { name: 'other', dir: '/app/books/other' }
];

const getMetadataFromEpub = (filePath) => {
  try {
    const zip = new AdmZip(filePath);
    const entries = zip.getEntries();
    const parser = new XMLParser();

    const containerEntry = entries.find(e => e.entryName.endsWith('container.xml'));
    if (!containerEntry) return {};
    const container = parser.parse(containerEntry.getData().toString());
    const opfPath = container.container.rootfiles.rootfile['@_full-path'];

    const opfEntry = entries.find(e => e.entryName === opfPath);
    if (!opfEntry) return {};
    const opf = parser.parse(opfEntry.getData().toString());

    const metadata = opf.package.metadata;
    const manifest = opf.package.manifest.item;
    const title = metadata['dc:title']?.['#text'] || metadata['dc:title'] || 'Unknown';
    const author = metadata['dc:creator']?.['#text'] || metadata['dc:creator'] || 'Unknown';

    let coverId = '';
    if (Array.isArray(manifest)) {
      const coverItem = manifest.find(i => i['@_id']?.toLowerCase().includes('cover') && i['@_media-type']?.startsWith('image'));
      coverId = coverItem?.['@_href'];
    } else if (manifest?.['@_id']?.toLowerCase().includes('cover')) {
      coverId = manifest['@_href'];
    }

    const coverPath = coverId ? path.join(path.dirname(opfPath), coverId).replaceAll('\\', '/') : null;
    return { title, author, coverPath };
  } catch {
    return {};
  }
};

app.get('/api/books', (req, res) => {
  const allBooks = [];

  for (const source of SOURCES) {
    if (!fs.existsSync(source.dir)) continue;
    const files = fs.readdirSync(source.dir);

    for (const file of files) {
      const ext = path.extname(file);
      if (ext === '.epub') {
        const fullPath = path.join(source.dir, file);
        const { title, author, coverPath } = getMetadataFromEpub(fullPath);

        allBooks.push({
          title: title || path.basename(file, ext),
          author: author || 'Unknown',
          file: file,
          source: source.name,
          coverUrl: coverPath ? `/api/cover/${source.name}/${file}` : null
        });
      }
    }
  }

  res.json(allBooks);
});

app.get('/api/cover/:source/:filename', (req, res) => {
  const { source, filename } = req.params;
  const sourceDir = SOURCES.find(s => s.name === source)?.dir;
  if (!sourceDir) return res.sendStatus(404);

  const filePath = path.join(sourceDir, filename);
  try {
    const zip = new AdmZip(filePath);
    const entries = zip.getEntries();
    const parser = new XMLParser();

    const containerEntry = entries.find(e => e.entryName.endsWith('container.xml'));
    const container = parser.parse(containerEntry.getData().toString());
    const opfPath = container.container.rootfiles.rootfile['@_full-path'];
    const opfEntry = entries.find(e => e.entryName === opfPath);
    const opf = parser.parse(opfEntry.getData().toString());
    const manifest = opf.package.manifest.item;

    let coverHref = '';
    if (Array.isArray(manifest)) {
      const coverItem = manifest.find(i => i['@_id']?.toLowerCase().includes('cover') && i['@_media-type']?.startsWith('image'));
      coverHref = coverItem?.['@_href'];
    } else if (manifest?.['@_id']?.toLowerCase().includes('cover')) {
      coverHref = manifest['@_href'];
    }

    const coverPath = path.join(path.dirname(opfPath), coverHref).replaceAll('\\', '/');
    const coverEntry = entries.find(e => e.entryName === coverPath);
    if (!coverEntry) return res.sendStatus(404);

    const ext = path.extname(coverHref).toLowerCase();
    const mimeType = ext === '.png' ? 'image/png' : 'image/jpeg';
    res.set('Content-Type', mimeType);
    res.send(coverEntry.getData());
  } catch {
    res.sendStatus(500);
  }
});

app.listen(port, () => {
  console.log(`LibreShelf backend running on port ${port}`);
});
