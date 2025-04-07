const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 4000;

// Middleware
app.use(cors());
app.use(express.json());

// Sample route
app.get('/api/books', (req, res) => {
  res.json([
    { id: 1, title: '1984', author: 'George Orwell' },
    { id: 2, title: 'Brave New World', author: 'Aldous Huxley' }
  ]);
});

app.listen(PORT, () => {
  console.log(`Backend server is running on port ${PORT}`);
});
