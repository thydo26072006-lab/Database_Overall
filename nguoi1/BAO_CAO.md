# Người 1 — bản fix

Phần 1.1.a,b: tạo 7 bảng BAN, DANH_MUC_MON, MON, SIZE_MON, HANG_HOA, CONG_THUC, CHI_TIET_CONG_THUC. Các CHECK đơn dòng nằm trong DDL; điều kiện liên bảng nằm trong nhóm hỗ trợ chung. Phần 2.2.a: Trigger 1 chống chu trình danh mục khi INSERT/UPDATE, gồm nhiều dòng; DELETE không tạo chu trình. Phần 2.1.a: INSERT trên DANH_MUC_MON, nhận tham số rộng, kiểm lỗi và trả dòng đã thêm.
Use case: Quản lý thực đơn → Cây danh mục → Thêm danh mục. Bảng CRUD chung giữ nguyên với Người 2 và 3. Dữ liệu mẫu nằm trong SQL tổng của nhóm. Các ca kiểm thử nằm trong `03_Demo.sql`.
Thiết kế mới bỏ khu vực bàn, bảng mã kho và các bảng topping riêng. Topping dùng MON/SIZE_MON với TC. Hàng hóa giữ vị trí/cảnh báo. Công thức có loại định lượng cố định hoặc tùy chọn.
Input INSERT: mã, tên, mã cha tùy chọn. Output: dòng mới hoặc lỗi 51001–51008. Trigger chống vòng trả 51010. Lưu đồ dưới thể hiện đường kiểm tra; ca đúng/sai nằm trong SQL dạng text.

Đối chiếu lý thuyết: 4A_SQL — CREATE TABLE/PK/FK/CHECK, SELECT/WHERE/ORDER BY, nhóm/tổng hợp/truy vấn con; 4B_AdvancedSQL trang 4–11 biến/IF/WHILE, 14–23 thủ tục/hàm, 25–30 trigger và inserted/deleted, 32–38 cursor, 40–49 xử lý lỗi. Cursor chỉ dùng ở khóa kho có thứ tự; các thuật toán duyệt cây/ca/hàm dùng WHILE, đúng phân công không bắt buộc cursor ở mọi nơi. 5_Normalization — giữ khóa ghép và thuộc tính phụ thuộc đúng bảng, không tự tuyên bố toàn hệ thống đạt 3NF/BCNF khi chưa chứng minh đủ phụ thuộc hàm. 6_DataStorageIndexingStructures — index phục vụ đường truy cập, luôn có chi phí ghi/lưu trữ, phải đo thực. 7_DatabaseSecurity — chỉ cấp quyền cần thiết; không tắt FK/trigger hoặc cấp sysadmin để demo.

## Chạy lại phần Người 1

1. Dùng `BTL2_FIX_NGUOI_1_2_3_4_5.sql` của nhóm để dựng một CSDL mới. File tổng đã chạy cả các ca Người 1.
2. Nếu cần xem riêng kết quả hoặc chụp ảnh, chọn CSDL vừa tạo và chạy toàn bộ `03_Demo.sql`. File sử dụng dữ liệu mẫu chung, `dbo.usp_FIX_Test` và các trigger chung về size/công thức.
3. Xem [kết quả chạy SQL Server](KET_QUA_CHAY_SQLSERVER.txt). Cả 15 ca Người 1 đều đạt trên SQL Server 2022 ngày 19/11/2026. Hai lưu đồ ở `hinh/`. Báo cáo Word còn cần ảnh DBMS chụp trên bộ 30 bảng.

SHA-256 của SQL tổng nhận từ nhóm là `be61a69d64ed55a52f9f9805003fd1575e132fc3b68eb5fff29093f215756054`. Khi kiểm thử, chỉ đổi tên CSDL thành `BTL2_Review_20261119_084154`.
