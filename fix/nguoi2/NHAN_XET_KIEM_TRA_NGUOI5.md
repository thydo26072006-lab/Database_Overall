# Nhận xét kiểm tra chéo Người 5

## 01_Truy_van_4.sql

File cho thấy truy vấn thống kê đúng số món và số lựa chọn size đang bán theo từng danh mục. Cách dùng `COUNT(DISTINCT MaMon)` và `COUNT_BIG(*)` hợp lý, vì số món và số cặp món–size là hai số khác nhau. Danh mục chưa có món đang bán sẽ không hiện trong kết quả; nếu muốn hiện cả danh mục đó thì cần chỉnh truy vấn.

## 02_Truy_van_5.sql

Truy vấn lọc ra các món có giá trung bình cao hơn mức trung bình giá của các món đang bán. Cách tính cho mỗi món trọng số như nhau, nên cần giữ đúng cách diễn giải này khi trình bày.

## 03_Ham_1.sql

Hàm đếm các size đang bán của món trong danh mục được chọn và các danh mục con. Quy ước trả `NULL` khi mã danh mục không hợp lệ, trả 0 khi danh mục hợp lệ nhưng chưa có lựa chọn đang bán là hợp lý. Hàm chỉ thống kê cấu hình món và size, không thể hiện món có đủ công thức hay nguyên liệu.

## 04_Ham_2.sql

Hàm tính tồn kho bằng cách cộng các biến động đã ghi sổ đến thời điểm được chọn. Các trường hợp hàng chưa có biến động, phiếu nháp và đầu vào không hợp lệ được xử lý rõ ràng. Hàm dùng vòng lặp nên có thể chạy chậm nếu lịch sử kho có nhiều dòng; đây là điểm có thể cân nhắc tối ưu thêm.

## 05_Demo_Ham_2_ban_giao.sql

Các demo bao quát những mốc nhập, xuất, kiểm kê, phiếu nháp và dữ liệu không hợp lệ. Cần nạp đúng dữ liệu mẫu trước khi chạy để kết quả khớp với kỳ vọng.

## Kết luận

Qua kiểm tra, ko có lỗi rõ ràng trong phần truy vấn và hàm. Nội dung khớp với mô tả. Cần lưu ý danh mục rỗng không xuất hiện ở Truy vấn 4, cách tính trung bình ở Truy vấn 5 và khả năng chạy chậm của Hàm 2 khi dữ liệu lớn.
