/* NGƯỜI 2 | TASK 2.2.b demo Trigger 2; 2.1.b UPDATE; bổ sung CHECK/BR. */
EXEC dbo.usp_FIX_Test N'N2-Trigger tạo S và TC nhiều dòng',N'
INSERT dbo.MON(MaMon,TenMon,TrangThaiKinhDoanh,LoaiMon,MaDanhMuc) VALUES
(''N2_NUOC'',N''Nước nháp'',''NgungBan'',''DoUong'',''DM_TRA''),(''N2_TOP'',N''Topping nháp'',''NgungBan'',''Topping'',''DM_TOPPING'');
IF (SELECT COUNT(*) FROM dbo.SIZE_MON WHERE (MaMon=''N2_NUOC'' AND MaSize=''S'') OR (MaMon=''N2_TOP'' AND MaSize=''TC''))<>2 THROW 51992,N''Sai size mặc định'',1;
SELECT * FROM dbo.SIZE_MON WHERE MaMon IN(''N2_NUOC'',''N2_TOP'');';
EXEC dbo.usp_FIX_Test N'N2-Topping không có size S',N'INSERT dbo.SIZE_MON(MaMon,MaSize,GiaBan,TrangThaiSize) VALUES(''TP_TRANCHAU'',''S'',5000,''DangBan'');',51213;
EXEC dbo.usp_FIX_Test N'N2-Món mới chưa được bật bán',N'INSERT dbo.MON(MaMon,TenMon,TrangThaiKinhDoanh,LoaiMon,MaDanhMuc) VALUES(''N2_BAD'',N''Sai'',''DangBan'',''DoUong'',''DM_TRA'');',51210;
EXEC dbo.usp_FIX_Test N'N2-Không ngừng size bán cuối',N'UPDATE dbo.SIZE_MON SET TrangThaiSize=''NgungBan'' WHERE MaMon=''TP_TRANCHAU'';',51212;
EXEC dbo.usp_FIX_Test N'N2-UPDATE tên và cha hợp lệ',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''DM_TRA'',N''Trà cập nhật'',N''DM_DOUONG'';';
EXEC dbo.usp_FIX_Test N'N2-UPDATE mã không có',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''KHONG_CO'',N''Thử'';',51203;
EXEC dbo.usp_FIX_Test N'N2-UPDATE tên quá dài',N'DECLARE @Ten NVARCHAR(MAX)=REPLICATE(N''x'',201); EXEC dbo.usp_N2_CapNhatDanhMuc N''DM_TRA'',@Ten;',51202;
EXEC dbo.usp_FIX_Test N'N2-UPDATE mã quá dài',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''1234567890123456789012345678901'',N''Thử'';',51206;
EXEC dbo.usp_FIX_Test N'N2-UPDATE tạo chu trình',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''DM_DOUONG'',N''Đồ uống'',N''DM_TRA'';',51010;
EXEC dbo.usp_FIX_Test N'N2-Lương không nhân theo số vai trò',N'IF (SELECT Luong FROM dbo.v_N2_LuongNhanVien WHERE MaNV=''NV01'')<>2400000 THROW 51992,N''Sai lương'',1; SELECT * FROM dbo.v_N2_LuongNhanVien;';
EXEC dbo.usp_FIX_Test N'N2-Số khách phải dương',N'
INSERT dbo.DON_HANG(MaDonHang,ThoiDiemTao,SoKhach,MaBan,MaNVTao) VALUES(''N2_DON'',''20261113 09:00'',0,''B01'',''NV01'');',547;
EXEC dbo.usp_FIX_Test N'N2-Giảm toàn đơn số lượng hưởng 0, topping trả đủ',N'
INSERT dbo.DON_HANG(MaDonHang,ThoiDiemTao,MaBan,MaNVTao,STTDongKeTiep) VALUES(''N2_DON'',''20261113 09:00'',''B01'',''NV01'',3);
INSERT dbo.CHI_TIET_DON_HANG(MaDonHang,STT,SoLuong,DonGiaTaiThoiDiemBan,TenMonTaiThoiDiemBan,MaCongThucApDung,MaSizeChon,LoaiDong,MaMon,STTDongMonChinh) VALUES
(''N2_DON'',1,2,30000,N''Trà sữa'',''CT_TRA_SUA_M'',''M'',''Mua'',''TRA_SUA'',NULL),
(''N2_DON'',2,2,5000,N''Trân châu'',''CT_TP_TRANCHAU_TC'',''TC'',''Topping'',''TP_TRANCHAU'',1);
UPDATE dbo.DON_HANG SET TrangThaiUuDai=''DaXacNhan'',MaKMChot=''KM_GIAM10'',STTDieuKienChot=1,ThoiDiemXacNhanKM=''20261113 09:01'',MaNVXacNhanKM=''NV02'' WHERE MaDonHang=''N2_DON'';
INSERT dbo.AP_DUNG_KM(MaDonHang,STTApDung,SoLuongHuongUuDai,SoTienGiam,NoiDungApDung,ThoiDiemApDung,LoaiApDung,TrangThaiApDung,MaKM,STTDieuKien)
VALUES(''N2_DON'',1,0,6000,N''10% trên 60.000 tiền nước; topping 10.000 trả đủ'',''20261113 09:01'',''ToanDon'',''DaXacNhan'',''KM_GIAM10'',1);
IF (SELECT SUM(SoLuong*DonGiaTaiThoiDiemBan) FROM dbo.CHI_TIET_DON_HANG WHERE MaDonHang=''N2_DON'')<>70000 THROW 51992,N''Tổng đơn sai'',1;
SELECT * FROM dbo.AP_DUNG_KM WHERE MaDonHang=''N2_DON'';';
EXEC dbo.usp_FIX_Test N'N2-Đổi số ly cập nhật phần topping; lượng đường 0 hợp lệ',N'
INSERT dbo.DON_HANG(MaDonHang,ThoiDiemTao,MaBan,MaNVTao,STTDongKeTiep) VALUES(''N2_DON'',''20261113 09:00'',''B01'',''NV01'',3);
INSERT dbo.CHI_TIET_DON_HANG(MaDonHang,STT,SoLuong,DonGiaTaiThoiDiemBan,TenMonTaiThoiDiemBan,MaCongThucApDung,MaSizeChon,LoaiDong,MaMon,STTDongMonChinh) VALUES
(''N2_DON'',1,2,30000,N''Trà sữa'',''CT_TRA_SUA_M'',''M'',''Mua'',''TRA_SUA'',NULL),
(''N2_DON'',2,2,5000,N''Trân châu'',''CT_TP_TRANCHAU_TC'',''TC'',''Topping'',''TP_TRANCHAU'',1);
UPDATE dbo.CHI_TIET_DON_HANG SET SoLuong=3 WHERE MaDonHang=''N2_DON'' AND STT=1;
IF (SELECT SoLuong FROM dbo.CHI_TIET_DON_HANG WHERE MaDonHang=''N2_DON'' AND STT=2)<>3 THROW 51992,N''Sai số phần'',1;
INSERT dbo.TIEU_HAO_DON_HANG(MaDonHang,STTDong,MaHangHoa,MaCongThuc,DinhLuongApDung,SoLuongMonApDung,SoLuongTieuHao,DonViTinhApDung)
VALUES(''N2_DON'',1,''HH_DUONG'',''CT_TRA_SUA_M'',0,3,0,N''g'');';
EXEC dbo.usp_FIX_Test N'N2-Ca chồng cùng nhân viên',N'
INSERT dbo.CA_LAM(MaCa,NgayLam,GioBatDau,GioKetThuc) VALUES(''N2_CHONG'',''20261113'',''11:00'',''14:00'');
INSERT dbo.LAM_VIEC(MaNV,MaCa) VALUES(''NV01'',''N2_CHONG'');',51402;
EXEC dbo.usp_FIX_Test N'N2-Ca tiếp giáp hợp lệ',N'
INSERT dbo.CA_LAM(MaCa,NgayLam,GioBatDau,GioKetThuc) VALUES(''N2_TIEP'',''20261113'',''12:00'',''13:00'');
INSERT dbo.LAM_VIEC(MaNV,MaCa) VALUES(''NV01'',''N2_TIEP'');';
EXEC dbo.usp_FIX_Test N'N2-Sửa giờ ca phải kiểm lại lịch',N'
INSERT dbo.LAM_VIEC(MaNV,MaCa) VALUES(''NV01'',''CA_1311_CHIEU'');
UPDATE dbo.CA_LAM SET GioBatDau=''11:00'' WHERE MaCa=''CA_1311_CHIEU'';',51402;
EXEC dbo.usp_FIX_Test N'N2-Vượt số bàn trong ca',N'INSERT dbo.PHAN_CONG(MaNV,MaBan,MaCa) VALUES(''NV01'',''B03'',''CA_1311_SANG'');',51405;
EXEC dbo.usp_FIX_Test N'N2-Phiếu đã ghi sổ bất biến',N'UPDATE dbo.PHIEU_KHO SET TrangThaiPhieu=''DaHuy'',ThoiDiemGhiSo=NULL WHERE MaPhieuKho=''PK_MO_SO'';',51422;
EXEC dbo.usp_FIX_Test N'N2-Chi tiết phiếu đã ghi sổ bất biến',N'UPDATE dbo.CHI_TIET_PHIEU_KHO SET BienDongSoLuong=11 WHERE MaPhieuKho=''PK_MO_SO'' AND MaHangHoa=''HH_KIEMTHU'';',51420;
EXEC dbo.usp_FIX_Test N'N2-Phiếu xuất sai dấu',N'
INSERT dbo.PHIEU_KHO(MaPhieuKho,LoaiPhieu,ThoiDiemLap,TrangThaiPhieu,NguoiLap,NguonTao) VALUES(''N2_XUAT'',''XuatHuy'',''20261115'',''Nhap'',''NVKHO'',''ThuCong'');
INSERT dbo.CHI_TIET_PHIEU_KHO(MaPhieuKho,STT,MaHangHoa,BienDongSoLuong) VALUES(''N2_XUAT'',1,''HH_KIEMTHU'',1);',51421;
EXEC dbo.usp_FIX_Test N'N2-Ghi sổ xuất vượt tồn bị chặn',N'
INSERT dbo.PHIEU_KHO(MaPhieuKho,LoaiPhieu,ThoiDiemLap,TrangThaiPhieu,NguoiLap,NguonTao) VALUES(''N2_XUAT'',''XuatHuy'',''20261115'',''Nhap'',''NVKHO'',''ThuCong'');
INSERT dbo.CHI_TIET_PHIEU_KHO(MaPhieuKho,STT,MaHangHoa,BienDongSoLuong) VALUES(''N2_XUAT'',1,''HH_KIEMTHU'',-9);
UPDATE dbo.PHIEU_KHO SET TrangThaiPhieu=''DaGhiSo'',ThoiDiemGhiSo=''20261115'',NguoiDuyet=''QL01'',ThoiDiemDuyet=''20261115'' WHERE MaPhieuKho=''N2_XUAT'';',51428;
EXEC dbo.usp_FIX_Test N'N2-Combo không dùng topping làm quà',N'UPDATE dbo.COMBO SET MaMonTang=''TP_TRANCHAU'',MaSizeTang=''TC'' WHERE MaKM=''KM_COMBO'';',51440;
GO

