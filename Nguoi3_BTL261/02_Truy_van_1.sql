-- Dữ liệu mẫu liên quan từ seed chung của Người 1 và Người 2. Chạy phần này để chụp dữ liệu nguồn.
SELECT MaDanhMuc, TenDanhMuc FROM dbo.DANH_MUC_MON ORDER BY MaDanhMuc;
SELECT MaMon, TenMon, MaDanhMuc, TrangThaiKinhDoanh, LoaiMon FROM dbo.MON ORDER BY MaMon;
SELECT MaMon, MaSize, GiaBan, TrangThaiSize FROM dbo.SIZE_MON ORDER BY MaMon, MaSize;
GO

-- Câu 1. Màn hình chọn món khi lập đơn, sau khi chọn danh mục Trà.
DECLARE @MaDanhMuc VARCHAR(30) = 'DM_TRA';

SELECT m.MaMon, m.TenMon, s.MaSize, s.GiaBan
FROM dbo.MON AS m
INNER JOIN dbo.SIZE_MON AS s ON s.MaMon = m.MaMon
WHERE m.MaDanhMuc = @MaDanhMuc
  AND m.LoaiMon IN ('DoUong', 'DoAn')
  AND m.TrangThaiKinhDoanh = 'DangBan'
  AND s.TrangThaiSize = 'DangBan'
ORDER BY m.TenMon, m.MaMon,
         CASE s.MaSize WHEN 'S' THEN 1 WHEN 'M' THEN 2 WHEN 'L' THEN 3 ELSE 4 END;
GO
