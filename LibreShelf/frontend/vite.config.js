import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

export default defineConfig({
  plugins: [react()],
  server: {
    host: true, // Accept all hosts
    port: 3000,
    strictPort: true,
    proxy: {
      '/api': {
        target: 'http://host.docker.internal:4000',
        changeOrigin: true
      }
    }
  },
  preview: {
    host: true, // Accept all hosts for `npm run preview`
    port: 4173
  }
})
