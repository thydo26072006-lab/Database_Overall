# PHÂN CÔNG NHIỆM VỤ BÀI TẬP LỚN SỐ 2

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

---

# PHẦN 3 – HIỆN THỰC ỨNG DỤNG (10 ĐIỂM)

**Chủ đề:** Hệ thống quản lý gọi món / đặt món.  
**Công nghệ đề xuất thống nhất:** React (Frontend), Node.js + Express (Backend), Microsoft SQL Server (Database).  
**Hạn hoàn thành toàn nhóm: 23:00, ngày 26/11/2026 (trước ngày 27/11/2026).**

> Phần 3 tiếp tục sử dụng các Stored Procedure, Function và Trigger đã thực hiện trong Phần 2. Đây là phân chia **khối lượng thực hiện**; việc ghi điểm vào bảng kê phải đối chiếu mẫu của giảng viên. Không thay thế các deadline của Phần 1–2 ở trên.

## 8. Nguyên tắc phân chia và yêu cầu đối chiếu

- **Yêu cầu 1 (2,5đ):** Màn hình hiển thị dữ liệu, thêm, cập nhật và xoá **bằng ba Stored Procedure của mục 2.1**.
- **Yêu cầu 2 (2,5đ):** Màn hình hiển thị dữ liệu và thực hiện các thao tác có liên quan đến **một trong hai Trigger ở mục 2.2**.
- **Yêu cầu 3 (2,0đ):** Màn hình sử dụng Stored Procedure hoặc Function đã xây dựng ở Phần 2 theo yêu cầu của đề bài.
- **Hỏi đáp – demo (2,0đ):** Ứng dụng chạy được, dữ liệu cập nhật thật trong SQL Server, các thành viên hiểu quy trình đã làm.
- **Yêu cầu 1 và 2 không được dùng trùng màn hình.** Yêu cầu 3 có thể dùng chung màn hình với một trong hai yêu cầu trước nếu nghiệp vụ phù hợp.
- Giữ nguyên tên bảng, thuộc tính, tham số, điều kiện nghiệp vụ và đối tượng T-SQL đã thống nhất; không viết lại toàn bộ logic ở Frontend để thay cho thủ tục/hàm.

## 9. Bảng phân công nhiệm vụ và deadline Phần 3

| Thành viên | Công việc chính | Liên kết Phần 2 | Đầu ra bàn giao | Deadline |
| --- | --- | --- | --- | --- |
| **Người 1** | Màn hình CRUD: danh sách, thêm, cập nhật, xoá; kiểm tra thông báo và lỗi | 2.1.a INSERT (Người 1); tích hợp UPDATE (Người 2), DELETE (Người 3) | Màn hình CRUD, API, ca kiểm thử đúng/sai, ảnh trước/sau | **24/11/2026 – 23:00** |
| **Người 2** | Màn hình nghiệp vụ Trigger riêng biệt; thực hiện DML và chứng minh Trigger kích hoạt | 2.2.a hoặc 2.2.b; ưu tiên Trigger 2 nếu phù hợp | Màn hình Trigger, API, dữ liệu minh chứng, ảnh và ca kiểm thử | **24/11/2026 – 23:00** |
| **Người 3** | Màn hình nhập tham số, gọi Stored Procedure / Function, hiển thị kết quả và lỗi | Ưu tiên 2.3.a Thủ tục 1; có thể chọn đối tượng khác đã hoàn thành nếu phù hợp | Màn hình xử lý nghiệp vụ, API, kết quả trả về và ảnh demo | **24/11/2026 – 23:00** |
| **Người 4** | Giao diện chung, menu điều hướng, tích hợp Frontend; Sequence Diagram / Flowchart, báo cáo mục 3.2 | Phối hợp Người 1–3, đối chiếu demo CRUD mục 2.1 | UI thống nhất, sơ đồ FE–BE–DB, nội dung báo cáo 3.2 | **25/11/2026 – 23:00** |
| **Người 5** | Backend chung, cấu hình SQL Server, quy ước API, kiểm thử tích hợp, báo cáo 3.1 và chuẩn bị demo | Liên kết toàn bộ Phần 2, đặc biệt Function 2.4 | Source chạy chung, README hướng dẫn chạy, báo cáo 3.1, bộ demo | **26/11/2026 – 12:00** |
| **Cả nhóm** | Kiểm thử đầu-cuối; kiểm tra Word, README, ảnh minh chứng và luyện hỏi đáp | Toàn bộ | Bản ứng dụng và báo cáo cuối cùng | **26/11/2026 – 23:00** |

