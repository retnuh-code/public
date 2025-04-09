import React, { useEffect, useRef } from 'react';
import { useParams } from 'react-router-dom';

const Read = () => {
  const { filename } = useParams();
  const readerRef = useRef(null);

  useEffect(() => {
    const loadReader = async () => {
      const { Readium } = await import('@readium/web');

      new Readium(readerRef.current, {
        url: `${window.location.origin}/api/read/${filename}`,
        settings: {
          enableBreakpoints: true
        }
      }).start();
    };

    loadReader();
  }, [filename]);

  return (
    <div style={{ height: '100vh', width: '100%' }}>
      <div ref={readerRef} style={{ height: '100%' }} />
    </div>
  );
};

export default Read;
