import React from 'react';
import { useParams } from 'react-router-dom';

export default function Read() {
  const { filename } = useParams();
  const fileUrl = `/api/read/${filename}`;
  const viewerUrl = `https://readium.web.app/?epub=${encodeURIComponent(fileUrl)}`;

  return (
    <iframe
      src={viewerUrl}
      title="EPUB Reader"
      style={{ width: '100vw', height: '100vh', border: 'none' }}
      allowFullScreen
    />
  );
}
