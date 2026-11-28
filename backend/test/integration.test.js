import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { once } from 'node:events';
import { createServer } from 'node:net';
import process from 'node:process';
import test from 'node:test';
import { setTimeout as delay } from 'node:timers/promises';
import { loadEnv } from '../src/config/load-env.js';
import { createQuery, getPool } from '../src/config/sql-server.js';

const host = '127.0.0.1';
const demoDatabase = 'BTL2_P3_DEMO';
const categoryPath = '/api/danh-muc-mon';
const itemPath = '/api/trigger-mon/mon';
const reportPath = '/api/bao-cao/phan-cong-theo-ca';
const selling = 'DangBan';
const inactive = 'NgungBan';
const query = createQuery();

async function checkPort(port) {
  const probe = createServer().listen(port, host);
  try {
    await once(probe, 'listening');
  } catch (error) {
    if (error.code !== 'EADDRINUSE') throw error;
    throw new Error('APP_PORT đang bận. Dừng backend đang chạy hoặc chọn cổng khác để chạy npm test.');
  }
  await new Promise((resolve, reject) => probe.close(error => error ? reject(error) : resolve()));
}

function createClient(origin) {
  return async (method, path, status, body) => {
    const response = await fetch(origin + path, {
      method,
      signal: AbortSignal.timeout(30000),
      ...(body === undefined ? {} : { headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) }),
    });
    const text = await response.text();
    assert.equal(response.status, status, method + ' ' + path + ' — ' + text);
    if (status === 204) {
      assert.equal(text, '');
      return;
    }
    assert.match(response.headers.get('content-type'), /^application\/json/);
    return JSON.parse(text);
  };
}

async function waitForBackend(origin, hasExited) {
  const deadline = Date.now() + 35000;
  while (!hasExited() && Date.now() < deadline) {
    const response = await fetch(origin + '/api/health', { signal: AbortSignal.timeout(1000) })
      .catch(() => null);
    if (response) {
      await response.text();
      if (response.ok) return;
    }
    await delay(100);
  }
  assert.fail('Backend không sẵn sàng để kiểm thử. Kiểm tra cấu hình, SQL Server và APP_PORT.');
}

function requireBusinessError(payload, code) {
  assert.deepEqual(Object.keys(payload), ['error']);
  assert.equal(payload.error.code, code);
  assert.ok(payload.error.message);
}

async function readFixtures({ parent, child, drink, topping, rejected }) {
  const [categories, items, sizes] = await Promise.all([
    query('SELECT * FROM dbo.DANH_MUC_MON WHERE MaDanhMuc IN (@parent, @child) ORDER BY MaDanhMuc',
      { parent, child }),
    query('SELECT * FROM dbo.MON WHERE MaMon IN (@drink, @topping, @rejected) ORDER BY MaMon',
      { drink, topping, rejected }),
    query('SELECT * FROM dbo.SIZE_MON WHERE MaMon IN (@drink, @topping, @rejected) ORDER BY MaMon, MaSize',
      { drink, topping, rejected }),
  ]);
  return { categories, items, sizes };
}

const emptyFixtures = { categories: [], items: [], sizes: [] };

async function cleanFixtures({ parent, child, drink, topping, rejected }) {
  await query(
    "SET XACT_ABORT ON; BEGIN TRANSACTION; " +
    "UPDATE dbo.MON SET TrangThaiKinhDoanh = 'NgungBan' WHERE MaMon IN (@drink, @topping, @rejected); " +
    'DELETE FROM dbo.SIZE_MON WHERE MaMon IN (@drink, @topping, @rejected); ' +
    'DELETE FROM dbo.MON WHERE MaMon IN (@drink, @topping, @rejected); ' +
    'IF EXISTS (SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = @child) ' +
    'EXEC dbo.usp_N3_XoaDanhMuc @MaDanhMuc = @child; ' +
    'IF EXISTS (SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = @parent) ' +
    'EXEC dbo.usp_N3_XoaDanhMuc @MaDanhMuc = @parent; COMMIT TRANSACTION;',
    { parent, child, drink, topping, rejected },
  );
  assert.deepEqual(await readFixtures({ parent, child, drink, topping, rejected }), emptyFixtures,
    'Dữ liệu thử phải được dọn hết.');
}

