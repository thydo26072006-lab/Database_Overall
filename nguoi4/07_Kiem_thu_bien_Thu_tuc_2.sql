/* NGƯỜI 4 | TASK 2.3.b: báo lỗi, khoảng rỗng, ngày biên, không sửa dữ liệu. */
EXEC dbo.usp_FIX_Test N'N4-P02 thiếu ngày bắt đầu',N'EXEC dbo.usp_N4_TongHopThucThuTheoNgay NULL,''20261117'';',51401;
EXEC dbo.usp_FIX_Test N'N4-P03 thiếu ngày kết thúc',N'EXEC dbo.usp_N4_TongHopThucThuTheoNgay ''20261114'',NULL;',51401;
EXEC dbo.usp_FIX_Test N'N4-P04 cả hai ngày NULL',N'EXEC dbo.usp_N4_TongHopThucThuTheoNgay NULL,NULL;',51401;
EXEC dbo.usp_FIX_Test N'N4-P05 đảo ngày',N'EXEC dbo.usp_N4_TongHopThucThuTheoNgay ''20261117'',''20261114'';',51401;
EXEC dbo.usp_FIX_Test N'N4-P06 ngày 19000101',N'
DECLARE @KQ TABLE(NgayThanhToan DATE,SoGiaoDich BIGINT,SoGiaoDichThuTien BIGINT,SoGiaoDichKhongThuTien BIGINT,TongTienThucThu DECIMAL(38,2));
INSERT @KQ EXEC dbo.usp_N4_TongHopThucThuTheoNgay ''19000101'',''19000101'';
IF (SELECT COUNT(*) FROM @KQ)<>1 OR EXISTS(SELECT 1 FROM @KQ WHERE NgayThanhToan<>''19000101'' OR SoGiaoDich<>0 OR SoGiaoDichThuTien<>0 OR SoGiaoDichKhongThuTien<>0 OR TongTienThucThu<>0)
THROW 51996,N''Sai kết quả ngày rỗng hoặc biên DATE'',1;';
EXEC dbo.usp_FIX_Test N'N4-P07 ngày 00010101',N'
DECLARE @KQ TABLE(NgayThanhToan DATE,SoGiaoDich BIGINT,SoGiaoDichThuTien BIGINT,SoGiaoDichKhongThuTien BIGINT,TongTienThucThu DECIMAL(38,2));
INSERT @KQ EXEC dbo.usp_N4_TongHopThucThuTheoNgay ''00010101'',''00010101'';
IF (SELECT COUNT(*) FROM @KQ)<>1 OR EXISTS(SELECT 1 FROM @KQ WHERE NgayThanhToan<>''00010101'' OR SoGiaoDich<>0 OR SoGiaoDichThuTien<>0 OR SoGiaoDichKhongThuTien<>0 OR TongTienThucThu<>0)
THROW 51996,N''Sai kết quả ngày rỗng hoặc biên DATE'',1;';
EXEC dbo.usp_FIX_Test N'N4-P08 ngày 99991231',N'
DECLARE @KQ TABLE(NgayThanhToan DATE,SoGiaoDich BIGINT,SoGiaoDichThuTien BIGINT,SoGiaoDichKhongThuTien BIGINT,TongTienThucThu DECIMAL(38,2));
INSERT @KQ EXEC dbo.usp_N4_TongHopThucThuTheoNgay ''99991231'',''99991231'';
IF (SELECT COUNT(*) FROM @KQ)<>1 OR EXISTS(SELECT 1 FROM @KQ WHERE NgayThanhToan<>''99991231'' OR SoGiaoDich<>0 OR SoGiaoDichThuTien<>0 OR SoGiaoDichKhongThuTien<>0 OR TongTienThucThu<>0)
THROW 51996,N''Sai kết quả ngày rỗng hoặc biên DATE'',1;';

GO
