# Bàn giao Người 3 · BTL2 POS

| Mục | File | Nội dung |
|---|---|---|
| 1.2 | `01_Chi_muc.sql` | Tạo 5 chỉ mục I1–I5. Người 2 đo và chụp minh chứng trước/sau ở Phần 33 của SQL tích hợp. |
| 1.3 | `02_Truy_van_1.sql` | Hiển thị dữ liệu nguồn và truy vấn món chính đang bán theo danh mục trực tiếp. |
| 2.1.c | `03_Thu_tuc_DELETE.sql` | Tạo `dbo.usp_N3_XoaDanhMuc` trên bảng CRUD chung `dbo.DANH_MUC_MON`. Người 4 thực hiện demo CRUD ở Phần 28. |
| 2.3.a | `04_Thu_tuc_1.sql`, `05_Demo_Thu_tuc_1.sql` | Tạo và demo thủ tục tổng hợp phân công theo ca với seed chung. |
| 2.4.a | `06_Demo_Ham_1.sql` | Hiển thị dữ liệu nguồn, thực thi Hàm 1 do Người 5 viết và so kết quả của 8 ca với kỳ vọng. |
| Báo cáo | `Bao_cao_Nguoi3.docx` | Nội dung ghép báo cáo nhóm, mã SQL dạng văn bản, lưu đồ và vị trí chèn ảnh DBMS. |

## Chuẩn bị CSDL kiểm thử trên VS Code

1. Khởi động SQL Server 2022. Trong VS Code, chọn kết nối **POS Task2 Local** và mở một tab SQL. Chạy truy vấn đọc sau để xem máy chủ và kiểm tra tên CSDL mới.

   ```sql
   SELECT @@SERVERNAME AS MayChu, SERVERPROPERTY('ProductVersion') AS PhienBan,
          DB_NAME() AS CSDLHienTai,
          DB_ID(N'BTL_POS_261_Nguoi3_Fix_Test') AS CSDLMoi;
   ```

   `CSDLMoi` phải là `NULL` khi cài lần đầu. Nếu tên đã tồn tại, đặt hậu tố mới, chẳng hạn `_02`, cho bản sao SQL tích hợp và dùng cùng tên trong các tab sau. CSDL `BTL_POS_261_Nguoi3_Test` lưu lược đồ của lần chạy cũ.

2. Mở `LEAD_FIX/BTL2_FIX_NGUOI_1_2_3_4_5.sql` trong thư mục tài liệu nhóm. Tạo một bản sao làm việc ngoài bộ nộp. Thay toàn bộ `BTL2_FIX_12345` bằng tên CSDL mới, gồm kiểm tra `DB_ID`, `CREATE DATABASE`, `USE` và thông báo. Chọn từ đầu file đến hết Phần 17, dừng trước dòng mở khối chú thích ngay trên tiêu đề **PHẦN 18**. Execute phần chọn. Phần này dựng 30 bảng, CHECK/FK, trigger, seed, chỉ mục, thủ tục và hàm. Kiểm tra tab Messages trước khi chuyển bước. Nếu cài lỗi giữa chừng, giữ CSDL cài dở để đọc lỗi và thử lại với tên mới sau khi xử lý.

3. Mở tab riêng trên cùng máy chủ. Chọn CSDL mới trong từng tab hoặc thực thi `USE [BTL_POS_261_Nguoi3_Fix_Test];` rồi `GO` trên dòng riêng tại đầu mỗi tab. Kiểm tra trước khi chạy demo.

   ```sql
   SELECT DB_NAME() AS CSDL,
          (SELECT COUNT(*) FROM sys.tables WHERE schema_id = SCHEMA_ID(N'dbo')) AS SoBang,
          OBJECT_ID(N'dbo.usp_N3_TongHopPhanCongTheoCa', N'P') AS ThuTuc1,
          OBJECT_ID(N'dbo.fn_N5_DemLuaChonTheoDanhMuc', N'FN') AS Ham1;
   ```

   Kỳ vọng 30 bảng và hai ID khác `NULL`. Phần 10–12 đã cài mã của Người 3, phần 15 đã cài Hàm 1 và khớp file `LEAD_FIX/nguoi5/03_Ham_1.sql`. Khi cần minh chứng lệnh tạo Thủ tục 1, có thể thực thi riêng file `04_Thu_tuc_1.sql` trong CSDL mới và chụp Messages. Nếu một kết nối từng báo CSDL đã tồn tại và bật `NOEXEC`, dùng tab/kết nối mới hoặc thực thi riêng `SET NOEXEC OFF;` một lần trước khi tiếp tục.

