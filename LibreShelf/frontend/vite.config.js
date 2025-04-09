import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import rollupNodePolyFill from 'rollup-plugin-polyfill-node'

export default defineConfig({
  define: {
    global: 'globalThis',
    'process.env': {},
  },
  plugins: [react()],
  resolve: {
    alias: {
      process: 'rollup-plugin-polyfill-node/polyfills/process-es6',
    },
  },
  optimizeDeps: {
    include: ['process'],
  },
  build: {
    rollupOptions: {
      plugins: [rollupNodePolyFill()],
    },
  },
  server: {
    host: '0.0.0.0',
    port: 3000
  }
})
