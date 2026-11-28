# Người 1 — bản fix

Phần 1.1.a,b: tạo 7 bảng BAN, DANH_MUC_MON, MON, SIZE_MON, HANG_HOA, CONG_THUC, CHI_TIET_CONG_THUC. Các CHECK đơn dòng nằm trong DDL; điều kiện liên bảng nằm trong nhóm hỗ trợ chung. Phần 2.2.a: Trigger 1 chống chu trình danh mục khi INSERT/UPDATE, gồm nhiều dòng; DELETE không tạo chu trình. Phần 2.1.a: INSERT trên DANH_MUC_MON, nhận tham số rộng, kiểm lỗi và trả dòng đã thêm.
Use case: Quản lý thực đơn → Cây danh mục → Thêm danh mục. Bảng CRUD chung giữ nguyên với Người 2 và 3. Dữ liệu mẫu nằm trong SQL tổng của nhóm. Các ca kiểm thử nằm trong `03_Demo.sql`.
Thiết kế mới bỏ khu vực bàn, bảng mã kho và các bảng topping riêng. Topping dùng MON/SIZE_MON với TC. Hàng hóa giữ vị trí/cảnh báo. Công thức có loại định lượng cố định hoặc tùy chọn.
Input INSERT: mã, tên, mã cha tùy chọn. Output: dòng mới hoặc lỗi 51001–51008. Trigger chặn chu trình bằng lỗi 51010. Lưu đồ dưới thể hiện đường kiểm tra; ca đúng/sai nằm trong SQL dạng text.

Đối chiếu lý thuyết: 4A_SQL — CREATE TABLE/PK/FK/CHECK, SELECT/WHERE/ORDER BY, nhóm/tổng hợp/truy vấn con; 4B_AdvancedSQL trang 4–11 biến/IF/WHILE, 14–23 thủ tục/hàm, 25–30 trigger và inserted/deleted, 32–38 cursor, 40–49 xử lý lỗi. Cursor chỉ dùng ở khóa kho có thứ tự; trigger duyệt cây danh mục dùng WHILE, đúng phân công không bắt buộc cursor ở mọi nơi. 5_Normalization — giữ khóa ghép và thuộc tính phụ thuộc đúng bảng, không tự tuyên bố toàn hệ thống đạt 3NF/BCNF khi chưa chứng minh đủ phụ thuộc hàm. 6_DataStorageIndexingStructures — index phục vụ đường truy cập, luôn có chi phí ghi/lưu trữ, phải đo thực. 7_DatabaseSecurity — chỉ cấp quyền cần thiết; không tắt FK/trigger hoặc cấp sysadmin để demo.

Thủ tục lưu dòng vừa thêm qua `OUTPUT`. Nếu giao dịch của bên gọi rơi vào `XACT_STATE() = -1`, bên gọi phải hoàn tác toàn bộ.

## Chạy lại phần Người 1

1. Dùng `BTL2_SQL_TONG_HOP.sql` trên nhánh `main` để dựng CSDL thử đến hết Phần 17.
2. Trong CSDL thử, chạy `02_Trigger_INSERT.sql`, rồi chạy `03_Demo.sql` khi phiên hiện tại chưa mở giao dịch. Demo dùng dữ liệu mẫu chung và `dbo.usp_FIX_Test`.
3. [Kết quả SQL Server 2022](KET_QUA_CHAY_SQLSERVER.txt) ghi 17/17 ca đạt. Báo cáo Word có ảnh chạy và lưu đồ.