## 10. Mô tả công việc và đầu ra theo từng người

### Người 1 – Màn hình CRUD (Yêu cầu 1)

- Chốt **một bảng dữ liệu chung** đúng với các Stored Procedure INSERT / UPDATE / DELETE mục 2.1. Không tự chuyển sang bảng `MON` nếu ba thủ tục hiện tại thao tác trên bảng khác.
- Xây dựng danh sách dữ liệu từ SQL Server, form thêm/sửa và chức năng xoá có xác nhận.
- Backend phải gọi **đúng ba Stored Procedure đã thực hiện** (không thay bằng INSERT / UPDATE / DELETE trực tiếp để lấy điểm yêu cầu 1).
- Sau mỗi thao tác tải lại dữ liệu thật; hiển thị thành công, kiểm tra điều kiện và thông báo lỗi.
- Bàn giao source, endpoint API, test đúng/sai, ảnh trước/sau và mô tả nghiệp vụ cho Người 4.
- **Deadline: 23:00 ngày 24/11/2026.**

### Người 2 – Màn hình Trigger (Yêu cầu 2)

- Chọn đúng một Trigger mục 2.2; màn hình nghiệp vụ **khác** màn hình CRUD của Người 1.
- Có chức năng xem dữ liệu và thao tác thêm, cập nhật, xoá phù hợp nghiệp vụ để kích hoạt Trigger.
- Trigger **tự kích hoạt khi thực thi DML trên SQL Server**, không gọi Trigger trực tiếp từ Frontend.
- Chứng minh dữ liệu bảng chính và bảng liên quan thay đổi trước/sau; kiểm thử trường hợp hợp lệ và lỗi.
- Bàn giao source, API, tên Trigger, thao tác kích hoạt, ca kiểm thử và ảnh minh chứng.
- **Deadline: 23:00 ngày 24/11/2026.**

### Người 3 – Màn hình Stored Procedure / Function (Yêu cầu 3)

- Ưu tiên tái sử dụng Thủ tục 1 tại mục 2.3.a; chỉ chọn thủ tục/hàm khác đã có nếu khớp quy trình.
- Xây dựng ô nhập tham số, nút thực thi và khu vực hiển thị kết quả trả về.
- Kiểm thử tham số hợp lệ, tham số sai và trường hợp không có dữ liệu.
- Ghi rõ tên đối tượng SQL, input, output và cách hiển thị; không thay xử lý tại Database bằng tính toán chỉ có ở Frontend.
- Bàn giao source, API, ảnh thành công/lỗi, mô tả luồng FE–BE–Database.
- **Deadline: 23:00 ngày 24/11/2026.**

### Người 4 – Giao diện chung và báo cáo 3.2

- Thiết kế trang chủ, menu điều hướng, kiểu bảng dữ liệu, biểu mẫu, nút và thông báo thống nhất.
- Ghép ba màn hình thành **một ứng dụng**; phối hợp Người 1 kiểm tra đủ chức năng CRUD.
- Vẽ Sequence Diagram hoặc Flowchart từng quy trình, thể hiện Frontend → Backend → SQL Server và Stored Procedure / Function / Trigger tương ứng.
- Viết mục **3.2 Chi tiết hiện thực**: màn hình, chức năng, thao tác, sơ đồ, đối tượng SQL, hình chụp minh hoạ và diễn giải.
- **Deadline: 23:00 ngày 25/11/2026.**

