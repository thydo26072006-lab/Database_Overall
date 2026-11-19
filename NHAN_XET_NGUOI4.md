# Kiểm tra chéo Người 4

Người kiểm tra là Người 1. Bản được kiểm tra ngày 19/11/2026 là nhánh [`nguoi4` tại commit `35a54f9`](https://github.com/thydo26072006-lab/Database_Overall/tree/35a54f9bb8ba967ee344598a43df7d7bc626b429/nguoi4). Cả 12 tệp trong thư mục Người 4 khớp với ZIP ngày 17/11. Tám script SQL có trong SQL tổng của nhóm.

## Kết quả kiểm thử

Chạy SQL tổng trên một CSDL mới bằng SQL Server 2022 bản 16.0.4305.5. Sau đó, chạy trực tiếp hai file truy vấn trên CSDL này với dữ liệu mẫu do Người 4 tạo trong giao dịch riêng.

| Hạng mục | Kết quả thực tế |
|---|---|
| Truy vấn 2 | 5 giao dịch, tổng 110.000 đồng và có một giao dịch 0 đồng. Giao dịch ở ngoài khoảng ngày bị loại. Việc phát hành lại hóa đơn không nhân đôi khoản thu. |
| Truy vấn 3 | `HH_KIEMTHU` có 3 phiếu đã ghi sổ. Tăng 10,5 kg, giảm 2,5 kg và biến động ròng 8 kg. |
| Thủ tục 2 | 14/11 thu 80.000, 15/11 thu 20.000, 16/11 có dòng 0 đồng, 17/11 thu 10.000. Ca hợp lệ và 7 ca ngày lỗi/ngày biên đều đạt. |
| Demo CRUD | 15/15 ca đạt trên `DANH_MUC_MON`, gồm luồng hợp lệ và các ca lỗi dự kiến. |
| Demo Hàm 2 | 10/10 ca đạt, gồm phiếu nháp, hàng chưa nhập, lượng 0,000001 và đầu vào NULL. |

Truy vấn 2 đọc bảng `THANH_TOAN` và lọc theo mốc đầu ngày, nên tránh nhân dòng hóa đơn và bao gồm trọn ngày cuối. Truy vấn 3 nhóm theo mặt hàng và đơn vị. Thủ tục 2 dùng `IF` kiểm ngày và `WHILE` điền ngày trống, có xử lý ngày `9999-12-31`.

## Các điểm cần sửa trước khi ghép báo cáo

1. **Thiếu hướng dẫn thứ tự chạy.** [File 04, dòng 10](https://github.com/thydo26072006-lab/Database_Overall/blob/35a54f9bb8ba967ee344598a43df7d7bc626b429/nguoi4/04_Demo_Thu_tuc_2.sql#L10) gọi thủ tục tạo mẫu được định nghĩa trong [file 08, dòng 10](https://github.com/thydo26072006-lab/Database_Overall/blob/35a54f9bb8ba967ee344598a43df7d7bc626b429/nguoi4/08_Du_lieu_demo_bao_cao.sql#L10). File 05 và 07 gọi `dbo.usp_FIX_Test` từ SQL tổng. Nên ghi rõ dựng CSDL bằng SQL tổng. Khi cài riêng phần Người 4 trên một CSDL chung đã có dữ liệu và mã hỗ trợ, chạy file 03 và 08 trước các file demo.
2. **Truy vấn 2 chạy riêng theo mốc mặc định trả bảng trống.** Tôi chạy file 01 ngay sau SQL tổng và thấy 0 dòng. Gọi helper tạo mẫu trong giao dịch rồi chạy lại chính file 01 thì có đủ 5 dòng. Thêm hướng dẫn gọi helper, chạy truy vấn trong cùng phiên rồi `ROLLBACK`. File 04 hiện kiểm một bản chép của hai truy vấn, nên khi sửa file 01 hoặc 02, cần chạy lại chính file đã sửa để đối chiếu.
3. **Word thiếu minh chứng DBMS.** Báo cáo tại commit này chỉ có hai ảnh lưu đồ. Hai tệp `KIEM_TRA_CU_PHAP.txt` và `KET_QUA_CHAY_SQLSERVER.txt` được dẫn trong Word chưa có trên nhánh Người 4. Cần thêm ảnh chạy thật và sửa tham chiếu sang tệp kết quả thực tế của nhóm.

Mọi mẫu thanh toán từ lần chạy kiểm tra đã được hoàn tác. Tôi xác nhận còn 0 dòng thanh toán demo sau khi chạy.
