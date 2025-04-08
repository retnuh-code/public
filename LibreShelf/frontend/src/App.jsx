import React, { useEffect, useState } from 'react'

export default function App() {
  const [books, setBooks] = useState([])

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(setBooks)
  }, [])

  return (
    <div className="app">
      <h1 className="header">📚 LibreShelf</h1>
      <div className="grid">
        {books.map((book, idx) => (
          <div key={idx} className="book-card">
            <img
              src={book.coverUrl || '/fallback.png'}
              alt={book.title}
              className="cover"
            />
            <div className="title">{book.title}</div>
            <div className="author">{book.author}</div>
          </div>
        ))}
      </div>
    </div>
  )
}
