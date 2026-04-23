// 1. 必须引入 express
const express = require('express');

// 2. 必须初始化 router 实例 (这就是你报错漏掉的那一行)
const router = express.Router();

// 3. 定义你的登录逻辑
router.post('/', (req, res) => {
  const { username, password } = req.body;

  // 硬编码验证逻辑
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
    // 如果是查数据库，记得在这里写 db.query
    res.status(401).json({ status: 'error', message: 'Invalid credentials' });
  }
});

// 4. 必须导出 router，否则 app.js/index.js 引用时会报错
module.exports = router;