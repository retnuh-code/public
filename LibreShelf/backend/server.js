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
    const parser = new XMLParser({ ignoreAttributes: false });

    const containerEntry = entries.find(e => e.entryName.endsWith('container.xml'));
    const container = parser.parse(containerEntry.getData().toString());
    const opfPath = container.container.rootfiles.rootfile['@_full-path'];

    const opfEntry = entries.find(e => e.entryName === opfPath);
    const opf = parser.parse(opfEntry.getData().toString());

    const metadata = opf.package.metadata;
    const manifest = Array.isArray(opf.package.manifest.item)
      ? opf.package.manifest.item
      : [opf.package.manifest.item];

    const titleRaw = metadata['dc:title'];
    const authorRaw = metadata['dc:creator'];

    const title = typeof titleRaw === 'string' ? titleRaw : titleRaw?.['#text'] || 'Unknown';
    const author = typeof authorRaw === 'string' ? authorRaw : authorRaw?.['#text'] || 'Unknown';

    const coverItem = manifest.find(item =>
      item['@_id']?.toLowerCase().includes('cover') && item['@_media-type']?.startsWith('image')
    );

    const coverPath = coverItem
      ? path.join(path.dirname(opfPath), coverItem['@_href']).replaceAll('\\', '/')
      : null;

    return { title, author, coverPath };
  } catch (err) {
    console.error('EPUB parse failed:', filePath, err);
    return {};
  }
};

app.get('/api/books', (req, res) => {
  const allBooks = [];

  for (const source of SOURCES) {
    if (!fs.existsSync(source.dir)) continue;
    const files = fs.readdirSync(source.dir).filter(f => f.endsWith('.epub'));

    for (const file of files) {
      const fullPath = path.join(source.dir, file);
      const { title, author, coverPath } = getMetadataFromEpub(fullPath);

      allBooks.push({
        file,
        source: source.name,
        title,
        author,
        coverUrl: coverPath ? `/api/cover/${source.name}/${file}` : null
      });
    }
  }

  res.json(allBooks);
});

app.get('/api/cover/:source/:file', (req, res) => {
  const { source, file } = req.params;
  const sourceDir = SOURCES.find(s => s.name === source)?.dir;
  if (!sourceDir) return res.sendStatus(404);

  const filePath = path.join(sourceDir, file);
  try {
    const zip = new AdmZip(filePath);
    const entries = zip.getEntries();
    const parser = new XMLParser({ ignoreAttributes: false });

    const containerEntry = entries.find(e => e.entryName.endsWith('container.xml'));
    const container = parser.parse(containerEntry.getData().toString());
    const opfPath = container.container.rootfiles.rootfile['@_full-path'];

    const opfEntry = entries.find(e => e.entryName === opfPath);
    const opf = parser.parse(opfEntry.getData().toString());
    const manifest = Array.isArray(opf.package.manifest.item)
      ? opf.package.manifest.item
      : [opf.package.manifest.item];

    const coverItem = manifest.find(item =>
      item['@_id']?.toLowerCase().includes('cover') && item['@_media-type']?.startsWith('image')
    );

    const coverPath = coverItem
      ? path.join(path.dirname(opfPath), coverItem['@_href']).replaceAll('\\', '/')
      : null;

    const coverEntry = entries.find(e => e.entryName === coverPath);
    if (!coverEntry) return res.sendStatus(404);

    const ext = path.extname(coverPath).toLowerCase();
    const mime = ext === '.png' ? 'image/png' : 'image/jpeg';
    res.set('Content-Type', mime);
    res.send(coverEntry.getData());
  } catch (err) {
    console.error('Cover error:', filePath, err);
    res.sendStatus(500);
  }
});

// ✅ Send EPUB file to Readium
app.get('/api/read/:source/:file', (req, res) => {
  const { source, file } = req.params;
  const sourceDir = SOURCES.find(s => s.name === source)?.dir;
  if (!sourceDir) return res.sendStatus(404);

  const filePath = path.join(sourceDir, file);
  if (!fs.existsSync(filePath)) return res.sendStatus(404);

  res.setHeader('Content-Type', 'application/epub+zip');
  res.sendFile(filePath);
});

app.listen(port, () => console.log(`Backend running on port ${port}`));
