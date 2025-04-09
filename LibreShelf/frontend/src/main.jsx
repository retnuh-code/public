import React from 'react'
import ReactDOM from 'react-dom/client'
import App from './App.jsx'
import './assets/index.css'

// 🛠 Manually polyfill process.nextTick
if (typeof process === 'undefined') {
  window.process = {}
}
if (typeof process.nextTick === 'undefined') {
  process.nextTick = function (cb) {
    Promise.resolve().then(cb)
  }
}

ReactDOM.createRoot(document.getElementById('root')).render(
  <React.StrictMode>
    <App />
  </React.StrictMode>
)
