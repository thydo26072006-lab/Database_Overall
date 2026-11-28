/* NGƯỜI 2 | TASK 2.2.b: nhóm Trigger 2 — MON và SIZE_MON.
   BR05/43/83: đúng loại size, món đang bán phải có size đang bán.
   Khởi tạo cấu hình nháp: topping=TC, món thường=S, giá 0/NgungBan.
   Đây là tiện ích tạo nháp, không tự kích hoạt bán hoặc suy giá từ MON.
   inserted/deleted được xử lý theo tập, không giả định chỉ có một dòng. */
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO
CREATE OR ALTER TRIGGER dbo.trg_N2_Mon_TaoSizeMacDinh
ON dbo.MON AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    IF NOT EXISTS(SELECT 1 FROM inserted) RETURN;
    -- Món mới phải ở dạng nháp; không cho DangBan khi chưa có size.
    IF EXISTS(SELECT 1 FROM inserted i LEFT JOIN deleted d ON d.MaMon=i.MaMon
              WHERE d.MaMon IS NULL AND i.TrangThaiKinhDoanh='DangBan')
        THROW 51210,N'Món mới phải NgungBan; cấu hình size rồi mới kích hoạt.',1;
    IF EXISTS(SELECT 1 FROM inserted i JOIN deleted d ON d.MaMon=i.MaMon
              WHERE i.LoaiMon<>d.LoaiMon AND EXISTS(SELECT 1 FROM dbo.SIZE_MON s WHERE s.MaMon=i.MaMon))
        THROW 51211,N'Không đổi loại món khi còn quy cách; ngừng bán và tạo mã mới nếu đã dùng.',1;
    INSERT dbo.SIZE_MON(MaMon,MaSize,GiaBan,TrangThaiSize)
    SELECT i.MaMon,CASE WHEN i.LoaiMon='Topping' THEN 'TC' ELSE 'S' END,0,'NgungBan'
    FROM inserted i LEFT JOIN deleted d ON d.MaMon=i.MaMon
    WHERE d.MaMon IS NULL AND NOT EXISTS(SELECT 1 FROM dbo.SIZE_MON s WHERE s.MaMon=i.MaMon);
    IF EXISTS(SELECT 1 FROM inserted i WHERE i.TrangThaiKinhDoanh='DangBan'
              AND NOT EXISTS(SELECT 1 FROM dbo.SIZE_MON s WHERE s.MaMon=i.MaMon AND s.TrangThaiSize='DangBan'))
        THROW 51212,N'Món đang bán phải có ít nhất một quy cách đang bán.',1;
END;
GO
CREATE OR ALTER TRIGGER dbo.trg_N2_Size_DungLoai
ON dbo.SIZE_MON AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @SoMon BIGINT;
    SELECT @SoMon=COUNT_BIG(*) FROM dbo.MON WITH(UPDLOCK,HOLDLOCK)
    WHERE MaMon IN(SELECT MaMon FROM inserted UNION SELECT MaMon FROM deleted);
    IF EXISTS(SELECT 1 FROM inserted i JOIN dbo.MON m ON m.MaMon=i.MaMon
              WHERE (m.LoaiMon='Topping' AND i.MaSize<>'TC') OR (m.LoaiMon<>'Topping' AND i.MaSize='TC'))
        THROW 51213,N'Topping chỉ dùng TC; món thường chỉ dùng S/M/L.',1;
    IF EXISTS(SELECT 1 FROM dbo.MON m
              WHERE m.MaMon IN(SELECT MaMon FROM inserted UNION SELECT MaMon FROM deleted)
              AND m.TrangThaiKinhDoanh='DangBan'
              AND NOT EXISTS(SELECT 1 FROM dbo.SIZE_MON s WHERE s.MaMon=m.MaMon AND s.TrangThaiSize='DangBan'))
        THROW 51212,N'Không bỏ hoặc ngừng size đang bán cuối cùng của món đang bán.',1;
END;
GO

