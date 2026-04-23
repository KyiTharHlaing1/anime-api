// routes/login.js
router.post('/', (req, res) => {
  const { username, password } = req.body;

  // 这里假设你用的是硬编码。如果是查数据库，逻辑也是一样的
  if (username === 'admin' && password === '1234') {
    res.json({
      status: 'ok',
      user: {
        username: 'Admin User',
        role: 'Administrator',
        email: 'admin@anime.com',
        avatar: 'https://ui-avatars.com/api/?name=Admin'
      }
    });
  } else {
    res.status(401).json({ status: 'error', message: 'Invalid credentials' });
  }
});