import { defineConfig, loadEnv } from 'vite';

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, process.cwd(), 'VITE_');
  const proxy = {};

  for (const [prefix, target] of [
    ['/api/danh-muc-mon', env.VITE_N1_API_TARGET],
    ['/api/trigger-mon', env.VITE_N2_API_TARGET],
    ['/api/bao-cao', env.VITE_N3_API_TARGET],
  ]) {
    if (target?.trim()) proxy[`^${prefix}([/?]|$)`] = target.trim();
  }

  proxy['^/api([/?]|$)'] = env.VITE_API_PROXY_TARGET?.trim() || 'http://127.0.0.1:3001';

  return {
    esbuild: { jsx: 'automatic' },
    server: { host: '127.0.0.1', proxy },
    preview: { host: '127.0.0.1', proxy },
  };
});
