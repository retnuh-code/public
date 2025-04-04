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
    const parser = new XMLParser({ ignoreAttributes: false, attributeNamePrefix: '@_' });

    const containerEntry = entries.find(e => e.entryName.endsWith('container.xml'));
    if (!containerEntry) return {};
    const container = parser.parse(containerEntry.getData().toString());
    const opfPath = container.container.rootfiles.rootfile['@_full-path'];

    const opfEntry = entries.find(e => e.entryName === opfPath);
    if (!opfEntry) return {};
    const opf = parser.parse(opfEntry.getData().toString());

    const metadata = opf.package.metadata;
    const manifest = Array.isArray(opf.package.manifest.item)
      ? opf.package.manifest.item
      : [opf.package.manifest.item];

    const title = metadata['dc:title'] || 'Unknown';
    const author = metadata['dc:creator'] || 'Unknown';

    // Step 1: Look for <meta name="cover" content="id">
    const metaTags = Array.isArray(metadata.meta) ? metadata.meta : [metadata.meta];
    const coverMeta = metaTags.find(m => m['@_name'] === 'cover');
    const coverId = coverMeta?.['@_content'];

    // Step 2: Try to find matching <item id=coverId>
    let coverHref = '';
    if (coverId) {
      const matchById = manifest.find(i => i['@_id'] === coverId && i['@_media-type']?.startsWith('image'));
      coverHref = matchById?.['@_href'] || '';
    }

    // Step 3: Try to find <item properties="cover-image">
    if (!coverHref) {
      const matchByProperty = manifest.find(i => i['@_properties']?.includes('cover-image'));
      coverHref = matchByProperty?.['@_href'] || '';
    }

    // Step 4: Fallback to any image in manifest
    if (!coverHref) {
      const anyImage = manifest.find(i => i['@_media-type']?.startsWith('image'));
      coverHref = anyImage?.['@_href'] || '';
    }

    const coverPath = coverHref ? path.join(path.dirname(opfPath), coverHref).replaceAll('\\', '/') : null;
    return { title, author, coverPath };
  } catch (err) {
    console.warn(`[EPUB Parse Error] ${filePath}:`, err.message);
    return {};
  }
};

app.get('/api/books', async (req, res) => {
  const allBooks = [];

  for (const source of SOURCES) {
    if (!fs.existsSync(source.dir)) continue;
    const files = fs.readdirSync(source.dir);

    for (const file of files) {
      const ext = path.extname(file).toLowerCase();
      if (ext !== '.epub') continue;

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
    const parser = new XMLParser({ ignoreAttributes: false, attributeNamePrefix: '@_' });

    const containerEntry = entries.find(e => e.entryName.endsWith('container.xml'));
    const container = parser.parse(containerEntry.getData().toString());
    const opfPath = container.container.rootfiles.rootfile['@_full-path'];
    const opfEntry = entries.find(e => e.entryName === opfPath);
    const opf = parser.parse(opfEntry.getData().toString());
    const manifest = Array.isArray(opf.package.manifest.item)
      ? opf.package.manifest.item
      : [opf.package.manifest.item];

    const metadata = opf.package.metadata;
    const metaTags = Array.isArray(metadata.meta) ? metadata.meta : [metadata.meta];
    const coverMeta = metaTags.find(m => m['@_name'] === 'cover');
    const coverId = coverMeta?.['@_content'];

    let coverHref = '';
    if (coverId) {
      const matchById = manifest.find(i => i['@_id'] === coverId && i['@_media-type']?.startsWith('image'));
      coverHref = matchById?.['@_href'] || '';
    }

    if (!coverHref) {
      const matchByProperty = manifest.find(i => i['@_properties']?.includes('cover-image'));
      coverHref = matchByProperty?.['@_href'] || '';
    }

    if (!coverHref) {
      const anyImage = manifest.find(i => i['@_media-type']?.startsWith('image'));
      coverHref = anyImage?.['@_href'] || '';
    }

    const coverPath = path.join(path.dirname(opfPath), coverHref).replaceAll('\\', '/');
    const coverEntry = entries.find(e => e.entryName === coverPath);
    if (!coverEntry) return res.sendStatus(404);

    const ext = path.extname(coverHref).toLowerCase();
    const mimeType = ext === '.png' ? 'image/png' : 'image/jpeg';
    res.set('Content-Type', mimeType);
    res.send(coverEntry.getData());
  } catch (err) {
    console.warn(`[Cover Extract Error] ${filePath}:`, err.message);
    res.sendStatus(500);
  }
});

app.listen(port, () => {
  console.log(`LibreShelf backend running on port ${port}`);
});
