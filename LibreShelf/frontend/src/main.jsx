import React, { useEffect, useState } from 'react';
import ReactDOM from 'react-dom/client';
import './styles.css';

function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch(`${window.location.origin}/api/books`)
      .then(res => res.json())
      .then(data => setBooks(data))
      .catch(console.error);
  }, []);

  const resolveText = (value) => {
    if (typeof value === 'string') return value;
    if (typeof value === 'object' && '#text' in value) return value['#text'];
    return 'Unknown';
  };

  return (
    <div className="p-6 font-sans bg-gray-100 min-h-screen">
      <h1 className="text-4xl font-bold mb-8 text-center">📚 LibreShelf Library</h1>

      <div className="grid gap-6 grid-cols-[repeat(auto-fill,minmax(150px,1fr))] max-w-6xl mx-auto">
        {books.map((book, idx) => (
          <div key={idx} className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-xl transition">
            {book.coverUrl ? (
              <img
                src={`${window.location.origin}${book.coverUrl}`}
                alt="Cover"
                className="w-full h-[220px] object-cover"
              />
            ) : (
              <div className="h-[220px] bg-gray-300 flex items-center justify-center text-gray-500 text-sm">
                📘 No Cover
              </div>
            )}
            <div className="p-3 text-center">
              <div className="text-sm font-medium truncate">{resolveText(book.title)}</div>
              <div className="text-xs text-gray-500">{resolveText(book.author)}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

ReactDOM.createRoot(document.getElementById('root')).render(<App />);
