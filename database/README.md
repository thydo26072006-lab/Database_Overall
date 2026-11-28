# Nạp cơ sở dữ liệu thử BTL2_P3_DEMO

Dùng một instance SQL Server 2022 trở lên và tài khoản Windows có quyền tạo cơ sở dữ liệu. Hai tệp SQL được lưu nguyên bản từ các nhánh nguồn.

| Thứ tự | Tệp | Nguồn và tác dụng |
| --- | --- | --- |
| 1 | [BTL2_SQL_TONG_HOP.sql](BTL2_SQL_TONG_HOP.sql) | `main@de645fa`. Mặc định tạo `BTL2_FIX_12345`. Bản tạm sẽ đổi đích sang `BTL2_P3_DEMO` trước khi nạp cấu trúc 30 bảng, đối tượng SQL và dữ liệu mẫu. |
| 2 | [02_Trigger_INSERT.sql](02_Trigger_INSERT.sql) | `nguoi1@8d01b11`. Cập nhật trigger chống vòng lặp danh mục và thủ tục thêm danh mục. Chạy trong `BTL2_P3_DEMO`. |

## Nạp bằng PowerShell và sqlcmd

Chạy từ thư mục gốc của bản checkout Người 5. Đổi `$btl2SqlInstance` theo instance của máy. Lệnh dưới dùng xác thực Windows. Cờ `-C` dành cho môi trường thử local dùng chứng chỉ tự ký.

```powershell
$btl2SqlInstance = 'localhost\YUSHINOMI'
$btl2DbName = 'BTL2_P3_DEMO'
$btl2Source = (Resolve-Path -LiteralPath '.\database\BTL2_SQL_TONG_HOP.sql').Path
$btl2TempSql = [IO.Path]::GetTempFileName()
try {
    $btl2SqlText = [IO.File]::ReadAllText($btl2Source, [Text.Encoding]::UTF8)
    [IO.File]::WriteAllText($btl2TempSql,
        $btl2SqlText.Replace('BTL2_FIX_12345', $btl2DbName), [Text.UTF8Encoding]::new($false))

    sqlcmd -S $btl2SqlInstance -E -C -d master -b -f 65001 -i $btl2TempSql
    if ($LASTEXITCODE -ne 0) { throw 'Script tổng hợp thất bại. Dừng trước khi chạy script Người 1.' }

    sqlcmd -S $btl2SqlInstance -E -C -d $btl2DbName -b -f 65001 -i '.\database\02_Trigger_INSERT.sql'
    if ($LASTEXITCODE -ne 0) { throw 'Script Người 1 thất bại.' }
} finally {
    Remove-Item -LiteralPath $btl2TempSql
}
```

Script tổng hợp dừng nếu `BTL2_P3_DEMO` đã tồn tại. Nếu cơ sở dữ liệu hiện có đã được nạp đủ hai script, tiếp tục dùng cơ sở dữ liệu đó. Khi cần dựng một CSDL thử riêng, đổi `$btl2DbName` thành tên mới chỉ gồm chữ cái ASCII, số và dấu gạch dưới, bắt đầu bằng chữ cái. Hai lệnh sẽ dùng cùng tên đích.

## Nạp bằng SSMS

1. Mở `BTL2_SQL_TONG_HOP.sql` trong cửa sổ truy vấn mới, kết nối đúng instance và chọn `master`. Trong cửa sổ truy vấn, thay toàn bộ `BTL2_FIX_12345` bằng `BTL2_P3_DEMO`, rồi chạy toàn bộ nội dung. Giữ nguyên tệp nguồn trên đĩa. Nếu có lỗi, xem thẻ **Messages** và dừng trước bước 2.
2. Mở `02_Trigger_INSERT.sql` trong cửa sổ truy vấn mới. Chọn `BTL2_P3_DEMO` ở danh sách cơ sở dữ liệu rồi chạy toàn bộ tệp.
3. Trong cửa sổ truy vấn ở `BTL2_P3_DEMO`, chạy kiểm tra nhanh bên dưới.

## Kiểm tra nhanh sau khi nạp

