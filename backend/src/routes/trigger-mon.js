import { Router } from 'express';

const statuses = ['NgungBan', 'DangBan'];
const sizes = ['S', 'M', 'L', 'TC'];
const types = ['DoUong', 'DoAn', 'Topping'];
const sqlErrors = new Map([
  [51210, [422, 'Món mới phải ở trạng thái ngừng bán. Hãy cấu hình size trước khi bật bán.']],
  [51211, [409, 'Không thể đổi loại món khi món còn size.']],
  [51212, [409, 'Món đang bán phải còn ít nhất một size đang bán.']],
  [51213, [422, 'Topping chỉ dùng size TC. Đồ ăn và đồ uống dùng size S, M hoặc L.']],
  [547, [409, 'Danh mục hoặc món không tồn tại, hoặc size đang được dữ liệu khác sử dụng.']],
  [2627, [409, 'Mã món hoặc size đã tồn tại.']],
  [2601, [409, 'Mã món hoặc size đã tồn tại.']],
]);

function sendError(res, status, code, message) {
  return res.status(status).json({ error: { code, message } });
}

function validText(value, length) {
  return typeof value === 'string' && value.trim().length > 0 && value.trim().length <= length;
}

function validSize(maSize, giaBan, trangThaiSize) {
  return sizes.includes(maSize) && Number.isSafeInteger(giaBan) && giaBan >= 0 && statuses.includes(trangThaiSize);
}

