import React, { useEffect, useState } from 'react';
import { Link } from 'react-router-dom';

export default function Home() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(data => setBooks(data));
  }, []);

  return (
    <div>
      <h2>Available Books</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fill, 200px)', gap: '1rem' }}>
        {books.map(book => (
          <Link
            to={`/read/${encodeURIComponent(book.filename)}`}
            key={book.filename}
            style={{ textDecoration: 'none', color: 'black' }}
          >
            <div style={{ border: '1px solid #ccc', padding: '1rem', borderRadius: '5px' }}>
              {book.cover ? (
                <img src={book.cover} alt={book.title} style={{ width: '100%', height: 'auto' }} />
              ) : (
                <div style={{ width: '100%', height: '250px', background: '#eee' }} />
              )}
              <h4 style={{ margin: '0.5rem 0 0 0' }}>{book.title}</h4>
              <p style={{ margin: 0, fontSize: '0.9rem' }}>{book.author}</p>
            </div>
          </Link>
        ))}
      </div>
    </div>
  );
}
