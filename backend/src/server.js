import { once } from 'node:events';
import './config/load-env.js';
import { createApp } from './app.js';
import { connectSqlServer } from './config/sql-server.js';

let pool;
try {
  const port = Number(process.env.APP_PORT ?? 3001);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('APP_PORT phải là số cổng hợp lệ.');
  }

  pool = await connectSqlServer();
  pool.on('error', (error) => console.error('Lỗi kết nối SQL Server:', error.code ?? error.name));
  const server = createApp(pool).listen(port, '127.0.0.1');
  await once(server, 'listening');
  console.log(`API danh mục món: http://127.0.0.1:${port}/api/danh-muc-mon`);

  const close = () => server.close(() => pool.close());
  process.once('SIGINT', close);
  process.once('SIGTERM', close);
} catch (error) {
  console.error('Không khởi động được API:', error.code ?? error.message);
  await pool?.close();
  process.exitCode = 1;
}
