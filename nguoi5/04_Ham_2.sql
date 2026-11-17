/* NGƯỜI 5 | File 04_Ham_2.sql | Bản sửa theo EERD_UPDATE.xlsx. */
/* Một kho theo BR49, không có MaKho/KHO/TON_KHO.
   Input: MaHangHoa, mốc DATETIME2(0), lấy cả thời điểm bằng mốc.
   Output: DECIMAL(18,6); chưa có biến động hợp lệ trả 0.
   NULL: đầu vào sai, hàng không tồn tại, phiếu DaGhiSo thiếu thời điểm,
   tổng tồn âm hoặc vượt miền DECIMAL(18,6). Không THROW trong scalar UDF.
   Chỉ đọc sổ; không thay thế kiểm tồn/khóa khi ghi sổ. Phiếu DaGhiSo
   bất biến; sửa sai bằng phiếu đối chiếu, không hủy lại phiếu đã ghi sổ.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER FUNCTION dbo.fn_N5_TonKhoDenThoiDiem
(@MaHangHoa VARCHAR(30), @DenThoiDiem DATETIME2(0))
RETURNS DECIMAL(18,6)
AS
BEGIN
    IF NULLIF(LTRIM(RTRIM(@MaHangHoa)), '') IS NULL OR @DenThoiDiem IS NULL
        RETURN NULL;
    IF NOT EXISTS (SELECT 1 FROM dbo.HANG_HOA WHERE MaHangHoa=@MaHangHoa)
        RETURN NULL;
    IF EXISTS (
        SELECT 1 FROM dbo.PHIEU_KHO p
        JOIN dbo.CHI_TIET_PHIEU_KHO c ON c.MaPhieuKho=p.MaPhieuKho
        WHERE c.MaHangHoa=@MaHangHoa AND p.TrangThaiPhieu='DaGhiSo'
          AND p.ThoiDiemGhiSo IS NULL
    ) RETURN NULL;
    DECLARE @BienDong TABLE (STT BIGINT IDENTITY(1,1) PRIMARY KEY,
                            SoLuong DECIMAL(18,6) NOT NULL);
    INSERT @BienDong(SoLuong)
    SELECT c.BienDongSoLuong FROM dbo.PHIEU_KHO p
    JOIN dbo.CHI_TIET_PHIEU_KHO c ON c.MaPhieuKho=p.MaPhieuKho
    WHERE c.MaHangHoa=@MaHangHoa AND p.TrangThaiPhieu='DaGhiSo'
      AND p.ThoiDiemGhiSo<=@DenThoiDiem;
    -- Accumulator 37,6: addition has room for a carry and retains all 6 decimals.
    DECLARE @i BIGINT=1,@n BIGINT,@Luong DECIMAL(18,6),@Ton DECIMAL(37,6)=0;
    SELECT @n=COUNT_BIG(*) FROM @BienDong;
    WHILE @i<=@n
    BEGIN
        SELECT @Luong=SoLuong FROM @BienDong WHERE STT=@i;
        SET @Ton=@Ton+@Luong;
        SET @i=@i+1;
    END;
    IF @Ton<0 OR @Ton>999999999999.999999 RETURN NULL;
    RETURN CONVERT(DECIMAL(18,6),@Ton);
END;
GO
