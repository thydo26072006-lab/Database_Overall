/* NGUOI 1 - MUC 2.2.a VA 2.1.a
   Chay sau 01_Cau_truc.sql trong CSDL chung cua nhom.
   Bang CRUD chung: dbo.DANH_MUC_MON.
   BR04 / R03: danh muc co toi da mot cha va khong tao chu trinh.
*/
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

CREATE OR ALTER TRIGGER dbo.trg_N1_DanhMuc_KhongChuTrinh
ON dbo.DANH_MUC_MON
AFTER INSERT, UPDATE
AS
BEGIN
    IF ROWCOUNT_BIG() = 0 RETURN;
    SET NOCOUNT ON;

    -- Khoa bang den het giao dich, tranh hai phien cung tao vong lap.
    -- Bien bang chi ton tai trong lan chay trigger, khong them bang nghiep vu.
    DECLARE @ConLai TABLE
    (
        MaDanhMuc VARCHAR(30) COLLATE DATABASE_DEFAULT PRIMARY KEY,
        MaDanhMucCha VARCHAR(30) COLLATE DATABASE_DEFAULT NULL
    );

    INSERT INTO @ConLai (MaDanhMuc, MaDanhMucCha)
    SELECT MaDanhMuc, MaDanhMucCha
    FROM dbo.DANH_MUC_MON WITH (TABLOCKX, HOLDLOCK);

    -- Loai goc truoc, roi lan luot cac nut co cha da duoc loai.
    -- Neu con nut ma khong loai them duoc thi cac nut do phu thuoc vong.
    WHILE EXISTS (SELECT 1 FROM @ConLai)
    BEGIN
        DELETE c
        FROM @ConLai AS c
        WHERE c.MaDanhMucCha IS NULL
           OR NOT EXISTS
              (SELECT 1 FROM @ConLai AS p
               WHERE p.MaDanhMuc = c.MaDanhMucCha);

        IF @@ROWCOUNT = 0
            THROW 51010, N'Danh muc khong duoc tao chu trinh cha-con.', 1;
    END;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_N1_ThemDanhMuc
    @MaDanhMuc NVARCHAR(MAX),
    @TenDanhMuc NVARCHAR(MAX),
    @MaDanhMucCha NVARCHAR(MAX) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @SoGiaoDichBanDau INT = @@TRANCOUNT;
    DECLARE @DaLuuDiem BIT = 0;

    BEGIN TRY
        -- Nhan tham so rong de kiem tra truoc, tranh SQL Server cat ngan ma.
        SET @MaDanhMuc = TRIM(@MaDanhMuc);
        SET @TenDanhMuc = TRIM(@TenDanhMuc);
        SET @MaDanhMucCha = TRIM(@MaDanhMucCha);

        IF @MaDanhMuc IS NULL OR @MaDanhMuc = N''
            THROW 51001, N'Ma danh muc khong duoc de trong.', 1;

        IF @TenDanhMuc IS NULL OR @TenDanhMuc = N''
            THROW 51002, N'Ten danh muc khong duoc de trong.', 1;

        IF DATALENGTH(@TenDanhMuc) > 400
            THROW 51003, N'Ten danh muc vuot qua NVARCHAR(200).', 1;

        DECLARE @MaChuyenDoi VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @MaDanhMuc);
        DECLARE @MaChaChuyenDoi VARCHAR(MAX) = CONVERT(VARCHAR(MAX), @MaDanhMucCha);

        IF DATALENGTH(@MaChuyenDoi) > 30
           OR CONVERT(NVARCHAR(MAX), @MaChuyenDoi) COLLATE Latin1_General_100_BIN2
              <> @MaDanhMuc COLLATE Latin1_General_100_BIN2
            THROW 51004, N'Ma danh muc khong luu nguyen ven trong VARCHAR(30).', 1;

        IF @MaDanhMucCha IS NOT NULL
           AND (@MaDanhMucCha = N'' OR DATALENGTH(@MaChaChuyenDoi) > 30
                OR CONVERT(NVARCHAR(MAX), @MaChaChuyenDoi) COLLATE Latin1_General_100_BIN2
                   <> @MaDanhMucCha COLLATE Latin1_General_100_BIN2)
            THROW 51005, N'Ma cha phai la NULL hoac ma hop le trong VARCHAR(30).', 1;

        DECLARE @Ma VARCHAR(30) = CONVERT(VARCHAR(30), @MaChuyenDoi);
        DECLARE @MaCha VARCHAR(30) = CONVERT(VARCHAR(30), @MaChaChuyenDoi);

        IF @Ma = @MaCha
            THROW 51006, N'Danh muc khong duoc la cha cua chinh no.', 1;

        IF @SoGiaoDichBanDau = 0
            BEGIN TRANSACTION;
        ELSE
        BEGIN
            SAVE TRANSACTION N1_ThemDanhMuc;
            SET @DaLuuDiem = 1;
        END;

        -- Lay khoa truoc khi kiem tra va ghi, giu ca ba buoc trong mot giao dich.
        DECLARE @SoDanhMuc BIGINT;
        SELECT @SoDanhMuc = COUNT_BIG(*)
        FROM dbo.DANH_MUC_MON WITH (TABLOCKX, HOLDLOCK);

        IF EXISTS (SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = @Ma)
            THROW 51007, N'Ma danh muc da ton tai.', 1;

        IF @MaCha IS NOT NULL
           AND NOT EXISTS (SELECT 1 FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = @MaCha)
            THROW 51008, N'Danh muc cha chua ton tai.', 1;

        DECLARE @DanhMucVuaThem TABLE
        (
            MaDanhMuc VARCHAR(30),
            TenDanhMuc NVARCHAR(200),
            MaDanhMucCha VARCHAR(30)
        );

        INSERT INTO dbo.DANH_MUC_MON (MaDanhMuc, TenDanhMuc, MaDanhMucCha)
        OUTPUT inserted.MaDanhMuc, inserted.TenDanhMuc, inserted.MaDanhMucCha
        INTO @DanhMucVuaThem (MaDanhMuc, TenDanhMuc, MaDanhMucCha)
        VALUES (@Ma, CONVERT(NVARCHAR(200), @TenDanhMuc), @MaCha);

        -- Chi COMMIT giao dich do chinh thu tuc mo.
        IF @SoGiaoDichBanDau = 0
            COMMIT TRANSACTION;

        SELECT MaDanhMuc, TenDanhMuc, MaDanhMucCha
        FROM @DanhMucVuaThem;
    END TRY
    BEGIN CATCH
        IF @SoGiaoDichBanDau = 0 AND XACT_STATE() <> 0
            ROLLBACK TRANSACTION;
        ELSE IF @SoGiaoDichBanDau > 0 AND @DaLuuDiem = 1 AND XACT_STATE() = 1
            ROLLBACK TRANSACTION N1_ThemDanhMuc;

        -- Neu giao dich ngoai da bi loi (XACT_STATE=-1), ben goi phai ROLLBACK.
        THROW;
    END CATCH;
END;
GO
