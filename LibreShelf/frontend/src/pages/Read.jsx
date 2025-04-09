import React from 'react';
import { useParams } from 'react-router-dom';

const Read = () => {
  const { filename } = useParams();
  const fileUrl = `/api/read/${filename}`;

  return (
    <iframe
      title="EPUB Reader"
      src={`https://readium.web.app/?epub=${encodeURIComponent(fileUrl)}`}
      style={{
        width: '100%',
        height: '100vh',
        border: 'none'
      }}
      allowFullScreen
    />
  );
};

export default Read;
