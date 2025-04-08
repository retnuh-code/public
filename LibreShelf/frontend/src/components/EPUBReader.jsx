import { useEffect, useRef } from 'react';
import ePub from 'epubjs';

const EPUBReader = ({ book }) => {
  const viewerRef = useRef(null);
  const bookRef = useRef(null);
  const renditionRef = useRef(null);

  useEffect(() => {
    if (!book || !viewerRef.current) return;

    const bookUrl = `/api/read/${book.source}/${book.file}`;
    bookRef.current = ePub(bookUrl);

    renditionRef.current = bookRef.current.renderTo(viewerRef.current, {
      width: '100%',
      height: '100%',
    });

    bookRef.current.ready
      .then(() => renditionRef.current.display())
      .catch(console.error);

    return () => {
      renditionRef.current?.destroy();
      bookRef.current?.destroy();
    };
  }, [book]);

  return <div ref={viewerRef} className="h-screen w-full" />;
};

export default EPUBReader;
