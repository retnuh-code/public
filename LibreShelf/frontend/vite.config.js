// frontend/vite.config.js
import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    strictPort: true,
    port: 3000,
    cors: true,
    hmr: {
      protocol: 'ws',
      host: '0.0.0.0',
    }
  },
  preview: {
    port: 3000,
    host: true,
    allowedHosts: 'all', // ✅ This allows any host via Cloudflare Tunnel or public domain
  },
});
