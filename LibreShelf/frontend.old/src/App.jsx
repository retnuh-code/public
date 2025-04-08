import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then((res) => res.json())
      .then((data) => setBooks(data))
      .catch((err) => console.error('Failed to fetch books:', err));
  }, []);

  return (
    <div className="container">
      <h1 className="header">📚 LibreShelf</h1>
      <div className="grid">
        {books.map((book, idx) => (
          <div className="card" key={idx}>
            <img
              src={book.coverUrl || '/default-cover.jpg'}
              alt={book.title}
              className="cover"
            />
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

export default App;
