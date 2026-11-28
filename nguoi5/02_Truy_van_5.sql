/* NGƯỜI 5 | File 02_Truy_van_5.sql | Bản sửa theo EERD_UPDATE.xlsx. */
/* Chuẩn: EERD_UPDATE.xlsx và EERD_VE_LAI.drawio main đã khôi phục.
   Phạm vi thống kê gồm DoUong, DoAn và Topping/TC; đếm cấu hình,
   không khẳng định topping bán riêng hoặc món có đủ công thức/tồn. */
/* Người 5 — Truy vấn 5 (mục 1.3 / hàng 1.2.e bảng kê).
   Màn hình rà soát giá: món có giá trung bình các size đang bán
   cao hơn trung bình giá của từng món đang bán trên toàn thực đơn.
   Hai tầng truy vấn con lồng nhau trong HAVING:
     tầng 1: AVG(g.GiaTBMon); tầng 2: AVG(s2.GiaBan), GROUP BY m2.MaMon.
   Mỗi món có trọng số bằng nhau trong ngưỡng so sánh.
   Chạy trên lược đồ main đã đồng bộ. Không thay đổi dữ liệu.
*/
SELECT m.MaMon, m.TenMon, COUNT_BIG(*) AS SoSizeDangBan,
       CAST(AVG(s.GiaBan) AS DECIMAL(18,2)) AS GiaTrungBinhMon
FROM dbo.MON AS m
JOIN dbo.SIZE_MON AS s ON s.MaMon = m.MaMon
WHERE m.TrangThaiKinhDoanh = 'DangBan'
  AND s.TrangThaiSize = 'DangBan'
GROUP BY m.MaMon, m.TenMon
HAVING AVG(s.GiaBan) >
(
    SELECT AVG(g.GiaTBMon)
    FROM
    (
        SELECT m2.MaMon, AVG(s2.GiaBan) AS GiaTBMon
        FROM dbo.MON AS m2
        JOIN dbo.SIZE_MON AS s2 ON s2.MaMon = m2.MaMon
        WHERE m2.TrangThaiKinhDoanh = 'DangBan'
          AND s2.TrangThaiSize = 'DangBan'
        GROUP BY m2.MaMon
    ) AS g
)
ORDER BY GiaTrungBinhMon DESC, m.MaMon;
GO
