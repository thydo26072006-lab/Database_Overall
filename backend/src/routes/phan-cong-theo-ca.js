import { Router } from 'express';

function parseDate(value) {
  if (typeof value !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(value) || value.startsWith('0000')) {
    return null;
  }
  const date = new Date(value + 'T00:00:00.000Z');
  return Number.isNaN(date.valueOf()) || date.toISOString().slice(0, 10) !== value ? null : date;
}

export function createShiftReportRouter(getPool, sql) {
  const router = Router();
  router.get('/', async (req, res) => {
    const from = parseDate(req.query.tuNgay);
    const to = parseDate(req.query.denNgay);
    if (!from || !to || from > to) {
      return res.status(400).json({
        code: 'INVALID_DATE_RANGE',
        message: 'Nhập đủ ngày hợp lệ và chọn ngày bắt đầu không sau ngày kết thúc.',
      });
    }

    try {
      const pool = await getPool();
      const { recordset } = await pool.request()
        .input('TuNgay', sql.Date, from)
        .input('DenNgay', sql.Date, to)
        .execute('dbo.usp_N3_TongHopPhanCongTheoCa');

      const data = recordset.map((row) => ({
        ...row,
        NgayLam: row.NgayLam.toISOString().slice(0, 10),
        GioBatDau: row.GioBatDau.toISOString().slice(11, 19),
        GioKetThuc: row.GioKetThuc.toISOString().slice(11, 19),
      }));
      return res.json({ data });
    } catch (error) {
      if (error.number === 51312) {
        return res.json({ data: [], code: 'NO_SHIFTS', message: 'Không có ca làm trong khoảng ngày đã chọn.' });
      }
      if (error.number === 51311) {
        return res.status(400).json({ code: 'INVALID_DATE_RANGE', message: error.message });
      }
      console.error('Tổng hợp phân công theo ca:', error.code, error.number);
      return res.status(500).json({ code: 'REPORT_FAILED', message: 'Không thể tải báo cáo. Vui lòng thử lại.' });
    }
  });
  return router;
}
