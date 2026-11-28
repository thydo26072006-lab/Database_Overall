# Cơ sở dữ liệu SQL Server

[BTL2_SQL_TONG_HOP.sql](BTL2_SQL_TONG_HOP.sql) nạp chung lược đồ 30 bảng, dữ liệu mẫu, ràng buộc, chỉ mục, truy vấn và các đối tượng SQL đã hoàn thành trong Phần 1–2. Phần danh mục sử dụng bản cập nhật thủ tục thêm và trigger chống vòng lặp từ nhánh Người 1.

## Khởi tạo và kiểm chứng

Từ thư mục gốc, thay tên instance theo máy của bạn. PowerShell cần `sqlcmd` và tài khoản Windows có quyền tạo CSDL. Cờ `-TrustServerCertificate` phù hợp với SQL Server cục bộ dùng chứng chỉ tự ký.

```powershell
powershell.exe -NoProfile -ExecutionPolicy RemoteSigned -File './database/Khoi_Tao_Du_Lieu_Demo.ps1' -Instance 'localhost\SQLEXPRESS' -TrustServerCertificate
```

Script in tên CSDL mới có dạng `BTL2_P3_DEMO_<hậu tố>`. Thêm `-DatabaseName BTL2_P3_DEMO` nếu muốn dùng đúng tên mặc định trong tệp cấu hình. Script dừng khi CSDL đích đã tồn tại.

Đặt `DB_NAME` trong `backend/.env` bằng tên CSDL vừa tạo. Dữ liệu mẫu có 6 danh mục, 7 món, 13 size và hai ca làm việc ngày 13/11/2026. Trà chanh dùng mã `TRA_CHANH` và bắt đầu ở trạng thái ngừng bán.

## Dựng lại dữ liệu demo trước buổi trình bày

Chạy lại lệnh khởi tạo để tạo một CSDL mới. Dừng backend, đặt lại `DB_NAME` theo kết quả rồi khởi động lại. CSDL của phiên trước vẫn sẵn sàng nếu cần chuyển lại.

## Chạy bằng SSMS

Mở [script hợp nhất](BTL2_SQL_TONG_HOP.sql), thay tên `BTL2_FIX_12345` bằng tên CSDL mới và chạy toàn bộ script. Sau đó chọn đúng CSDL để chạy [kiểm tra metadata](03_Kiem_tra_doi_tuong_Phan2.sql) hoặc [kiểm thử tham số báo cáo ca](kiem-thu/phan_cong_theo_ca.sql).
