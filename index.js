const db = require('./db');

(async () => {
  try {
    const [rows] = await db.query('SELECT 1');
    console.log('✅ DB Connected!');
  } catch (err) {
    console.error('❌ DB Error:', err);
  }
})();

const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

const animeRoutes = require('./routes/animes');

app.use('/api/animes', animeRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Anime API running' });
});

const PORT = 3333;

if (process.env.NODE_ENV !== 'production') {
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;