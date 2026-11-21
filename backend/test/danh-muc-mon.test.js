import assert from 'node:assert/strict';
import { randomBytes } from 'node:crypto';
import { once } from 'node:events';
import test from 'node:test';
import sql from 'mssql';
import '../src/config/load-env.js';
import { createApp } from '../src/app.js';
import { connectSqlServer } from '../src/config/sql-server.js';

test('API danh mục thực thi ba thủ tục Phần 2 trên SQL Server', async (t) => {
  assert.match(process.env.DB_NAME ?? '', /^BTL2_P3_/,
    'Hãy dùng một CSDL thử riêng có tên bắt đầu bằng BTL2_P3_.');

  const pool = await connectSqlServer();
  t.after(() => pool.close());

  const server = createApp(pool).listen(0, '127.0.0.1');
  await once(server, 'listening');
  t.after(() => new Promise((resolve) => server.close(resolve)));

  const url = `http://127.0.0.1:${server.address().port}/api/danh-muc-mon`;
  const code = `P3_N1_${randomBytes(4).toString('hex').toUpperCase()}`;
  const originalName = 'Món uống theo mùa';
  const updatedName = 'Món mùa lễ';
  const path = `/${code}`;

  async function call(method, suffix, status, body) {
    const result = await fetch(url + suffix, {
      method,
      headers: body === undefined ? undefined : { 'Content-Type': 'application/json' },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const text = await result.text();
    assert.equal(result.status, status, `${method} ${suffix}: ${text}`);
    return text ? JSON.parse(text) : undefined;
  }

  async function row(codeToRead) {
    const result = await pool.request()
      .input('code', sql.VarChar(30), codeToRead)
      .query('SELECT TenDanhMuc AS tenDanhMuc, MaDanhMucCha AS maDanhMucCha FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = @code');
    return result.recordset[0];
  }

  const parentBefore = await row('DM_DOUONG');
  const teaBefore = await row('DM_TRA');
  assert.equal(teaBefore?.maDanhMucCha, 'DM_DOUONG');
  assert.equal(parentBefore?.maDanhMucCha, null);

  try {
    await t.test('GET đọc dữ liệu mẫu từ SQL Server', async () => {
      const { data } = await call('GET', '', 200);
      assert.ok(data.some((item) => item.maDanhMuc === 'DM_TRA'));
      assert.ok(data.every((item) => item.maDanhMuc !== code));
    });

    await t.test('POST thêm tên tiếng Việt và danh mục cha', async () => {
      const category = { maDanhMuc: code, tenDanhMuc: originalName, maDanhMucCha: 'DM_DOUONG' };
      assert.deepEqual((await call('POST', '', 201, category)).data, category);
      assert.deepEqual(await row(code), { tenDanhMuc: originalName, maDanhMucCha: 'DM_DOUONG' });
    });

    await t.test('POST từ chối mã trùng 51007', async () => {
      const { error } = await call('POST', '', 409, { maDanhMuc: code, tenDanhMuc: 'Tên khác' });
      assert.equal(error.code, 51007);
      assert.equal((await row(code)).tenDanhMuc, originalName);
    });

    await t.test('POST từ chối mã dài 31 ký tự 51004', async () => {
      const { error } = await call('POST', '', 422, { maDanhMuc: code.padEnd(31, 'X'), tenDanhMuc: originalName });
      assert.equal(error.code, 51004);
      assert.equal(await row(code.padEnd(30, 'X')), undefined);
    });

    await t.test('POST từ chối danh mục cha không tồn tại 51008', async () => {
      const newCode = `${code}_CHA`;
      const { error } = await call('POST', '', 422, {
        maDanhMuc: newCode, tenDanhMuc: originalName, maDanhMucCha: `${code}_THIEU`,
      });
      assert.equal(error.code, 51008);
      assert.equal(await row(newCode), undefined);
    });

    await t.test('PUT đổi tên, bỏ cha và GET đọc lại thay đổi', async () => {
      const updated = { tenDanhMuc: updatedName, maDanhMucCha: null };
      assert.deepEqual((await call('PUT', path, 200, updated)).data, { maDanhMuc: code, ...updated });
      assert.deepEqual(await row(code), updated);
      const { data } = await call('GET', '', 200);
      assert.deepEqual(data.find((item) => item.maDanhMuc === code), { maDanhMuc: code, ...updated });
    });

    await t.test('PUT chặn vòng cha–con 51010 và giữ dữ liệu cũ', async () => {
      const { error } = await call('PUT', '/DM_DOUONG', 422, {
        tenDanhMuc: parentBefore.tenDanhMuc, maDanhMucCha: 'DM_TRA',
      });
      assert.equal(error.code, 51010);
      assert.deepEqual(await row('DM_DOUONG'), parentBefore);
    });

    await t.test('DELETE từ chối danh mục còn con hoặc món 51303', async () => {
      for (const [id, info] of [['DM_DOUONG', parentBefore], ['DM_TRA', teaBefore]]) {
        assert.equal((await call('DELETE', `/${id}`, 409)).error.code, 51303);
        assert.deepEqual(await row(id), info);
      }
    });

    await t.test('DELETE xóa danh mục thử và GET xác nhận danh sách', async () => {
      assert.equal(await call('DELETE', path, 204), undefined);
      assert.equal(await row(code), undefined);
      assert.ok((await call('GET', '', 200)).data.every((item) => item.maDanhMuc !== code));
    });

    await t.test('PUT và DELETE trả 404 với danh mục đã xóa', async () => {
      assert.equal((await call('PUT', path, 404, { tenDanhMuc: updatedName })).error.code, 51203);
      assert.equal((await call('DELETE', path, 404)).error.code, 51302);
    });
  } finally {
    if (await row(code)) {
      await pool.request().input('MaDanhMuc', sql.NVarChar(sql.MAX), code).execute('dbo.usp_N3_XoaDanhMuc');
    }
  }
});
