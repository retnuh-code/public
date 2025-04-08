import { useEffect, useRef } from 'react';
import ePub from 'epubjs';

const EPUBReader = ({ book, onClose }) => {
  const viewerRef = useRef(null);

  useEffect(() => {
    if (!book) return;
    const bookPath = `/api/read/${book.source}/${book.file}`;
    const rendition = ePub(bookPath).renderTo(viewerRef.current, {
      width: '100%',
      height: '100%',
    });
    rendition.display();

    return () => {
      rendition?.destroy();
    };
  }, [book]);

  return (
    <div className="fixed inset-0 bg-white z-50 flex flex-col">
      <div className="p-2 bg-gray-200 border-b text-right">
        <button onClick={onClose} className="bg-red-500 text-white px-3 py-1 rounded">
          Close
        </button>
      </div>
      <div ref={viewerRef} className="flex-1 overflow-hidden" />
    </div>
  );
};

export default EPUBReader;