### Người 5 – Backend chung, kiến trúc và demo

- Thiết lập cấu hình kết nối SQL Server dùng chung; thống nhất routes / controllers / services, định dạng API response và xử lý lỗi.
- Phối hợp tích hợp API thực thi Stored Procedure, Function và DML làm phát sinh Trigger; hỗ trợ, **không viết thay toàn bộ** phần của Người 1–3.
- Viết mục **3.1 Mô tả công nghệ, cấu trúc source, kiến trúc**; README hướng dẫn cài đặt, cấu hình và chạy.
- Không đưa tài khoản/mật khẩu SQL Server hoặc tệp `.env` chứa bí mật lên GitHub.
- Kiểm thử toàn bộ luồng từ giao diện tới SQL Server; chuẩn bị dữ liệu demo và tình huống hỏi đáp.
- **Deadline: 12:00 ngày 26/11/2026.**

## 11. Các màn hình nghiệp vụ đề xuất

| Màn hình | Chức năng minh hoạ | Điều kiện bắt buộc |
| --- | --- | --- |
| Quản lý thực đơn / bảng CRUD thực tế | Xem danh sách; form thêm/sửa; xác nhận xoá | Chỉ dùng quản lý thực đơn nếu cả ba thủ tục 2.1 thao tác trên đúng bảng đó; nếu không phải thay theo SQL thực tế |
| Quản lý đơn hàng / chi tiết đơn | Thêm món, sửa số lượng, xoá dòng món, quan sát dữ liệu thay đổi | Phải khớp Trigger mục 2.2 thực tế và không trùng màn hình Yêu cầu 1 |
| Tra cứu / xử lý nghiệp vụ | Nhập tham số; gọi Stored Procedure hoặc Function; trình bày kết quả | Có thể tích hợp vào màn hình 1 hoặc 2 nếu đúng nghiệp vụ |
| Trang chủ / điều hướng | Đi đến các chức năng, giới thiệu hệ thống | Chỉ là giao diện hỗ trợ, không thay thế minh chứng ba yêu cầu |

## 12. Công nghệ, kiến trúc và cấu trúc source thống nhất

**Kiến trúc đề xuất:** Frontend (React) gửi HTTP request tới Backend (Node.js + Express); Backend kết nối Microsoft SQL Server để thực thi Stored Procedure, Function hoặc thao tác DML kích hoạt Trigger. Frontend không kết nối trực tiếp SQL Server.

```text
Database_Overall/
├── frontend/
│   └── src/
│       ├── pages/
│       ├── components/
│       └── services/
├── backend/
│   └── src/
│       ├── routes/
│       ├── controllers/
│       ├── services/
│       └── config/
├── database/
│   └── *.sql
└── README.md
```

**Lưu ý:** Đây là cấu trúc dự kiến dành cho phần phát triển ứng dụng, không phải xác nhận repository hiện đã có đủ các thư mục trên. Sử dụng một repository và branch riêng cho từng người; thống nhất tên endpoint, đối tượng SQL, kiểu dữ liệu và định dạng trả về trước khi ghép.

## 13. Tiến độ và quy định bàn giao

| Mốc thời gian | Công việc bắt buộc | Người phụ trách |
| --- | --- | --- |
| **22/11/2026 – 23:00** | Chốt bảng CRUD, ba thủ tục 2.1, Trigger 2.2 được chọn, thủ tục/hàm cho Yêu cầu 3; thống nhất API và giao diện | Cả nhóm; Người 5 tổng hợp |
| **24/11/2026 – 23:00** | Hoàn thiện ba màn hình nghiệp vụ, các API tương ứng, kiểm thử đúng/sai và bàn giao | Người 1, 2, 3 |
| **25/11/2026 – 23:00** | Hoàn thành giao diện chung, tích hợp Frontend, sơ đồ tương tác và báo cáo mục 3.2 | Người 4; cả nhóm phối hợp |
| **26/11/2026 – 12:00** | Hoàn thiện Backend dùng chung, kết nối SQL Server, báo cáo 3.1, kiểm thử tích hợp và hướng dẫn chạy | Người 5 |
| **26/11/2026 – 23:00** | Kiểm thử đầu-cuối, chụp minh chứng, hoàn thiện báo cáo, README và luyện demo/hỏi đáp | Cả 5 người |