4. Execute lần lượt `02_Truy_van_1.sql`, `05_Demo_Thu_tuc_1.sql`, `06_Demo_Ham_1.sql`. Ba file đọc seed và có thể chạy lại. Các bảng biến chỉ tồn tại trong batch. Seed ở Phần 09 được ghi vào CSDL mới khi cài đặt. SQL tích hợp có demo CRUD hoàn tác giao dịch, và Phần 33 xóa/tạo lại năm chỉ mục trong giao dịch rồi hoàn tác. Ba file demo của Người 3 ở bước này không xóa dữ liệu hay đối tượng trong CSDL. Giữ nguyên hai CSDL để đối chiếu khi cần.

## Kết quả và ảnh cần chụp

| Phần | Đầu vào và kết quả kỳ vọng | Vùng chụp trong VS Code |
|---|---|---|
| Truy vấn 1 | `DM_TRA` có 5 dòng. Trà đào M/L là 35.000/40.000đ. Trà sữa S/M/L là 25.000/30.000/35.000đ. | Một ảnh dữ liệu `DANH_MUC_MON`, `MON`, `SIZE_MON` (có thể dùng nhiều ảnh nếu bảng cuộn). Một ảnh **toàn cửa sổ DBMS** có kết nối/CSDL, lệnh SELECT và đủ 5 dòng. |
| Thủ tục 1 · P0 | Tạo `usp_N3_TongHopPhanCongTheoCa` thành công, P0 hiển thị tên đối tượng trong CSDL mới. | Lệnh tạo với Messages thành công và P0 với kết quả tra đối tượng. |
| Thủ tục 1 · P1 | Seed có 3 ca và 3 lượt phân công trong hai ngày. Lọc 13/11/2026 trả ca sáng `1/2/2`, ca chiều `0/0/0`. Ca 14/11 là đối chứng ngoài bộ lọc. | Hai bảng nguồn `CA_LAM`, `PHAN_CONG`. Một ảnh lệnh gọi và kết quả hai ca. |
| Thủ tục 1 · P2 | Ngày đảo và ngày bắt đầu `NULL` trả `51311`. Ngày 01/01/1900 trả `51312`. | Lệnh gọi hoặc tên ca và bảng mã lỗi/thông báo thật. |
| Hàm 1 · H0/H1 | Hàm có trong CSDL mới. Bảng nguồn cho thấy Đồ uống gồm Cà phê và Trà, có size ngừng bán, hai topping TC và danh mục rỗng. | H0 với tên hàm và CSDL. H1 với hai bảng nguồn, cuộn/chụp thêm nếu thiếu các dòng đối chứng. |
| Hàm 1 · H2 | `DM_DOUONG=8`, `DM_TRA=5`, `DM_DOAN=1`, `DM_TOPPING=2`, `DM_RONG=0`. Mã không có, `NULL` và mã chỉ có khoảng trắng trả `NULL`. | Lệnh gọi hàm và đủ 8 dòng có cột đầu vào, kỳ vọng, thực tế và PASS/FAIL. |

Giữ ảnh gốc đủ rõ để đọc mã, tên CSDL và số liệu. Kết quả trong bảng là kỳ vọng tĩnh cho seed tích hợp. Báo cáo cập nhật kết quả thực thi khi có ảnh mới.
