import React, { useEffect, useState } from 'react';
import BookGrid from '../components/BookGrid';

export default function Home() {
  const [books, setBooks] = useState([]);

  useEffect(() => {
    fetch('/api/books')
      .then((res) => res.json())
      .then(setBooks);
  }, []);

  return <BookGrid books={books} />;
}
