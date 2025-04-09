import React from 'react';
import { useParams } from 'react-router-dom';

export default function Reader() {
  const { filename } = useParams();
  const fileUrl = `/api/read/${filename}`;

  return (
    <div style={{ height: '100vh' }}>
      <iframe
        src={fileUrl}
        title="reader"
        style={{
          width: '100%',
          height: '100%',
          border: 'none'
        }}
      />
    </div>
  );
}
