import React, { useEffect, useState } from 'react';
import BookCard from './components/BookCard';
import EPUBReader from './components/EPUBReader';

const App = () => {
  const [books, setBooks] = useState([]);
  const [readingBook, setReadingBook] = useState(null);

  useEffect(() => {
    fetch(`${import.meta.env.VITE_API_BASE}/books`)
      .then(res => res.json())
      .then(setBooks)
      .catch(console.error);
  }, []);

  useEffect(() => {
    const path = window.location.pathname;
    const segments = path.split('/').filter(Boolean);
    if (segments[0] === 'read' && segments[1]) {
      const slug = segments[1];
      const match = books.find(book =>
        `${book.file}`.replace(/\.epub$/, '').includes(slug)
      );
      if (match) setReadingBook(match);
    }
  }, [books]);

  const handleRead = (book) => {
    setReadingBook(book);
    const slug = book.file.replace(/\.epub$/, '');
    window.history.pushState({}, '', `/read/${slug}`);
  };

  return (
    <div className="p-4">
      <div className="bg-white shadow-md p-4 mb-4 flex justify-between items-center">
        <h1 className="text-xl font-bold">📚 LibreShelf</h1>
        {readingBook && (
          <button
            className="bg-red-500 text-white px-3 py-1 rounded"
            onClick={() => {
              setReadingBook(null);
              window.history.pushState({}, '', '/');
            }}
          >
            Close
          </button>
        )}
      </div>

      {!readingBook ? (
        <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
          {books.map(book => (
            <div key={`${book.source}/${book.file}`} onClick={() => handleRead(book)}>
              <BookCard book={book} />
            </div>
          ))}
        </div>
      ) : (
        <EPUBReader book={readingBook} />
      )}
    </div>
  );
};

export default App;