```sql
SELECT DB_NAME() AS CSDL;
SELECT COUNT(*) AS SoBang FROM sys.tables WHERE is_ms_shipped = 0;
SELECT
    (SELECT COUNT(*) FROM dbo.DANH_MUC_MON) AS SoDanhMuc,
    (SELECT COUNT(*) FROM dbo.MON) AS SoMon,
    (SELECT COUNT(*) FROM dbo.SIZE_MON) AS SoSize;

EXEC dbo.usp_N3_TongHopPhanCongTheoCa
    @TuNgay = '20261113', @DenNgay = '20261113';
```

Dữ liệu mẫu mới nạp có 30 bảng, 6 danh mục, 7 món, 13 size và 2 ca ngày 13/11/2026. Sau khi xác nhận, đặt `DB_NAME=BTL2_P3_DEMO` trong `backend/.env` và dùng cấu hình kết nối theo [tệp mẫu](../backend/.env.example).

## Kiểm tra đối tượng Phần 2

Sau khi nạp hai script, chạy [03_Kiem_tra_doi_tuong_Phan2.sql](03_Kiem_tra_doi_tuong_Phan2.sql) trong CSDL đích. Script chỉ đọc metadata và cần tài khoản nhìn thấy metadata của toàn bộ đối tượng trong CSDL. Kết quả đạt gồm 30 bảng, 4 thủ tục, 2 trigger đang bật và 2 hàm vô hướng. Khi sai tên, loại, số bảng hoặc trạng thái trigger, SQL Server trả lỗi `51700` và `sqlcmd -b` thoát với mã khác 0.

```powershell
sqlcmd -S 'localhost\YUSHINOMI' -E -C -d BTL2_P3_DEMO -b -f 65001 -i '.\database\03_Kiem_tra_doi_tuong_Phan2.sql'
```

Trong SSMS, chọn CSDL đích trước khi chạy toàn bộ tệp.

## Dựng lại dữ liệu demo trước buổi trình bày

Dùng [Khoi_Tao_Du_Lieu_Demo.ps1](Khoi_Tao_Du_Lieu_Demo.ps1) để dựng một CSDL sạch dưới tên mới. Script chạy hai tệp SQL theo thứ tự, kiểm tra 38 đối tượng, số lượng dữ liệu mẫu và hai kết quả hàm. Nếu tên CSDL đã tồn tại, script dừng ở bước đầu và giữ dữ liệu của CSDL đó.

Từ thư mục gốc của bản checkout Người 5, chạy PowerShell với tài khoản có quyền tạo CSDL. Đổi instance theo máy đang dùng. Tham số `-TrustServerCertificate` dành cho instance thử cục bộ dùng chứng chỉ tự ký.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File '.\database\Khoi_Tao_Du_Lieu_Demo.ps1' -Instance 'localhost\YUSHINOMI' -TrustServerCertificate
```

1. Chờ dòng `Demo database is ready. DB_NAME=...`. Tên mặc định có hậu tố tự sinh. Có thể dùng `-DatabaseName BTL2_P3_DEMO_20261127` để chọn tên mới dễ nhận biết.
2. Ghi lại `DB_NAME` hiện tại, dừng backend bằng `Ctrl+C`, rồi đặt `DB_NAME` trong `backend/.env` theo tên script vừa in. Từ thư mục `backend`, chạy `npm start`. Khi PowerShell có biến môi trường `DB_NAME`, đặt lại biến đó cùng tên mới hoặc mở một phiên sạch để backend đọc `.env`.
3. Kiểm tra `GET /api/health` và mở ba màn hình nghiệp vụ. Dữ liệu sạch có 6 danh mục, 7 món, 13 size và 2 ca báo cáo ngày 13/11/2026.
4. Để quay về CSDL cũ, dừng backend, khôi phục giá trị `DB_NAME` đã ghi lại rồi chạy lại `npm start`. Nếu bước nạp báo lỗi giữa chừng, giữ backend ở CSDL đang dùng. Sửa lỗi rồi chạy lại với tên mới.

Script tạo CSDL và kiểm tra kết quả. Việc chuyển backend được thực hiện sau khi xác nhận bản mới sẵn sàng.
