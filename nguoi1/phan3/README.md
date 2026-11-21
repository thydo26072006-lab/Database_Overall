# Phần 3 – Người 1: Danh mục món

**Yêu cầu 1 · Hạn bàn giao 23:00 ngày 24/11/2026.**

Màn hình Quản lý thực đơn → Danh mục món hiển thị mã, tên và danh mục cha. Người dùng có thể thêm, đổi tên hoặc đổi cha, xác nhận xóa và xem kết quả ngay trên danh sách. Mã danh mục được giữ khi sửa.

## Cách chạy

1. Dựng một CSDL thử mới từ [SQL tổng của nhóm](https://github.com/thydo26072006-lab/Database_Overall/blob/de645fa/BTL2_SQL_TONG_HOP.sql). Trước khi chạy, thay toàn bộ `BTL2_FIX_12345` bằng tên mới, ví dụ `BTL2_P3_DEMO`. Sau đó chạy [02_Trigger_INSERT.sql](../02_Trigger_INSERT.sql) trong CSDL vừa dựng để dùng bản Người 1 đã sửa.
2. Dùng Node.js 22 trở lên. Tạo tệp `backend/.env` từ [mẫu cấu hình](../../backend/.env.example), điền tên CSDL, tài khoản và mật khẩu SQL Server của máy. Với SQL Server thử cục bộ dùng chứng chỉ tự ký, đặt `DB_TRUST_SERVER_CERTIFICATE=true`.
3. Từ thư mục gốc, mở hai cửa sổ terminal và chạy lần lượt:

   ```sh
   cd backend
   npm ci
   npm start
   ```

   ```sh
   cd frontend
   npm ci
   npm run dev
   ```

   Mở [màn hình danh mục](http://127.0.0.1:5173). Để chạy kiểm thử API với dữ liệu mẫu, chạy `npm test` trong `backend` trên CSDL thử có tên bắt đầu bằng `BTL2_P3_`.

## Bàn giao tích hợp

| API | Dữ liệu gửi và kết quả | Đối tượng SQL |
| --- | --- | --- |
| `GET /api/danh-muc-mon` | 200 · `{ data: [...] }` | Đọc `dbo.DANH_MUC_MON` |
| `POST /api/danh-muc-mon` | `maDanhMuc`, `tenDanhMuc`, `maDanhMucCha` (chuỗi hoặc `null`); 201 · `{ data: dòng vừa thêm }` | `dbo.usp_N1_ThemDanhMuc` |
| `PUT /api/danh-muc-mon/:maDanhMuc` | `tenDanhMuc`, `maDanhMucCha` (chuỗi hoặc `null`); 200 · `{ data: dòng đã sửa }` | `dbo.usp_N2_CapNhatDanhMuc` |
| `DELETE /api/danh-muc-mon/:maDanhMuc` | 204 sau khi xóa | `dbo.usp_N3_XoaDanhMuc` |

Bản ghi API có ba trường `maDanhMuc`, `tenDanhMuc`, `maDanhMucCha`. Lỗi nghiệp vụ trả `{ error: { code, message } }`; ví dụ mã trùng 51007, tạo vòng 51010, danh mục còn con hoặc món 51303. Thủ tục thêm/sửa nhận mã, tên và mã cha dưới dạng `NVARCHAR(MAX)`; SQL Server kiểm tra dữ liệu trước khi chuyển sang kiểu cột.

- **Người 4:** Gắn [DanhMucMonPage.jsx](../../frontend/src/pages/DanhMucMonPage.jsx) vào menu Quản lý thực đơn. Luồng cho báo cáo 3.2: người dùng thao tác → React gửi yêu cầu → Express gọi thủ tục tương ứng → SQL Server trả kết quả hoặc mã lỗi → React báo kết quả và tải lại danh sách khi thành công. Màn hình Trigger của Người 2 được gắn ở mục riêng.
- **Người 5:** Mount `createDanhMucMonRouter(pool)` tại `/api/danh-muc-mon` sau `express.json()`, dùng pool SQL Server chung. Bản chạy thử dùng proxy `/api` từ Vite sang cổng 3001. Khi tích hợp, dùng đường dẫn tương đối qua proxy hoặc phục vụ giao diện và API cùng origin. Nếu triển khai hai origin, đặt `VITE_API_BASE_URL` và cấu hình CORS trong backend chung.

## Kiểm thử và ảnh minh chứng

Đã chạy trên SQL Server 2022 (16.0.4305.5). **10/10 ca API đạt**, gồm đọc, thêm tên tiếng Việt và chọn cha, từ chối mã trùng/quá dài/cha không tồn tại, sửa và bỏ cha, từ chối tạo vòng, từ chối xoá danh mục còn con hoặc món, xoá hợp lệ và trả 404 khi thao tác lại trên mã đã xoá. Các thao tác ghi được đối chiếu bằng SELECT độc lập.

**9/9 kiểm tra trên trình duyệt đạt.** Đã thử tải lại trang sau khi xóa, hủy xóa, thao tác với mã đặc biệt và dùng biểu mẫu bằng bàn phím trên màn hình hẹp.

Ảnh chụp từ trình duyệt trong lần chạy với dữ liệu mẫu của nhóm:

1. [Trước khi thêm](hinh/01-truoc-khi-them.png) — danh sách có sáu danh mục mẫu.
2. [Sau khi thêm](hinh/02-sau-khi-them.png) — có `P3_N1_DEMO`, tên **Món theo mùa**, cha **Đồ uống**.
3. [Sau khi sửa](hinh/03-sau-khi-sua.png) — đổi tên thành **Món mùa lễ** và bỏ danh mục cha.
4. [Ca bị từ chối](hinh/04-xoa-bi-tu-choi.png) — xóa **Đồ uống** nhận lỗi 51303 vì còn danh mục con.
5. [Sau khi xóa](hinh/05-sau-khi-xoa.png) — `P3_N1_DEMO` biến mất, danh sách trở lại sáu dòng. Khi hủy hộp xác nhận, dòng thử vẫn còn.
