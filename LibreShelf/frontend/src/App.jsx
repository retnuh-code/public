// frontend/src/App.jsx
import React, { useEffect, useState } from 'react';
import './styles.css';

function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch(`${window.location.origin}/api/books`)
      .then(res => res.json())
      .then(data => setBooks(data))
      .catch(console.error);
  }, []);

  return (
    <div className="bg-[#111] text-white min-h-screen px-8 py-6">
      <h1 className="text-3xl font-bold mb-6">📚 LibreShelf Library</h1>

      <div className="grid gap-6 grid-cols-[repeat(auto-fill,minmax(160px,1fr))]">
        {books.map((book, idx) => (
          <div
            key={idx}
            className="flex flex-col items-center hover:scale-105 transition-transform"
          >
            <div className="w-[160px] h-[240px] bg-gray-800 overflow-hidden rounded-md shadow-md">
              <img
                src={book.coverUrl}
                alt={`Cover for ${book.title}`}
                className="w-full h-full object-cover"
              />
            </div>
            <div className="mt-2 text-center">
              <div className="text-sm font-semibold text-white truncate w-[160px]">
                {typeof book.title === 'object' ? book.title['#text'] : book.title}
              </div>
              <div className="text-xs text-gray-400">
                {typeof book.author === 'object' ? book.author['#text'] : book.author}
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
