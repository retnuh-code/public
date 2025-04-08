import { useEffect, useRef } from 'react';
import ePub from 'epubjs';

const EPUBReader = ({ book, onClose }) => {
  const viewerRef = useRef(null);
  const bookRef = useRef(null);
  const renditionRef = useRef(null);

  useEffect(() => {
    if (!book) return;

    const bookUrl = `/api/read/${book.source}/${book.file}`;
    bookRef.current = ePub(bookUrl);

    const viewerElement = viewerRef.current;
    if (!viewerElement) return;

    const iframe = document.createElement('iframe');
    iframe.setAttribute('style', 'width:100%; height:100%; border:none;');
    iframe.setAttribute('sandbox', 'allow-same-origin allow-scripts allow-modals allow-forms allow-downloads');
    viewerElement.appendChild(iframe);

    renditionRef.current = bookRef.current.renderTo(iframe, {
      width: '100%',
      height: '100%',
    });

    bookRef.current.ready
      .then(() => renditionRef.current.display())
      .catch(console.error);

    return () => {
      viewerElement.innerHTML = '';
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
      <div ref={viewerRef} className="flex-1 overflow-hidden" />
    </div>
  );
};

export default EPUBReader;
