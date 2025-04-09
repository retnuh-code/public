import React from 'react'

const BookCard = ({ book }) => {
  const { title, author, coverUrl } = book;

  return (
    <div className="bg-white shadow-md rounded-md overflow-hidden hover:shadow-xl transition">
      <img
        src={coverUrl}
        alt={title}
        className="w-full max-h-60 object-contain bg-white p-2"
      />
      <div className="p-2">
        <h2 className="font-semibold text-sm truncate">{title}</h2>
        <p className="text-xs text-gray-600">{author}</p>
      </div>
    </div>
  );
};

export default BookCard;
