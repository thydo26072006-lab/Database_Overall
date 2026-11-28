import { Router } from 'express';
import { createDanhMucMonController, handleDanhMucMonError } from '../controllers/danh-muc-mon.js';
import { createDanhMucMonService } from '../services/danh-muc-mon.js';

export function createDanhMucMonRouter(pool, sql) {
  const router = Router();
  const controller = createDanhMucMonController(createDanhMucMonService(pool, sql));

  router.get('/', controller.list);
  router.post('/', controller.create);
  router.put('/:maDanhMuc', controller.update);
  router.delete('/:maDanhMuc', controller.remove);
  router.use(handleDanhMucMonError);
  return router;
}
