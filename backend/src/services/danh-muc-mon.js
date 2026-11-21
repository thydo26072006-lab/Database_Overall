import sql from 'mssql';

function categoryDto(row) {
  return {
    maDanhMuc: row.MaDanhMuc,
    tenDanhMuc: row.TenDanhMuc,
    maDanhMucCha: row.MaDanhMucCha,
  };
}

export function createDanhMucMonService(pool) {
  async function save(procedure, { maDanhMuc, tenDanhMuc, maDanhMucCha }) {
    const result = await pool.request()
      .input('MaDanhMuc', sql.NVarChar(sql.MAX), maDanhMuc)
      .input('TenDanhMuc', sql.NVarChar(sql.MAX), tenDanhMuc)
      .input('MaDanhMucCha', sql.NVarChar(sql.MAX), maDanhMucCha)
      .execute(procedure);
    return categoryDto(result.recordset[0]);
  }

  return {
    async list() {
      const result = await pool.request().query(`
        SELECT MaDanhMuc, TenDanhMuc, MaDanhMucCha
        FROM dbo.DANH_MUC_MON
        ORDER BY TenDanhMuc, MaDanhMuc
      `);
      return result.recordset.map(categoryDto);
    },
    create(category) {
      return save('dbo.usp_N1_ThemDanhMuc', category);
    },
    update(category) {
      return save('dbo.usp_N2_CapNhatDanhMuc', category);
    },
    async remove(maDanhMuc) {
      await pool.request()
        .input('MaDanhMuc', sql.NVarChar(sql.MAX), maDanhMuc)
        .execute('dbo.usp_N3_XoaDanhMuc');
    },
  };
}
