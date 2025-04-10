import React, { useEffect } from 'react';
import { useParams } from 'react-router-dom';

const Read = () => {
  const { filename } = useParams();

  useEffect(() => {
    if (!filename) return;

    // Redirect to local Readium viewer with query param
    window.location.href = `/readium/index.html?epub=/api/read/${encodeURIComponent(filename)}`;
  }, [filename]);

  return (
    <div>
      <p>Loading reader for <strong>{filename}</strong>...</p>
    </div>
  );
};

export default Read;
