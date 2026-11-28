-- N5-17. Chạy trong CSDL đã nạp bằng hai script ở database/README.md.
-- Kiểm tra metadata. Không thay đổi bảng nghiệp vụ hoặc dữ liệu mẫu.
SET NOCOUNT ON;

DECLARE @YeuCau TABLE (
    TenDoiTuong SYSNAME NOT NULL PRIMARY KEY,
    Loai CHAR(2) NOT NULL,
    BangGanTrigger SYSNAME NULL
);

INSERT @YeuCau (TenDoiTuong, Loai, BangGanTrigger)
VALUES
    (N'AP_DUNG_KM', 'U', NULL),
    (N'BAN', 'U', NULL),
    (N'CA_LAM', 'U', NULL),
    (N'CHI_TIET_CONG_THUC', 'U', NULL),
    (N'CHI_TIET_DON_HANG', 'U', NULL),
    (N'CHI_TIET_PHIEU_KHO', 'U', NULL),
    (N'CHINH_SACH_DIEM', 'U', NULL),
    (N'COMBO', 'U', NULL),
    (N'CONG_THUC', 'U', NULL),
    (N'DANH_GIA', 'U', NULL),
    (N'DANH_GIA_NHAN_VIEN', 'U', NULL),
    (N'DANH_MUC_MON', 'U', NULL),
    (N'DIEU_KIEN_KM', 'U', NULL),
    (N'DON_HANG', 'U', NULL),
    (N'HANG_HOA', 'U', NULL),
    (N'HOA_DON', 'U', NULL),
    (N'KHACH_HANG', 'U', NULL),
    (N'KHUYEN_MAI', 'U', NULL),
    (N'LAM_VIEC', 'U', NULL),
    (N'LIEN_HE_NHAN_VIEN', 'U', NULL),
    (N'MON', 'U', NULL),
    (N'NHAN_VIEN', 'U', NULL),
    (N'PHAN_CONG', 'U', NULL),
    (N'PHIEU_KHO', 'U', NULL),
    (N'PHUC_VU', 'U', NULL),
    (N'QUAN_LY', 'U', NULL),
    (N'SIZE_MON', 'U', NULL),
    (N'THANH_TOAN', 'U', NULL),
    (N'THU_NGAN', 'U', NULL),
    (N'TIEU_HAO_DON_HANG', 'U', NULL),
    (N'usp_N1_ThemDanhMuc', 'P', NULL),
    (N'usp_N2_CapNhatDanhMuc', 'P', NULL),
    (N'usp_N3_XoaDanhMuc', 'P', NULL),
    (N'trg_N2_Mon_TaoSizeMacDinh', 'TR', N'MON'),
    (N'trg_N2_Size_DungLoai', 'TR', N'SIZE_MON'),
    (N'usp_N3_TongHopPhanCongTheoCa', 'P', NULL),
    (N'fn_N5_DemLuaChonTheoDanhMuc', 'FN', NULL),
    (N'fn_N5_TonKhoDenThoiDiem', 'FN', NULL);

DECLARE @KetQua TABLE (
    TenDoiTuong SYSNAME NOT NULL PRIMARY KEY,
    Loai CHAR(2) NOT NULL,
    BangGanTrigger SYSNAME NULL,
    TrangThai NVARCHAR(80) NOT NULL
);

INSERT @KetQua (TenDoiTuong, Loai, BangGanTrigger, TrangThai)
SELECT
    y.TenDoiTuong,
    y.Loai,
    y.BangGanTrigger,
    CASE
        WHEN o.object_id IS NULL THEN N'THIẾU HOẶC SAI SCHEMA'
        WHEN o.type COLLATE DATABASE_DEFAULT <> y.Loai THEN N'SAI LOẠI'
        WHEN y.Loai = 'TR' AND t.is_disabled = 1 THEN N'TRIGGER BỊ TẮT'
        WHEN y.Loai = 'TR' AND (
            t.parent_class <> 1 OR p.object_id IS NULL
            OR p.type <> 'U' OR p.name COLLATE DATABASE_DEFAULT <> y.BangGanTrigger
        ) THEN N'SAI BẢNG GẮN TRIGGER'
        ELSE N'ĐẠT'
    END
FROM @YeuCau AS y
LEFT JOIN sys.objects AS o
    ON o.schema_id = SCHEMA_ID(N'dbo') AND o.is_ms_shipped = 0
    AND o.name COLLATE DATABASE_DEFAULT = y.TenDoiTuong
LEFT JOIN sys.triggers AS t ON t.object_id = o.object_id
LEFT JOIN sys.objects AS p
    ON p.object_id = t.parent_id AND p.schema_id = SCHEMA_ID(N'dbo');

SELECT
    N'dbo.' + TenDoiTuong AS DoiTuong,
    CASE Loai
        WHEN 'U' THEN N'Bảng'
        WHEN 'P' THEN N'Thủ tục'
        WHEN 'TR' THEN N'Trigger'
        WHEN 'FN' THEN N'Hàm vô hướng'
    END AS LoaiYeuCau,
    CASE WHEN BangGanTrigger IS NOT NULL THEN N'dbo.' + BangGanTrigger END AS BangGanTrigger,
    TrangThai
FROM @KetQua
ORDER BY CASE Loai WHEN 'U' THEN 1 WHEN 'P' THEN 2 WHEN 'TR' THEN 3 ELSE 4 END, TenDoiTuong;

DECLARE @SoBang INT = (SELECT COUNT(*) FROM sys.tables WHERE is_ms_shipped = 0);
DECLARE @SoLoi INT = (SELECT COUNT(*) FROM @KetQua WHERE TrangThai <> N'ĐẠT');

SELECT DB_NAME() AS CSDL, @SoBang AS SoBangThucTe, 30 AS SoBangYeuCau, @SoLoi AS SoDoiTuongLoi;

IF @SoBang <> 30 OR @SoLoi <> 0
    THROW 51700, N'Kiểm tra đối tượng Phần 2 thất bại. Xem kết quả và số bảng ở trên.', 1;

PRINT N'ĐẠT: 30 bảng, 4 thủ tục, 2 trigger đang bật và 2 hàm vô hướng.';
