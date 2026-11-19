# Nhận xét bài Người 2

SQL Server đã tạo được 23 bảng, hai trigger và thủ tục UPDATE của Người 2. Điểm cần sửa là cấu trúc bảng liên hệ nhân viên theo Excel. Phần demo cần bổ sung các tệp dùng chung và minh chứng chạy với dữ liệu mẫu.

## Đối chiếu với đề và phân công

| Phần được giao | Kết quả rà soát |
| --- | --- |
| 1.1.a và 1.1.b — Tạo bảng và ràng buộc | [`01_Cau_truc.sql`](nguoi2/01_Cau_truc.sql) tạo 23 bảng còn lại cho nhân sự, ca làm, đơn hàng, thanh toán, khuyến mãi và kho. Có 57 `CHECK`, tổng cộng 74 khi tính thêm 17 `CHECK` của Người 1. Năm chỉ mục duy nhất có điều kiện trong DDL bảo vệ các quy tắc như một đơn đang phục vụ mỗi bàn và một hóa đơn hiệu lực mỗi giao dịch. Bảng `LIEN_HE_NHAN_VIEN` cần đồng bộ với sheet 07. |
| 1.1.c — Demo chỉ mục | [`05_Demo_chi_muc.sql`](nguoi2/05_Demo_chi_muc.sql) tạo đúng năm định nghĩa của [Người 3](nguoi3/01_Chi_muc.sql) và chạy cùng năm câu `SELECT` trước/sau. File lấy `STATISTICS IO/TIME` và hoàn tác thay đổi chỉ mục cuối lượt chạy. Lần chạy hiện có thực hiện được cả hai lượt trên bảng rỗng. |
| 2.2.b — Trigger 2 và demo | [`02_Trigger_2.sql`](nguoi2/02_Trigger_2.sql) gồm hai trigger phối hợp trên `MON` và `SIZE_MON`. Món mới sinh quy cách nháp `S` hoặc `TC` theo loại. Cặp loại món–size sai bị chặn và món đang bán phải giữ ít nhất một quy cách đang bán. [`04_Demo.sql`](nguoi2/04_Demo.sql) có ca thêm nhiều món cùng lúc, size sai loại và ngừng size đang bán cuối cùng. |
| 2.1.b — Thủ tục UPDATE | [`03_Thu_tuc_UPDATE.sql`](nguoi2/03_Thu_tuc_UPDATE.sql) nhận mã, tên và mã cha, kiểm tra đầu vào trước khi thu hẹp kiểu và trả dòng cập nhật qua `OUTPUT`. Trigger 1 của Người 1 bảo vệ chu trình nhiều cấp và trả `51010`. Người 4 gọi đúng thủ tục này trong [demo CRUD chung](nguoi4/05_Demo_CRUD.sql). |

**Bản được đối chiếu.** Năm khối SQL trong [Word Người 2](nguoi2/Bao_cao_Nguoi2_FIX.docx) khớp từng dòng với năm tệp SQL rời. Word còn chứa các phần mã đặt tên `chung/03_Bao_ve_nghiep_vu.sql`, `chung/04_Kho_va_khuyen_mai.sql`, `chung/05a_Dong_mon_va_topping.sql` và `chung/05_Du_lieu_mau.sql`. Các phần này hiện có dưới dạng mã trong Word. Bộ tệp rời đang kiểm thiếu thư mục `chung/`. Phạm vi nhận xét là bản `Assignment_New_FIX` và log chạy riêng Người 2. [Tài liệu phân công](Phan_cong_BTL2_Database_SQL_Server.docx)

## Nội dung cần hoàn thiện theo đề

### 1. Ảnh và diễn giải kết quả trong báo cáo

Word đã có SQL dạng chữ và hai lưu đồ. Khi bổ sung minh chứng, nên ghép ảnh với kết quả tương ứng để người đọc thấy rõ thao tác và dữ liệu trả về.

