# PHÂN CÔNG NHIỆM VỤ BÀI TẬP LỚN SỐ 2

[Phần 3 của Người 1 – Danh mục món](nguoi1/phan3/README.md)

MÔN HỆ CƠ SỞ DỮ LIỆU  |  PHẦN 1 VÀ PHẦN 2

Nhóm: ..........................................    Chủ đề: ............................................................

Công cụ thống nhất: Microsoft SQL Server; sử dụng Transact-SQL (T-SQL) và hệ quản trị theo slide môn học. Hạn hoàn thành toàn nhóm: 23:00, ngày 16/11/2026 (trước ngày 17/11).

## 1. Nguyên tắc phân chia và tài liệu đối chiếu

Mỗi thành viên phụ trách đúng 4,0/20,0 điểm: Phần 1 (2,0 điểm) và Phần 2 (2,0 điểm); tổng đóng góp dự kiến 20%/người. Mỗi hàng trong bảng kê nhiệm vụ của giảng viên chỉ có một người nhận điểm. Cặp nội dung viết câu lệnh và demo được giao cùng người khi có thể; phần khác người phải có bàn giao minh bạch.

Thuật ngữ kỹ thuật sử dụng thống nhất: bảng dữ liệu; ràng buộc CHECK; chỉ mục (INDEX); câu truy vấn SELECT; thủ tục lưu trữ (Stored Procedure); hàm (Function); bộ kích hoạt (Trigger); con trỏ (Cursor); xử lý lỗi (Error Handling); điều kiện và vòng lặp. Không mặc định mọi thủ tục/hàm bắt buộc dùng Cursor nếu có phương án T-SQL phù hợp và vẫn đáp ứng yêu cầu của cô.

## 2. Bảng phân công theo đúng điểm thành phần

| Thành viên | PHẦN 1 – 2,0 điểm | PHẦN 2 – 2,0 điểm | Hạn cá nhân |
| --- | --- | --- | --- |
| Người 1 | 1.1.a Tạo bảng phần 1 (1,0); 1.1.b ràng buộc phần 1 (0,5); 1.1 Demo bảng/ràng buộc (0,5) | 2.2.a Trigger 1 + demo (1,5); 2.1.a INSERT (0,5) | 11/11, 23:00 |
| Người 2 | 1.1.a Tạo bảng phần 2 (1,0); 1.1.b ràng buộc phần 2 (0,5); 1.1.c Demo chỉ mục (0,5) | 2.2.b Trigger 2 + demo (1,5); 2.1.b UPDATE (0,5) | 12/11, 23:00 |
| Người 3 | 1.1.c Chỉ mục phần 1 và 2 (1,0); truy vấn 1 (1,0) | 2.3.a Thủ tục 1 + demo (1,25); 2.1.c DELETE (0,5); 2.4.a Demo hàm 1 (0,25) | 13/11, 23:00 |
| Người 4 | Truy vấn 2 (1,0); truy vấn 3 (1,0) | 2.3.b Thủ tục 2 + demo (1,25); 2.1 Demo INSERT/UPDATE/DELETE (0,5); 2.4.b Demo hàm 2 (0,25) | 14/11, 12:00 |
| Người 5 | Truy vấn 4 (1,0); truy vấn 5 (1,0) | 2.4.a Hàm 1 (1,0); 2.4.b Hàm 2 (1,0) | 14/11, 12:00 |

Lưu ý: “truy vấn 1–5” tương ứng năm hàng 1.2.a–1.2.e trong BẢNG KÊ NHIỆM VỤ của mẫu; phần nội dung báo cáo ghi mục “1.3 Truy vấn dữ liệu”. Các mục CREATE INDEX và demo chỉ mục được gộp theo điểm của bảng kê.

## 3. Mô tả công việc và đầu ra cần bàn giao

### Người 1 – Cấu trúc bảng và Trigger 1

Thiết kế, tạo các bảng được phân công bằng CREATE TABLE; xác định khóa chính, khóa ngoại và ràng buộc CHECK theo quy tắc nghiệp vụ. Viết Trigger 1 trên một bảng, xử lý sự kiện INSERT/UPDATE/DELETE khi hợp lý; kiểm tra dữ liệu trước/sau và trường hợp đúng/sai. Viết thủ tục lưu trữ INSERT có kiểm tra điều kiện và xử lý lỗi. Bàn giao script bảng và dữ liệu mẫu sớm cho cả nhóm.

### Người 2 – Cấu trúc bảng và Trigger 2

Phụ trách các bảng còn lại và ràng buộc tương ứng; phối hợp với Người 3 chụp màn hình, diễn giải hiệu quả truy vấn trước/sau khi tạo chỉ mục. Viết Trigger 2 liên quan hơn một bảng, gắn với quy tắc nghiệp vụ có ảnh hưởng liên bảng. Viết thủ tục UPDATE trên cùng bảng CRUD đã thống nhất.

### Người 3 – Chỉ mục, truy vấn và thủ tục 1

Viết CREATE INDEX và giải thích chỉ mục phục vụ chức năng, màn hình nào; kiểm chứng hiệu quả trước/sau (phối hợp Người 2). Viết truy vấn 1; xây dựng thủ tục lưu trữ 1 trả về dữ liệu từ một/nhiều bảng, có điều kiện và vòng lặp; thực hiện demo. Viết DELETE trên bảng CRUD chung. Nhận và thực hiện demo hàm 1 từ Người 5.

### Người 4 – Truy vấn, thủ tục 2 và demo CRUD

