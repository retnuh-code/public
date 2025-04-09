import React from "react";
import WebReader from "@readium/react-web-reader";

const App = () => {
  const exampleEpub = "/books/example.epub"; // Replace with actual file or API-served path

  return (
    <div style={{ height: "100vh" }}>
      <WebReader
        url={exampleEpub}
        title="LibreShelf Reader"
        injectables={{
          styles: [],
          scripts: []
        }}
      />
    </div>
  );
};

export default App;
