const db = require('./db');
const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

(async () => {
  try {
    await db.query('SELECT 1');
    console.log('✅ DB Connected!');
  } catch (err) {
    console.error('❌ DB Error:', err);
  }
})();

const animeRoutes = require('./routes/animes');
const loginRoutes = require('./routes/login');

app.use('/api/animes', animeRoutes);
app.use('/api/login', loginRoutes);

app.get('/', (req, res) => {
  res.json({ message: 'Anime API running' });
});

if (!process.env.VERCEL) {
  const PORT = process.env.PORT || 3333;
  app.listen(PORT, () => {
    console.log(`Server running on port ${PORT}`);
  });
}

module.exports = app;