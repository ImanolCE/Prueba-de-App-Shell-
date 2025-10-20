import express from 'express'
import cors from 'cors'
const app = express()
const PORT = 5174

app.use(cors())

app.get('/api/products', (_req, res) => {
  res.json([
    { id: 1, name: 'Teclado Mecánico', description: 'Switches lineales.', price: 899 },
    { id: 2, name: 'Mouse Inalámbrico', description: 'Precisión óptica.', price: 499 },
    { id: 3, name: 'Audífonos', description: 'Aislamiento de sonido.', price: 1199 }
  ])
})

app.listen(PORT, () => console.log(`API en http://localhost:${PORT}`))
