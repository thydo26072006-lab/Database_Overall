import { Router } from 'express';
import { getPool as getSharedPool } from '../config/sql-server.js';

const routerPaths = {
  danhMucMon: '/danh-muc-mon',
  triggerMon: '/trigger-mon',
  shiftReport: '/bao-cao/phan-cong-theo-ca',
};

export function createApiRouter({ getPool = getSharedPool, routers = {} } = {}) {
  const router = Router();

  router.get('/health', async (_request, response) => {
    response.set('Cache-Control', 'no-store');
    try {
      const pool = await getPool();
      await pool.request().query('SELECT 1');
    } catch {
      return response.status(503).json({
        error: { code: 'DB_UNAVAILABLE', message: 'Không thể kết nối cơ sở dữ liệu.' },
      });
    }

    return response.json({ data: { status: 'ok', database: 'connected' } });
  });

  for (const [name, path] of Object.entries(routerPaths)) {
    if (routers[name]) router.use(path, routers[name]);
  }

  return router;
}
