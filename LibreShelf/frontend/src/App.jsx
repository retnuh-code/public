import React from "react";
import { WebReader } from "@readium/react-web-reader";

export default function App() {
  return (
    <div style={{ height: "100vh", width: "100vw" }}>
      <WebReader
        manifestUrl="/example/publication/manifest.json"
        proxyUrl={url => `/api/proxy?url=${encodeURIComponent(url)}`}
        injectables={{
          scripts: [],
          styles: []
        }}
      />
    </div>
  );
}
