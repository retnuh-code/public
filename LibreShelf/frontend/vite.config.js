import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'
import rollupNodePolyFill from 'rollup-plugin-polyfill-node'
import inject from '@rollup/plugin-inject'

export default defineConfig({
  define: {
    global: 'globalThis',
    'process.env': {},
  },
  plugins: [react()],
  resolve: {
    alias: {
      process: 'rollup-plugin-polyfill-node/polyfills/process-es6',
      buffer: 'rollup-plugin-polyfill-node/polyfills/buffer-es6'
    },
  },
  optimizeDeps: {
    include: ['process', 'buffer'],
  },
  build: {
    rollupOptions: {
      plugins: [
        inject({
          process: 'process',
          Buffer: ['buffer', 'Buffer'],
        }),
        rollupNodePolyFill()
      ],
    },
  },
  server: {
    host: '0.0.0.0',
    port: 3000
  }
})
