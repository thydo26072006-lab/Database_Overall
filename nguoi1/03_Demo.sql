/* NGƯỜI 1 | TASK 1.1 demo bảng/CHECK; TASK 2.2.a demo Trigger 1; 2.1.a INSERT.
   Chụp màn hình DBMS gồm câu lệnh và kết quả thật của các nhóm dưới. */
SELECT DB_NAME() AS CSDL,@@VERSION AS PhienBan;
SELECT name FROM sys.tables WHERE schema_id=SCHEMA_ID('dbo') ORDER BY name;
SELECT OBJECT_NAME(parent_object_id) AS Bang,name,definition FROM sys.check_constraints ORDER BY Bang,name;
GO
EXEC dbo.usp_FIX_Test N'N1-CHECK giá âm',N'UPDATE dbo.SIZE_MON SET GiaBan=-1 WHERE MaMon=''CF_SUA'' AND MaSize=''S'';',547;
EXEC dbo.usp_FIX_Test N'N1-CHECK VND nguyên',N'UPDATE dbo.SIZE_MON SET GiaBan=100.5 WHERE MaMon=''CF_SUA'' AND MaSize=''S'';',547;
EXEC dbo.usp_FIX_Test N'N1-Thêm topping đúng mô hình',N'
INSERT dbo.MON(MaMon,TenMon,TrangThaiKinhDoanh,LoaiMon,MaDanhMuc) VALUES(''TP_DEMO'',N''Topping demo'',''NgungBan'',''Topping'',''DM_TOPPING'');
IF NOT EXISTS(SELECT 1 FROM dbo.SIZE_MON WHERE MaMon=''TP_DEMO'' AND MaSize=''TC'') THROW 51992,N''Thiếu TC'',1;';
EXEC dbo.usp_FIX_Test N'N1-INSERT danh mục cha/con',N'
EXEC dbo.usp_N1_ThemDanhMuc N''DM_TEST_CHA'',N''Cha'';
EXEC dbo.usp_N1_ThemDanhMuc N''DM_TEST_CON'',N''Con'',N''DM_TEST_CHA'';
IF NOT EXISTS (
    SELECT 1 FROM dbo.DANH_MUC_MON
    WHERE MaDanhMuc = ''DM_TEST_CON'' AND MaDanhMucCha = ''DM_TEST_CHA''
)
    THROW 51992, N''Thiếu danh mục con hoặc sai danh mục cha.'', 1;';
EXEC dbo.usp_FIX_Test N'N1-INSERT trùng mã',N'EXEC dbo.usp_N1_ThemDanhMuc N''DM_TRA'',N''Trùng'';',51007;
EXEC dbo.usp_FIX_Test N'N1-INSERT thiếu cha',N'EXEC dbo.usp_N1_ThemDanhMuc N''DM_TEST'',N''Thử'',N''KHONG_CO'';',51008;
EXEC dbo.usp_FIX_Test N'N1-INSERT mã quá dài',N'EXEC dbo.usp_N1_ThemDanhMuc N''1234567890123456789012345678901'',N''Thử'';',51004;
EXEC dbo.usp_FIX_Test N'N1-INSERT tên rỗng',N'EXEC dbo.usp_N1_ThemDanhMuc N''DM_TEST'',N''  '';',51002;
EXEC dbo.usp_FIX_Test N'N1-Trigger INSERT nhiều dòng tạo vòng',N'
INSERT dbo.DANH_MUC_MON(MaDanhMuc,TenDanhMuc,MaDanhMucCha) VALUES(''DM_C1'',N''C1'',''DM_C2''),(''DM_C2'',N''C2'',''DM_C1'');',51010;
EXEC dbo.usp_FIX_Test N'N1-Trigger UPDATE tạo vòng nhiều cấp',N'UPDATE dbo.DANH_MUC_MON SET MaDanhMucCha=''DM_TRA'' WHERE MaDanhMuc=''DM_DOUONG'';',51010;
EXEC dbo.usp_FIX_Test N'N1-DELETE danh mục rỗng', N'
DELETE dbo.DANH_MUC_MON WHERE MaDanhMuc = ''DM_RONG'';
IF @@ROWCOUNT <> 1
    THROW 51992, N''Phải xóa đúng một danh mục rỗng.'', 1;';
EXEC dbo.usp_FIX_Test N'N1-Không xóa cha còn con',N'DELETE dbo.DANH_MUC_MON WHERE MaDanhMuc=''DM_DOUONG'';',547;
EXEC dbo.usp_FIX_Test N'N1-Định lượng có thể thay đổi',N'
IF NOT EXISTS(SELECT 1 FROM dbo.CHI_TIET_CONG_THUC WHERE MaCongThuc=''CT_TRA_SUA_M'' AND MaHangHoa=''HH_DUONG'' AND LoaiDinhLuong=''CoTheThayDoi'') THROW 51992,N''Thiếu cấu hình'',1;';
EXEC dbo.usp_FIX_Test N'N1-Không dùng công cụ trong công thức',N'
INSERT dbo.CHI_TIET_CONG_THUC(MaCongThuc,MaHangHoa,DinhLuongCoSo) VALUES(''CT_TRA_SUA_M'',''HH_CONGCU'',1);',51414;
EXEC dbo.usp_FIX_Test N'N1-Công thức chồng hiệu lực',N'
INSERT dbo.CONG_THUC(MaCongThuc,MaMon,MaSize,TuLuc,DenLuc,TrangThai) VALUES(''CT_TEST'',''TRA_SUA'',''M'',''20261110'',''20261201'',''Nhap'');
INSERT dbo.CHI_TIET_CONG_THUC(MaCongThuc,MaHangHoa,DinhLuongCoSo) VALUES(''CT_TEST'',''HH_TRA'',10);
UPDATE dbo.CONG_THUC SET TrangThai=''KichHoat'' WHERE MaCongThuc=''CT_TEST'';',51411;
EXEC dbo.usp_FIX_Test N'N1-UPDATE đổi cha hợp lệ', N'
INSERT dbo.DANH_MUC_MON (MaDanhMuc, TenDanhMuc, MaDanhMucCha)
VALUES (''DM_N1_CHA_CU'', N''Cha cũ'', NULL),
       (''DM_N1_CHA_MOI'', N''Cha mới'', NULL),
       (''DM_N1_CON'', N''Danh mục con'', ''DM_N1_CHA_CU'');
SELECT N''Trước'' AS Moc, MaDanhMuc, MaDanhMucCha
FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = ''DM_N1_CON'';
UPDATE dbo.DANH_MUC_MON
SET MaDanhMucCha = ''DM_N1_CHA_MOI''
WHERE MaDanhMuc = ''DM_N1_CON'';
IF NOT EXISTS (
    SELECT 1 FROM dbo.DANH_MUC_MON
    WHERE MaDanhMuc = ''DM_N1_CON'' AND MaDanhMucCha = ''DM_N1_CHA_MOI''
)
    THROW 51992, N''Danh mục chưa được chuyển sang cha mới.'', 1;
SELECT N''Sau'' AS Moc, MaDanhMuc, MaDanhMucCha
FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = ''DM_N1_CON'';
';

EXEC dbo.usp_FIX_Test N'N1-INSERT mã cha trùng mã danh mục', N'
EXEC dbo.usp_N1_ThemDanhMuc
    N''DM_N1_TU_CHA'', N''Danh mục thử'', N''DM_N1_TU_CHA'';', 51006;
GO