async function testCategories(t, request, fixtures) {
  const { parent, child } = fixtures;
  const root = { maDanhMuc: parent, tenDanhMuc: 'Danh mục gốc kiểm thử', maDanhMucCha: null };
  const leaf = { maDanhMuc: child, tenDanhMuc: 'Danh mục con kiểm thử', maDanhMucCha: parent };
  const renamed = { ...leaf, tenDanhMuc: 'Đã đổi tên danh mục', maDanhMucCha: null };
  const parentUrl = categoryPath + '/' + parent;
  const childUrl = categoryPath + '/' + child;

  await t.test('POST, GET, PUT và DELETE danh mục', async () => {
    assert.deepEqual(await request('POST', categoryPath, 201, root), { data: root });
    assert.deepEqual(await request('POST', categoryPath, 201, leaf), { data: leaf });

    const { data } = await request('GET', categoryPath, 200);
    assert.deepEqual(data.find(row => row.maDanhMuc === parent), root);
    assert.deepEqual(data.find(row => row.maDanhMuc === child), leaf);

    const before = await readFixtures(fixtures);
    requireBusinessError(await request('POST', categoryPath, 409, leaf), 51007);
    requireBusinessError(await request('PUT', parentUrl, 422,
      { tenDanhMuc: root.tenDanhMuc, maDanhMucCha: child }), 51010);
    requireBusinessError(await request('DELETE', parentUrl, 409), 51303);
    assert.deepEqual(await readFixtures(fixtures), before);

    assert.deepEqual(await request('PUT', childUrl, 200,
      { tenDanhMuc: renamed.tenDanhMuc, maDanhMucCha: null }), { data: renamed });
    const { categories } = await readFixtures(fixtures);
    const persisted = categories.find(row => row.MaDanhMuc === child);
    assert.equal(persisted.TenDanhMuc, renamed.tenDanhMuc);
    assert.equal(persisted.MaDanhMucCha, null);

    await request('DELETE', childUrl, 204);
    await request('DELETE', parentUrl, 204);
    assert.deepEqual((await readFixtures(fixtures)).categories, []);
  });
}

async function testItems(t, request, fixtures) {
  const { drink, topping, rejected } = fixtures;
  const drinkUrl = itemPath + '/' + drink;
  const toppingUrl = itemPath + '/' + topping;
  const stateUrl = drinkUrl + '/trang-thai';
  const drinkSizeUrl = drinkUrl + '/size';
  const size = (maSize, giaBan, trangThaiSize) => ({ maSize, giaBan, trangThaiSize });
  const drinkBody = { maMon: drink, tenMon: 'Trà sữa kiểm thử', loaiMon: 'DoUong', maDanhMuc: 'DM_TRA' };
  const toppingBody = { maMon: topping, tenMon: 'Trân châu kiểm thử', loaiMon: 'Topping', maDanhMuc: 'DM_TOPPING' };

  await t.test('GET danh mục món và các endpoint món, size cùng hai trigger', async () => {
    const categories = await request('GET', '/api/trigger-mon/danh-muc', 200);
    const requiredCategories = await query(
      "SELECT MaDanhMuc AS maDanhMuc, TenDanhMuc AS tenDanhMuc FROM dbo.DANH_MUC_MON WHERE MaDanhMuc IN ('DM_TRA', 'DM_TOPPING') ORDER BY MaDanhMuc",
    );
    assert.equal(requiredCategories.length, 2, 'Cần dữ liệu mẫu cho DM_TRA và DM_TOPPING.');
    for (const category of requiredCategories) assert.ok(categories.data.some(row =>
      row.maDanhMuc === category.maDanhMuc && row.tenDanhMuc === category.tenDanhMuc));

    requireBusinessError(await request('POST', itemPath, 422,
      { ...drinkBody, maMon: rejected, trangThaiKinhDoanh: selling }), 51210);
    assert.deepEqual(await readFixtures(fixtures), emptyFixtures);
    assert.deepEqual(await request('POST', itemPath, 201, drinkBody), { data: { MaMon: drink } });
    assert.deepEqual(await request('POST', itemPath, 201, toppingBody), { data: { MaMon: topping } });

    const initial = await request('GET', itemPath, 200);
    const drinkRow = initial.data.find(row => row.maMon === drink);
    const toppingRow = initial.data.find(row => row.maMon === topping);
    assert.equal(drinkRow.tenMon, drinkBody.tenMon);
    assert.equal(toppingRow.tenMon, toppingBody.tenMon);
    assert.deepEqual(drinkRow.sizes, [size('S', 0, inactive)]);
    assert.deepEqual(toppingRow.sizes, [size('TC', 0, inactive)]);

    const drafts = await readFixtures(fixtures);
    requireBusinessError(await request('PATCH', stateUrl, 409, { trangThaiKinhDoanh: selling }), 51212);
    requireBusinessError(await request('POST', toppingUrl + '/size', 422, size('M', 10000, inactive)), 51213);
    requireBusinessError(await request('POST', drinkSizeUrl, 422, size('TC', 10000, inactive)), 51213);
    assert.deepEqual(await readFixtures(fixtures), drafts);

    const activeSize = size('S', 25000, selling);
    assert.deepEqual(await request('PUT', drinkSizeUrl + '/S', 200,
      { giaBan: activeSize.giaBan, trangThaiSize: selling }), { data: { maMon: drink, ...activeSize } });
    assert.deepEqual(await request('PATCH', stateUrl, 200, { trangThaiKinhDoanh: selling }),
      { data: { maMon: drink, trangThaiKinhDoanh: selling } });

    const active = await readFixtures(fixtures);
    assert.equal(active.items.find(row => row.MaMon === drink).TrangThaiKinhDoanh, selling);
    assert.equal(active.sizes.find(row => row.MaMon === drink && row.MaSize === 'S').GiaBan, activeSize.giaBan);
    requireBusinessError(await request('PUT', drinkSizeUrl + '/S', 409,
      { giaBan: 29000, trangThaiSize: inactive }), 51212);
    requireBusinessError(await request('DELETE', drinkSizeUrl + '/S', 409), 51212);
    assert.deepEqual(await readFixtures(fixtures), active);

    assert.deepEqual(await request('POST', drinkSizeUrl, 201, size('M', 35000, selling)),
      { data: { MaMon: drink, MaSize: 'M', GiaBan: 35000, TrangThaiSize: selling } });
    await request('DELETE', drinkSizeUrl + '/M', 204);
    const final = await request('GET', itemPath, 200);
    const item = final.data.find(row => row.maMon === drink);
    assert.deepEqual(item.sizes, [activeSize]);
    assert.equal(item.trangThaiKinhDoanh, selling);
  });
}

