import { fileURLToPath } from 'node:url';
import { defineConfig, loadEnv } from 'vite';

const root = fileURLToPath(new URL('.', import.meta.url));
const envDir = fileURLToPath(new URL('..', import.meta.url));

export default defineConfig(({ mode }) => {
  const { APP_PORT = '3002' } = loadEnv(mode, envDir, 'APP_');
  return {
    root,
    envDir,
    esbuild: { jsx: 'automatic' },
    server: {
      host: '127.0.0.1',
      port: 5175,
      strictPort: true,
      proxy: { '/api': `http://127.0.0.1:${APP_PORT}` },
    },
  };
});
