/* NGƯỜI 5 | Bộ test bàn giao Hàm 2; phần demo được giao Người 4 khi tích hợp.
   Hai tham số, một kho; không hủy/sửa chứng từ đã ghi sổ để dựng demo. */
DECLARE @KQ TABLE(Ca NVARCHAR(100),KyVong DECIMAL(18,6),ThucTe DECIMAL(18,6));
INSERT @KQ VALUES
(N'Trước nhập',0,dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU','20261031')),
(N'Đúng mốc nhập',10,dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU','20261101')),
(N'Sau xuất hủy',7.5,dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU','20261102')),
(N'Sau kiểm kê',8,dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU','20261103')),
(N'Phiếu nháp không tính tồn',8,dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU','20261130')),
(N'Hàng chưa nhập',0,dbo.fn_N5_TonKhoDenThoiDiem('HH_CHUA_NHAP','20261130')),
(N'Giữ đủ sáu số lẻ',0.000001,dbo.fn_N5_TonKhoDenThoiDiem('HH_TINY','20261130')),
(N'Mã không có',NULL,dbo.fn_N5_TonKhoDenThoiDiem('KHONG_CO','20261130')),
(N'Mã NULL',NULL,dbo.fn_N5_TonKhoDenThoiDiem(NULL,'20261130')),
(N'Mốc NULL',NULL,dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU',NULL));
SELECT *,CASE WHEN ThucTe=KyVong OR (ThucTe IS NULL AND KyVong IS NULL) THEN 'PASS' ELSE 'FAIL' END AS KetQua FROM @KQ;
IF EXISTS(SELECT KyVong,ThucTe FROM @KQ WHERE KyVong<>ThucTe OR (KyVong IS NULL AND ThucTe IS NOT NULL) OR (KyVong IS NOT NULL AND ThucTe IS NULL))
    THROW 51993,N'Demo Hàm 2 không khớp kỳ vọng.',1;
GO
