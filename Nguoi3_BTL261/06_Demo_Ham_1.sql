-- H0. Kiểm tra Hàm 1 của Người 5 đã được tạo trong CSDL kiểm thử.
SELECT DB_NAME() AS CSDL, name AS Ham
FROM sys.objects
WHERE object_id = OBJECT_ID(N'dbo.fn_N5_DemLuaChonTheoDanhMuc', N'FN');
GO

-- H1. Đối chiếu cây danh mục và các cấu hình size trong seed tích hợp.
SELECT MaDanhMuc, TenDanhMuc, MaDanhMucCha
FROM dbo.DANH_MUC_MON
WHERE MaDanhMuc IN ('DM_DOUONG', 'DM_CAPHE', 'DM_TRA', 'DM_DOAN', 'DM_TOPPING', 'DM_RONG')
ORDER BY MaDanhMucCha, MaDanhMuc;

SELECT m.MaDanhMuc, m.MaMon, m.LoaiMon, m.TrangThaiKinhDoanh,
       s.MaSize, s.TrangThaiSize
FROM dbo.MON AS m
LEFT JOIN dbo.SIZE_MON AS s ON s.MaMon = m.MaMon
WHERE m.MaDanhMuc IN ('DM_DOUONG', 'DM_CAPHE', 'DM_TRA', 'DM_DOAN', 'DM_TOPPING', 'DM_RONG')
ORDER BY m.MaDanhMuc, m.MaMon, s.MaSize;
GO

-- H2. Gọi hàm một lần cho mỗi ca và so kết quả, kể cả NULL.
DECLARE @Ca TABLE
(
    STT INT PRIMARY KEY,
    Ca NVARCHAR(100) NOT NULL,
    MaDanhMuc VARCHAR(30) NULL,
    KyVong BIGINT NULL
);
INSERT @Ca VALUES
(1, N'Đồ uống gồm các danh mục con', 'DM_DOUONG', 8),
(2, N'Trà chỉ tính món và size đang bán', 'DM_TRA', 5),
(3, N'Đồ ăn có một quy cách đang bán', 'DM_DOAN', 1),
(4, N'Topping được đếm theo cấu hình TC', 'DM_TOPPING', 2),
(5, N'Danh mục hợp lệ nhưng rỗng', 'DM_RONG', 0),
(6, N'Mã không tồn tại', 'KHONG_CO', NULL),
(7, N'Tham số NULL', NULL, NULL),
(8, N'Tham số chỉ có khoảng trắng', '  ', NULL);

DECLARE @KetQua TABLE
(
    STT INT PRIMARY KEY,
    ThucTe BIGINT NULL
);
INSERT @KetQua (STT, ThucTe)
SELECT STT, dbo.fn_N5_DemLuaChonTheoDanhMuc(MaDanhMuc) FROM @Ca;

SELECT c.Ca, QUOTENAME(c.MaDanhMuc, '''') AS DauVao, c.KyVong, k.ThucTe,
       CASE WHEN k.ThucTe = c.KyVong OR (k.ThucTe IS NULL AND c.KyVong IS NULL)
            THEN 'PASS' ELSE 'FAIL' END AS KetQua
FROM @Ca AS c
JOIN @KetQua AS k ON k.STT = c.STT
ORDER BY c.STT;

IF EXISTS
(
    SELECT STT, KyVong FROM @Ca
    EXCEPT
    SELECT STT, ThucTe FROM @KetQua
)
    THROW 51993, N'Demo Hàm 1 không khớp kỳ vọng của seed tích hợp.', 1;
GO
