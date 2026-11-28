import express from 'express';
import { createCors } from './middlewares/cors.js';
import { errorHandler, notFound } from './middlewares/error-handler.js';
import { createApiRouter } from './routes/index.js';

export function createApp({ corsOrigins = [], getPool, routers } = {}) {
  const app = express();
  app.disable('x-powered-by');
  app.use(createCors(corsOrigins));
  app.use(express.json({ limit: '16kb' }));
  app.use('/api', createApiRouter({ getPool, routers }));
  app.use(notFound);
  app.use(errorHandler);

  return app;
}
