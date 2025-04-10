import React from 'react';
import { useNavigate } from 'react-router-dom';
import './BookGrid.css';

const BookGrid = ({ books }) => {
  const navigate = useNavigate();

  const handleClick = (filename) => {
    navigate(`/readium/index.html?epub=/api/read/${filename}`);
  };

  return (
    <div className="book-grid">
      {books.map((book, index) => (
        <div className="book-card" key={index} onClick={() => handleClick(book.filename)}>
          <div className="book-cover">
            {book.cover ? (
              <img src={`/api/read/${book.cover}`} alt={`${book.title} cover`} />
            ) : (
              <div className="book-placeholder">No Cover</div>
            )}
          </div>
          <div className="book-info">
            <h3>{book.title}</h3>
            <p>{book.author}</p>
          </div>
        </div>
      ))}
    </div>
  );
};

export default BookGrid;
