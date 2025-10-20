# PWA App Shell – Demo (React + Vite)

PWA que implementa el patrón App Shell: encabezado, menú, pie de página y una vista con contenido dinámico. 
Incluye Service Worker y manifest con íconos/colores, y funciona sin conexión.

## Tecnologías
- **React + Vite**
- **vite-plugin-pwa** (genera Service Worker + manifest)
- **JSON estático** como contenido dinámico simulado (`public/products.json`)

---

## Estructura de Archvivos

```
└── 📁pwa-app-shell
    └── 📁public
        └── 📁icons
            ├── icon-192.png
            ├── icon-512.png
        ├── products.json
        ├── vite.svg
    └── 📁src
        └── 📁assets
            ├── react.svg
        ├── App.css
        ├── App.jsx
        ├── index.css
        ├── main.jsx
        ├── styles.css
    ├── .gitignore
    ├── eslint.config.js
    ├── index.html
    ├── package-lock.json
    ├── package.json
    ├── README.md
    └── vite.config.js
```
---

## Instalación y ejecución

- 1) instalar dependencias

    npm install

- 2) correr  (con Service Worker habilitado)

    npm run dev

    - abrir http://localhost:5173

---

# Cómo probar sin conexión (paso a paso)

1. Abrir http://localhost:5173.

2. Navegar a Productos (esto solicita /products.json).

    - Nota: en este proyecto el JSON está en precache, así que estará disponible offline desde el primer intento.

3. Abrir DevTools → pestaña Application:

    - Service Workers: confirmar que este en activated and running para http://localhost:5173.
    - Cache Storage: verificar que existen los cachés y que incluyen products.json y los assets del shell.
    - Manifest: revisar nombre, short_name, theme_color, background_color e íconos 192/512.

4. Ir a Network y  seleccionar Offline.

5. Recargar la página:

    - El App Shell (encabezado, menú, pie y contenedor) debe renderizarse desde caché.
    - La vista Productos debe mostrar la lista desde el caché del JSON

    Nota: El manifest es generado por vite-plugin-pwa e inyectado como manifest.webmanifest

---

## Arquitectura y decisiones

- App Shell: UI mínima cacheada (topbar, sidebar/tabbar responsiva, footer y <main> con vistas).

- Service Worker: 
generado por vite-plugin-pwa con registerType.AutoUpdate y devOptions.enabled: true para que funcione en npm run dev.

- Precache: en vite.config.js se incluyen icons/ y products.json dentro de includeAssets para que estén disponibles offline.

- Contenido dinámico: la vista Productos hace fetch('/products.json') (mock local). Esto simula una API (productos) dentro del App Shell.