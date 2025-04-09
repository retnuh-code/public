import React from "react";
import { ReactReader } from "@readium/react-reader";

const Reader = () => {
  return (
    <ReactReader
      url="/api/read/sample.epub"
      location={"epubcfi(/6/2[cover]!/6)"}
      locationChanged={loc => console.log("Current CFI:", loc)}
    />
  );
};

export default Reader;
