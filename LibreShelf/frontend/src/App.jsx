import React, { useEffect, useState } from 'react'
import BookCard from './components/BookCard'

const App = () => {
  const [books, setBooks] = useState([])

  useEffect(() => {
    fetch(`${import.meta.env.VITE_API_BASE}/books`)
      .then(res => res.json())
      .then(setBooks)
      .catch(console.error)
  }, [])

  return (
    <div className="p-6 grid grid-cols-2 sm:grid-cols-3 md:grid-cols-4 lg:grid-cols-5 gap-4">
      {books.map(book => (
        <BookCard key={book.id} book={book} />
      ))}
    </div>
  )
}

export default App

