server: {
  proxy: {
    '/api': {
      target: 'http://backend:4000',
      changeOrigin: true
    }
  }
},
preview: {
  host: true,
  port: 3000,
  strictPort: true,
  allowedHosts: ['*']
}
