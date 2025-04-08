import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import nodeGlobals from 'vite-plugin-node-globals'

export default defineConfig({
  plugins: [react(), nodeGlobals()],
  server: {
    host: '0.0.0.0',
    port: 3000
  }
})
