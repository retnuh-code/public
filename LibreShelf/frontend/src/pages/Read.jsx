import React, { useEffect, useRef } from 'react';
import { useParams } from 'react-router-dom';
import { v4 as uuidv4 } from 'uuid';
import '@readium/web/dist/style.css';

const Read = () => {
  const { filename } = useParams();
  const readerRef = useRef(null);
  const readerId = useRef(uuidv4());

  useEffect(() => {
    const loadReader = async () => {
      const { Readium } = await import('@readium/web');
      const reader = new Readium(readerRef.current, {
        url: `/api/read/${filename}`,
        settings: {
          enableBreakpoints: true
        }
      });
      reader.start();
    };

    loadReader();
  }, [filename]);

  return (
    <div style={{ height: '100vh', width: '100%' }}>
      <div id={readerId.current} ref={readerRef} style={{ height: '100%' }} />
    </div>
  );
};

export default Read;
