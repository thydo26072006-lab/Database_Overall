/* NGƯỜI 4 | TASK 1.3 / hàng 1.2.c: Truy vấn 3 có GROUP BY và tổng hợp.
   Use case: quản lý kho xem tăng/giảm/ròng từng mặt hàng trong một kỳ.
   Bảng khác truy vấn 2: HANG_HOA, PHIEU_KHO, CHI_TIET_PHIEU_KHO.
   Chỉ phiếu DaGhiSo; kiểm kê dương/âm tính vào tăng/giảm tương ứng.
   BienDongRongTrongKy không phải số tồn cuối nếu kỳ không từ đầu sổ.
   Nhóm theo mặt hàng và đơn vị; không cộng g/kg/chai thành một tổng chung.
   Một dòng phiếu/mặt hàng là duy nhất theo UQ, COUNT_BIG là số phiếu liên quan.
*/
DECLARE @TuNgay DATE='20261101',@DenNgay DATE='20261103',@MaHangHoa VARCHAR(30)='HH_KIEMTHU';
IF @TuNgay IS NULL OR @DenNgay IS NULL OR @TuNgay>@DenNgay
    THROW 51401,N'Nhập đủ ngày và không đảo khoảng ngày.',1;
DECLARE @DenLoaiTru DATETIME2(0)=NULL;
IF @DenNgay<CONVERT(DATE,'99991231') SET @DenLoaiTru=DATEADD(DAY,1,CONVERT(DATETIME2(0),@DenNgay));
-- BEGIN_QUERY
SELECT h.MaHangHoa,h.TenHangHoa,h.DonViTinh,
       COUNT_BIG(*) AS SoPhieuDaGhiSo,
       SUM(CASE WHEN c.BienDongSoLuong>0 THEN c.BienDongSoLuong ELSE CONVERT(DECIMAL(18,6),0) END) AS TongTangTrongKy,
       SUM(CASE WHEN c.BienDongSoLuong<0 THEN -c.BienDongSoLuong ELSE CONVERT(DECIMAL(18,6),0) END) AS TongGiamTrongKy,
       SUM(c.BienDongSoLuong) AS BienDongRongTrongKy
FROM dbo.HANG_HOA h
JOIN dbo.CHI_TIET_PHIEU_KHO c ON c.MaHangHoa=h.MaHangHoa
JOIN dbo.PHIEU_KHO p ON p.MaPhieuKho=c.MaPhieuKho
WHERE p.TrangThaiPhieu='DaGhiSo'
  AND p.ThoiDiemGhiSo>=CONVERT(DATETIME2(0),@TuNgay)
  AND (@DenLoaiTru IS NULL OR p.ThoiDiemGhiSo<@DenLoaiTru)
  AND (@MaHangHoa IS NULL OR h.MaHangHoa=@MaHangHoa)
GROUP BY h.MaHangHoa,h.TenHangHoa,h.DonViTinh
ORDER BY h.MaHangHoa;
-- END_QUERY
GO
