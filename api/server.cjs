// api/server.js
const app = require('./app.cjs');

const PORT = process.env.API_PORT || 4000;

app.listen(PORT, () => {
  console.log(`API escuchando en http://localhost:${PORT}`);
});