Viết truy vấn 2–3, bảo đảm hai câu có mục đích độc lập và dữ liệu mẫu phù hợp. Xây dựng thủ tục lưu trữ 2 có đầu vào/đầu ra phù hợp, xử lý điều kiện và vòng lặp; vẽ lưu đồ và demo đúng/sai. Tổng hợp test INSERT/UPDATE/DELETE do Người 1, 2, 3 viết để thực hiện demo chung. Nhận và demo hàm 2 từ Người 5.

### Người 5 – Truy vấn tổng hợp và hai hàm

Viết truy vấn 4–5; nhận phân loại truy vấn từ nhóm để đủ năm dạng cô yêu cầu. Viết hai hàm (Function) có truy xuất dữ liệu từ một/nhiều bảng, xử lý điều kiện và vòng lặp, định nghĩa rõ đầu vào, kiểu dữ liệu trả về và kết quả mẫu. Giao script, dữ liệu và các trường hợp kiểm thử hàm 1 cho Người 3, hàm 2 cho Người 4.

## 4. Quy định SQL Server và kiểm thử theo mẫu báo cáo

- Các câu lệnh phải viết dưới dạng TEXT, không dùng ảnh chụp thay cho mã SQL. Ảnh minh họa phải có ít nhất một ảnh bao quát giao diện DBMS, có mô tả kết quả và dữ liệu mẫu.

- Năm truy vấn phải gồm: hai truy vấn có SELECT, FROM, WHERE, ORDER BY; hai truy vấn có SELECT, FROM, WHERE, GROUP BY, ORDER BY và hàm tổng hợp; một truy vấn có hai truy vấn con lồng nhau và hàm tổng hợp. Nhóm phân loại trước khi viết để không trùng dạng.

- Mục 2.1: ba thủ tục INSERT, UPDATE, DELETE thao tác trên một bảng dữ liệu, có kiểm tra điều kiện và xử lý ngoại lệ. Người 1, 2, 3 chia nhau phần code; Người 4 nhận toàn bộ để demo.

- Mục 2.2: một Trigger trên một bảng; một Trigger ảnh hưởng hơn một bảng. Trigger không chỉ kiểm tra những ràng buộc có thể khai báo trực tiếp bằng PRIMARY KEY, UNIQUE, NOT NULL hoặc CHECK. Demo các trường hợp INSERT/UPDATE/DELETE có ý nghĩa.

- Mục 2.3 và 2.4: mỗi loại gồm hai yêu cầu; có dữ liệu trả về từ một hoặc nhiều bảng, có câu lệnh điều kiện và vòng lặp; trình bày mô tả, lưu đồ (nơi mẫu yêu cầu), Input, Output, SQL, demo trường hợp hợp lệ và báo lỗi.

- Bám sát cú pháp trong slide SQL Server: CREATE TABLE, ALTER TABLE ... ADD CONSTRAINT, CREATE INDEX, CREATE OR ALTER PROCEDURE, CREATE OR ALTER FUNCTION, CREATE OR ALTER TRIGGER; thực thi trong cùng một cơ sở dữ liệu, thống nhất tên đối tượng và kiểu dữ liệu.

- Chỉ sử dụng tên bảng, cột, điều kiện nghiệp vụ từ ERD/BTL1 đã được nhóm chốt. Không tự thêm thuộc tính hoặc thay đổi quy tắc mà chưa cập nhật ERD và ghi chú thay đổi so với BTL1.

## 5. Tiến độ và cách ghép bài

| Thời gian | Công việc bắt buộc | Người phụ trách |
| --- | --- | --- |
| 10–11/11 | Chốt ERD, tên bảng, dữ liệu mẫu; chạy script CREATE TABLE và ràng buộc | Người 1, 2 (cả nhóm duyệt) |
| 12–13/11 | Hoàn thành chỉ mục, Trigger, Stored Procedure và Function theo phần việc; test độc lập | Người 2, 3, 4, 5 |
| 14/11, 12:00 | Hoàn thành mọi phần việc cá nhân; bàn giao mã SQL, lưu đồ, ảnh và diễn giải | Cả 5 người |
| 15/11, 23:00 | Tích hợp một bộ script; kiểm thử dữ liệu mẫu, kiểm tra điểm và loại truy vấn | Cả nhóm |
| 16/11, 23:00 | Chốt báo cáo Word và BẢNG KÊ NHIỆM VỤ; chuẩn bị SQL và dữ liệu chạy sẵn để vấn đáp | Cả nhóm |

## 6. Nguyên tắc bàn giao liên kết

Người 1/2 → cả nhóm: lược đồ bảng, tên cột, khóa và dữ liệu mẫu. Người 3 → Người 2: mã tạo chỉ mục và kết quả đo trước/sau. Người 1/2/3 → Người 4: ba thủ tục CRUD và bộ test. Người 5 → Người 3/4: hàm 1/hàm 2 và bộ test. Mỗi người nộp: tập tin .sql, nội dung báo cáo, hình chụp, mô tả use case và dữ liệu mẫu để người ghép báo cáo không phải viết lại.

Nhóm phải hiểu cả nội dung không được phân công vì giảng viên có thể hỏi chéo kỹ thuật trong buổi báo cáo.

## 7. Đối chiếu thang điểm

| Thành viên | Phần 1 | Phần 2 | Tổng | Tỷ lệ |
| --- | --- | --- | --- | --- |
| Người 1 | 2,0 | 2,0 | 4,0 | 20% |
| Người 2 | 2,0 | 2,0 | 4,0 | 20% |
| Người 3 | 2,0 | 2,0 | 4,0 | 20% |
| Người 4 | 2,0 | 2,0 | 4,0 | 20% |
| Người 5 | 2,0 | 2,0 | 4,0 | 20% |
| Tổng | 10,0 | 10,0 | 20,0 | 100% |

---

Phân công BTL2 Hệ cơ sở dữ liệu – SQL Server | Hoàn thành trước 17/11/2026
