import React, { useEffect, useRef } from 'react';

export default function ReadiumViewer() {
  const iframeRef = useRef();

  useEffect(() => {
    const url = '/api/read/local/sample.epub';
    if (iframeRef.current) {
      iframeRef.current.src = `https://readium-player.herokuapp.com/?url=${encodeURIComponent(url)}`;
    }
  }, []);

  return (
    <iframe
      ref={iframeRef}
      title="Readium EPUB Reader"
      style={{ width: '100%', height: '90vh', border: 'none' }}
    />
  );
}