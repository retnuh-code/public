import React from 'react';
import { Routes, Route, Link } from 'react-router-dom';
import Home from './pages/Home';
import Read from './pages/Read';

export default function App() {
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '1rem' }}>
      <header style={{ marginBottom: '2rem' }}>
        <Link to="/" style={{ textDecoration: 'none', color: 'black' }}>
          <h1>LibreShelf</h1>
        </Link>
      </header>

      <Routes>
        <Route path="/" element={<Home />} />
        <Route path="/read/:filename" element={<Read />} />
      </Routes>
    </div>
  );
}
