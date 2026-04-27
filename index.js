const db = require('./db');
const express = require('express');
const cors = require('cors');

const app = express();

app.use(cors());
app.use(express.json());

// 异步测试数据库连接（这在 Serverless 环境下有时会增加首次启动耗时，但对排错很有帮助）
(async () => {
  try {
    const [rows] = await db.query('SELECT 1');
    console.log('✅ DB Connected!');
  } catch (err) {
    console.error('❌ DB Error:', err);
  }
})();

const animeRoutes = require('./routes/animes');
const loginRoutes = require('./routes/login');
const userRoutes = require('./routes/user'); 

app.use('/api/animes', animeRoutes);
app.use('/api/login', loginRoutes);
app.use('/api/user', userRoutes); // ✅ 新增


app.get('/', (req, res) => {
  res.json({ message: 'Anime API running' });
});

// ✨ 关键修改：只有在非 Vercel 环境下才启动服务器
// Vercel 部署会自动注入 VERCEL 环境变量
if (!process.env.VERCEL) {
  const PORT = process.env.PORT || 3333;
  app.listen(PORT, '0.0.0.0', () => {
    console.log(`Server running on port ${PORT}`);
  });
}

// ✨ 必须导出 app，Vercel 才能将它转换为 Serverless Function
module.exports = app;