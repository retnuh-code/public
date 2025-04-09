import { useEffect, useState } from 'react';

const EPUBReader = ({ book, onClose }) => {
  const [htmlContent, setHtmlContent] = useState('');

  useEffect(() => {
    const fetchEPUB = async () => {
      try {
        const url = `/api/read/${book.source}/${book.file}`;
        const response = await fetch(url);
        const blob = await response.blob();

        const zip = await JSZip.loadAsync(blob);
        const containerXml = await zip.file('META-INF/container.xml').async('string');
        const parser = new DOMParser();
        const containerDoc = parser.parseFromString(containerXml, 'application/xml');
        const rootfilePath = containerDoc.querySelector('rootfile').getAttribute('full-path');

        const opfXml = await zip.file(rootfilePath).async('string');
        const opfDoc = parser.parseFromString(opfXml, 'application/xml');
        const item = [...opfDoc.querySelectorAll('item')].find(i => i.getAttribute('media-type') === 'application/xhtml+xml');

        if (!item) throw new Error('XHTML content not found');

        const contentPath = rootfilePath.replace(/[^/]+$/, '') + item.getAttribute('href');
        const xhtml = await zip.file(contentPath).async('string');
        setHtmlContent(xhtml);
      } catch (err) {
        console.error('Failed to load EPUB:', err);
        setHtmlContent('<p class="text-red-600">Failed to load EPUB content.</p>');
      }
    };

    fetchEPUB();
  }, [book]);

  return (
    <div className="fixed inset-0 bg-white z-50 flex flex-col overflow-auto">
      <div className="p-2 bg-gray-200 border-b text-right">
        <button
          onClick={onClose}
          className="bg-red-500 text-white px-3 py-1 rounded"
        >
          Close
        </button>
      </div>
      <div className="p-6 prose max-w-none" dangerouslySetInnerHTML={{ __html: htmlContent }} />
    </div>
  );
};

export default EPUBReader;
