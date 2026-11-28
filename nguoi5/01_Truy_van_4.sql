/* NGƯỜI 5 | File 01_Truy_van_4.sql | Bản sửa theo EERD_UPDATE.xlsx. */
/* Chuẩn: EERD_UPDATE.xlsx và EERD_VE_LAI.drawio main đã khôi phục.
   Phạm vi thống kê gồm DoUong, DoAn và Topping/TC; đếm cấu hình,
   không khẳng định topping bán riêng hoặc món có đủ công thức/tồn. */
/* Người 5 — Truy vấn 4 (mục 1.3 / hàng 1.2.d bảng kê).
   Màn hình quản lý thực đơn: thống kê lựa chọn đang bán theo danh mục trực tiếp.
   Dạng: SELECT, FROM, WHERE, GROUP BY, ORDER BY và hàm tổng hợp.
   Chạy trên lược đồ main đã đồng bộ. Không thay đổi dữ liệu.
   Mỗi lựa chọn là một cặp (MaMon, MaSize), không phải một món riêng.
*/
SELECT dm.MaDanhMuc, dm.TenDanhMuc,
       COUNT(DISTINCT m.MaMon) AS SoMonDangBan,
       COUNT_BIG(*) AS SoLuaChonSize,
       MIN(s.GiaBan) AS GiaThapNhat,
       MAX(s.GiaBan) AS GiaCaoNhat,
       CAST(AVG(s.GiaBan) AS DECIMAL(18,2)) AS GiaTrungBinhMoiSize
FROM dbo.DANH_MUC_MON AS dm
JOIN dbo.MON AS m ON m.MaDanhMuc = dm.MaDanhMuc
JOIN dbo.SIZE_MON AS s ON s.MaMon = m.MaMon
WHERE m.TrangThaiKinhDoanh = 'DangBan'
  AND s.TrangThaiSize = 'DangBan'
GROUP BY dm.MaDanhMuc, dm.TenDanhMuc
ORDER BY SoLuaChonSize DESC, dm.MaDanhMuc;
GO
