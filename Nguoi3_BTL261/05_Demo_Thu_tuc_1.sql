-- P0. Kiểm tra CSDL và thủ tục đã tạo.
SELECT DB_NAME() AS CSDL, name AS ThuTuc
FROM sys.procedures
WHERE schema_id = SCHEMA_ID(N'dbo')
  AND name = N'usp_N3_TongHopPhanCongTheoCa';
GO

-- P1. Đọc seed tích hợp. Ca 14/11 là ca đối chứng ngoài khoảng lọc.
SELECT MaCa, NgayLam, GioBatDau, GioKetThuc
FROM dbo.CA_LAM
WHERE NgayLam BETWEEN '20261113' AND '20261114'
ORDER BY NgayLam, GioBatDau, MaCa;

SELECT pc.MaCa, pc.MaBan, pc.MaNV
FROM dbo.PHAN_CONG AS pc
JOIN dbo.CA_LAM AS ca ON ca.MaCa = pc.MaCa
WHERE ca.NgayLam BETWEEN '20261113' AND '20261114'
ORDER BY pc.MaCa, pc.MaBan, pc.MaNV;

DECLARE @KetQua TABLE
(
    MaCa VARCHAR(30), NgayLam DATE, GioBatDau TIME(0), GioKetThuc TIME(0),
    SoNhanVienPhucVu INT, SoBanDuocPhanCong INT, SoLuotPhanCong INT,
    TinhTrang NVARCHAR(30)
);
INSERT @KetQua
EXEC dbo.usp_N3_TongHopPhanCongTheoCa @TuNgay = '20261113', @DenNgay = '20261113';

SELECT * FROM @KetQua ORDER BY NgayLam, GioBatDau, MaCa;

IF (SELECT COUNT(*) FROM @KetQua) <> 2
   OR NOT EXISTS
   (
       SELECT 1 FROM @KetQua
       WHERE MaCa = 'CA_1311_SANG' AND NgayLam = '20261113'
         AND GioBatDau = '08:00' AND GioKetThuc = '12:00'
         AND SoNhanVienPhucVu = 1 AND SoBanDuocPhanCong = 2 AND SoLuotPhanCong = 2
         AND TinhTrang = N'Đã phân công'
   )
   OR NOT EXISTS
   (
       SELECT 1 FROM @KetQua
       WHERE MaCa = 'CA_1311_CHIEU' AND NgayLam = '20261113'
         AND GioBatDau = '13:00' AND GioKetThuc = '17:00'
         AND SoNhanVienPhucVu = 0 AND SoBanDuocPhanCong = 0 AND SoLuotPhanCong = 0
         AND TinhTrang = N'Chưa phân công'
   )
    THROW 51992, N'Kết quả Thủ tục 1 khác kỳ vọng của seed tích hợp.', 1;
GO

-- P2. Ghi nhận đúng mã lỗi thực tế của từng đầu vào.
DECLARE @Loi TABLE
(
    STT INT IDENTITY PRIMARY KEY, Ca NVARCHAR(60), MaLoi INT, ThongBao NVARCHAR(4000)
);

BEGIN TRY
    EXEC dbo.usp_N3_TongHopPhanCongTheoCa @TuNgay = '20261114', @DenNgay = '20261113';
    THROW 51390, N'Ngày đảo phải báo lỗi 51311.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 51311 THROW;
    INSERT @Loi (Ca, MaLoi, ThongBao)
    VALUES (N'Ngày đảo', ERROR_NUMBER(), ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    EXEC dbo.usp_N3_TongHopPhanCongTheoCa @TuNgay = NULL, @DenNgay = '20261113';
    THROW 51390, N'Thiếu ngày phải báo lỗi 51311.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 51311 THROW;
    INSERT @Loi (Ca, MaLoi, ThongBao)
    VALUES (N'Thiếu ngày', ERROR_NUMBER(), ERROR_MESSAGE());
END CATCH;

BEGIN TRY
    EXEC dbo.usp_N3_TongHopPhanCongTheoCa @TuNgay = '19000101', @DenNgay = '19000101';
    THROW 51390, N'Khoảng trống phải báo lỗi 51312.', 1;
END TRY
BEGIN CATCH
    IF ERROR_NUMBER() <> 51312 THROW;
    INSERT @Loi (Ca, MaLoi, ThongBao)
    VALUES (N'Không có ca', ERROR_NUMBER(), ERROR_MESSAGE());
END CATCH;

SELECT Ca, MaLoi, ThongBao FROM @Loi ORDER BY STT;
GO
