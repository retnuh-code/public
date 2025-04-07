import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  preview: {
    port: 3000,
    host: true,
    strictPort: true,
    cors: true,
    headers: {
      'Access-Control-Allow-Origin': '*'
    }
  },
  server: {
    host: true
  }
});
