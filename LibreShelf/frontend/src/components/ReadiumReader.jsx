import React, { useState } from "react";
import { ReactReader } from "@readium/react-reader";

const ReadiumReader = () => {
  const [location, setLocation] = useState();

  const epubUrl = "/api/read/source/sample.epub"; // This will hit the backend

  return (
    <div style={{ height: "100vh" }}>
      <ReactReader
        url={epubUrl}
        location={location}
        locationChanged={setLocation}
      />
    </div>
  );
};

export default ReadiumReader;
