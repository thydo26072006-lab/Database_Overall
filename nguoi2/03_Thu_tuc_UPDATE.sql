/* NGƯỜI 2 | TASK 2.1.b UPDATE | CRUD chung dbo.DANH_MUC_MON.
   Nhận tham số rộng, kiểm độ dài trước chuyển kiểu; khóa trước kiểm tra/ghi.
   Trigger 1 tiếp tục bảo vệ chu trình nhiều cấp. */
CREATE OR ALTER PROCEDURE dbo.usp_N2_CapNhatDanhMuc
    @MaDanhMuc NVARCHAR(MAX),
    @TenDanhMuc NVARCHAR(MAX),
    @MaDanhMucCha NVARCHAR(MAX)=NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @TranDau INT=@@TRANCOUNT,@Save BIT=0;
    BEGIN TRY
        SET @MaDanhMuc=LTRIM(RTRIM(@MaDanhMuc));
        SET @TenDanhMuc=LTRIM(RTRIM(@TenDanhMuc));
        SET @MaDanhMucCha=LTRIM(RTRIM(@MaDanhMucCha));
        IF NULLIF(@MaDanhMuc,N'') IS NULL THROW 51201,N'Mã danh mục không được rỗng.',1;
        IF NULLIF(@TenDanhMuc,N'') IS NULL OR DATALENGTH(@TenDanhMuc)>400
            THROW 51202,N'Tên phải có nội dung và không vượt NVARCHAR(200).',1;
        DECLARE @M VARCHAR(MAX)=CONVERT(VARCHAR(MAX),@MaDanhMuc),@P VARCHAR(MAX)=CONVERT(VARCHAR(MAX),@MaDanhMucCha);
        IF DATALENGTH(@M)>30 OR CONVERT(NVARCHAR(MAX),@M) COLLATE Latin1_General_100_BIN2<>@MaDanhMuc COLLATE Latin1_General_100_BIN2
            THROW 51206,N'Mã không lưu nguyên vẹn trong VARCHAR(30).',1;
        IF @MaDanhMucCha IS NOT NULL AND (@MaDanhMucCha=N'' OR DATALENGTH(@P)>30 OR CONVERT(NVARCHAR(MAX),@P) COLLATE Latin1_General_100_BIN2<>@MaDanhMucCha COLLATE Latin1_General_100_BIN2)
            THROW 51206,N'Mã cha không lưu nguyên vẹn trong VARCHAR(30).',1;
        DECLARE @Ma VARCHAR(30)=@M,@Cha VARCHAR(30)=@P;
        IF @Ma=@Cha THROW 51204,N'Danh mục không thể là cha chính nó.',1;
        IF @TranDau=0 BEGIN TRANSACTION;
        ELSE BEGIN SAVE TRANSACTION N2_Update; SET @Save=1; END;
        DECLARE @So BIGINT;
        SELECT @So=COUNT_BIG(*) FROM dbo.DANH_MUC_MON WITH(TABLOCKX,HOLDLOCK);
        IF NOT EXISTS(SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc=@Ma)
            THROW 51203,N'Không tìm thấy danh mục.',1;
        IF @Cha IS NOT NULL AND NOT EXISTS(SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc=@Cha)
            THROW 51205,N'Không tìm thấy danh mục cha.',1;
        DECLARE @KetQua TABLE(MaDanhMuc VARCHAR(30),TenDanhMuc NVARCHAR(200),MaDanhMucCha VARCHAR(30));
        UPDATE dbo.DANH_MUC_MON SET TenDanhMuc=CONVERT(NVARCHAR(200),@TenDanhMuc),MaDanhMucCha=@Cha
        OUTPUT inserted.MaDanhMuc,inserted.TenDanhMuc,inserted.MaDanhMucCha INTO @KetQua
        WHERE MaDanhMuc=@Ma;
        IF @TranDau=0 COMMIT TRANSACTION;
        SELECT * FROM @KetQua;
    END TRY
    BEGIN CATCH
        IF @TranDau=0 AND XACT_STATE()<>0 ROLLBACK TRANSACTION;
        ELSE IF @TranDau>0 AND @Save=1 AND XACT_STATE()=1 ROLLBACK TRANSACTION N2_Update;
        THROW;
    END CATCH;
END;
GO

