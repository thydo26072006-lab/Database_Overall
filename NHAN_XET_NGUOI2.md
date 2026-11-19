# Nhận xét bài Người 2

Phạm vi gồm năm tệp SQL trong `nguoi2_main/`. Cấu trúc bảng liên hệ được đối chiếu với sheet `07_LUOC_DO_QUAN_HE` của Excel hiện hành. ScriptDom kiểm tra 5 tệp và 22 đoạn SQL động trong demo với **0 lỗi cú pháp**. Kết quả này xác nhận cú pháp. Các ca nghiệp vụ và số liệu hiệu năng cần được xác nhận khi chạy trên SQL Server.

## 1. Cấu trúc bảng

`01_Cau_truc.sql` tạo 23 bảng cho nhân sự, lịch ca, đơn hàng, thanh toán, khuyến mãi và kho. Các chỉ mục duy nhất có điều kiện bảo vệ những quy tắc như mỗi bàn có tối đa một đơn đang phục vụ và mỗi giao dịch có tối đa một hóa đơn hiệu lực. [Mã tạo bảng](nguoi2_main/01_Cau_truc.sql)

**Điểm cần sửa theo Excel.** `LIEN_HE_NHAN_VIEN` hiện dùng `MaNV`, `Loai`, `GiaTri` với khóa chính ghép. Excel yêu cầu `MaLienHe VARCHAR(30)` làm khóa chính, `MaNV VARCHAR(30) NOT NULL` làm khóa ngoại tới `NHAN_VIEN`, cùng `Sdt VARCHAR(20) NULL` và `Email VARCHAR(254) NULL`. Mỗi dòng cần ít nhất một giá trị liên hệ có nội dung. Kiểm duy nhất riêng cho mỗi cột có giá trị sau khi chuẩn hóa. Quy tắc mỗi nhân viên có ít nhất một liên hệ cần được kiểm trong giao dịch tạo hồ sơ hoặc xóa liên hệ cuối. [DDL liên hệ](nguoi2_main/01_Cau_truc.sql#L260) · [Excel hiện hành](So_do_AND_CSV/EERD_UPDATE.xlsx)

## 2. Trigger và thủ tục UPDATE

- **Trigger 2.** Trigger trên `MON` tạo quy cách `S` hoặc `TC` khi thêm món nháp. Trigger trên `SIZE_MON` bảo vệ cặp loại món–size và quy cách đang bán cuối cùng. Điều kiện chặn xóa quy cách chỉ bảo vệ món `DangBan`. Với topping `NgungBan`, quy cách `TC` có thể bị xóa nếu chưa được tham chiếu. Cần chốt và kiểm thử trường hợp này nếu nghiệp vụ yêu cầu topping luôn có một quy cách `TC`. [Trigger trên SIZE_MON](nguoi2_main/02_Trigger_2.sql#L31)
- **UPDATE danh mục.** Thủ tục kiểm nội dung và độ dài trước khi chuyển kiểu, sau đó dùng `OUTPUT` để trả dòng vừa cập nhật. Cần ghi rõ khi bỏ trống tham số `@MaDanhMucCha` thì thủ tục đặt cha về `NULL`. Thao tác chỉ đổi tên phải truyền lại mã cha hiện tại nếu cần giữ nguyên cây danh mục. Việc chặn chu trình nhiều cấp phụ thuộc Trigger 1. [Thủ tục UPDATE](nguoi2_main/03_Thu_tuc_UPDATE.sql)

## 3. Demo nghiệp vụ

`04_Demo.sql` gọi `dbo.usp_FIX_Test` ở cả 22 ca. Bộ năm file cần được chạy trên cơ sở dữ liệu đã nạp thủ tục này, view `dbo.v_N2_LuongNhanVien`, dữ liệu mẫu như `DM_TRA`, `NV01`, `TP_TRANCHAU`, cùng các quy tắc liên bảng mà ca lịch làm và kho viện dẫn. Các phụ thuộc này nằm ngoài năm file đang rà soát. [Script demo](nguoi2_main/04_Demo.sql)

- Ca tạo size mặc định kiểm đã có cặp `S` và `TC`. Nên kiểm thêm giá `0` và trạng thái `NgungBan` của cả hai dòng để xác nhận đầy đủ cấu hình nháp. [Ca tạo size](nguoi2_main/04_Demo.sql#L2)
- Ca UPDATE hợp lệ hiện gọi thủ tục rồi kết thúc. Nên kiểm tên và mã cha trong bảng sau khi chạy, đồng thời chọn mã cha khác nếu mục tiêu là minh họa chuyển cha. [Ca UPDATE](nguoi2_main/04_Demo.sql#L10)
- Ca lương và ca cập nhật số lượng topping dùng `<>` với kết quả truy vấn vô hướng. Khi truy vấn thiếu dòng, giá trị `NULL` làm điều kiện báo lỗi bị bỏ qua. Nên dùng `NOT EXISTS` để yêu cầu có đúng dòng mang giá trị kỳ vọng. [Ca lương](nguoi2_main/04_Demo.sql#L15) · [Ca topping](nguoi2_main/04_Demo.sql#L28)

## 4. Demo chỉ mục

Năm câu `SELECT` trước và sau giống nhau. Script thu `STATISTICS IO/TIME` và hoàn tác việc bỏ, tạo lại chỉ mục. Do bắt đầu bằng năm lệnh `DROP INDEX`, script cần đủ năm chỉ mục `IX_N3_*` đã được tạo. Cần nạp dữ liệu khớp điều kiện lọc trước khi đo và dùng kết quả thực thi để nhận xét hiệu quả. [Demo chỉ mục](nguoi2_main/05_Demo_chi_muc.sql)
