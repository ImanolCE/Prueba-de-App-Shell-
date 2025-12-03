import { useEffect, useState } from 'react'
import './styles.css'

const version = import.meta.env.VITE_APP_VERSION ?? 'UNKNOWN';

function NavLink({ href, icon, label }) {
  const active = (typeof window !== 'undefined') && window.location.hash === href
  return (
    <a href={href} className={active ? 'active' : ''}>
      <span aria-hidden="true">{icon}</span>
      <span>{label}</span>
    </a>
  )
}

function TopBar(){
  return (
    <div className="topbar">
      <div className="brand">
        <div className="logo" />
        <div>PWAaaa App&nbsp;Shell</div>
        <span className="badge">Offline Ready</span>
        {/* etiqueta con la versión */}
        <span className="version-pill">
          Versión: <strong>{version.toUpperCase()}</strong>
        </span>
      </div>
      <div className="search">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
          <path d="M21 21l-4.3-4.3M10.5 18a7.5 7.5 0 1 1 0-15 7.5 7.5 0 0 1 0 15Z" stroke="currentColor" strokeWidth="1.6" strokeLinecap="round"/>
        </svg>
        <input placeholder="Buscar..." />
      </div>
    </div>
  )
}


function SideBar(){
  return (
    <aside className="sidebar">
      <nav className="nav">
        <NavLink href="#/inicio"  label="Inicio" />
        <NavLink href="#/productos"  label="Productos" />
        <NavLink href="#/acerca"  label="Acerca" />
      </nav>
    </aside>
  )
}

function TabBar(){
  return (
    <div className="tabbar">
      <NavLink href="#/inicio"  label="Inicio" />
      <NavLink href="#/productos"  label="Productos" />
      <NavLink href="#/acerca" label="Acerca" />
    </div>
  )
}

function Inicio(){
  return (
    <div className="container">
      <section className="card">
        <h2 className="m0">Bienvenidooooooo !! </h2>
        
        <div className="flex justify-between mt16">
          <span className="badge">PWA</span>
          <button className="btn" onClick={()=>location.hash='#/productos'}>Ver productos</button>
        </div>
      </section>

      <section className="grid">
        {/* <div className="card span-6">
          <h3 className="m0">¿Qué es el App Shell?</h3>
          <p className="mt8">El armazón mínimo de la UI (topbar, menú, footer, contenedor) que se sirve desde caché para velocidad y soporte offline.</p>
        </div> */}
       
      </section>
    </div>
  )
}

function Productos(){
  const [items,setItems] = useState(null)
  const [error,setError] = useState(null)

  useEffect(()=>{
    fetch('/products.json') // o '/api/products' si usas Express
      .then(r => r.ok ? r.json() : Promise.reject('Error'))
      .then(setItems)
      .catch(()=>setError('No se pudo cargar el contenido (¿sin conexión?).'))
  },[])

  return (
    <div className="container">
      <header className="card">
        <h1>App Shell PWA - Blue/Green</h1>
          <p>
            Versión activa: <strong>{version.toUpperCase()}</strong>
          </p>

        <h2 className="m0">Productos</h2>
        <p className="mt8">Ejemplo de contenido dinámico dentro del App Shell.</p>
      </header>

      {!items && !error && (
        <section className="card"><p>Cargando…</p></section>
      )}

      {error && (
        <section className="card"><p>{error}</p></section>
      )}

      {items && (
        <section className="grid grid-2col">
          {items.map(p=>(
            <article className="card" key={p.id}>
              <h3 className="m0">{p.name}</h3>
              <p className="mt8">{p.description}</p>
              <p className="mt8"><b>Precio:</b> ${p.price}</p>
            </article>
          ))}
        </section>
      )}
    </div>
  )
}

function Acerca(){
  return (
    <div className="container">
      <section className="card">
        <h2 className="m0">Acerca</h2>
        <p className="mt8">App Shell cacheado, manifest para instalación y soporte offline mediante Service Worker.</p>
      </section>
    </div>
  )
}

export default function App(){
  const [route,setRoute]=useState(window.location.hash || '#/inicio')
  useEffect(()=>{
    const onHash=()=>setRoute(window.location.hash || '#/inicio')
    window.addEventListener('hashchange', onHash)
    return ()=>window.removeEventListener('hashchange', onHash)
  },[])

  let View=<Inicio/>
  if(route==='#/productos') View=<Productos/>
  if(route==='#/acerca') View=<Acerca/>

  return (
    <div className="app">
      <TopBar/>
      <SideBar/>
      <TabBar/>
      <main className="main">{View}</main>
      <footer className="footer">Actividad 3: PWA - Prueba </footer>
    </div>
  )
}
