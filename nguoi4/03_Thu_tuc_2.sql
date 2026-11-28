/* Người 4 — Thủ tục 2, mục 2.3.b (1,25 điểm gồm demo).
   Input: hai ngày, bao gồm cả hai đầu mút theo giờ lưu trong CSDL.
   Output: mỗi ngày một dòng, có ngày trống; đếm cả thanh toán 0 đồng.
   SUM(DECIMAL(18,2)) trả DECIMAL(38,2), COUNT_BIG trả BIGINT.
   Đọc và tổng hợp nguồn một lần, sau đó WHILE điền lịch ngày.
   IF kiểm đầu vào; BREAK tránh DATEADD tràn tại 9999-12-31.
   Không đặt giới hạn nghiệp vụ mới lên khoảng ngày; khoảng dài trả nhiều dòng.
   Không COMMIT/ROLLBACK giao dịch của bên gọi, không sửa bảng nghiệp vụ.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER PROCEDURE dbo.usp_N4_TongHopThucThuTheoNgay
    @TuNgay DATE,
    @DenNgay DATE
AS
BEGIN
    SET NOCOUNT ON;
    IF @TuNgay IS NULL OR @DenNgay IS NULL OR @TuNgay > @DenNgay
        THROW 51401, N'Nhập đủ ngày và bảo đảm ngày bắt đầu không sau ngày kết thúc.', 1;

    DECLARE @DenLoaiTru DATETIME2(0)=NULL;
    -- Không DATEADD trên 9999-12-31; IF riêng không phụ thuộc short-circuit WHERE.
    IF @DenNgay<CONVERT(DATE,'99991231')
        SET @DenLoaiTru=DATEADD(DAY,1,CONVERT(DATETIME2(0),@DenNgay));

    DECLARE @TongHop TABLE
    (
        NgayThanhToan DATE PRIMARY KEY,
        SoGiaoDich BIGINT NOT NULL,
        SoGiaoDichThuTien BIGINT NOT NULL,
        SoGiaoDichKhongThuTien BIGINT NOT NULL,
        TongTienThucThu DECIMAL(38,2) NOT NULL
    );
    INSERT @TongHop
    SELECT CONVERT(DATE, tt.ThoiGianThanhToan), COUNT_BIG(*),
           SUM(CONVERT(BIGINT, CASE WHEN tt.SoTienThanhToan > 0 THEN 1 ELSE 0 END)),
           SUM(CONVERT(BIGINT, CASE WHEN tt.SoTienThanhToan = 0 THEN 1 ELSE 0 END)),
           SUM(tt.SoTienThanhToan)
    FROM dbo.THANH_TOAN AS tt
    WHERE tt.ThoiGianThanhToan>=CONVERT(DATETIME2(0),@TuNgay)
      AND (@DenLoaiTru IS NULL OR tt.ThoiGianThanhToan<@DenLoaiTru)
    GROUP BY CONVERT(DATE, tt.ThoiGianThanhToan);

    DECLARE @BaoCao TABLE
    (
        NgayThanhToan DATE PRIMARY KEY,
        SoGiaoDich BIGINT NOT NULL,
        SoGiaoDichThuTien BIGINT NOT NULL,
        SoGiaoDichKhongThuTien BIGINT NOT NULL,
        TongTienThucThu DECIMAL(38,2) NOT NULL
    );
    DECLARE @Ngay DATE = @TuNgay;
    WHILE @Ngay <= @DenNgay
    BEGIN
        IF EXISTS (SELECT 1 FROM @TongHop WHERE NgayThanhToan = @Ngay)
            INSERT @BaoCao SELECT * FROM @TongHop WHERE NgayThanhToan = @Ngay;
        ELSE
            INSERT @BaoCao VALUES (@Ngay, 0, 0, 0, 0);

        IF @Ngay = @DenNgay BREAK;
        SET @Ngay = DATEADD(DAY, 1, @Ngay);
    END;

    SELECT NgayThanhToan, SoGiaoDich, SoGiaoDichThuTien,
           SoGiaoDichKhongThuTien, TongTienThucThu
    FROM @BaoCao
    ORDER BY NgayThanhToan;
END;
GO
