# Bàn giao backend chung cho Người 4

Xác nhận ngày 27/11/2026. Backend chạy tại `http://127.0.0.1:3001` từ thư mục `nguoi5_branch/backend` trên máy local. Ba nhóm API dùng chung CSDL thử `BTL2_P3_DEMO`.

## Khởi động backend

Trên máy đã kiểm tra, tệp `backend/.env` đã được cấu hình. Môi trường gồm Node.js ≥ 22.12, ODBC Driver 18 và SQL Server với dữ liệu mẫu đã nạp. Nếu cài từ đầu, chạy `npm ci` và dùng [.env.example](../backend/.env.example) để tạo cấu hình cho máy đó.

```powershell
Set-Location 'D:\Database_Overall\nguoi5_branch\backend'
npm start
```

Thông số đã kiểm chứng trên máy này.

| Biến | Giá trị |
| --- | --- |
| `APP_PORT` | `3001` |
| `DB_AUTH` | `windows` |
| `DB_INSTANCE` | `localhost\YUSHINOMI` |
| `DB_NAME` | `BTL2_P3_DEMO` |
| `DB_ENCRYPT` | `true` |
| `DB_TRUST_SERVER_CERTIFICATE` | `true` với chứng chỉ của instance thử cục bộ |
| `CORS_ORIGIN` | `http://127.0.0.1:5173,http://localhost:5173` |

Kiểm tra `GET /api/health` tại `http://127.0.0.1:3001/api/health`. Khi SQL Server sẵn sàng, API trả HTTP 200 với `{"data":{"status":"ok","database":"connected"}}`.

## Cấu hình frontend cho N4-37

Dùng chế độ proxy một đích theo [frontend/.env.example](../../frontend/.env.example). Giữ `VITE_API_BASE_URL` trống, đặt `VITE_API_PROXY_TARGET=http://127.0.0.1:3001` hoặc dùng địa chỉ mặc định và bỏ cấu hình ba đích riêng `VITE_N1_API_TARGET`, `VITE_N2_API_TARGET`, `VITE_N3_API_TARGET`.

Nếu cần gọi trực tiếp để kiểm tra CORS, đặt `VITE_API_BASE_URL=http://127.0.0.1:3001` và khai báo đúng origin thực tế của frontend trong `CORS_ORIGIN`. Khởi động lại tiến trình tương ứng sau khi đổi cấu hình.

## Kết quả kiểm tra tại cổng bàn giao

- `npm test` đạt 7/7, bao phủ đủ 12 endpoint nghiệp vụ và health. Bộ kiểm thử đã dọn dữ liệu thử.
- `npm start` được kiểm tra trong ba lượt đọc liên tiếp. Cả năm yêu cầu trong mỗi lượt đều trả HTTP 200.

| Yêu cầu GET | Kết quả |
| --- | --- |
| `/api/health` | SQL Server đã kết nối. |
| `/api/danh-muc-mon` | 6 danh mục. |
| `/api/trigger-mon/danh-muc` | 6 danh mục dùng cho form món. |
| `/api/trigger-mon/mon` | 7 món kèm dữ liệu size. |
| `/api/bao-cao/phan-cong-theo-ca?tuNgay=2026-11-13&denNgay=2026-11-13` | 2 ca ngày 13/11/2026. |

Phiên xác minh đã dừng và trả lại cổng 3001. Có thể khởi động lại với lệnh ở trên. Xem [hợp đồng API Người 4](../../nguoi4_phan3/KE_HOACH_NGUOI4_PHAN3.md#5-hợp-đồng-api-với-người-5) và [nhật trình kiểm tra](../.n5-local/minh-chung/N5-15/kiem-tra-ban-giao.log).