- **Mục 1.1.a và 1.1.b.** Chèn ảnh các bảng và ràng buộc được tạo. Có thể dùng ca `SoKhach = 0` kỳ vọng lỗi `547` để minh họa `CHECK` sau khi nạp dữ liệu mẫu và chạy lại demo.
- **Mục 1.1.c.** Chạy lại trên cùng bộ dữ liệu có bản ghi khớp các truy vấn. Chụp Actual Execution Plan và phần Messages trước/sau cho I1–I5. Lượt hiện có cho `logical reads = 0` ở cả hai lượt, các truy vấn đều trả rỗng. Chỉ diễn giải hiệu quả từ số liệu trên dữ liệu đã nạp. [Log demo chỉ mục](BTL2_Original_20261119_222711_4f58c0ea/nguoi2_05_Demo_chi_muc.sql.log)
- **Mục 2.2.b.** Chụp dữ liệu `MON` và `SIZE_MON` trước/sau ca thêm nhiều món nháp. Thêm ảnh một ca bị chặn, chẳng hạn gán size `S` cho topping hoặc ngừng size đang bán cuối cùng.
- **Mục 2.1.b.** Trình bày màn hình đổi tên hoặc chuyển cha danh mục, đầu vào, dòng trả về và nhóm mã lỗi. Ghép ảnh kết quả đúng/sai với demo CRUD mà Người 4 thực hiện.

Theo mẫu nhận xét Người 1, báo cáo cần ít nhất một ảnh bao quát giao diện DBMS và có diễn giải đi kèm ảnh.

### 2. Lưu đồ và mô tả cần khớp với SQL

