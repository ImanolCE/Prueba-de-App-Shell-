import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import { VitePWA } from 'vite-plugin-pwa'

export default defineConfig({

  plugins: [
    react(),
    VitePWA({
      registerType: 'autoUpdate',
       devOptions: { enabled: true },
      includeAssets: ['icons/icon-192.png', 'icons/icon-512.png', 'products.json'],
      manifest: {
        name: 'PWA App Shell ',
        short_name: 'PWA-Shell',
        start_url: '/',
        display: 'standalone',
        theme_color: '#0ea5e9',
        background_color: '#0b1220',
        icons: [
          { src: 'icons/icon-192.png', sizes: '192x192', type: 'image/png' },
          { src: 'icons/icon-512.png', sizes: '512x512', type: 'image/png' }
        ]
      },
      workbox: {
        runtimeCaching: [
          {
            urlPattern: ({ url }) => url.pathname.startsWith('/api/'),
            handler: 'NetworkFirst',
            options: { cacheName: 'api-cache' }
          }
        ]
      }
    })
  ]
})
