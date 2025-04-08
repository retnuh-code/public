import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(setBooks)
      .catch(console.error);
  }, []);

  return (
    <div className="app-container">
      <h1 className="app-title">📚 LibreShelf</h1>
      <div className="book-grid">
        {books.map((book, i) => (
          <div className="book-card" key={i}>
            <div className="cover-wrapper">
              {book.coverUrl ? (
                <img src={book.coverUrl} alt={book.title} className="book-cover" />
              ) : (
                <div className="book-placeholder">📘</div>
              )}
            </div>
            <div className="book-meta">
              <div className="book-title" title={book.title}>{book.title}</div>
              <div className="book-author">{book.author}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
