import express from 'express';
import { query } from './config/db.js';
import { createTriggerMonRouter } from './routes/trigger-mon.js';

const app = express();
app.disable('x-powered-by');
app.use(express.json({ limit: '16kb' }));
app.get('/api/health', (_req, res) => res.json({ data: { status: 'ok' } }));
app.use('/api/trigger-mon', createTriggerMonRouter(query));
app.use((_req, res) => res.status(404).json({ error: { code: 'NOT_FOUND', message: 'Không tìm thấy API.' } }));
app.use((error, _req, res, _next) => {
  console.error('API Trigger món:', error.code ?? error.name);
  res.status(error.status ?? 500).json({ error: { code: 'SERVER_ERROR', message: 'Yêu cầu không hợp lệ hoặc máy chủ gặp lỗi.' } });
});

const port = Number(process.env.APP_PORT ?? 3002);
if (!Number.isInteger(port) || port < 1 || port > 65535) throw new Error('APP_PORT không hợp lệ.');
app.listen(port, '127.0.0.1', () => console.log(`API Trigger món: http://127.0.0.1:${port}/api/trigger-mon/mon`));
