// api/app.js
const express = require('express');
const path = require('path');

// Carga de productos desde el JSON público
const productsPath = path.join(__dirname, '..', 'public', 'products.json');
const products = require(productsPath);

const app = express();

app.use(express.json());

// Endpoint 1: health check
app.get('/api/health', (req, res) => {
  res.status(200).json({
    status: 'OK',
    service: 'pwa-app-shell-api',
  });
});

// Endpoint 2: lista de productos
app.get('/api/products', (req, res) => {
  res.status(200).json({
    total: products.length,
    items: products,
  });
});

// Endpoint 3: detalle de producto por id (asumimos que products tienen id numérico)
app.get('/api/products/:id', (req, res) => {
  const id = Number(req.params.id);
  const product = products.find((p) => Number(p.id) === id);

  if (!product) {
    return res.status(404).json({ message: 'Producto no encontrado' });
  }

  res.status(200).json(product);
});

module.exports = app;
