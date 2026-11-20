/* NGƯỜI 4 | TASK 2.3.b demo thủ tục 2 và dữ liệu cho truy vấn 2–3.
   CSDL 30 bảng thật; mọi mẫu thanh toán có đầy đủ nguồn nghiệp vụ.
   Dữ liệu tạo trong giao dịch riêng và ROLLBACK, không để lại thanh toán mẫu.
   Không dùng fixture 6 bảng hoặc bản sao #procedure; gọi đúng procedure nộp.
*/
IF @@TRANCOUNT<>0 THROW 51990,N'Demo N4 cần giao dịch riêng.',1;
SET NOCOUNT ON; SET XACT_ABORT ON;
BEGIN TRY
BEGIN TRANSACTION;
EXEC dbo.usp_N4_ChuanBiDuLieuBaoCao;
DECLARE @TuNgay DATE='20261114',@DenNgay DATE='20261117',@DenLoaiTru DATETIME2(0)='20261118';
DECLARE @Q2 TABLE(MaThanhToan VARCHAR(30),MaDonHang VARCHAR(30),ThoiGianThanhToan DATETIME2(0),PhuongThuc VARCHAR(30),SoTienThanhToan DECIMAL(18,2),MaNVThuNgan VARCHAR(30));
INSERT @Q2
SELECT tt.MaThanhToan, tt.MaDonHang, tt.ThoiGianThanhToan,
       tt.PhuongThuc, tt.SoTienThanhToan, tt.MaNVThuNgan
FROM dbo.THANH_TOAN AS tt
WHERE tt.ThoiGianThanhToan>=CONVERT(DATETIME2(0),@TuNgay)
      AND (@DenLoaiTru IS NULL OR tt.ThoiGianThanhToan<@DenLoaiTru)
ORDER BY tt.ThoiGianThanhToan, tt.MaThanhToan;
SELECT N'N4-Q2: chi tiết thu tiền, không nhân theo hóa đơn' AS MinhHoa;
SELECT * FROM @Q2 ORDER BY ThoiGianThanhToan,MaThanhToan;
IF (SELECT COUNT(*) FROM @Q2)<>5 OR (SELECT SUM(SoTienThanhToan) FROM @Q2)<>110000
 OR NOT EXISTS(SELECT 1 FROM @Q2 WHERE MaThanhToan='N4_T3' AND SoTienThanhToan=0 AND PhuongThuc='KhongThuTien')
 OR EXISTS(SELECT 1 FROM @Q2 WHERE MaThanhToan IN('N4_T0','N4_T6'))
 THROW 51996,N'FAIL N4-Q2: sai ngày biên/số dòng/tổng tiền.',1;
DECLARE @TuKho DATE='20261101',@DenKho DATE='20261103',@DenKhoLoaiTru DATETIME2(0)='20261104',@MaHangHoa VARCHAR(30)='HH_KIEMTHU';
DECLARE @Q3 TABLE(MaHangHoa VARCHAR(30),TenHangHoa NVARCHAR(200),DonViTinh NVARCHAR(200),SoPhieuDaGhiSo BIGINT,TongTangTrongKy DECIMAL(38,6),TongGiamTrongKy DECIMAL(38,6),BienDongRongTrongKy DECIMAL(38,6));
INSERT @Q3
SELECT h.MaHangHoa,h.TenHangHoa,h.DonViTinh,
       COUNT_BIG(*) AS SoPhieuDaGhiSo,
       SUM(CASE WHEN c.BienDongSoLuong>0 THEN c.BienDongSoLuong ELSE CONVERT(DECIMAL(18,6),0) END) AS TongTangTrongKy,
       SUM(CASE WHEN c.BienDongSoLuong<0 THEN -c.BienDongSoLuong ELSE CONVERT(DECIMAL(18,6),0) END) AS TongGiamTrongKy,
       SUM(c.BienDongSoLuong) AS BienDongRongTrongKy
FROM dbo.HANG_HOA h
JOIN dbo.CHI_TIET_PHIEU_KHO c ON c.MaHangHoa=h.MaHangHoa
JOIN dbo.PHIEU_KHO p ON p.MaPhieuKho=c.MaPhieuKho
WHERE p.TrangThaiPhieu='DaGhiSo'
  AND p.ThoiDiemGhiSo>=CONVERT(DATETIME2(0),@TuKho)
  AND (@DenKhoLoaiTru IS NULL OR p.ThoiDiemGhiSo<@DenKhoLoaiTru)
  AND (@MaHangHoa IS NULL OR h.MaHangHoa=@MaHangHoa)
GROUP BY h.MaHangHoa,h.TenHangHoa,h.DonViTinh
ORDER BY h.MaHangHoa;
SELECT N'N4-Q3: tăng 10.5, giảm 2.5, ròng 8; phiếu nháp không tính' AS MinhHoa;
SELECT * FROM @Q3 ORDER BY MaHangHoa;
IF (SELECT COUNT(*) FROM @Q3)<>1 OR NOT EXISTS(SELECT 1 FROM @Q3 WHERE MaHangHoa='HH_KIEMTHU' AND SoPhieuDaGhiSo=3 AND TongTangTrongKy=10.5 AND TongGiamTrongKy=2.5 AND BienDongRongTrongKy=8)
 THROW 51996,N'FAIL N4-Q3: sai tổng hợp kho.',1;
DECLARE @KQ TABLE(NgayThanhToan DATE,SoGiaoDich BIGINT,SoGiaoDichThuTien BIGINT,SoGiaoDichKhongThuTien BIGINT,TongTienThucThu DECIMAL(38,2));
DECLARE @KyVong TABLE(NgayThanhToan DATE,SoGiaoDich BIGINT,SoGiaoDichThuTien BIGINT,SoGiaoDichKhongThuTien BIGINT,TongTienThucThu DECIMAL(38,2));
INSERT @KyVong VALUES('20261114',3,2,1,80000),('20261115',1,1,0,20000),('20261116',0,0,0,0),('20261117',1,1,0,10000);
INSERT @KQ EXEC dbo.usp_N4_TongHopThucThuTheoNgay '20261114','20261117';
SELECT N'N4-P01: đủ ngày trống và giao dịch 0 đồng' AS MinhHoa;
SELECT * FROM @KQ ORDER BY NgayThanhToan;
IF EXISTS(SELECT * FROM @KQ EXCEPT SELECT * FROM @KyVong) OR EXISTS(SELECT * FROM @KyVong EXCEPT SELECT * FROM @KQ) OR (SELECT COUNT(*) FROM @KQ)<>4
 THROW 51996,N'FAIL thủ tục 2: sai dữ liệu tổng hợp ngày.',1;
IF (SELECT COUNT(*) FROM dbo.THANH_TOAN WHERE MaThanhToan LIKE 'N4_T%')<>7 OR (SELECT COUNT(*) FROM dbo.HOA_DON WHERE MaHoaDon LIKE 'N4_H%')<>8
 THROW 51996,N'FAIL dữ liệu nguồn: hóa đơn phát hành lại phải không tạo thêm khoản thu.',1;
SELECT N'PASS N4-Q2/Q3/P01: đối chiếu kỳ vọng thành công; chuẩn bị hoàn tác' AS KetQua;
ROLLBACK TRANSACTION;
END TRY
BEGIN CATCH
 IF XACT_STATE()<>0 ROLLBACK TRANSACTION;
 THROW;
END CATCH;
GO
