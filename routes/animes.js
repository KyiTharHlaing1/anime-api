const express = require('express');
const router = express.Router();
const db = require('../db');


// ✅ GET ALL
router.get('/', async (req, res) => {
  const [rows] = await db.query('SELECT * FROM animes');
  res.json(rows);
});


// ✅ GET BY ID
router.get('/:id', async (req, res) => {
  const [rows] = await db.query(
    'SELECT * FROM animes WHERE id = ?',
    [req.params.id]
  );

  if (rows.length === 0) {
    return res.status(404).json({ error: 'Not found' });
  }

  res.json(rows[0]);
});


// ✅ CREATE
router.post('/', async (req, res) => {
  const { title, description, image_url, genre, rating } = req.body;

  const [result] = await db.query(
    'INSERT INTO animes (title, description, image_url, genre, rating) VALUES (?, ?, ?, ?, ?)',
    [title, description, image_url, genre, rating]
  );

  res.status(201).json({ id: result.insertId });
});


// ✅ UPDATE
router.put('/:id', async (req, res) => {
  const { title, description, image_url, genre, rating } = req.body;

  await db.query(
    'UPDATE animes SET title=?, description=?, image_url=?, genre=?, rating=? WHERE id=?',
    [title, description, image_url, genre, rating, req.params.id]
  );

  res.json({ message: 'Updated' });
});


// ✅ DELETE
router.delete('/:id', async (req, res) => {
  await db.query(
    'DELETE FROM animes WHERE id=?',
    [req.params.id]
  );

  res.json({ message: 'Deleted' });
});


// ⭐ UPDATE RATING（作業重點）
router.patch('/:id/rating', async (req, res) => {
  const { rating } = req.body;

  await db.query(
    'UPDATE animes SET rating=? WHERE id=?',
    [rating, req.params.id]
  );

  res.json({ message: 'Rating updated' });
});

module.exports = router;