async function testReport(t, request) {
  const path = (tuNgay, denNgay) => reportPath + '?' + new URLSearchParams({ tuNgay, denNgay });
  await t.test('Báo cáo trả hai ca và giữ đúng ngày giờ, số liệu', async () => {
    const { data } = await request('GET', path('2026-11-13', '2026-11-13'), 200);
    assert.deepEqual(data, [
      {
        MaCa: 'CA_1311_SANG', NgayLam: '2026-11-13', GioBatDau: '08:00:00', GioKetThuc: '12:00:00',
        SoNhanVienPhucVu: 1, SoBanDuocPhanCong: 2, SoLuotPhanCong: 2, TinhTrang: 'Đã phân công',
      },
      {
        MaCa: 'CA_1311_CHIEU', NgayLam: '2026-11-13', GioBatDau: '13:00:00', GioKetThuc: '17:00:00',
        SoNhanVienPhucVu: 0, SoBanDuocPhanCong: 0, SoLuotPhanCong: 0, TinhTrang: 'Chưa phân công',
      },
    ]);
  });
  await t.test('Báo cáo trả 400 INVALID_DATE_RANGE khi thiếu ngày hoặc khoảng ngày sai', async () => {
    for (const url of [reportPath, path('2026-11-14', '2026-11-13'), path('2026-02-29', '2026-03-01')]) {
      const payload = await request('GET', url, 400);
      assert.equal(payload.code, 'INVALID_DATE_RANGE');
      assert.ok(payload.message);
    }
  });
  await t.test('Báo cáo không có ca trả 200 NO_SHIFTS và mảng rỗng', async () => {
    const payload = await request('GET', path('2026-11-15', '2026-11-15'), 200);
    assert.equal(payload.code, 'NO_SHIFTS');
    assert.deepEqual(payload.data, []);
    assert.ok(payload.message);
  });
}

test('Backend tích hợp 12 endpoint và health trên SQL Server', async t => {
  // Bộ kiểm thử ghi dữ liệu tạm và cần dữ liệu mẫu của đúng CSDL thử.
  const config = loadEnv();
  assert.equal(config.db.name, demoDatabase, 'Đặt DB_NAME=BTL2_P3_DEMO để chạy npm test.');
  await checkPort(config.appPort);

  const origin = 'http://' + host + ':' + config.appPort;
  const request = createClient(origin);
  const prefix = 'N513_' + randomBytes(8).toString('hex').toUpperCase();
  const fixtures = {
    parent: prefix + '_P', child: prefix + '_C',
    drink: prefix + '_D', topping: prefix + '_T', rejected: prefix + '_X',
  };
  let exited = false;
  const backend = import('../src/server.js').finally(() => { exited = true; });
  let canClean = false;
  try {
    await waitForBackend(origin, () => exited);
    assert.deepEqual(await query('SELECT DB_NAME() AS db'), [{ db: demoDatabase }]);
    assert.deepEqual(await readFixtures(fixtures), emptyFixtures);
    canClean = true;

    await t.test('GET /api/health xác nhận kết nối SQL Server', async () => {
      assert.deepEqual(await request('GET', '/api/health', 200), { data: { status: 'ok', database: 'connected' } });
    });
    await testCategories(t, request, fixtures);
    await testItems(t, request, fixtures);
    await testReport(t, request);
  } finally {
    try {
      if (canClean) await cleanFixtures(fixtures);
    } finally {
      if (!exited) process.emit('SIGINT', 'SIGINT');
      await backend;
      await assert.rejects(getPool(), /chưa được khởi tạo/);
    }
  }
});
