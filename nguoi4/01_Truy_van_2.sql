/* Người 4 — Truy vấn 2, hàng 1.2.b (1,0 điểm).
   Use case: thu ngân/QL tra giao dịch thành công theo ngày thanh toán.
   Dạng SELECT / FROM / WHERE / ORDER BY. Nguồn EERD_UPDATE.xlsx, sheet 02/07.
   Mỗi dòng THANH_TOAN là một giao dịch thành công; gồm cả đơn 0 đồng.
   Không nối HOA_DON: hủy/phát hành lại hóa đơn không tạo thêm khoản thu.
   Chạy trên CSDL chung đã tạo bảng chuẩn; không thay đổi dữ liệu.
*/
DECLARE @TuNgay DATE = '20261114', @DenNgay DATE = '20261117';
IF @TuNgay IS NULL OR @DenNgay IS NULL OR @TuNgay > @DenNgay
    THROW 51401, N'Nhập đủ ngày và bảo đảm ngày bắt đầu không sau ngày kết thúc.', 1;

    DECLARE @DenLoaiTru DATETIME2(0)=NULL;
    -- Không DATEADD trên 9999-12-31; IF riêng không phụ thuộc short-circuit WHERE.
    IF @DenNgay<CONVERT(DATE,'99991231')
        SET @DenLoaiTru=DATEADD(DAY,1,CONVERT(DATETIME2(0),@DenNgay));

-- BEGIN_QUERY
SELECT tt.MaThanhToan, tt.MaDonHang, tt.ThoiGianThanhToan,
       tt.PhuongThuc, tt.SoTienThanhToan, tt.MaNVThuNgan
FROM dbo.THANH_TOAN AS tt
WHERE tt.ThoiGianThanhToan>=CONVERT(DATETIME2(0),@TuNgay)
      AND (@DenLoaiTru IS NULL OR tt.ThoiGianThanhToan<@DenLoaiTru)
ORDER BY tt.ThoiGianThanhToan, tt.MaThanhToan;
-- END_QUERY
GO
