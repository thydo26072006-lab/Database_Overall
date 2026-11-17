/* NGƯỜI 5 | File 03_Ham_1.sql | Bản sửa theo EERD_UPDATE.xlsx. */
/* Chuẩn: EERD_UPDATE.xlsx và EERD_VE_LAI.drawio main đã khôi phục.
   Phạm vi thống kê gồm DoUong, DoAn và Topping/TC; đếm cấu hình,
   không khẳng định topping bán riêng hoặc món có đủ công thức/tồn. */
/* Người 5 — Hàm 1, bàn giao demo cho Người 3.
   Input: mã danh mục gốc VARCHAR(30).
   Output: BIGINT = số cặp món–size đang bán trong danh mục và mọi cấp con.
   NULL: mã NULL/rỗng/không tồn tại, hoặc phát hiện chu trình dữ liệu.
   0: danh mục hợp lệ nhưng không có lựa chọn đang bán.
   Không kiểm tra công thức/khả năng pha chế; đây là thống kê cấu hình thực đơn.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER FUNCTION dbo.fn_N5_DemLuaChonTheoDanhMuc
(
    @MaDanhMuc VARCHAR(30)
)
RETURNS BIGINT
AS
BEGIN
    IF NULLIF(LTRIM(RTRIM(@MaDanhMuc)), '') IS NULL
        RETURN NULL;
    IF NOT EXISTS (SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = @MaDanhMuc)
        RETURN NULL;

    DECLARE @HangDoi TABLE
    (
        MaDanhMuc VARCHAR(30) PRIMARY KEY,
        DaDuyet BIT NOT NULL
    );
    INSERT @HangDoi VALUES (@MaDanhMuc, 0);

    DECLARE @MaDangDuyet VARCHAR(30), @Tong BIGINT = 0, @SoLuaChon BIGINT;
    WHILE EXISTS (SELECT 1 FROM @HangDoi WHERE DaDuyet = 0)
    BEGIN
        SELECT TOP (1) @MaDangDuyet = MaDanhMuc
        FROM @HangDoi WHERE DaDuyet = 0 ORDER BY MaDanhMuc;

        SELECT @SoLuaChon = COUNT_BIG(*)
        FROM dbo.MON AS m
        JOIN dbo.SIZE_MON AS s ON s.MaMon = m.MaMon
        WHERE m.MaDanhMuc = @MaDangDuyet
          AND m.TrangThaiKinhDoanh = 'DangBan'
          AND s.TrangThaiSize = 'DangBan';
        SET @Tong = @Tong + @SoLuaChon;
        UPDATE @HangDoi SET DaDuyet = 1 WHERE MaDanhMuc = @MaDangDuyet;

        -- Mỗi danh mục chỉ có một cha; gặp lại nút đã vào hàng đợi là chu trình.
        -- BR04 yêu cầu ngăn chu trình ở tầng ghi; nhánh này phòng vệ dữ liệu nhập ngoài.
        IF EXISTS
        (
            SELECT 1 FROM dbo.DANH_MUC_MON AS dm
            JOIN @HangDoi AS q ON q.MaDanhMuc = dm.MaDanhMuc
            WHERE dm.MaDanhMucCha = @MaDangDuyet
        )
            RETURN NULL;

        INSERT @HangDoi (MaDanhMuc, DaDuyet)
        SELECT MaDanhMuc, 0 FROM dbo.DANH_MUC_MON
        WHERE MaDanhMucCha = @MaDangDuyet;
    END;
    RETURN @Tong;
END;
GO
