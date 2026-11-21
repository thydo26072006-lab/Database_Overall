import express from 'express';
import { createDanhMucMonRouter } from './routes/danh-muc-mon.js';

export function createApp(pool) {
  const app = express();
  app.disable('x-powered-by');
  app.use(express.json({ limit: '16kb' }));
  app.use('/api/danh-muc-mon', createDanhMucMonRouter(pool));

  app.use((_request, response) => {
    response.status(404).json({ error: { code: 'NOT_FOUND', message: 'Không tìm thấy địa chỉ API.' } });
  });
  app.use((error, _request, response, _next) => {
    if (error.type === 'entity.parse.failed' || error.type === 'entity.too.large' || error instanceof URIError) {
      response.status(error.status ?? 400).json({
        error: { code: 'INVALID_REQUEST', message: 'Yêu cầu gửi lên không hợp lệ.' },
      });
      return;
    }
    console.error('Lỗi API danh mục:', error.code ?? error.name, error.number ?? '');
    response.status(500).json({
      error: { code: 'SERVER_ERROR', message: 'Không thể xử lý yêu cầu. Vui lòng thử lại.' },
    });
  });
  return app;
}
