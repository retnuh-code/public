import React, { useEffect, useState } from 'react'

function App() {
  const [books, setBooks] = useState([])

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(setBooks)
      .catch(console.error)
  }, [])

  return (
    <div className="container">
      <h1>📚 LibreShelf Library</h1>
      <div className="grid">
        {books.map((book, i) => (
          <div key={i} className="book">
            <img src={book.coverUrl || ''} alt="Cover" />
            <h3>{typeof book.title === 'object' ? book.title['#text'] : book.title}</h3>
            <p>{typeof book.author === 'object' ? book.author['#text'] : book.author}</p>
          </div>
        ))}
      </div>
    </div>
  )
}

export default App
