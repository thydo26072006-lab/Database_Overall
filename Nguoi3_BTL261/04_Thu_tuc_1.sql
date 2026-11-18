CREATE OR ALTER PROCEDURE dbo.usp_N3_TongHopPhanCongTheoCa
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;

    IF @TuNgay IS NULL OR @DenNgay IS NULL OR @TuNgay > @DenNgay
        THROW 51311, N'Nhập đủ ngày và bảo đảm ngày bắt đầu không sau ngày kết thúc.', 1;

    DECLARE @BaoCao TABLE
    (
        STT INT IDENTITY PRIMARY KEY,
        MaCa VARCHAR(30) NOT NULL,
        NgayLam DATE NOT NULL,
        GioBatDau TIME(0) NOT NULL,
        GioKetThuc TIME(0) NOT NULL,
        SoNhanVienPhucVu INT NULL,
        SoBanDuocPhanCong INT NULL,
        SoLuotPhanCong INT NULL,
        TinhTrang NVARCHAR(30) NULL
    );

    INSERT @BaoCao (MaCa, NgayLam, GioBatDau, GioKetThuc)
    SELECT MaCa, NgayLam, GioBatDau, GioKetThuc
    FROM dbo.CA_LAM
    WHERE NgayLam BETWEEN @TuNgay AND @DenNgay;

    IF @@ROWCOUNT = 0
        THROW 51312, N'Không có ca làm trong khoảng ngày đã chọn.', 1;

    DECLARE @STT INT = 1, @SoCa INT, @MaCa VARCHAR(30);
    DECLARE @SoNhanVien INT, @SoBan INT, @SoLuot INT;

    SELECT @SoCa = COUNT(*) FROM @BaoCao;
    WHILE @STT <= @SoCa
    BEGIN
        SELECT @MaCa = MaCa FROM @BaoCao WHERE STT = @STT;

        SELECT @SoNhanVien = COUNT(DISTINCT MaNV),
               @SoBan = COUNT(DISTINCT MaBan),
               @SoLuot = COUNT(*)
        FROM dbo.PHAN_CONG
        WHERE MaCa = @MaCa;

        UPDATE @BaoCao
        SET SoNhanVienPhucVu = @SoNhanVien,
            SoBanDuocPhanCong = @SoBan,
            SoLuotPhanCong = @SoLuot,
            TinhTrang = CASE WHEN @SoLuot = 0 THEN N'Chưa phân công' ELSE N'Đã phân công' END
        WHERE STT = @STT;

        SET @STT += 1;
    END;

    SELECT MaCa, NgayLam, GioBatDau, GioKetThuc, SoNhanVienPhucVu,
           SoBanDuocPhanCong, SoLuotPhanCong, TinhTrang
    FROM @BaoCao
    ORDER BY NgayLam, GioBatDau, MaCa;
END;
GO
