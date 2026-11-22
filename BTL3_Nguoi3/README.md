# BTL3 Người 3 – Tổng hợp phân công theo ca

Màn hình Yêu cầu 3 gọi thủ tục `dbo.usp_N3_TongHopPhanCongTheoCa` (mục 2.3.a). [Báo cáo Word](Bao_cao_BTL3_Nguoi3.docx) có lưu đồ và ảnh minh chứng để ghép vào mục 3.2.

## Chạy thử

1. Dùng Node.js 22.12 trở lên và SQL Server đã nạp bản `BTL2_SQL_TONG_HOP.sql` của nhóm.
2. Trong thư mục `BTL3_Nguoi3`, chạy `npm ci`. Sao chép `.env.example` thành `.env` và điền thông tin kết nối SQL Server. Giữ `.env` trên máy cá nhân.
3. Mở hai cửa sổ terminal trong cùng thư mục. Chạy `npm run api` ở cửa sổ thứ nhất và `npm run dev` ở cửa sổ thứ hai. Mở [giao diện](http://127.0.0.1:5173).

| Từ ngày | Đến ngày | Kết quả |
| --- | --- | --- |
| 13/11/2026 | 13/11/2026 | Hai ca, gồm ca sáng đã phân công và ca chiều chưa phân công |
| 14/11/2026 | 13/11/2026 | Thông báo khoảng ngày không hợp lệ |
| 15/11/2026 | 15/11/2026 | Thông báo không có ca làm |

## Tích hợp vào ứng dụng chung

- **Người 4:** Ghép `frontend/src/pages/ShiftReport.jsx` vào giao diện chung, kèm `shiftReport.css` và `frontend/src/services/shiftReport.js`.
- **Người 5:** Gắn `createShiftReportRouter(getPool)` từ `backend/src/routes/phan-cong-theo-ca.js` vào Express, dùng pool SQL Server chung với `useUTC: true`. Giữ endpoint `GET /api/bao-cao/phan-cong-theo-ca` với hai tham số `tuNgay` và `denNgay` dạng `YYYY-MM-DD`, hoặc cập nhật đồng thời hàm gọi API ở frontend.