**Mỗi thành viên bàn giao:** mã nguồn, hướng dẫn chạy, tên bảng/thủ tục/hàm/trigger đã dùng, dữ liệu mẫu, kiểm thử đúng/sai, ảnh chụp trước/sau và phần mô tả liên quan. Ảnh minh hoạ phải có chú thích; sơ đồ phải thể hiện đúng luồng FE–BE–Database.

## 14. Checklist kiểm tra trước khi nộp Phần 3

- [ ] Có ít nhất hai màn hình **khác nhau** tương ứng Yêu cầu 1 và Yêu cầu 2.
- [ ] Yêu cầu 1 hiển thị dữ liệu và thực hiện INSERT / UPDATE / DELETE thông qua **ba Stored Procedure mục 2.1**.
- [ ] Yêu cầu 2 phát sinh thao tác DML thực tế từ ứng dụng để kích hoạt **một Trigger mục 2.2**, có dữ liệu chứng minh trước/sau.
- [ ] Yêu cầu 3 gọi đúng Stored Procedure / Function đã làm trong Phần 2, có tham số và kết quả minh hoạ.
- [ ] Mục 3.1 trình bày công nghệ, kiến trúc FE–BE–Database và cấu trúc source.
- [ ] Mục 3.2 mô tả màn hình, chức năng, Sequence Diagram / Flowchart và đối tượng SQL liên quan.
- [ ] Ứng dụng chạy được với cùng SQL Server, có dữ liệu mẫu và README hướng dẫn.
- [ ] Tất cả thành viên chuẩn bị hỏi đáp về Stored Procedure, Function, Trigger và xử lý lỗi.
- [ ] Hoàn thành và kiểm tra chung **trước 23:00 ngày 26/11/2026**.

## 15. Lưu ý đối chiếu điểm Phần 3

Trong phần mô tả yêu cầu: Yêu cầu 1 = **2,5đ**, Yêu cầu 2 = **2,5đ**, Yêu cầu 3 = **2,0đ**, hỏi đáp – demo = **2,0đ**. Bảng kê cuối mẫu báo cáo trình bày trọng số khác; bảng phân công trên mô tả **đầu việc** chứ không tự quy đổi thành 2,0 điểm/người. Khi điền bảng kê chính thức, nhóm đối chiếu cách tính điểm với giảng viên và tuân thủ nguyên tắc mỗi hàng do một thành viên đảm nhận.

## 16. Cấu trúc tổng hợp 5 thành viên và hướng dẫn chạy ứng dụng Phần 3

### Cấu trúc thư mục tổng hợp trên `main`

