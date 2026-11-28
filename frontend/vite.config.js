import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  const proxy = {
    '^/api([/?]|$)': env.VITE_API_PROXY_TARGET?.trim() || 'http://127.0.0.1:3001',
  };

  return {
    esbuild: { jsx: 'automatic' },
    server: { host: '127.0.0.1', proxy },
    preview: { host: '127.0.0.1', proxy },
  };
});
