-- Chọn CSDL đã nạp BTL2_SQL_TONG_HOP.sql trong VS Code trước khi chạy.
SELECT DB_NAME() AS TenCSDL,
       OBJECT_ID(N'dbo.usp_N3_TongHopPhanCongTheoCa', N'P') AS MaDoiTuong;
GO

-- Dữ liệu mẫu, dự kiến 2 dòng với số đếm (1, 2, 2) và (0, 0, 0).
EXEC dbo.usp_N3_TongHopPhanCongTheoCa @TuNgay = '20261113', @DenNgay = '20261113';
GO

BEGIN TRY
    EXEC dbo.usp_N3_TongHopPhanCongTheoCa @TuNgay = '20261114', @DenNgay = '20261113';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 51311 THROW;
    SELECT ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;
GO

BEGIN TRY
    EXEC dbo.usp_N3_TongHopPhanCongTheoCa @TuNgay = '19000101', @DenNgay = '19000101';
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 51312 THROW;
    SELECT ERROR_NUMBER() AS MaLoi, ERROR_MESSAGE() AS ThongBao;
END CATCH;
GO
