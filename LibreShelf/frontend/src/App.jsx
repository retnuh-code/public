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

  return (
    <div className="p-4">
      <div className="bg-white shadow-md p-4 mb-4 flex justify-between items-center">
        <h1 className="text-xl font-bold">📚 LibreShelf</h1>
      </div>
      <div className="grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
        {books.map(book => (
          <div key={`${book.source}/${book.file}`} onClick={() => setReadingBook(book)}>
            <BookCard book={book} />
          </div>
        ))}
      </div>

      {readingBook && (
        <EPUBReader book={readingBook} onClose={() => setReadingBook(null)} />
      )}
    </div>
  );
};

export default App;
