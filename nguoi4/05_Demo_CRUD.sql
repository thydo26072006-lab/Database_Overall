/* NGƯỜI 4 | TASK 2.1 DEMO CRUD nhận đúng mã Người 1/2/3.
   Không cài bản CRUD cũ; dùng usp_N1_ThemDanhMuc, usp_N2_CapNhatDanhMuc,
   usp_N3_XoaDanhMuc và trigger hiện có trong bộ fix 30 bảng.
   Mỗi ca có transaction riêng và hoàn tác trước ca tiếp theo, không phụ thuộc fixture.
*/
EXEC dbo.usp_FIX_Test N'N4-C01 luồng INSERT-UPDATE-DELETE hợp lệ',N'
EXEC dbo.usp_N1_ThemDanhMuc N''N4_CRUD_A'',N''Gốc A'';
EXEC dbo.usp_N1_ThemDanhMuc N''N4_CRUD_B'',N''Con B'',N''N4_CRUD_A'';
SELECT N''Sau INSERT'' AS Buoc,* FROM dbo.DANH_MUC_MON WHERE MaDanhMuc IN(''N4_CRUD_A'',''N4_CRUD_B'');
EXEC dbo.usp_N2_CapNhatDanhMuc N''N4_CRUD_B'',N''Đổi tên và tách cha'',NULL;
IF NOT EXISTS(SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc=''N4_CRUD_B'' AND TenDanhMuc=N''Đổi tên và tách cha'' AND MaDanhMucCha IS NULL) THROW 51996,N''UPDATE sai'',1;
SELECT N''Sau UPDATE'' AS Buoc,* FROM dbo.DANH_MUC_MON WHERE MaDanhMuc IN(''N4_CRUD_A'',''N4_CRUD_B'');
EXEC dbo.usp_N3_XoaDanhMuc N''N4_CRUD_B'';
EXEC dbo.usp_N3_XoaDanhMuc N''N4_CRUD_A'';
IF EXISTS(SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc IN(''N4_CRUD_A'',''N4_CRUD_B'')) THROW 51996,N''DELETE sai'',1;';
EXEC dbo.usp_FIX_Test N'N4-C02 INSERT trùng mã',N'EXEC dbo.usp_N1_ThemDanhMuc N''DM_TRA'',N''Trùng'';',51007;
EXEC dbo.usp_FIX_Test N'N4-C03 INSERT thiếu cha',N'EXEC dbo.usp_N1_ThemDanhMuc N''N4_CRUD_A'',N''Thử'',N''N4_KHONG_CO'';',51008;
EXEC dbo.usp_FIX_Test N'N4-C04 INSERT mã rỗng',N'EXEC dbo.usp_N1_ThemDanhMuc N'''',N''Thử'';',51001;
EXEC dbo.usp_FIX_Test N'N4-C05 UPDATE tạo chu trình',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''DM_DOUONG'',N''Đồ uống'',N''DM_TRA'';',51010;
EXEC dbo.usp_FIX_Test N'N4-C06 UPDATE mã không tồn tại',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''N4_KHONG_CO'',N''Thử'';',51203;
EXEC dbo.usp_FIX_Test N'N4-C07 UPDATE tên rỗng',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''DM_TRA'',N'''';',51202;
EXEC dbo.usp_FIX_Test N'N4-C08 UPDATE cha không tồn tại',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''DM_TRA'',N''Trà'',N''N4_KHONG_CO'';',51205;
EXEC dbo.usp_FIX_Test N'N4-C09 DELETE danh mục có con',N'EXEC dbo.usp_N3_XoaDanhMuc N''DM_DOUONG'';',51303;
EXEC dbo.usp_FIX_Test N'N4-C10 DELETE danh mục có món',N'EXEC dbo.usp_N3_XoaDanhMuc N''DM_TRA'';',51303;
EXEC dbo.usp_FIX_Test N'N4-C11 DELETE mã không tồn tại',N'EXEC dbo.usp_N3_XoaDanhMuc N''N4_KHONG_CO'';',51302;
EXEC dbo.usp_FIX_Test N'N4-C12 DELETE mã rỗng',N'EXEC dbo.usp_N3_XoaDanhMuc N'''';',51301;
EXEC dbo.usp_FIX_Test N'N4-C13 INSERT mã quá dài không cắt ngầm',N'EXEC dbo.usp_N1_ThemDanhMuc N''1234567890123456789012345678901'',N''Thử'';',51004;
EXEC dbo.usp_FIX_Test N'N4-C14 UPDATE mã quá dài không cắt ngầm',N'EXEC dbo.usp_N2_CapNhatDanhMuc N''1234567890123456789012345678901'',N''Thử'';',51206;
EXEC dbo.usp_FIX_Test N'N4-C15 DELETE mã quá dài không cắt ngầm',N'EXEC dbo.usp_N3_XoaDanhMuc N''1234567890123456789012345678901'';',51301;
IF EXISTS(SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc IN('N4_CRUD_A','N4_CRUD_B')) OR @@TRANCOUNT<>0
    THROW 51996,N'Demo CRUD để lại dữ liệu/giao dịch.',1;
GO
