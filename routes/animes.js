const express = require('express');
const router = express.Router();
const db = require('../db');

// ✅ GET ALL
router.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT * FROM animes');
    res.json(rows);
  } catch (err) {
    console.error('GET ALL ERROR:', err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ GET BY ID
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
    console.error('GET BY ID ERROR:', err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ CREATE
router.post('/', async (req, res) => {
  try {
    const { title, description, image_url, genre, rating } = req.body;

    const [result] = await db.query(
      'INSERT INTO animes (title, description, image_url, genre, rating) VALUES (?, ?, ?, ?, ?)',
      [title, description, image_url, genre, rating]
    );

    res.status(201).json({ id: result.insertId });
  } catch (err) {
    console.error('CREATE ERROR:', err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ UPDATE
router.put('/:id', async (req, res) => {
  try {
    const { title, description, image_url, genre, rating } = req.body;

    await db.query(
      'UPDATE animes SET title=?, description=?, image_url=?, genre=?, rating=? WHERE id=?',
      [title, description, image_url, genre, rating, req.params.id]
    );

    res.json({ message: 'Updated' });
  } catch (err) {
    console.error('UPDATE ERROR:', err);
    res.status(500).json({ error: err.message });
  }
});

// ✅ DELETE
router.delete('/:id', async (req, res) => {
  try {
    await db.query(
      'DELETE FROM animes WHERE id=?',
      [req.params.id]
    );

    res.json({ message: 'Deleted' });
  } catch (err) {
    console.error('DELETE ERROR:', err);
    res.status(500).json({ error: err.message });
  }
});

// ⭐ UPDATE RATING
router.patch('/:id/rating', async (req, res) => {
  try {
    const { rating } = req.body;

    if (rating === undefined) {
      return res.status(400).json({
        error: 'Rating missing'
      });
    }

    await db.query(
      'UPDATE animes SET rating=? WHERE id=?',
      [rating, req.params.id]
    );

    res.json({ message: 'Rating updated' });
  } catch (err) {
    console.error('PATCH ERROR:', err);
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;