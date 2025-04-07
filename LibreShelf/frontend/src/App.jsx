import React, { useEffect, useState } from 'react';

export default function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then((res) => res.json())
      .then((data) => setBooks(data))
      .catch(console.error);
  }, []);

  return (
    <div className="app">
      <h1>📚 LibreShelf</h1>
      <div className="book-grid">
        {books.map((book, idx) => (
          <div className="book-card" key={idx}>
            {book.coverUrl ? (
              <img src={book.coverUrl} alt={book.title} className="cover" />
            ) : (
              <div className="cover placeholder">No Cover</div>
            )}
            <div className="info">
              <div className="title">{book.title}</div>
              <div className="author">{book.author}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}
