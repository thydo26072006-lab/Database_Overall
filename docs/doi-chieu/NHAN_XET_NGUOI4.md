# Kiểm tra chéo Người 4

Người 1 kiểm tra ngày 19/11 trên CSDL 30 bảng của nhóm, dùng SQL Server 2022. [Bản Người 4 được kiểm tra](https://github.com/thydo26072006-lab/Database_Overall/tree/35a54f9bb8ba967ee344598a43df7d7bc626b429/nguoi4)

Khi có dữ liệu demo, Truy vấn 2 trả 5 giao dịch, tổng 110.000 đồng, trong đó có một giao dịch 0 đồng. Giao dịch có hóa đơn phát hành lại vẫn chỉ được tính một lần. Truy vấn 3 cho kết quả `HH_KIEMTHU` tăng 10,5 kg, giảm 2,5 kg, tức tăng ròng 8 kg trong kỳ. Thủ tục 2 vẫn trả một dòng cho ngày 16/11 dù hôm đó không có giao dịch. Bảy ca kiểm tra ngày, 15 ca CRUD và 10 ca demo Hàm 2 đều đạt.

Có ba chỗ cần bổ sung trước khi ghép bài.

1. **Ghi rõ thứ tự chạy.** File 04 gọi thủ tục tạo dữ liệu ở file 08. File 05 và 07 cũng cần `dbo.usp_FIX_Test` từ SQL tổng. Dùng SQL tổng để dựng CSDL và chạy demo. Nếu cài riêng phần Người 4 trên CSDL đã có dữ liệu và thủ tục dùng chung, chạy file 03 và 08 trước file 04. [Chỗ gọi ở file 04](https://github.com/thydo26072006-lab/Database_Overall/blob/35a54f9bb8ba967ee344598a43df7d7bc626b429/nguoi4/04_Demo_Thu_tuc_2.sql#L10) · [Thủ tục ở file 08](https://github.com/thydo26072006-lab/Database_Overall/blob/35a54f9bb8ba967ee344598a43df7d7bc626b429/nguoi4/08_Du_lieu_demo_bao_cao.sql#L10)
2. **Ghi cách chạy riêng Truy vấn 2.** Chạy file 01 ngay sau khi dựng CSDL thì ra 0 dòng vì chưa có giao dịch trong khoảng ngày mặc định. Để xem đúng 5 dòng mẫu, mở giao dịch, gọi `dbo.usp_N4_ChuanBiDuLieuBaoCao`, chạy file 01 trong cùng phiên rồi `ROLLBACK`. File 04 có chép lại cả hai truy vấn. Nếu sửa truy vấn, chạy trực tiếp file 01 hoặc 02 đã sửa để kiểm tra.
3. **Chèn ảnh kết quả vào Word.** Bản hiện tại có hai lưu đồ. Cần thêm ảnh chạy trên SQL Server và cập nhật chỗ dẫn `KIEM_TRA_CU_PHAP.txt` và `KET_QUA_CHAY_SQLSERVER.txt`, vì hai file đó chưa có trên nhánh.
