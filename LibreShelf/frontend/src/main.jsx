import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom/client';
import './styles.css';

function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(data => setBooks(data))
      .catch(console.error);
  }, []);

  return (
    <div className="p-6 font-sans">
      <h1 className="text-3xl font-bold mb-6">📚 LibreShelf Library</h1>
      <div className="grid gap-6 grid-cols-[repeat(auto-fill,minmax(200px,1fr))]">
        {books.map((book, idx) => (
          <div key={idx} className="border rounded-lg p-4 shadow-md bg-white">
            <div className="w-full h-40 bg-gray-200 flex items-center justify-center text-gray-500 mb-4">
              📘 Cover
            </div>
            <div className="text-lg font-semibold truncate">{book.title}</div>
            <div className="text-sm text-gray-600 italic">{book.author}</div>
            <div className="text-xs text-gray-400 mt-1">Source: {book.source}</div>
          </div>
        ))}
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);

