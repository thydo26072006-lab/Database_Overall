# Nhận xét bài Người 1 do Người 3 kiểm tra

Rà soát ngày 19/11/2026. Bảy bảng của Người 1 khớp lược đồ quan hệ đã chốt. Ba tệp SQL cũng khớp các phần tương ứng trong bản lead ghép. Điểm còn thiếu theo đề là ảnh và diễn giải kết quả trong báo cáo. Trong phần demo, có hai ca cần xem lại cách xác nhận kết quả.

## Đối chiếu với đề và phân công

| Phần được giao | Kết quả rà soát |
| --- | --- |
| 1.1.a và 1.1.b — Tạo bảng và ràng buộc | `01_Cau_truc.sql` tạo 7 bảng gồm `BAN`, `DANH_MUC_MON`, `MON`, `SIZE_MON`, `HANG_HOA`, `CONG_THUC` và `CHI_TIET_CONG_THUC`. Cột, kiểu dữ liệu, NULL, khóa chính và khóa ngoại khớp sheet 07 của EERD. Có 17 CHECK trong phần Người 1 và 74 CHECK trong bản ghép. Mức tối thiểu của đề là 10 CHECK trên toàn CSDL. |
| 1.1 — Demo bảng và ràng buộc | Có lệnh tra bảng và CHECK, dữ liệu mẫu chung và log chạy. Word còn thiếu ảnh và diễn giải. |
| 2.2.a — Trigger 1 và demo | `trg_N1_DanhMuc_KhongChuTrinh` chạy khi INSERT hoặc UPDATE trên một bảng `DANH_MUC_MON`. Việc chặn chu trình qua nhiều cấp phù hợp BR04/R03. Bộ demo có ca INSERT nhiều dòng và UPDATE tạo vòng bị chặn. |
| 2.1.a — Thủ tục INSERT | `usp_N1_ThemDanhMuc` thao tác trên bảng CRUD chung `DANH_MUC_MON`, có kiểm tra đầu vào và xử lý lỗi. Người 1 phụ trách thủ tục INSERT. Người 4 phụ trách demo chung INSERT/UPDATE/DELETE theo `phan_cong.docx`. |

**Bản được đối chiếu.** Cả ba tệp SQL của Người 1 đều khớp nội dung với các phần tương ứng trong bản ghép của lead: `01_Cau_truc.sql` (dòng 40), `02_Trigger_INSERT.sql` (dòng 543) và `03_Demo.sql` (dòng 1787). SQL trong Word cũng khớp với các tệp riêng và các phần hỗ trợ, dữ liệu mẫu đã trích từ Phần 06–09 của bản ghép.

## Nội dung cần hoàn thiện theo đề

### 1. Ảnh và diễn giải kết quả trong báo cáo

`Bao_cao_Nguoi1_FIX.docx` có SQL dạng chữ và hai ảnh lưu đồ. `KET_QUA_CHAY_SQLSERVER.txt` ghi 15/15 ca đạt trên bản ghép. Khi hoàn thiện báo cáo, các mục sau cần có minh chứng theo `de_bai.docx`:

- **Mục 1.1:** Ảnh tạo bảng thành công, các bảng đã tạo và ràng buộc được áp dụng. Hai ca giá âm và giá có phần lẻ trong log đều bị `CK_SIZE_MON_Gia` từ chối, có thể dùng để giải thích ràng buộc hoạt động thế nào.
- **Mục 2.2.a:** Ảnh tạo trigger, dữ liệu danh mục trước và sau khi chạy, kèm kết quả của ca hợp lệ và ca bị chặn. Có thể chọn các ca hiện có nếu chúng cho thấy đầy đủ dữ liệu và kết quả. Ca INSERT nhiều dòng và UPDATE tạo vòng đã có mã 51010 trong log. Trigger chỉ chạy với INSERT và UPDATE. Ca DELETE cha còn con trả mã 547 từ khóa ngoại.
- **Mục 2.1.a:** Mô tả mục đích, trường hợp sử dụng, màn hình, đầu vào, đầu ra, lưu đồ và lệnh tạo thủ tục INSERT thuộc phần Người 1. Khi ghép mục 2.1, nhóm bổ sung ảnh tạo thủ tục và kết quả chạy các trường hợp đúng/sai kèm dữ liệu mẫu. Phần demo CRUD chung do Người 4 phụ trách.

Ảnh cần có diễn giải và báo cáo cần có ít nhất một ảnh bao quát giao diện DBMS với nội dung tương ứng, theo phần lưu ý của đề. Việc chọn số ảnh và cách bố trí tùy theo kết quả chạy.

### 2. Lưu đồ và mô tả cần khớp với SQL

