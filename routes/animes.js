const express = require('express');
const router = express.Router();
const db = require('../db');

// GET ALL
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM animes');
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// GET BY ID
router.get('/:id', async (req, res) => {
  try {
    const [rows] = await db.query(
      'SELECT * FROM animes WHERE id = ?',
      [req.params.id]
    );

    if (rows.length === 0) {
      return res.status(404).json({ error: 'Not found' });
    }

    res.json(rows[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

// PATCH RATING
router.patch('/:id/rating', async (req, res) => {
  try {
    const { rating } = req.body;

    await db.query(
      'UPDATE animes SET rating=? WHERE id=?',
      [rating, req.params.id]
    );

    res.json({ message: 'Rating updated' });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;