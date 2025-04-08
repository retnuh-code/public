import { useEffect, useRef } from 'react';
import ePub from 'epubjs';

const EPUBReader = ({ book, onClose }) => {
  const iframeRef = useRef(null);
  const bookRef = useRef(null);
  const renditionRef = useRef(null);

  useEffect(() => {
    if (!book) return;

    const viewer = document.createElement('div');
    viewer.style.width = '100%';
    viewer.style.height = '100%';

    const iframe = iframeRef.current;
    if (!iframe || !iframe.contentDocument) return;

    // Clear previous content
    iframe.contentDocument.body.innerHTML = '';
    iframe.contentDocument.body.appendChild(viewer);

    bookRef.current = ePub(`/api/read/${book.source}/${book.file}`);
    renditionRef.current = bookRef.current.renderTo(viewer, {
      width: '100%',
      height: '100%'
    });

    bookRef.current.ready.then(() => {
      renditionRef.current.display();
    }).catch(console.error);

    return () => {
      renditionRef.current?.destroy();
      bookRef.current?.destroy();
    };
  }, [book]);

  return (
    <div className="fixed inset-0 bg-white z-50 flex flex-col">
      <div className="p-2 bg-gray-200 border-b text-right">
        <button
          onClick={onClose}
          className="bg-red-500 text-white px-3 py-1 rounded"
        >
          Close
        </button>
      </div>
      <iframe
        ref={iframeRef}
        className="flex-1"
        sandbox="allow-scripts allow-same-origin"
        title="EPUB Reader"
      />
    </div>
  );
};

export default EPUBReader;
