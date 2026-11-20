/* NGƯỜI 4 | TASK 2.4.b: DEMO HÀM 2 nhận từ Người 5.
   CSDL 30 bảng thật, mã HH_KIEMTHU/HH_CHUA_NHAP/HH_TINY theo seed chung.
   Giữ nguyên chữ ký hai tham số và thân hàm của Người 5. */
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
