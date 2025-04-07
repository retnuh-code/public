import React, { useEffect, useState } from 'react';
import './App.css';

function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(data => setBooks(data));
  }, []);

  return (
    <div className="container">
      <h1>📚 LibreShelf</h1>
      <div className="grid">
        {books.map((book, idx) => (
          <div className="book" key={idx}>
            <img src={book.coverUrl || '/placeholder.jpg'} alt={book.title} />
            <div className="meta">
              <div className="title">{book.title?.['#text'] || book.title}</div>
              <div className="author">{book.author?.['#text'] || book.author}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  );
}

export default App;
