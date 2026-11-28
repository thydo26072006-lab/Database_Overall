# Hệ thống quản lý gọi món và đặt món

Ứng dụng BTL2 môn Hệ cơ sở dữ liệu. React gọi một backend Express, dùng chung lược đồ và dữ liệu mẫu trên SQL Server.

| Thành phần | Nội dung |
| --- | --- |
| [frontend](frontend/) | Trang chủ, danh mục món, món và size, tổng hợp phân công theo ca |
| [backend](backend/) | 12 endpoint nghiệp vụ và kiểm tra kết nối, dùng chung một pool SQL Server |
| [database](database/) | Script hợp nhất Phần 1–2, dữ liệu mẫu, thủ tục, trigger, hai hàm và các ca kiểm tra SQL |
| [docs](docs/) | Thiết kế EERD, báo cáo, minh chứng và kịch bản demo |

## Luồng nghiệp vụ

| Màn hình | Đối tượng SQL Server |
| --- | --- |
| Danh mục món | usp_N1_ThemDanhMuc, usp_N2_CapNhatDanhMuc, usp_N3_XoaDanhMuc |
| Món và size | MON, SIZE_MON, trg_N2_Mon_TaoSizeMacDinh, trg_N2_Size_DungLoai |
| Tổng hợp phân công theo ca | usp_N3_TongHopPhanCongTheoCa |

Xem [tài liệu nộp bài](docs/README.md) và [phân công gốc](docs/PHAN_CONG.md).

## Chạy ứng dụng

Mở hai cửa sổ PowerShell từ thư mục gốc để chạy backend và frontend.

### Chuẩn bị môi trường chạy ứng dụng Phần 3

- Node.js từ `22.12.0` và `npm` trong `PATH` (kiểm tra bằng `node --version` và `npm --version`).
- Microsoft SQL Server 2022 trở lên. Khi nạp dữ liệu bằng PowerShell cần `sqlcmd` và tài khoản Windows có quyền tạo CSDL (hoặc dùng SSMS).
- Nếu backend dùng Windows Auth (`DB_AUTH=windows`), cài **ODBC Driver 18 for SQL Server** (`npm ci` cài gói `msnodesqlv8` cho chế độ này).

### Nạp cơ sở dữ liệu

Tạo và kiểm tra CSDL bằng [hướng dẫn SQL Server](database/README.md). Dữ liệu mẫu gồm 6 danh mục, 7 món, 13 size và hai ca ngày 13/11/2026.

### Cài và chạy backend (`./backend`)

```powershell
Set-Location './backend'
npm ci
if (!(Test-Path -LiteralPath .env)) {
    Copy-Item -LiteralPath .env.example -Destination .env
}
```

Với Windows Auth trên máy cục bộ, cấu hình `backend/.env` (thay `DB_INSTANCE` theo instance SQL Server của máy):

```dotenv
APP_PORT=3001
DB_NAME=BTL2_P3_DEMO
DB_AUTH=windows
DB_INSTANCE=localhost\SQLEXPRESS
DB_ENCRYPT=true
DB_TRUST_SERVER_CERTIFICATE=true
CORS_ORIGIN=http://127.0.0.1:5173,http://localhost:5173
```

Nếu dùng SQL Auth qua TCP, đặt `DB_AUTH=sql` và điền `DB_HOST`, `DB_PORT`, `DB_USER`, `DB_PASSWORD` theo [tệp mẫu backend](backend/.env.example). Không commit tệp `.env` chứa thông tin đăng nhập lên GitHub.

Khởi chạy backend bằng `npm start` và kiểm tra sức khỏe kết nối:

```powershell
Invoke-RestMethod 'http://127.0.0.1:3001/api/health' | ConvertTo-Json -Compress
```

Kết quả hợp lệ khi SQL Server sẵn sàng: `{"data":{"status":"ok","database":"connected"}}`.

### Cài và chạy frontend (`./frontend`)

```powershell
Set-Location './frontend'
npm ci
if (!(Test-Path -LiteralPath .env.local)) {
    Copy-Item -LiteralPath .env.example -Destination .env.local
}
```

Trong `frontend/.env.local`, cấu hình proxy tới backend chung:

```dotenv
VITE_API_BASE_URL=
VITE_API_PROXY_TARGET=http://127.0.0.1:3001
```

Chạy `npm run dev` và mở địa chỉ Vite hiển thị (mặc định `http://127.0.0.1:5173`). Để xem bản build cục bộ, chạy `npm run build` rồi `npm run preview`.

### Chạy kiểm thử tích hợp

Dùng `DB_NAME=BTL2_P3_DEMO` hoặc CSDL mẫu có tên do script khởi tạo sinh ra, dừng backend đang chạy trên `APP_PORT`, sau đó chạy:

```powershell
Set-Location './backend'
npm test
```

Bộ kiểm thử tự khởi động backend, kiểm tra 12 endpoint nghiệp vụ và `/api/health`, tự dọn dữ liệu thử rồi đóng kết nối SQL (kỳ vọng 7 phép kiểm tra đạt, `fail 0`).
