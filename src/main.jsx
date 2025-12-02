// src/main.jsx
import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './styles.css'   // :contentReference[oaicite:0]{index=0}

//  ya NO registramos el Service Worker de vite-plugin-pwa
// import { registerSW } from 'virtual:pwa-register'
// registerSW()

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)

// Al cargar la app, desregistramos cualquier Service Worker viejo
if ('serviceWorker' in navigator) {
  window.addEventListener('load', () => {
    navigator.serviceWorker
      .getRegistrations()
      .then((registrations) => {
        registrations.forEach((reg) => {
          reg.unregister()
        })
      })
      .catch((err) => {
        console.log('Error al desregistrar service workers', err)
      })
  })
}
