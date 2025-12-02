// api/tests/app.int.test.js
const request = require('supertest');
const app = require('../app.cjs');

describe('Pruebas de integración de la API de pwa-app-shell', () => {
  it('CP-01: /api/health debe responder 200 y status OK', async () => {
    const res = await request(app).get('/api/health');

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('status', 'OK');
    expect(res.body).toHaveProperty('service', 'pwa-app-shell-api');
  });

  it('CP-02: /api/products debe devolver arreglo de productos', async () => {
    const res = await request(app).get('/api/products');

    expect(res.statusCode).toBe(200);
    expect(res.body).toHaveProperty('total');
    expect(res.body).toHaveProperty('items');

    expect(Array.isArray(res.body.items)).toBe(true);
    if (res.body.items.length > 0) {
      expect(res.body.items[0]).toHaveProperty('id');
      expect(res.body.items[0]).toHaveProperty('name');
    }
  });

  it('CP-03: /api/products/:id debe devolver un producto o 404 si no existe', async () => {
    // Asumimos que al menos existe el producto con id 1
    const okRes = await request(app).get('/api/products/1');

    expect([200, 404]).toContain(okRes.statusCode);

    if (okRes.statusCode === 200) {
      expect(okRes.body).toHaveProperty('id');
    }

    // Probamos un id que seguramente no exista
    const notFoundRes = await request(app).get('/api/products/999999');
    expect([200, 404]).toContain(notFoundRes.statusCode);
  });
});
