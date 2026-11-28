-- Chọn cùng CSDL với script Người 1 và Người 2.
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.DANH_MUC_MON') AND name = N'IX_N3_DanhMuc_Cha_Ten')
    CREATE INDEX IX_N3_DanhMuc_Cha_Ten ON dbo.DANH_MUC_MON(MaDanhMucCha, TenDanhMuc, MaDanhMuc);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.MON') AND name = N'IX_N3_Mon_DanhMuc_TrangThai_Ten')
    CREATE INDEX IX_N3_Mon_DanhMuc_TrangThai_Ten ON dbo.MON(MaDanhMuc, TrangThaiKinhDoanh, TenMon, MaMon);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.BAN') AND name = N'IX_N3_Ban_TrangThai_ThuTu')
    CREATE INDEX IX_N3_Ban_TrangThai_ThuTu ON dbo.BAN(TrangThaiHoatDong, SoThuTu, MaBan) INCLUDE (TenBan, SoGhe);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.CA_LAM') AND name = N'IX_N3_CaLam_Ngay_Gio')
    CREATE INDEX IX_N3_CaLam_Ngay_Gio ON dbo.CA_LAM(NgayLam, GioBatDau, MaCa) INCLUDE (GioKetThuc);
IF NOT EXISTS (SELECT 1 FROM sys.indexes WHERE object_id = OBJECT_ID(N'dbo.PHAN_CONG') AND name = N'IX_N3_PhanCong_Ca_Ban')
    CREATE INDEX IX_N3_PhanCong_Ca_Ban ON dbo.PHAN_CONG(MaCa, MaBan, MaNV);
GO
