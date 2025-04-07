import React, { useEffect, useState } from 'react';

function App() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(setBooks)
      .catch(console.error);
  }, []);

  return (
    <div className="library">
      <h1>📚 LibreShelf Library</h1>
      <div className="book-grid">
        {books.map((book, i) => (
          <div className="book-card" key={i}>
            <div className="cover">
              {book.coverUrl ? (
                <img src={book.coverUrl} alt={book.title} />
              ) : (
                <div className="no-cover">No Cover</div>
              )}
            </div>
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
