# Phần 3 · Người 2 · Quản lý món và size

thực hiện màn hình **Quản lý món và size** để minh họa Trigger ở mục 2.2.b. Màn hình này đáp ứng **Yêu cầu 2** của Phần 3 và tách riêng với màn hình quản lý danh mục món của Người 1.

## Những gì đã làm

- Hiển thị danh sách món, trạng thái bán và các size kèm giá bán của từng món.
- Cho phép thêm món, bật hoặc ngừng bán món, thêm size, sửa giá và trạng thái của size, hoặc xóa size sau khi xác nhận.
- Đọc lại dữ liệu từ SQL Server sau mỗi thao tác và hiển thị kết quả hoặc lý do thao tác bị từ chối.

## Trigger hoạt động thế nào

Khi người dùng thêm món, giao diện React gửi yêu cầu đến API Express. API thêm dữ liệu vào bảng `MON`. SQL Server tự kích hoạt `trg_N2_Mon_TaoSizeMacDinh` và tạo một dòng trong bảng `SIZE_MON`. Đồ ăn và đồ uống nhận size **S**, còn topping nhận size **TC**. Size mặc định có giá **0 đồng** và ở trạng thái **Ngừng bán**.

Nếu người dùng chọn **Đang bán** ngay khi tạo món, Trigger từ chối với lỗi **51210**. Để bật bán món, cần chuyển ít nhất một size sang trạng thái **Đang bán** trước. Trigger `trg_N2_Size_DungLoai` cũng kiểm tra loại size và chặn xóa size đang bán cuối cùng của một món đang bán.

## Kết quả kiểm tra

Đã kiểm tra 21 phản hồi API trên cơ sở dữ liệu thử tạo từ SQL tổng hợp của nhóm. Các ca thêm món có size mặc định, cập nhật giá và trạng thái, xóa size hợp lệ và từ chối thao tác sai đều đạt.

- [Trước khi thêm món](hinh/01-truoc-khi-them.jpg)
- [Trigger từ chối tạo món ở trạng thái Đang bán](hinh/02-tu-choi-mon-dang-ban.jpg)
- [Món mới và size S do SQL Server tự tạo](hinh/03-sau-khi-them.jpg)
- [Món và size S sau khi bật bán](hinh/04-sau-khi-bat-ban.jpg)