| Thành viên / Thành phần | Phần 1 & 2 | Phần 3 / Ứng dụng | Ghi chú |
| --- | --- | --- | --- |
| **Tài liệu chung** | `BTL2_SQL_TONG_HOP.sql`, `EERD_UPDATE.xlsx`, `EERD_VE_LAI.drawio`, `README.md` | `frontend/`, `backend/`, `database/` | Ứng dụng tích hợp đầy đủ 3 yêu cầu Phần 3 |
| **Người 1** | `nguoi1/` (`01_Cau_truc.sql`, `02_Trigger_INSERT.sql`, `03_Demo.sql`, `BAO_CAO.md`, `Bao_cao_Nguoi1_FIX.docx`, `hinh/`) | `nguoi1/phan3/` + màn hình & API CRUD `DANH_MUC_MON` đã tích hợp vào `frontend/` & `backend/` | Nhận xét chéo: `NHAN_XET_NGUOI4.md` |
| **Người 2** | `nguoi2/` | `nguoi2_phan3/` + màn hình & API Trigger `MON`/`SIZE_MON` đã tích hợp vào `frontend/` & `backend/` | Nhận xét chéo: `NHAN_XET_KIEM_TRA_NGUOI5.md` |
| **Người 3** | `Nguoi3_BTL261/` | `BTL3_Nguoi3/` + màn hình & API `sp_BaoCaoPhanCongTheoCa` đã tích hợp vào `frontend/` & `backend/` | Nhận xét chéo: `NHAN_XET_NGUOI_1.md` |
| **Người 4** | `nguoi4/` | `frontend/` (giao diện hợp nhất 4 màn hình), `nguoi4_phan3/` (báo cáo mục 3.2, sơ đồ Draw.io/PNG, ảnh minh chứng) | Nhận xét chéo: `NHAN_XET_NGUOI2.md` |
| **Người 5** | `nguoi5/` | `backend/` (Express API hợp nhất + kiểm thử tích hợp), `database/` (script nạp & kiểm tra CSDL), `nguoi5_phan3/` (báo cáo mục 3.1, bản ghép thử, kịch bản demo) | Bàn giao & kiểm thử tích hợp |

### Chuẩn bị môi trường chạy ứng dụng Phần 3

- Node.js từ `22.12.0` và `npm` trong `PATH` (kiểm tra bằng `node --version` và `npm --version`).
- Microsoft SQL Server 2022 trở lên. Khi nạp dữ liệu bằng PowerShell cần `sqlcmd` và tài khoản Windows có quyền tạo CSDL (hoặc dùng SSMS).
- Nếu backend dùng Windows Auth (`DB_AUTH=windows`), cài **ODBC Driver 18 for SQL Server** (`npm ci` cài gói `msnodesqlv8` cho chế độ này).

### Nạp CSDL thử (`BTL2_P3_DEMO`)

Nạp `database/BTL2_SQL_TONG_HOP.sql` trước, rồi nạp `database/02_Trigger_INSERT.sql` vào CSDL `BTL2_P3_DEMO`. Xem chi tiết lệnh `sqlcmd`, SSMS và bước dựng lại dữ liệu sạch trong [hướng dẫn nạp CSDL](database/README.md). Dữ liệu mẫu gồm 6 danh mục, 7 món, 13 size và 2 ca làm việc ngày 13/11/2026.

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

Trong `frontend/.env.local`, cấu hình proxy tới backend chung (bỏ hoặc chú thích `VITE_N1_API_TARGET`, `VITE_N2_API_TARGET`, `VITE_N3_API_TARGET` để cả ba nhóm API đi qua một cổng):

```dotenv
VITE_API_BASE_URL=
VITE_API_PROXY_TARGET=http://127.0.0.1:3001
```

Chạy `npm run dev` và mở địa chỉ Vite hiển thị (mặc định `http://127.0.0.1:5173`). Để chạy bản build sản xuất, chạy `npm run build` rồi `npm run preview`. Xem thêm [tài liệu bàn giao backend chung](nguoi5_phan3/BAN_GIAO_BACKEND_CHUNG.md).

### Chạy kiểm thử tích hợp

Dùng `DB_NAME=BTL2_P3_DEMO` với dữ liệu mẫu, dừng backend đang chạy trên `APP_PORT`, sau đó chạy:

```powershell
Set-Location './backend'
npm test
```

Bộ kiểm thử tự khởi động backend, kiểm tra 12 endpoint nghiệp vụ và `/api/health`, tự dọn dữ liệu thử rồi đóng kết nối SQL (kỳ vọng 7 phép kiểm tra đạt, `fail 0`).

---

**Phân công BTL2 Hệ cơ sở dữ liệu – Phần 3 | Hoàn thành trước 27/11/2026.**
