import { defineConfig } from 'vite';
import react from '@vitejs/plugin-react';

export default defineConfig({
  plugins: [react()],
  server: {
    host: true,
    port: 3000,
    strictPort: true,
    cors: true,
  },
  preview: {
    host: true,
    port: 4173,
    strictPort: true,
    cors: true,
    // ⚠️ This allows all hosts, including domains via Cloudflare Tunnel
    allowedHosts: 'all',
  },
});
