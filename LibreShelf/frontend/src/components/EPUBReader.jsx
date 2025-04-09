import React from "react";
import "@nypl/web-reader/styles.css";
import WebReader from "@nypl/web-reader";

const EPUBReader = ({ source, file }) => {
  const url = `/api/read/${source}/${file}`;

  return (
    <div style={{ height: "100vh", width: "100%" }}>
      <WebReader
        url={url}
        proxyUrl={url}
        pdfWorkerSrc=""
        injectables={{
          epubcfi: [],
          epub: [],
          pdf: [],
        }}
      />
    </div>
  );
};

export default EPUBReader;
