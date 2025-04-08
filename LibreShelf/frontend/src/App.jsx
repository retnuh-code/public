import React, { useEffect, useState } from 'react';

function App() {
  const [books, setBooks] = useState([]);
  const [rawJson, setRawJson] = useState('');

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(data => {
        console.log('Fetched books:', data);
        setBooks(data);
        setRawJson(JSON.stringify(data, null, 2)); // Dump as string
      })
      .catch(console.error);
  }, []);

  return (
    <div className="min-h-screen bg-black text-white p-8">
      <h1 className="text-4xl font-bold text-center mb-8 flex items-center justify-center gap-3">
        📚 <span>LibreShelf</span>
      </h1>

      {/* DEBUG DUMP */}
      <pre className="bg-gray-900 p-4 rounded-md text-sm overflow-x-auto">{rawJson}</pre>
    </div>
  );
}

export default App;
