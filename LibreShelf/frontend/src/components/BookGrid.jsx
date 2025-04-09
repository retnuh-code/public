import React from 'react';
import { useNavigate } from 'react-router-dom';

export default function BookGrid({ books }) {
  const navigate = useNavigate();

  return (
    <div style={{ display: 'flex', flexWrap: 'wrap', gap: '16px' }}>
      {books.map((book) => (
        <div key={book.filename} onClick={() => navigate(`/read/${book.filename}`)} style={{ cursor: 'pointer', border: '1px solid #ccc', padding: '10px' }}>
          <div style={{ height: '200px', width: '150px', backgroundColor: '#eee', marginBottom: '8px' }} />
          <div><strong>{book.title}</strong></div>
          <div>{book.author}</div>
        </div>
      ))}
    </div>
  );
}
