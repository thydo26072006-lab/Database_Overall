CREATE OR ALTER PROCEDURE dbo.usp_N3_XoaDanhMuc
    @MaDanhMuc NVARCHAR(MAX)
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        SET @MaDanhMuc = LTRIM(RTRIM(@MaDanhMuc));
        IF NULLIF(@MaDanhMuc, N'') IS NULL
            THROW 51301, N'Mã danh mục không được để trống.', 1;

        DECLARE @MaChuyenDoi VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @MaDanhMuc);
        IF DATALENGTH(@MaChuyenDoi) > 30
           OR CONVERT(NVARCHAR(MAX), @MaChuyenDoi) COLLATE Latin1_General_100_BIN2
              <> @MaDanhMuc COLLATE Latin1_General_100_BIN2
            THROW 51301, N'Mã danh mục phải lưu được nguyên vẹn trong VARCHAR(30).', 1;

        DECLARE @Ma VARCHAR(30) = CONVERT(VARCHAR(30), @MaChuyenDoi);
        DECLARE @DaXoa TABLE
        (
            MaDanhMuc VARCHAR(30),
            TenDanhMuc NVARCHAR(200),
            MaDanhMucCha VARCHAR(30)
        );

        -- Điều kiện và thao tác xóa nằm trong cùng câu lệnh.
        DELETE dm
        OUTPUT deleted.MaDanhMuc, deleted.TenDanhMuc, deleted.MaDanhMucCha
        INTO @DaXoa (MaDanhMuc, TenDanhMuc, MaDanhMucCha)
        FROM dbo.DANH_MUC_MON AS dm
        WHERE dm.MaDanhMuc = @Ma
          AND NOT EXISTS (SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMucCha = @Ma)
          AND NOT EXISTS (SELECT 1 FROM dbo.MON WHERE MaDanhMuc = @Ma);

        IF @@ROWCOUNT = 0
        BEGIN
            IF NOT EXISTS (SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = @Ma)
                THROW 51302, N'Không tìm thấy danh mục cần xóa.', 1;
            THROW 51303, N'Không thể xóa danh mục đang có danh mục con hoặc món.', 1;
        END;

        SELECT MaDanhMuc, TenDanhMuc, MaDanhMucCha FROM @DaXoa;
    END TRY
    BEGIN CATCH
        -- Khóa ngoại tiếp tục bảo vệ khi có tham chiếu phát sinh đồng thời.
        IF ERROR_NUMBER() = 547
            THROW 51303, N'Không thể xóa danh mục đang được tham chiếu.', 1;
        THROW;
    END CATCH;
END;
GO