export function createTriggerMonRouter(query) {
  const router = Router();

  router.get('/danh-muc', async (_req, res) => {
    const data = await query(`
      SELECT MaDanhMuc AS maDanhMuc, TenDanhMuc AS tenDanhMuc
      FROM dbo.DANH_MUC_MON ORDER BY TenDanhMuc, MaDanhMuc
    `);
    res.json({ data });
  });

  router.get('/mon', async (_req, res) => {
    const rows = await query(`
      SELECT m.MaMon AS maMon, m.TenMon AS tenMon, m.LoaiMon AS loaiMon,
             m.TrangThaiKinhDoanh AS trangThaiKinhDoanh, m.MaDanhMuc AS maDanhMuc,
             d.TenDanhMuc AS tenDanhMuc, s.MaSize AS maSize,
             s.GiaBan AS giaBan, s.TrangThaiSize AS trangThaiSize
      FROM dbo.MON AS m
      JOIN dbo.DANH_MUC_MON AS d ON d.MaDanhMuc = m.MaDanhMuc
      LEFT JOIN dbo.SIZE_MON AS s ON s.MaMon = m.MaMon
      ORDER BY m.MaMon, CASE s.MaSize WHEN 'S' THEN 1 WHEN 'M' THEN 2 WHEN 'L' THEN 3 ELSE 4 END
    `);
    const items = new Map();
    for (const { maSize, giaBan, trangThaiSize, ...item } of rows) {
      if (!items.has(item.maMon)) items.set(item.maMon, { ...item, sizes: [] });
      if (maSize) items.get(item.maMon).sizes.push({ maSize, giaBan, trangThaiSize });
    }
    res.json({ data: [...items.values()] });
  });

  router.post('/mon', async (req, res) => {
    const { maMon, tenMon, loaiMon, maDanhMuc, trangThaiKinhDoanh = 'NgungBan' } = req.body ?? {};
    if (!validText(maMon, 30) || !validText(tenMon, 200) || !validText(maDanhMuc, 30) ||
        !types.includes(loaiMon) || !statuses.includes(trangThaiKinhDoanh)) {
      return sendError(res, 400, 'INVALID_INPUT', 'Nhập mã, tên, loại món, danh mục và trạng thái hợp lệ.');
    }
    const [data] = await query(`
      DECLARE @NewItem TABLE (MaMon VARCHAR(30));
      INSERT dbo.MON (MaMon, TenMon, LoaiMon, MaDanhMuc, TrangThaiKinhDoanh)
      OUTPUT inserted.MaMon INTO @NewItem
      VALUES (@maMon, @tenMon, @loaiMon, @maDanhMuc, @trangThaiKinhDoanh);
      SELECT MaMon FROM @NewItem;
    `, { maMon: maMon.trim(), tenMon: tenMon.trim(), loaiMon, maDanhMuc: maDanhMuc.trim(), trangThaiKinhDoanh });
    res.status(201).json({ data });
  });

  router.patch('/mon/:maMon/trang-thai', async (req, res) => {
    const { maMon } = req.params;
    const { trangThaiKinhDoanh } = req.body ?? {};
    if (!validText(maMon, 30) || !statuses.includes(trangThaiKinhDoanh)) {
      return sendError(res, 400, 'INVALID_INPUT', 'Mã món hoặc trạng thái món không hợp lệ.');
    }
    const [result] = await query(`
      UPDATE dbo.MON SET TrangThaiKinhDoanh = @trangThaiKinhDoanh WHERE MaMon = @maMon;
      SELECT @@ROWCOUNT AS affected;
    `, { maMon, trangThaiKinhDoanh });
    if (!result.affected) return sendError(res, 404, 'MON_NOT_FOUND', 'Không tìm thấy món.');
    res.json({ data: { maMon, trangThaiKinhDoanh } });
  });

  router.post('/mon/:maMon/size', async (req, res) => {
    const { maMon } = req.params;
    const { maSize, giaBan, trangThaiSize = 'NgungBan' } = req.body ?? {};
    if (!validText(maMon, 30) || !validSize(maSize, giaBan, trangThaiSize)) {
      return sendError(res, 400, 'INVALID_INPUT', 'Chọn size, trạng thái và nhập giá là số nguyên không âm.');
    }
    const [data] = await query(`
      DECLARE @NewSize TABLE (MaMon VARCHAR(30), MaSize VARCHAR(2), GiaBan DECIMAL(18,2), TrangThaiSize VARCHAR(30));
      INSERT dbo.SIZE_MON (MaMon, MaSize, GiaBan, TrangThaiSize)
      OUTPUT inserted.MaMon, inserted.MaSize, inserted.GiaBan, inserted.TrangThaiSize INTO @NewSize
      VALUES (@maMon, @maSize, @giaBan, @trangThaiSize);
      SELECT MaMon, MaSize, GiaBan, TrangThaiSize FROM @NewSize;
    `, { maMon, maSize, giaBan, trangThaiSize });
    res.status(201).json({ data });
  });

  router.put('/mon/:maMon/size/:maSize', async (req, res) => {
    const { maMon, maSize } = req.params;
    const { giaBan, trangThaiSize } = req.body ?? {};
    if (!validText(maMon, 30) || !validSize(maSize, giaBan, trangThaiSize)) {
      return sendError(res, 400, 'INVALID_INPUT', 'Chọn size, trạng thái và nhập giá là số nguyên không âm.');
    }
    const [result] = await query(`
      UPDATE dbo.SIZE_MON SET GiaBan = @giaBan, TrangThaiSize = @trangThaiSize
      WHERE MaMon = @maMon AND MaSize = @maSize;
      SELECT @@ROWCOUNT AS affected;
    `, { maMon, maSize, giaBan, trangThaiSize });
    if (!result.affected) return sendError(res, 404, 'SIZE_NOT_FOUND', 'Không tìm thấy size của món.');
    res.json({ data: { maMon, maSize, giaBan, trangThaiSize } });
  });

  router.delete('/mon/:maMon/size/:maSize', async (req, res) => {
    const { maMon, maSize } = req.params;
    if (!validText(maMon, 30) || !sizes.includes(maSize)) {
      return sendError(res, 400, 'INVALID_INPUT', 'Mã món hoặc size không hợp lệ.');
    }
    const [result] = await query(`
      DELETE FROM dbo.SIZE_MON WHERE MaMon = @maMon AND MaSize = @maSize;
      SELECT @@ROWCOUNT AS affected;
    `, { maMon, maSize });
    if (!result.affected) return sendError(res, 404, 'SIZE_NOT_FOUND', 'Không tìm thấy size của món.');
    res.status(204).end();
  });

  router.use((error, _req, res, _next) => {
    const mapped = sqlErrors.get(error.number);
    if (mapped) return sendError(res, mapped[0], error.number, mapped[1]);
    console.error('API món và size:', error.code ?? error.name, error.number ?? '');
    return sendError(res, 500, 'DATABASE_ERROR', 'Không thể thao tác dữ liệu. Kiểm tra kết nối và cấu trúc SQL Server.');
  });

  return router;
}