- **Lưu đồ INSERT** (`hinh/luu_do_1.png`) chưa thể hiện rõ điều kiện từ chối mã cha trùng mã danh mục (51006). Chú thích đang nhắc đến WHILE, trong khi thủ tục INSERT không có vòng lặp. Phần mô tả hoặc lưu đồ có thể làm rõ thêm cách xử lý khi bên gọi đã mở giao dịch. Với `XACT_ABORT ON` và `THROW`, nếu giao dịch đã ở trạng thái `XACT_STATE() = -1`, bên gọi cần hoàn tác toàn bộ giao dịch đó. [Microsoft Learn về XACT_ABORT](https://learn.microsoft.com/en-us/sql/t-sql/statements/set-xact-abort-transact-sql/) · [Microsoft Learn về XACT_STATE](https://learn.microsoft.com/en-us/sql/t-sql/functions/xact-state-transact-sql/)
- **Lưu đồ Trigger 1** (`hinh/luu_do_2.png`) dùng cụm “trả kết quả / chấp nhận” ở nhánh hợp lệ. Nên diễn đạt rõ là trigger kết thúc và cho phép thao tác tiếp tục. Trigger không trả bảng kết quả.

## Nhận xét về SQL và ca kiểm thử

### 3. Hai ca demo có thể báo đạt khi chưa xác nhận được dữ liệu

- **Thêm danh mục cha và con** (`03_Demo.sql:12–15`, bản ghép dòng 1798–1801). Phép so sánh `<>` không làm nhánh báo lỗi chạy nếu dòng con bị thiếu hoặc mã cha là `NULL`. Ca kiểm thử cần xác nhận dòng con thực sự tồn tại và trỏ đúng danh mục cha. Cách kiểm có thể tùy tác giả.
- **Xóa danh mục rỗng** (`03_Demo.sql:23`). Nếu mã mẫu không tồn tại, lệnh DELETE có thể xóa 0 dòng mà ca vẫn báo đạt. Nếu giữ ca này, nên xác nhận thao tác đã xóa đúng dòng mẫu.

Đây là nhận xét về điều kiện báo đạt trong demo. Log bàn giao vẫn ghi 15/15 ca đạt với dữ liệu đã dùng. Để minh họa rõ hơn nhánh hợp lệ của Trigger 1, có thể thêm một ca UPDATE đổi cha thành công. Đề yêu cầu minh họa ca đúng, ca lỗi và dữ liệu trước/sau, nhưng không chỉ định phải dùng riêng phép thử đổi cha này.

### 4. Kết quả INSERT khi có thao tác đồng thời

Ở `02_Trigger_INSERT.sql:114–123` (bản ghép dòng 656–665), khi thủ tục tự mở giao dịch, lệnh `COMMIT` chạy trước khi `SELECT` đọc lại dòng theo mã. Nếu phiên khác sửa hoặc xóa dòng giữa hai lệnh, dữ liệu trả về có thể khác dữ liệu vừa thêm hoặc không có dòng nào. Đây là góp ý về tính nhất quán của đầu ra, ngoài phạm vi 15 ca trong log. Có thể cân nhắc giữ lại thông tin của dòng vừa thêm trước khi kết thúc giao dịch. [Microsoft Learn về OUTPUT](https://learn.microsoft.com/en-us/sql/t-sql/queries/output-clause-transact-sql/)

## Góp ý khi ghép báo cáo

- Trong Word, câu “Chưa có ảnh DBMS/kết quả SQL Server mới” nên phản ánh đúng tình trạng hiện tại là đã có log và còn thiếu ảnh. Có hai tệp được dẫn chiếu chưa thấy trong gói nhận được là `KIEM_TRA_CU_PHAP.txt` và `build/NGUON_SHA256.json`. Có thể cập nhật đường dẫn nếu các tệp này ở thư mục chung.
- `BAO_CAO.md` đã nêu các phụ thuộc chính của demo. Nếu cần ghi rõ cách chạy riêng, có thể hướng dẫn dùng CSDL đã dựng tới hết Phần 17 của SQL tổng, rồi chạy `03_Demo.sql` ngoài giao dịch đang mở. Phần 18 của SQL tổng đã chạy các ca này khi chạy toàn bộ bản ghép.

## Hai điểm để nhóm xác nhận

- **Quy cách TC của topping ngừng bán.** BR05 và sheet 07 ghi mỗi topping có đúng một quy cách TC. Bản ghép tự thêm TC khi tạo món nháp, nhưng điều kiện chặn việc mất quy cách cuối chỉ áp dụng cho món `DangBan` (dòng 694–731). Với món `NgungBan` mà TC chưa được tham chiếu, code cho thấy có thể xóa TC. Nhờ lead và Người 2 xác nhận trạng thái này có được phép theo nghiệp vụ đã chốt.
- **Số bảng trong EERD.** Sheet 07 và SQL tổng đều có 30 bảng. Ghi chú BR54 ở sheet 03 còn ghi 31 bảng. Số 30 trong báo cáo Người 1 khớp với lược đồ hiện tại.

## Mức độ kiểm chứng

Đã đối chiếu đề, phân công, EERD, SQL, báo cáo, hai lưu đồ và log. SHA-256 của SQL tổng và ba tệp riêng đều khớp mã ghi trong log bàn giao. Log ghi SQL Server 2022, 30 bảng, 74 CHECK và 15/15 ca đạt. Các góp ý về ca báo đạt sai, thao tác đồng thời và topping được ghi nhận qua đọc mã nguồn, chưa chạy đối chứng.
