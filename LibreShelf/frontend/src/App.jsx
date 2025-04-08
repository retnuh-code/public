import React from 'react';
import { WebReader } from '@nypl/web-reader';

// NOTE: Replace these with dynamic values if you want to support per-book routing
const DEFAULT_SOURCE = 'local';
const DEFAULT_FILE = 'local.epub';

function App() {
  const manifestUrl = `/api/read/${DEFAULT_SOURCE}/${DEFAULT_FILE}`;

  return (
    <div style={{ height: '100vh', width: '100vw' }}>
      <WebReader
        manifestUrl={manifestUrl}
        proxyUrl="/api/proxy"
        injectables={{}}
        settings={{
          enableTTS: false,
          showControls: true,
          theme: "day"
        }}
      />
    </div>
  );
}

export default App;
