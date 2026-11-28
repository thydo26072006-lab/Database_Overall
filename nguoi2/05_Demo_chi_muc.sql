/* NGƯỜI 2 | TASK 1.2 DEMO chỉ mục; mã CREATE INDEX do NGƯỜI 3 phụ trách.
   Cùng 5 nhu cầu I1–I5, cùng dữ liệu/câu SELECT trước/sau.
   DROP/CREATE nằm trong transaction và ROLLBACK để phục hồi 5 index ban đầu.
   Chạy ngoài giao dịch, tại CSDL kiểm thử riêng, không chạy đồng thời workload.
   SSMS: Ctrl+M trước khi chạy để lấy Actual Execution Plan; Messages có IO/TIME.
   Seed nhỏ có thể vẫn scan; không gán số tăng tốc giả hoặc ép INDEX hint. */
IF @@TRANCOUNT<>0 THROW 51990,N'Demo chỉ mục cần giao dịch riêng.',1;
SET NOCOUNT ON;
SET XACT_ABORT ON;
BEGIN TRY
    BEGIN TRANSACTION;
    DROP INDEX IX_N3_DanhMuc_Cha_Ten ON dbo.DANH_MUC_MON;
    DROP INDEX IX_N3_Mon_DanhMuc_TrangThai_Ten ON dbo.MON;
    DROP INDEX IX_N3_Ban_TrangThai_ThuTu ON dbo.BAN;
    DROP INDEX IX_N3_CaLam_Ngay_Gio ON dbo.CA_LAM;
    DROP INDEX IX_N3_PhanCong_Ca_Ban ON dbo.PHAN_CONG;
    SET STATISTICS IO ON;
    SET STATISTICS TIME ON;
    PRINT N'TRƯỚC: chưa có 5 index IX_N3';
    PRINT N'I1 Cây danh mục';
    SELECT MaDanhMuc,TenDanhMuc FROM dbo.DANH_MUC_MON WHERE MaDanhMucCha='DM_DOUONG' ORDER BY TenDanhMuc,MaDanhMuc;
    PRINT N'I2 Chọn món';
    SELECT MaMon,TenMon FROM dbo.MON WHERE MaDanhMuc='DM_TRA' AND TrangThaiKinhDoanh='DangBan' ORDER BY TenMon,MaMon;
    PRINT N'I3 Sơ đồ bàn, BR02 không có khu vực';
    SELECT MaBan,TenBan,SoGhe,SoThuTu FROM dbo.BAN WHERE TrangThaiHoatDong='HoatDong' ORDER BY SoThuTu,MaBan;
    PRINT N'I4 Lịch ca';
    SELECT MaCa,GioBatDau,GioKetThuc FROM dbo.CA_LAM WHERE NgayLam='20261113' ORDER BY GioBatDau,MaCa;
    PRINT N'I5 Phân công theo ca';
    SELECT MaBan,MaNV FROM dbo.PHAN_CONG WHERE MaCa='CA_1311_SANG' ORDER BY MaBan,MaNV;
    CREATE INDEX IX_N3_DanhMuc_Cha_Ten ON dbo.DANH_MUC_MON(MaDanhMucCha,TenDanhMuc,MaDanhMuc);
    CREATE INDEX IX_N3_Mon_DanhMuc_TrangThai_Ten ON dbo.MON(MaDanhMuc,TrangThaiKinhDoanh,TenMon,MaMon);
    CREATE INDEX IX_N3_Ban_TrangThai_ThuTu ON dbo.BAN(TrangThaiHoatDong,SoThuTu,MaBan) INCLUDE(TenBan,SoGhe);
    CREATE INDEX IX_N3_CaLam_Ngay_Gio ON dbo.CA_LAM(NgayLam,GioBatDau,MaCa) INCLUDE(GioKetThuc);
    CREATE INDEX IX_N3_PhanCong_Ca_Ban ON dbo.PHAN_CONG(MaCa,MaBan,MaNV);
    PRINT N'SAU: đã tạo đúng 5 index IX_N3, cùng truy vấn và dữ liệu';
    PRINT N'I1 Cây danh mục';
    SELECT MaDanhMuc,TenDanhMuc FROM dbo.DANH_MUC_MON WHERE MaDanhMucCha='DM_DOUONG' ORDER BY TenDanhMuc,MaDanhMuc;
    PRINT N'I2 Chọn món';
    SELECT MaMon,TenMon FROM dbo.MON WHERE MaDanhMuc='DM_TRA' AND TrangThaiKinhDoanh='DangBan' ORDER BY TenMon,MaMon;
    PRINT N'I3 Sơ đồ bàn';
    SELECT MaBan,TenBan,SoGhe,SoThuTu FROM dbo.BAN WHERE TrangThaiHoatDong='HoatDong' ORDER BY SoThuTu,MaBan;
    PRINT N'I4 Lịch ca';
    SELECT MaCa,GioBatDau,GioKetThuc FROM dbo.CA_LAM WHERE NgayLam='20261113' ORDER BY GioBatDau,MaCa;
    PRINT N'I5 Phân công theo ca';
    SELECT MaBan,MaNV FROM dbo.PHAN_CONG WHERE MaCa='CA_1311_SANG' ORDER BY MaBan,MaNV;
    SET STATISTICS IO OFF;
    SET STATISTICS TIME OFF;
    ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
    SET STATISTICS IO OFF;
    SET STATISTICS TIME OFF;
    IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
    THROW;
END CATCH;
GO

