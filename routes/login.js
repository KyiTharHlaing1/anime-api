const express = require('express');
const router = express.Router();

router.post('/', (req, res) => {
  const { username, password } = req.body;

  if (username === 'admin' && password === '1234') {
    res.json({
      status: 'ok',
      message: 'Login Success',
      user: {
        username: 'admin'
      }
    });
  } else {
    res.status(401).json({
      status: 'error',
      message: 'Invalid username or password'
    });
  }
});

module.exports = router;