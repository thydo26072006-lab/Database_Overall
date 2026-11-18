/* NGƯỜI 4 | DỮ LIỆU PHỤ TRỢ DEMO, không tính như Thủ tục 2.
   Tạo các mẫu hoàn chỉnh trong transaction do demo mở, cuối demo ROLLBACK.
   Không là API thanh toán: chỉ cấu hình cứng các đơn thử không KM/khách thành viên.
   Giữ nguyên 30 bảng, không #procedure/fixture thay thế; không tắt FK/trigger.
   Mỗi mẫu có nhân viên đúng vai trò/ca/bàn, món-size/công thức, tiêu hao,
   THANH_TOAN, HOA_DON, một XuatBan đã ghi sổ và đơn DaThanhToan.
   Thời gian minh họa UTC+7; cuối ca là 23:59:59 loại trừ nên mẫu cuối ngày
   dùng 23:59:58, không đặt thanh toán tại thời điểm không có ca hợp lệ.
*/
CREATE OR ALTER PROCEDURE dbo.usp_N4_ChuanBiDuLieuBaoCao
AS
BEGIN
    SET NOCOUNT ON;
    IF @@TRANCOUNT=0 THROW 51493,N'Dữ liệu demo N4 chỉ tạo trong transaction sẽ ROLLBACK.',1;
    IF EXISTS(SELECT 1 FROM dbo.NHAN_VIEN WHERE MaNV IN('N4_PV','N4_TN'))
      OR EXISTS(SELECT 1 FROM dbo.DON_HANG WHERE MaDonHang LIKE 'N4_D%')
      OR EXISTS(SELECT 1 FROM dbo.MON WHERE MaMon LIKE 'N4_M%')
        THROW 51493,N'Trùng mã demo; không ghi đè dữ liệu có sẵn.',1;
    DECLARE @Mau TABLE(STT INT PRIMARY KEY,ThoiDiem DATETIME2(0),PhuongThuc VARCHAR(30),SoTien DECIMAL(18,2));
    INSERT @Mau VALUES
    (0,'20261113 23:59:58','TienMat',7000),
    (1,'20261114 00:00:00','TienMat',50000),
    (2,'20261114 12:00:00','ChuyenKhoan',30000),
    (3,'20261114 23:59:58','KhongThuTien',0),
    (4,'20261115 08:00:00','ViDienTu',20000),
    (5,'20261117 23:59:58','The',10000),
    (6,'20261118 00:00:00','TienMat',9000);
    INSERT dbo.NHAN_VIEN(MaNV,HoTen,TrangThaiLamViec,NgayVaoLam,DuocLapPhieuKho,LuongCoSo)
    VALUES('N4_PV',N'Phục vụ demo báo cáo','DangLam','20260101',0,25000),
          ('N4_TN',N'Thu ngân demo báo cáo','DangLam','20260101',0,30000);
    INSERT dbo.PHUC_VU(MaNV,SoBanPhuTrachToiDa) VALUES('N4_PV',1);
    INSERT dbo.THU_NGAN(MaNV,DuocHuyHoaDon) VALUES('N4_TN',1);
    INSERT dbo.LIEN_HE_NHAN_VIEN(MaNV,Loai,GiaTri) VALUES('N4_PV','SDT','0994400001'),('N4_TN','SDT','0994400002');
    INSERT dbo.CA_LAM(MaCa,NgayLam,GioBatDau,GioKetThuc)
    SELECT DISTINCT 'N4_CA'+CONVERT(CHAR(8),CONVERT(DATE,ThoiDiem),112),CONVERT(DATE,ThoiDiem),'00:00:00','23:59:59' FROM @Mau;
    INSERT dbo.LAM_VIEC(MaNV,MaCa)
    SELECT n.MaNV,c.MaCa FROM (VALUES('N4_PV'),('N4_TN')) n(MaNV) CROSS JOIN dbo.CA_LAM c WHERE c.MaCa LIKE 'N4_CA%';
    INSERT dbo.PHAN_CONG(MaNV,MaBan,MaCa) SELECT 'N4_PV','B01',MaCa FROM dbo.CA_LAM WHERE MaCa LIKE 'N4_CA%';
    DECLARE @i INT=0,@Mon VARCHAR(30),@CT VARCHAR(30),@DH VARCHAR(30),@PK VARCHAR(30),@TT VARCHAR(30),@HD VARCHAR(30),
            @Ten NVARCHAR(200),@ThoiDiem DATETIME2(0),@Tien DECIMAL(18,2),@PT VARCHAR(30);
    WHILE @i<=6
    BEGIN
        SELECT @ThoiDiem=ThoiDiem,@Tien=SoTien,@PT=PhuongThuc FROM @Mau WHERE STT=@i;
        SELECT @Mon='N4_M'+CONVERT(VARCHAR(2),@i),@CT='N4_CT'+CONVERT(VARCHAR(2),@i),@DH='N4_D'+CONVERT(VARCHAR(2),@i),
               @PK='N4_PK'+CONVERT(VARCHAR(2),@i),@TT='N4_T'+CONVERT(VARCHAR(2),@i),@HD='N4_H'+CONVERT(VARCHAR(2),@i),
               @Ten=N'Món demo báo cáo '+CONVERT(NVARCHAR(2),@i);
        INSERT dbo.MON(MaMon,TenMon,TrangThaiKinhDoanh,LoaiMon,MaDanhMuc) VALUES(@Mon,@Ten,'NgungBan','DoAn','DM_DOAN');
        -- Trigger 2 tạo đúng size S nháp; giá mẫu có cả món 0 đồng hợp lệ.
        UPDATE dbo.SIZE_MON SET GiaBan=@Tien,TrangThaiSize='DangBan' WHERE MaMon=@Mon AND MaSize='S';
        INSERT dbo.CONG_THUC(MaCongThuc,MaMon,MaSize,TuLuc,DenLuc,TrangThai) VALUES(@CT,@Mon,'S','20260101','99991231','Nhap');
        INSERT dbo.CHI_TIET_CONG_THUC(MaCongThuc,MaHangHoa,DinhLuongCoSo,LoaiDinhLuong) VALUES(@CT,'HH_CAPHE',1,'CoDinh');
        UPDATE dbo.CONG_THUC SET TrangThai='KichHoat' WHERE MaCongThuc=@CT;
        UPDATE dbo.MON SET TrangThaiKinhDoanh='DangBan' WHERE MaMon=@Mon;
        -- Cấp dòng 1 và tăng bộ đếm 2 trong cùng transaction, không dùng MAX(STT)+1.
        INSERT dbo.DON_HANG(MaDonHang,ThoiDiemTao,MaBan,MaNVTao,STTDongKeTiep) VALUES(@DH,@ThoiDiem,'B01','N4_PV',2);
        INSERT dbo.CHI_TIET_DON_HANG(MaDonHang,STT,SoLuong,DonGiaTaiThoiDiemBan,TenMonTaiThoiDiemBan,MaCongThucApDung,MaSizeChon,LoaiDong,MaMon)
        VALUES(@DH,1,1,@Tien,@Ten,@CT,'S','Mua',@Mon);
        INSERT dbo.TIEU_HAO_DON_HANG(MaDonHang,STTDong,MaHangHoa,MaCongThuc,DinhLuongApDung,SoLuongMonApDung,SoLuongTieuHao,DonViTinhApDung)
        VALUES(@DH,1,'HH_CAPHE',@CT,1,1,1,N'g');
        INSERT dbo.THANH_TOAN(MaThanhToan,ThoiGianThanhToan,PhuongThuc,SoTienThanhToan,MaDonHang,MaNVThuNgan)
        VALUES(@TT,@ThoiDiem,@PT,@Tien,@DH,'N4_TN');
        INSERT dbo.HOA_DON(MaHoaDon,ThoiGianLap,TrangThaiHoaDon,MaThanhToan) VALUES(@HD,@ThoiDiem,'HieuLuc',@TT);
        INSERT dbo.PHIEU_KHO(MaPhieuKho,LoaiPhieu,ThoiDiemLap,TrangThaiPhieu,MaDonHang,NguonTao)
        VALUES(@PK,'XuatBan',@ThoiDiem,'Nhap',@DH,'HeThong');
        INSERT dbo.CHI_TIET_PHIEU_KHO(MaPhieuKho,STT,MaHangHoa,BienDongSoLuong) VALUES(@PK,1,'HH_CAPHE',-1);
        UPDATE dbo.PHIEU_KHO SET TrangThaiPhieu='DaGhiSo',ThoiDiemGhiSo=@ThoiDiem WHERE MaPhieuKho=@PK;
        UPDATE dbo.DON_HANG SET TrangThaiDonHang='DaThanhToan' WHERE MaDonHang=@DH;
        IF @i=1
        BEGIN
            -- Hủy/phát hành lại chỉ thay chứng từ, không thêm THANH_TOAN hoặc xuất kho.
            UPDATE dbo.HOA_DON SET TrangThaiHoaDon='DaHuy',ThoiGianHuy=DATEADD(SECOND,1,@ThoiDiem),LyDoHuy=N'In lại hóa đơn minh họa' WHERE MaHoaDon=@HD;
            INSERT dbo.HOA_DON(MaHoaDon,ThoiGianLap,TrangThaiHoaDon,MaThanhToan)
            VALUES('N4_H1_LAI',DATEADD(SECOND,2,@ThoiDiem),'HieuLuc',@TT);
        END;
        SET @i=@i+1;
    END;
END;
GO
