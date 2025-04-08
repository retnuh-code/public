// frontend/src/App.jsx
import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then((res) => res.json())
      .then((data) => setBooks(data))
      .catch((err) => console.error('Fetch error:', err));
  }, []);

  return (
    <div className="main-wrapper">
      <h1 className="title">📚 LibreShelf</h1>
      <div className="book-grid">
        {books.map((book, i) => (
          <div className="book-card" key={i}>
            <div className="book-cover">
              {book.coverUrl ? (
                <img src={book.coverUrl} alt={book.title} />
              ) : (
                <div className="no-cover">No Cover</div>
              )}
            </div>
            <div className="book-info">
              <div className="book-title">{book.title}</div>
              <div className="book-author">{book.author}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
