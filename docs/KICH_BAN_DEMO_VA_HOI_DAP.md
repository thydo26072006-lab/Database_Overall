# Kịch bản demo và hỏi đáp BTL2 Phần 3

## 1. Chuẩn bị trước khi trình bày

- Dùng một CSDL demo sạch. Ưu tiên dựng bản riêng và trỏ backend vào tên CSDL vừa tạo để có thể lặp lại buổi tập. Thực hiện theo [hướng dẫn dựng lại dữ liệu](../database/README.md#dựng-lại-dữ-liệu-demo-trước-buổi-trình-bày).
- Chạy `npm start` trong `backend` và `npm run dev` trong `frontend`. Mở địa chỉ Vite in ra. Cấu hình proxy trỏ tới `http://127.0.0.1:3001`. Kiểm tra `GET /api/health` trả HTTP 200 và `database: "connected"`. Xem [README chạy ứng dụng](../README.md#chạy-ứng-dụng).
- Mở SSMS trên cùng instance và chọn đúng CSDL theo `DB_NAME` của backend. Trong Chrome có thể mở **Network → Fetch/XHR** để đối chiếu phương thức, HTTP status và JSON.
- Chạy từng khối SQL riêng trong SSMS. Khối kiểm tra ban đầu phải báo 6 danh mục, 7 món, 13 size và hai mã demo chưa tồn tại. Khối này dùng lại được trước mỗi buổi tập.

```sql
SELECT DB_NAME() AS CSDL,
       (SELECT COUNT(*) FROM dbo.DANH_MUC_MON) AS SoDanhMuc,
       (SELECT COUNT(*) FROM dbo.MON) AS SoMon,
       (SELECT COUNT(*) FROM dbo.SIZE_MON) AS SoSize;
SELECT MaDanhMuc FROM dbo.DANH_MUC_MON WHERE MaDanhMuc = 'DEMO_DM_526';
SELECT MaMon FROM dbo.MON WHERE MaMon = 'DEMO_MON_526';
```

## 2. Kịch bản demo trực tiếp

Dự kiến 8–10 phút. Mở **Trang chủ** và giới thiệu ba mục trên thanh điều hướng. Khi chuyển màn hình, nói ngắn gọn thao tác đi qua React → Vite proxy → Express → SQL Server. Dùng [bản báo cáo Word ghép](bao-cao/phan-3/BAO_CAO_PHAN_3.docx) để mở sơ đồ hoặc ảnh minh chứng nếu cần đối chiếu.

### A. Quản lý danh mục món

Mở **Quản lý danh mục món**. Chạy truy vấn bên dưới trước khi thêm và sau mỗi thao tác ghi. Ban đầu truy vấn trả 0 dòng.

```sql
SELECT MaDanhMuc, TenDanhMuc, MaDanhMucCha
FROM dbo.DANH_MUC_MON
WHERE MaDanhMuc = 'DEMO_DM_526';
```

| Bước | Thao tác trên giao diện | Kết quả cần chỉ ra |
| --- | --- | --- |
| 1 | Bấm **Thêm danh mục**. Nhập mã `DEMO_DM_526`, tên **Danh mục demo**, chọn cha **Đồ uống (DM_DOUONG)** rồi bấm **Thêm danh mục**. | POST trả 201 qua `usp_N1_ThemDanhMuc`. SSMS có một dòng, cha là `DM_DOUONG`. |
| 2 | Mở lại form thêm, nhập cùng mã, tên **Tên thử trùng**. Bấm **Thêm danh mục**, xem lỗi rồi bấm **Huỷ**. | HTTP 409, mã `51007`. Dòng trong SSMS vẫn mang tên **Danh mục demo**. |
| 3 | Tại dòng thử bấm **Sửa**. Đổi tên thành **Danh mục demo đã sửa**, chọn **Không có danh mục cha** và bấm **Lưu thay đổi**. | PUT trả 200 qua `usp_N2_CapNhatDanhMuc`. SSMS cho thấy tên mới và cột cha là `NULL`. |
| 4 | Bấm nút xóa trên dòng thử và xác nhận **Xoá danh mục**. | DELETE trả 204 qua `usp_N3_XoaDanhMuc`. Dòng biến mất khỏi giao diện và truy vấn SSMS trả 0 dòng. |

### B. Quản lý món và size

Mở **Quản lý món và size**. Chạy khối sau trước và sau các bước. Giữ nguyên bộ lọc mã thử để dễ so sánh hai bảng.

```sql
SELECT MaMon, TenMon, LoaiMon, TrangThaiKinhDoanh, MaDanhMuc
FROM dbo.MON
WHERE MaMon = 'DEMO_MON_526';
SELECT MaSize, GiaBan, TrangThaiSize
FROM dbo.SIZE_MON
WHERE MaMon = 'DEMO_MON_526'
ORDER BY MaSize;
```

| Bước | Thao tác trên giao diện | Kết quả cần chỉ ra |
| --- | --- | --- |
| 1 | Trong **Thêm món**, nhập `DEMO_MON_526`, tên **Trà demo**, loại **Đồ uống**, danh mục **Trà (DM_TRA)** và trạng thái **Ngừng bán**. Bấm **Thêm món**. Nếu cần, bấm **Xem size** ở dòng mới. | POST trả 201. SSMS có món `NgungBan` và size `S` giá 0, trạng thái `NgungBan`. `trg_N2_Mon_TaoSizeMacDinh` tạo size khi ghi `MON`. |
| 2 | Chạy ca API kiểm tra size sai loại trong `npm test`. Giao diện lọc TC khỏi ô Thêm size của món thường. | HTTP 422, mã `51213` từ `trg_N2_Size_DungLoai`. SSMS vẫn chỉ có size `S`. |
| 3 | Ở dòng size `S`, bấm **Sửa**, nhập `25000`, chọn **Đang bán**, bấm **Lưu size**, rồi bấm **Bật bán món**. | PUT và PATCH trả 200. SSMS cho thấy cả món và size `S` ở trạng thái `DangBan`, giá size là 25000. |
| 4 | Ở dòng size `S`, bấm **Xóa** và xác nhận trong hộp thoại. | HTTP 409, mã `51212` vì đây là size đang bán cuối của món đang bán. Món và size vẫn giữ nguyên. |
| 5 | Bấm **Ngừng bán món** để kết thúc phần này. | PATCH trả 200. SSMS cho thấy món đã về `NgungBan`. Món và size thử vẫn nằm trong CSDL demo riêng. |

### C. Tổng hợp phân công theo ca

Mở **Tổng hợp phân công theo ca**. Nhập hai ngày rồi bấm **Xem báo cáo** cho từng ca sau.

| Từ ngày | Đến ngày | Kết quả |
| --- | --- | --- |
| 13/11/2026 | 13/11/2026 | HTTP 200. `CA_1311_SANG` có 1 nhân viên, 2 bàn, 2 lượt và trạng thái **Đã phân công**. `CA_1311_CHIEU` có các số đếm bằng 0 và trạng thái **Chưa phân công**. |
| 14/11/2026 | 13/11/2026 | HTTP 400, `INVALID_DATE_RANGE`. Express kiểm tra khoảng ngày trước khi gọi SQL. |
| 15/11/2026 | 15/11/2026 | HTTP 200, `NO_SHIFTS` và `data: []`. SQL báo `51312` và API chuyển thành kết quả rỗng có thông báo. |

Đối chiếu ca có dữ liệu trong SSMS bằng đúng hai tham số mà backend truyền vào thủ tục.

```sql
EXEC dbo.usp_N3_TongHopPhanCongTheoCa
    @TuNgay = '20261113', @DenNgay = '20261113';
```

### D. Hai hàm mục 2.4 trong SSMS

Chạy hai truy vấn sau khi món thử đã được đưa về **Ngừng bán**. Hai hàm được trình bày trực tiếp bằng T-SQL.

```sql
SELECT dbo.fn_N5_DemLuaChonTheoDanhMuc('DM_DOUONG') AS DoUong,
       dbo.fn_N5_DemLuaChonTheoDanhMuc('DM_TRA') AS Tra,
       dbo.fn_N5_DemLuaChonTheoDanhMuc('DM_RONG') AS DanhMucRong,
       dbo.fn_N5_DemLuaChonTheoDanhMuc(NULL) AS MaNull;

SELECT dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU', '20261101') AS SauNhap,
       dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU', '20261102') AS SauXuatHuy,
       dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU', '20261103') AS SauKiemKe,
       dbo.fn_N5_TonKhoDenThoiDiem('HH_KIEMTHU', '20261130') AS CuoiThang,
       dbo.fn_N5_TonKhoDenThoiDiem('HH_TINY', '20261130') AS SauSoLe;
```

Hàm đếm trả `8, 5, 0, NULL`. Hàm tồn kho trả `10,000000 → 7,500000 → 8,000000`, giữ `8,000000` cuối tháng vì phiếu nháp chưa ghi sổ và trả `0,000001` cho `HH_TINY`.

### Kết thúc và lặp lại buổi tập

Kiểm tra đã xóa danh mục demo và đã ngừng bán món thử. Khi cần trình bày lại từ dữ liệu sạch, dùng [quy trình N5-19](../database/README.md#dựng-lại-dữ-liệu-demo-trước-buổi-trình-bày) để dựng CSDL mới, chuyển `DB_NAME` rồi khởi động lại backend. Nếu UI gặp lỗi, kiểm tra health, tên CSDL ở cả backend và SSMS, địa chỉ proxy, sau đó mở ảnh trước/sau trong báo cáo để giải thích kết quả dự kiến.

## 3. Câu hỏi và đáp án vấn đáp

### Stored Procedure và Trigger

1. **Ba thủ tục CRUD làm gì?** Thêm dùng `usp_N1_ThemDanhMuc`, sửa dùng `usp_N2_CapNhatDanhMuc`, xóa dùng `usp_N3_XoaDanhMuc`. Danh sách đọc từ `DANH_MUC_MON`. Sau thao tác ghi thành công, giao diện đọc lại danh sách.
2. **Vì sao xóa danh mục có con hoặc có món lại bị chặn?** Thủ tục chỉ xóa khi không còn bản ghi tham chiếu. SQL trả `51303`, backend trả HTTP 409 và giữ dữ liệu để người dùng xử lý phụ thuộc.
3. **Hệ thống ngăn vòng danh mục cha–con ở đâu?** Trigger `trg_N1_DanhMuc_KhongChuTrinh` kiểm tra cấu trúc phân cấp sau khi ghi. Nếu phát hiện vòng, SQL trả `51010`, API danh mục trả 422.
4. **Ai gọi trigger khi thêm món?** Backend gửi lệnh DML vào `MON` hoặc `SIZE_MON`. SQL Server tự kích hoạt trigger tương ứng. Món mới có size mặc định `S` hoặc `TC`. Trigger trên `SIZE_MON` bảo vệ loại size và size đang bán cuối.
5. **Vì sao món mới phải ở trạng thái Ngừng bán?** Món cần cấu hình size có thể bán trước. SQL `51210` chặn tạo món mới ở trạng thái Đang bán, còn `51212` bảo vệ điều kiện món đang bán phải có ít nhất một size đang bán.
6. **Ba số đếm trong báo cáo khác nhau thế nào?** Thủ tục đếm nhân viên khác nhau, bàn khác nhau và tổng lượt phân công trong từng ca. Ca có lịch nhưng chưa có phân công vẫn xuất hiện với ba số 0.

### Function 2.4

7. **Hàm đếm lựa chọn đếm món hay size?** Hàm duyệt danh mục gốc và các danh mục con, rồi đếm từng cặp món–size nếu cả món và size đều đang bán. Hàm trả `BIGINT`, trả 0 cho danh mục hợp lệ nhưng rỗng và `NULL` cho đầu vào không hợp lệ hoặc khi phát hiện vòng.
8. **Hàm tồn kho lấy dữ liệu theo mốc nào?** Hàm cộng biến động của phiếu `DaGhiSo` có `ThoiDiemGhiSo` nhỏ hơn hoặc bằng mốc. Phiếu nháp được bỏ qua. Kết quả là `DECIMAL(18,6)`.
9. **Khi nào tồn kho là 0 và khi nào là NULL?** Mã hàng hợp lệ chưa có biến động đến mốc trả 0. Mã rỗng hoặc không tồn tại, mốc `NULL`, phiếu đã ghi sổ thiếu thời điểm hoặc tổng ngoài miền hợp lệ làm hàm trả `NULL`. Hàm chỉ đọc sổ, còn kiểm tồn khi ghi do luồng ghi sổ xử lý.

### Kiến trúc, phản hồi và kiểm thử

10. **Vì sao trình duyệt gọi Express để lấy dữ liệu?** Express giữ cấu hình kết nối và kiểm tra yêu cầu, truyền tham số vào SQL và trả hợp đồng HTTP. Trình duyệt chỉ nhận dữ liệu và thông báo phục vụ hiển thị.
11. **Ba router dùng chung SQL Server bằng cách nào?** Lúc khởi động, backend mở một `ConnectionPool`. Router danh mục dùng pool trực tiếp, router món và size dùng `createQuery()`, router báo cáo lấy pool qua `getPool()`.
12. **Vite proxy và CORS được dùng khi nào?** Với proxy, trình duyệt gửi `/api` tương đối tới Vite và Vite chuyển tới backend cổng 3001. Khi đặt `VITE_API_BASE_URL` để trình duyệt gọi thẳng một origin khác, backend cấp quyền CORS theo `CORS_ORIGIN`.
13. **Hợp đồng lỗi giữa các màn hình khác nhau ra sao?** Danh mục, món và size dùng `{ error: { code, message } }`. Lỗi riêng của báo cáo có `code` và `message` ở cấp gốc. Với báo cáo rỗng, frontend nhận HTTP 200, `NO_SHIFTS` và mảng rỗng để hiển thị thông báo.
14. **Health trả 503 nghĩa là gì?** Express đã xử lý được yêu cầu HTTP nhưng truy vấn `SELECT 1` qua pool thất bại hoặc pool chưa sẵn sàng. Health trả `DB_UNAVAILABLE` để người vận hành kiểm tra kết nối SQL Server.
15. **Vì sao pool đặt useUTC?** Router báo cáo đọc ngày giờ từ driver và dùng chuỗi ISO để định dạng kết quả. `useUTC: true` giúp giữ đúng mốc ngày và giờ gốc của ca khi Node chạy ở UTC+7.
16. **Kiểm thử xác nhận điều gì?** Backend có bộ kiểm thử cho 12 endpoint và health. Với demo trực tiếp, xem HTTP trong Network và kết quả truy vấn trước/sau trong SSMS để xác nhận giao diện phản ánh dữ liệu thật. Các mã lỗi trong tài liệu đi kèm trạng thái dữ liệu sau khi yêu cầu bị từ chối.
