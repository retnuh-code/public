import React from 'react';
import { Outlet, Link } from 'react-router-dom';

export default function App() {
  return (
    <div style={{ fontFamily: 'sans-serif', padding: '1rem' }}>
      <header style={{ marginBottom: '2rem' }}>
        <Link to="/" style={{ textDecoration: 'none', color: 'black' }}>
          <h1>LibreShelf</h1>
        </Link>
      </header>

      <Outlet />
    </div>
  );
}
