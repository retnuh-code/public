import React, { useEffect, useState } from 'react'

export default function App() {
  const [books, setBooks] = useState([])

  useEffect(() => {
    fetch('/api/books')
      .then(res => res.json())
      .then(data => setBooks(data))
      .catch(console.error)
  }, [])

  return (
    <div className="p-6 font-sans bg-gray-100 min-h-screen">
      <h1 className="text-4xl font-bold mb-8 text-center">📚 LibreShelf</h1>
      <div className="grid gap-6 grid-cols-[repeat(auto-fill,minmax(150px,1fr))] max-w-6xl mx-auto">
        {books.map((book, idx) => (
          <div key={idx} className="bg-white rounded-xl shadow-md overflow-hidden hover:shadow-xl transition">
            <div className="h-[220px] bg-gray-200 flex items-center justify-center">
              {book.coverUrl ? (
                <img src={book.coverUrl} alt={book.title} className="h-full w-full object-cover" />
              ) : (
                <span className="text-sm text-gray-500">📘 No Cover</span>
              )}
            </div>
            <div className="p-3 text-center">
              <div className="text-sm font-medium truncate">{book.title}</div>
              <div className="text-xs text-gray-500">{book.author}</div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}
