# Phần 3 – Danh mục món (Người 1)

Màn hình dùng bảng `DANH_MUC_MON`. Có thể thêm danh mục, đổi tên, đổi danh mục cha hoặc xóa sau khi xác nhận. Sau mỗi lần lưu thành công, màn hình đọc lại danh sách từ SQL Server.

## Cách chạy

1. Tải [SQL tổng của nhóm](https://github.com/thydo26072006-lab/Database_Overall/blob/de645fa/BTL2_SQL_TONG_HOP.sql), đổi tất cả `BTL2_FIX_12345` thành `BTL2_P3_DEMO` rồi chạy để tạo CSDL thử. Chọn CSDL vừa tạo và chạy tiếp [02_Trigger_INSERT.sql](../02_Trigger_INSERT.sql).
2. Dùng Node.js 22 trở lên. Sao chép [`.env.example`](../../backend/.env.example) thành `backend/.env` rồi điền tài khoản và mật khẩu SQL Server. Nếu SQL Server thử trên máy dùng chứng chỉ tự ký, đặt `DB_TRUST_SERVER_CERTIFICATE=true`.
3. Mở hai cửa sổ terminal ở thư mục gốc. Chạy backend ở cửa sổ thứ nhất.

   ```sh
   cd backend
   npm ci
   npm start
   ```

   Chạy frontend ở cửa sổ còn lại.

   ```sh
   cd frontend
   npm ci
   npm run dev
   ```

   Mở [màn hình danh mục](http://127.0.0.1:5173). Nếu đổi `APP_PORT` từ 3001, cập nhật cổng proxy tương ứng trong [vite.config.js](../../frontend/vite.config.js).

## Bàn giao tích hợp

| API | Dữ liệu gửi và kết quả | Đối tượng SQL |
| --- | --- | --- |
| `GET /api/danh-muc-mon` | 200 · `{ data: [...] }` | Đọc `dbo.DANH_MUC_MON` |
| `POST /api/danh-muc-mon` | Gửi mã, tên và mã cha. Trả 201 và dòng mới trong `data`. | `dbo.usp_N1_ThemDanhMuc` |
| `PUT /api/danh-muc-mon/:maDanhMuc` | Gửi tên và mã cha. Trả 200 và dòng đã sửa trong `data`. | `dbo.usp_N2_CapNhatDanhMuc` |
| `DELETE /api/danh-muc-mon/:maDanhMuc` | 204 sau khi xóa | `dbo.usp_N3_XoaDanhMuc` |

Tên trường JSON là `maDanhMuc`, `tenDanhMuc` và `maDanhMucCha`. Danh mục gốc có `maDanhMucCha: null`. Khi sửa, mã danh mục lấy từ đường dẫn. Nếu thủ tục báo lỗi, API trả `{ error: { code, message } }` để giao diện hiển thị.

- **Người 4** gắn [DanhMucMonPage.jsx](../../frontend/src/pages/DanhMucMonPage.jsx) vào mục Quản lý thực đơn. Luồng ở mục 3.2 là React gửi yêu cầu → Express gọi thủ tục → SQL Server trả kết quả hoặc mã lỗi → React hiện thông báo.
- **Người 5** đăng ký `createDanhMucMonRouter(pool)` tại `/api/danh-muc-mon` sau `express.json()`, dùng pool SQL Server chung. Bản chạy thử chuyển `/api` qua proxy Vite. Nếu frontend và API dùng hai địa chỉ khác nhau, đặt `VITE_API_BASE_URL` và cấu hình CORS ở backend chung.

## Kiểm thử và ảnh minh chứng

Chạy `npm test` trong `backend` với CSDL thử có tên bắt đầu bằng `BTL2_P3_`. Trên SQL Server 2022, 10 ca API đều đạt. Bộ kiểm thử đọc lại bảng sau khi ghi và kiểm tra các lỗi như mã trùng (51007), tạo vòng cha–con (51010) và xóa danh mục còn con hoặc món (51303).

Ảnh chụp từ trình duyệt trong lần chạy với dữ liệu mẫu của nhóm:

1. [Trước khi thêm](hinh/01-truoc-khi-them.png) — danh sách có sáu danh mục mẫu.
2. [Sau khi thêm](hinh/02-sau-khi-them.png) — có `P3_N1_DEMO`, tên **Món theo mùa**, cha **Đồ uống**.
3. [Sau khi sửa](hinh/03-sau-khi-sua.png) — đổi tên thành **Món mùa lễ** và bỏ danh mục cha.
4. [Xóa bị từ chối](hinh/04-xoa-bi-tu-choi.png) — **Đồ uống** còn danh mục con nên SQL Server trả lỗi 51303.
5. [Sau khi xóa](hinh/05-sau-khi-xoa.png) — `P3_N1_DEMO` biến mất, danh sách trở lại sáu dòng. Khi hủy hộp xác nhận, dòng thử vẫn còn.