- **Lưu đồ UPDATE.** Code kiểm mã cha trùng mã danh mục và trả `51204` trước khi mở giao dịch hoặc đặt savepoint. Lưu đồ hiện gộp điều kiện này vào bước sau khi khóa. Nên đưa nhánh kiểm về đúng vị trí và bỏ chú thích về `WHILE` ở cuối hình vì thủ tục này xử lý bằng các nhánh điều kiện. [Lưu đồ UPDATE](nguoi2/hinh/luu_do_1.png) · [Thủ tục UPDATE](nguoi2/03_Thu_tuc_UPDATE.sql#L26)
- **Lưu đồ Trigger 2.** Hình hiện gộp các thao tác trên `MON` và `SIZE_MON` vào một luồng. Nên làm rõ nhánh tạo size nháp chỉ diễn ra khi thêm món và bổ sung nhánh `51211` khi đổi loại món còn quy cách. Phần kiểm cặp loại món–size và bảo vệ size đang bán cuối cùng thuộc trigger trên `SIZE_MON`. [Lưu đồ Trigger 2](nguoi2/hinh/luu_do_2.png) · [SQL Trigger 2](nguoi2/02_Trigger_2.sql)

## Nhận xét về SQL và ca kiểm thử

### 3. Đồng bộ bảng liên hệ nhân viên theo Excel

[`01_Cau_truc.sql`](nguoi2/01_Cau_truc.sql#L260) hiện định danh mỗi dòng bằng `(MaNV, Loai, GiaTri)`. Sheet `07_LUOC_DO_QUAN_HE` quy định `MaLienHe VARCHAR(30)` làm khóa chính, `MaNV VARCHAR(30) NOT NULL` làm khóa ngoại tới `NHAN_VIEN`, cùng hai cột `Sdt VARCHAR(20) NULL` và `Email VARCHAR(254) NULL`. Mỗi dòng cần ít nhất một giá trị liên hệ có nội dung. Kiểm duy nhất riêng cho mỗi cột sau khi chuẩn hóa và bảo đảm mỗi nhân viên có ít nhất một dòng liên hệ theo Excel.

Người 2 phụ trách sửa DDL. Câu chèn liên hệ trong dữ liệu mẫu chung kèm Word và câu `INSERT` của Người 4 cùng dùng ba cột cũ. Cần cập nhật các câu chèn theo DDL đã chốt trước khi chạy lại demo. [Đặc tả Excel](So_do_AND_CSV/EERD_UPDATE.xlsx) · [Ghi chú bàn giao](CHECK_BAO_CAO.md#người-2--đồng-bộ-bảng-liên-hệ-nhân-viên-theo-excel) · [Dữ liệu demo Người 4](nguoi4/08_Du_lieu_demo_bao_cao.sql#L33)

### 4. Các ca demo cần xác nhận dữ liệu sau thao tác

- **Ca lương của `NV01`.** Phép so sánh `<> 2400000` cho kết quả `UNKNOWN` nếu thiếu dòng hoặc lương bằng `NULL`, nên nhánh báo lỗi có thể bị bỏ qua. Nên kiểm sự tồn tại của dòng `NV01` có mức lương kỳ vọng. [Ca kiểm lương](nguoi2/04_Demo.sql#L15)
- **Ca UPDATE tên và cha.** Ca hiện truyền `DM_DOUONG`, vốn là cha của `DM_TRA` trong dữ liệu mẫu kèm Word. Ca này minh họa đổi tên thành công. Nếu muốn minh họa cả chuyển cha, dùng một cha hợp lệ khác rồi kiểm trực tiếp tên và mã cha sau UPDATE. Demo CRUD của Người 4 đã có ca tách cha và kiểm trực tiếp dòng trong bảng. [Ca UPDATE Người 2](nguoi2/04_Demo.sql#L10) · [Ca CRUD Người 4](nguoi4/05_Demo_CRUD.sql#L6)

### 5. Xác nhận quy tắc TC của topping ngừng bán

Trigger tự tạo `TC` khi thêm topping nháp. Điều kiện chặn mất quy cách đang bán cuối cùng áp dụng khi món ở trạng thái `DangBan`. Theo mã hiện tại, topping `NgungBan` có thể mất quy cách `TC` nếu quy cách đó chưa bị tham chiếu. Người 2 cần xác nhận với nhóm cách áp dụng BR05 cho món nháp. Nếu BR05 yêu cầu luôn giữ đúng một `TC`, bổ sung ca xóa `TC` của topping ngừng bán để kiểm quy tắc đã chốt. [Trigger trên SIZE_MON](nguoi2/02_Trigger_2.sql#L31) · [Đối chiếu BR05 trong nhận xét Người 1](NHAN_XET_NGUOI_1.md)

## Góp ý khi ghép báo cáo

- Đóng gói lại các tệp `chung/` từ bản nguồn của nhóm để có seed và các ràng buộc hỗ trợ. View `dbo.v_N2_LuongNhanVien` đã có mã trong phần `03_Bao_ve_nghiep_vu.sql` đính kèm Word. Cần thêm định nghĩa `dbo.usp_FIX_Test` từ bản ghép để chạy các ca trong `04_Demo.sql`.
- Đổi số mục demo chỉ mục trong Word và Markdown từ **1.2** thành **1.1.c** theo tài liệu phân công. Người 3 sở hữu mã tạo I1–I5, Người 2 phụ trách đo trước/sau. Hai script hiện có cùng định nghĩa chỉ mục.
- Cập nhật đoạn tình trạng kiểm chứng trong Word theo lượt chạy thực tế. Có thể dùng log hiện tại để ghi nhận đã cài được các đối tượng. Ảnh demo nghiệp vụ và số liệu hiệu năng cần đến từ lượt chạy có đủ phụ thuộc và dữ liệu.

## Mức độ kiểm chứng

Đã đối chiếu phân công, SQL, sheet 07 của Excel, Word, hai lưu đồ và log thực thi. Nhật ký SQL Server 2025 ghi **4/5 tệp của Người 2 hoàn tất** và xác nhận SHA-256 của cả 8 tệp đã đưa vào lượt chạy. `04_Demo.sql` ghi 22 lần cùng lỗi `Msg 2812` vì thiếu `dbo.usp_FIX_Test`, nên chưa có kết quả đạt hay trượt cho từng ca nghiệp vụ. Demo chỉ mục hoàn tất trên bảng rỗng. Các góp ý về điều kiện kiểm lương, đổi cha và quy cách TC dựa trên đọc mã nguồn, chưa chạy đối chứng có seed. [Tổng hợp lượt chạy](BTL2_Original_20261119_222711_4f58c0ea/summary.csv) · [Log lỗi demo nghiệp vụ](BTL2_Original_20261119_222711_4f58c0ea/nguoi2_04_Demo.sql.log)
