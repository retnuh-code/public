import React from 'react'

const BookCard = ({ book }) => {
  return (
    <div className="bg-white shadow-md rounded-md overflow-hidden hover:shadow-xl transition">
      <img
        src={book.cover_url || '/placeholder.jpg'}
        alt={book.title}
        className="w-full h-48 object-cover"
      />
      <div className="p-2">
        <h3 className="text-sm font-semibold truncate">{book.title}</h3>
        <p className="text-xs text-gray-600 truncate">{book.author}</p>
      </div>
    </div>
  )
}

export default BookCard
