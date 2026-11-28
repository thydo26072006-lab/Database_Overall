"""Tạo tài liệu Word bằng Open XML, chỉ dùng thư viện chuẩn Python."""
from pathlib import Path
from zipfile import ZipFile, ZIP_DEFLATED
import xml.etree.ElementTree as E
import hashlib
import json

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[1]
OUT = BASE / 'Giai_thich_chi_tiet_code_Nguoi5.docx'
W = 'http://schemas.openxmlformats.org/wordprocessingml/2006/main'
R = 'http://schemas.openxmlformats.org/officeDocument/2006/relationships'
E.register_namespace('w', W)
E.register_namespace('r', R)
def el(parent, tag, text=None, **attrs):
    node = E.SubElement(parent, '{'+W+'}'+tag, {'{'+W+'}'+k: str(v) for k,v in attrs.items()})
    if text is not None:
        node.text = text
    return node
doc = E.Element('{'+W+'}document')
body = el(doc, 'body')
def p(text='', style='Normal', parent=None):
    node = el(body if parent is None else parent, 'p')
    pr = el(node, 'pPr'); el(pr, 'pStyle', val=style)
    run = el(node, 'r')
    for i, line in enumerate(text.split('\n')):
        if i: el(run, 'br')
        t = el(run, 't', line)
        t.set('{http://www.w3.org/XML/1998/namespace}space', 'preserve')
    return node
def h(text, level=1): return p(text, 'Heading'+str(level))
def page():
    node = p(); el(el(node, 'r'), 'br', type='page')
def table(headers, rows, widths=None):
    widths = widths or [9600//len(headers)]*len(headers)
    t = el(body, 'tbl'); pr = el(t,'tblPr')
    el(pr,'tblW',w=9600,type='dxa')
    bs=el(pr,'tblBorders')
    for side in ('top','left','bottom','right','insideH','insideV'):
        el(bs,side,val='single',sz=4,color='CAD5E2')
    el(pr,'tblLayout',type='fixed')
    margins=el(pr,'tblCellMar')
    for side in ('top','left','bottom','right'): el(margins,side,w=90,type='dxa')
    grid=el(t,'tblGrid')
    for width in widths: el(grid,'gridCol',w=width)
    for i,row in enumerate([headers]+rows):
        tr=el(t,'tr'); trpr=el(tr,'trPr'); el(trpr,'cantSplit')
        if i==0: el(trpr,'tblHeader')
        for width,value in zip(widths,row):
            tc=el(tr,'tc'); tcp=el(tc,'tcPr'); el(tcp,'tcW',w=width,type='dxa')
            if i==0: el(tcp,'shd',val='clear',fill='E6EEF8')
            p(str(value),'TableText',tc)
    p('')

coverage = {}
def annotate(path, items):
    """Mỗi dải dòng giữ nguyên mã nguồn; kiểm tra không bỏ sót dòng nào."""
    lines=path.read_text(encoding='utf-8-sig').splitlines()
    seen=set()
    p('Nguồn: '+str(path.relative_to(ROOT)).replace('\\','/')+'. Số dòng dưới đây trùng file SQL gốc.', 'Small')
    for start,end,explanation in items:
        label=f'Dòng {start}' if start==end else f'Dòng {start}–{end}'
        p(label,'Label')
        for index in range(start-1,end):
            assert index+1 not in seen, (path,index+1)
            seen.add(index+1)
            if lines[index].strip(): p(f'{index+1:02d}  {lines[index]}','Code')
        for text in explanation.split('\n'): p(text)
    missing=[i for i,line in enumerate(lines,1) if line.strip() and i not in seen]
    assert not missing,(path,missing)
    coverage[str(path.relative_to(ROOT)).replace('\\','/')]=dict(
        total_lines=len(lines), explained_nonempty_lines=sum(bool(x.strip()) for x in lines),
        sha256=hashlib.sha256(path.read_bytes()).hexdigest())

p('NGƯỜI 5','Subtitle')
p('GIẢI THÍCH CHI TIẾT\nTỪNG CÂU LỆNH SQL','Title')
p('Truy vấn 4 • Truy vấn 5 • Hàm 1 • Hàm 2\nKèm giải thích mã kiểm thử bàn giao','Subtitle')
p('Bài tập lớn số 2 – Môn Hệ cơ sở dữ liệu')
p('Phiên bản giải thích: bộ tích hợp trong thư mục fix.\nNgày biên soạn: 17/11/2026.')
p('Mục tiêu: hiểu mỗi câu lệnh làm gì, vì sao cần câu lệnh đó, dữ liệu đi qua các bước như thế nào và cách giải thích khi vấn đáp.')
p('Tài liệu học và thuyết trình; giữ nguyên SQL nguồn. Các bảng kết quả minh họa được suy ra từ dữ liệu mẫu trong dự án, không phải ảnh chụp hoặc xác nhận chạy SQL Server mới.', 'Note')
page()
h('Nội dung')
for text in [
    '1. Phạm vi công việc, phiên bản và cách đọc',
    '2. Kiến thức nền và các bảng liên quan',
    '3. Truy vấn 4: thống kê lựa chọn đang bán theo danh mục',
    '4. Truy vấn 5: tìm món có giá trung bình cao hơn ngưỡng',
    '5. Hàm 1: đếm lựa chọn của danh mục và mọi cấp con',
    '6. Hàm 2: tính tồn kho tại một thời điểm',
    '7. Giải thích từng câu lệnh kiểm thử Hàm 2',
    '8. Giải thích mã demo Hàm 1 được bàn giao cho Người 3',
    '9. Cách chạy, giới hạn và câu hỏi vấn đáp',
    '10. Danh sách nguồn đối chiếu trong dự án',
]: p(text)
h('1. Phạm vi công việc, phiên bản và cách đọc')
p('Theo file phân công, Người 5 phụ trách bốn nội dung: Truy vấn 4 (1 điểm), Truy vấn 5 (1 điểm), Hàm 1 (1 điểm) và Hàm 2 (1 điểm). Tổng cộng 4/20 điểm. Người 3 nhận demo Hàm 1; Người 4 nhận demo Hàm 2. Viết hàm và thực hiện demo là hai nhiệm vụ có người nhận riêng.')
p('Dự án có thư mục Nguoi5_BTL2/nguoi5 và bộ đã chỉnh sửa trong fix/nguoi5. Tài liệu này bám theo bộ fix vì README xác định fix/BTL2_FIX_NGUOI_1_2_3_4_5.sql là file tích hợp đủ năm người, theo EERD_UPDATE.xlsx. Không dùng tên bảng hoặc tham số của phiên bản cũ để diễn giải bản này.')
table(['Nội dung','Mã nguồn được giải thích','Vai trò'],[
    ('Truy vấn 4','01_Truy_van_4.sql','GROUP BY và các hàm tổng hợp'),
    ('Truy vấn 5','02_Truy_van_5.sql','Hai tầng truy vấn con và AVG'),
    ('Hàm 1','03_Ham_1.sql','IF, WHILE; duyệt cây danh mục'),
    ('Hàm 2','04_Ham_2.sql','IF, WHILE; cộng sổ biến động kho'),
    ('Test bàn giao Hàm 2','05_Demo_Ham_2_ban_giao.sql','Người 5 bàn giao; Người 4 demo'),
    ('Demo Hàm 1','../nguoi3/07_Demo_Ham_1.sql','Người 3 demo hàm nhận từ Người 5'),
], [1700,4300,3600])
p('Mỗi khối bên dưới chép nguyên câu lệnh với số dòng từ file nguồn, rồi giải thích cú pháp và ý nghĩa nghiệp vụ. Một câu SQL có thể trải nhiều dòng; các dòng thuộc cùng câu được trình bày chung để thấy đủ ý. Các chú thích cũng được giải thích. Dòng trắng chỉ phân cách nên không có hành vi thực thi.')
h('2. Kiến thức nền và các bảng liên quan')
table(['Bảng','Dữ liệu liên quan','Được dùng ở đâu'],[
    ('DANH_MUC_MON','Mã, tên, mã danh mục cha; tạo cây danh mục','Truy vấn 4; Hàm 1'),
    ('MON','Mã món, tên, danh mục, trạng thái kinh doanh','Truy vấn 4–5; Hàm 1'),
    ('SIZE_MON','Cặp món–size, giá, trạng thái size','Truy vấn 4–5; Hàm 1'),
    ('HANG_HOA','Danh sách mặt hàng và đơn vị tính','Kiểm tra đầu vào Hàm 2'),
    ('PHIEU_KHO','Mã phiếu, trạng thái, thời điểm ghi sổ','Lọc phiếu hợp lệ trong Hàm 2'),
    ('CHI_TIET_PHIEU_KHO','Mặt hàng và lượng tăng/giảm của từng dòng phiếu','Nguồn số lượng cộng vào tồn'),
], [2300,4400,2900])
p('Một món có nhiều size. Sau JOIN MON với SIZE_MON, một dòng thường ứng với một cặp (MaMon, MaSize). Ví dụ một cà phê có S, M, L tạo ba dòng: đếm dòng được ba lựa chọn, còn đếm DISTINCT mã món được một món. Topping dùng size TC cũng được tính là cấu hình món–size, nhưng điều đó không khẳng định topping được bán độc lập.')
p('Danh mục trực tiếp là danh mục ghi tại MON.MaDanhMuc. Truy vấn 4 chỉ thống kê danh mục đó. Hàm 1 còn mở rộng xuống tất cả cấp con. Hai nội dung trả lời hai câu hỏi khác nhau nên kết quả của danh mục cha có thể khác nhau.')
table(['Cú pháp/kiểu','Cách hiểu trong bài'],[
    ('dbo.','Schema chứa bảng/hàm; không phải tên cơ sở dữ liệu.'),
    ('AS dm, m, s / p, c','Bí danh ngắn của bảng; m.MaMon là cột MaMon của MON.'),
    ('@TenBien','Biến hoặc tham số T-SQL; @HangDoi là biến bảng cục bộ.'),
    ('VARCHAR(30) / NVARCHAR(100)','Chuỗi mã tối đa 30 ký tự byte theo kiểu varchar / chuỗi Unicode để lưu nhãn tiếng Việt.'),
    ('BIGINT / BIT','Số nguyên 64 bit / cờ 0 hoặc 1 (nếu cho phép NULL còn có trạng thái NULL).'),
    ('DECIMAL(18,2) / DECIMAL(18,6)','Số chính xác: tổng 18 chữ số; lần lượt 2 hoặc 6 chữ số sau dấu thập phân.'),
    ('DATETIME2(0)','Mốc ngày và giờ, không giữ phần giây lẻ; không chứa thông tin múi giờ.'),
    ('NULL','Giá trị thiếu hoặc không tính được; phải kiểm bằng IS NULL/IS NOT NULL.'),
    ('GO','Dấu phân cách batch do SSMS/sqlcmd hiểu; không phải một câu lệnh T-SQL gửi trực tiếp cho engine.'),
    ('/* ... */ và --','Chú thích nhiều dòng và chú thích tới hết dòng; không được thực thi.'),
], [3100,6500])
p('COUNT_BIG(*) trả BIGINT và đếm mọi dòng, kể cả dòng có một cột NULL. COUNT(DISTINCT cột) đếm các giá trị khác nhau không NULL và trả INT. AVG, MIN, MAX bỏ qua giá trị NULL; với GiaBan không NULL theo cấu trúc, mọi giá đang được chọn đều tham gia tính. DECIMAL giúp giữ số lượng chính xác hơn cách biểu diễn gần đúng bằng FLOAT.')

page(); h('3. Truy vấn 4: thống kê lựa chọn đang bán theo danh mục')
h('3.1. Mục đích và cách tính',2)
p('Màn hình quản lý thực đơn cần biết mỗi danh mục trực tiếp có bao nhiêu món và bao nhiêu lựa chọn size đang bán, giá thấp nhất/cao nhất và giá trung bình trên các lựa chọn. Truy vấn chỉ đọc dữ liệu. Cả món và size phải đang bán thì dòng mới được thống kê.')
p('Luồng xử lý logic để giải thích: FROM/JOIN tạo các dòng món–size → WHERE loại dòng ngừng bán → GROUP BY chia theo danh mục → SELECT tính chỉ tiêu → ORDER BY sắp xếp. Đây là thứ tự logic, không phải khẳng định thứ tự thực thi vật lý mà bộ tối ưu SQL Server phải dùng.')
h('3.2. Giải thích từng câu và từng mệnh đề',2)
annotate(BASE/'01_Truy_van_4.sql',[
    (1,10,'Khối chú thích xác định tác giả, phiên bản, vị trí nhiệm vụ và phạm vi nghiệp vụ. “Đang bán” ở đây là trạng thái cấu hình; không kiểm công thức hoặc số tồn để bảo đảm có thể bán ngay. Mỗi lựa chọn là một cặp món–size.'),
    (11,11,'SELECT chọn hai cột định danh danh mục. MaDanhMuc giúp phân biệt các danh mục có cùng tên; TenDanhMuc để hiển thị dễ đọc. Dấu phẩy báo còn các biểu thức khác trong danh sách kết quả.'),
    (12,12,'COUNT(DISTINCT m.MaMon) bỏ các mã món lặp lại do một món có nhiều size. AS SoMonDangBan đặt tên cột kết quả. Một món chỉ được đếm khi còn ít nhất một size qua được điều kiện lọc.'),
    (13,13,'COUNT_BIG(*) đếm tất cả dòng sau JOIN và WHERE trong mỗi nhóm. Theo khóa của SIZE_MON, mỗi dòng tương ứng một cặp món–size; kết quả trả BIGINT. Ví dụ một món có ba size đang bán đóng góp ba lựa chọn.'),
    (14,14,'MIN lấy giá thấp nhất trong các size đang bán của danh mục, đặt tên GiaThapNhat.'),
    (15,15,'MAX lấy giá cao nhất trong cùng tập lựa chọn, đặt tên GiaCaoNhat.'),
    (16,16,'AVG(s.GiaBan) lấy tổng giá chia số giá tham gia của các dòng size. CAST chuyển kết quả sang DECIMAL(18,2) để hiển thị hai số lẻ; có thể làm tròn khi chuyển. Mỗi size có trọng số ngang nhau, nên món có nhiều size ảnh hưởng nhiều hơn vào trung bình danh mục.'),
    (17,17,'FROM chọn DANH_MUC_MON làm bảng nguồn và đặt bí danh dm. Schema dbo chỉ nơi chứa bảng.'),
    (18,18,'JOIN mặc định là INNER JOIN: chỉ giữ món có MaDanhMuc khớp mã danh mục. Mỗi món được gắn với danh mục trực tiếp; câu lệnh này không đi qua MaDanhMucCha và không duyệt danh mục con.'),
    (19,19,'Nối SIZE_MON với MON qua MaMon để lấy giá và trạng thái từng size. Món không có size khớp sẽ không tạo dòng kết quả. Một món nhiều size tạo nhiều dòng.'),
    (20,20,"WHERE chỉ giữ món có trạng thái kinh doanh bằng 'DangBan'. Món ngừng bán bị loại dù size riêng của nó có thể còn trạng thái đang bán."),
    (21,21,"AND yêu cầu thêm điều kiện size cũng phải 'DangBan'. Hai điều kiện cùng đúng; ví dụ size S của TRA_DAO ngừng bán nên không được tính."),
    (22,22,'GROUP BY gom các dòng theo cặp mã và tên danh mục. Hai cột thường trong SELECT đều được đưa vào nhóm; các biểu thức COUNT/MIN/MAX/AVG được tính độc lập trong từng nhóm.'),
    (23,23,'ORDER BY ưu tiên danh mục nhiều lựa chọn nhất vì DESC là giảm dần. Nếu số lựa chọn bằng nhau thì MaDanhMuc tăng dần theo mặc định ASC và quy tắc collation. Dấu chấm phẩy kết thúc câu SELECT.'),
    (24,24,'GO kết thúc batch trong công cụ chạy script. Không thêm dòng dữ liệu và không lưu kết quả vào một bảng.'),
])
h('3.3. Kết quả suy ra từ seed chung',2)
table(['Mã danh mục','Số món','Số lựa chọn','Min','Max','Giá TB/size'],[
    ('DM_TRA',2,5,'25.000','40.000','33.000,00'),
    ('DM_CAPHE',1,3,'25.000','35.000','30.000,00'),
    ('DM_TOPPING',2,2,'5.000','6.000','5.500,00'),
    ('DM_DOAN',1,1,'15.000','15.000','15.000,00'),
], [2200,1000,1300,1500,1500,2100])
p('DM_TRA có TRA_SUA với S/M/L giá 25.000/30.000/35.000 và TRA_DAO với M/L giá 35.000/40.000. Tổng 165.000 chia 5 = 33.000. Size S của TRA_DAO giá 30.000 đang ngừng bán nên bị loại. MON_NGUNG cũng bị loại. DM_DOUONG không có món gắn trực tiếp nên không xuất hiện; DM_RONG cũng không xuất hiện. Muốn hiện danh mục rỗng phải thiết kế truy vấn khác với LEFT JOIN và cách đếm phù hợp.')

page(); h('4. Truy vấn 5: tìm món có giá trung bình cao hơn ngưỡng')
h('4.1. Câu hỏi nghiệp vụ và hai tầng truy vấn con',2)
p('Màn hình rà soát giá cần những món có giá trung bình các size đang bán cao hơn trung bình giá của từng món đang bán trên toàn thực đơn. Đầu tiên tính một giá trung bình cho mỗi món; sau đó lấy trung bình của các giá trung bình đó. Mỗi món có trọng số bằng nhau dù có một size hay ba size.')
p('Ký hiệu: A(m) = trung bình giá các size đang bán của món m. Ngưỡng T = tổng các A(m) / số món có ít nhất một size đang bán. Kết quả là các món thỏa A(m) > T. Dấu > là lớn hơn nghiêm ngặt, không lấy món bằng đúng ngưỡng.')
h('4.2. Giải thích từng câu và từng mệnh đề',2)
annotate(BASE/'02_Truy_van_5.sql',[
    (1,12,'Chú thích nêu dạng truy vấn con lồng nhau, mục đích rà soát giá và nguyên tắc mỗi món có trọng số bằng nhau. Phạm vi vẫn bao gồm cấu hình topping TC. Đây là câu SELECT chỉ đọc.'),
    (13,13,'SELECT lấy mã, tên món và COUNT_BIG(*) là số size đang bán của món sau khi lọc. Mỗi nhóm kết quả ứng với một món, không phải một danh mục.'),
    (14,14,'AVG(s.GiaBan) tính giá trung bình của món trong nhóm ngoài. CAST(... AS DECIMAL(18,2)) định dạng kiểu kết quả hai số lẻ; tên cột là GiaTrungBinhMon. Phép lọc HAVING bên dưới dùng AVG chưa CAST, tránh dùng số hiển thị đã làm tròn để so sánh.'),
    (15,16,'Đọc MON với bí danh m rồi INNER JOIN SIZE_MON với bí danh s theo MaMon. Món không có dòng size phù hợp sẽ không nằm trong tập tính.'),
    (17,18,"WHERE và AND lọc đồng thời món đang bán và size đang bán. Lọc trước khi AVG nên giá của size ngừng bán không tác động tới trung bình."),
    (19,19,'GROUP BY theo mã và tên món để đếm size, tính giá trung bình riêng của từng món. Mã giúp không gộp nhầm các món cùng tên.'),
    (20,21,'HAVING lọc sau khi đã nhóm, vì điều kiện liên quan AVG của mỗi nhóm. Không đặt trực tiếp AVG(s.GiaBan) vào WHERE của cùng tầng SELECT. Dấu ( mở truy vấn con vô hướng trả một ngưỡng để so sánh.'),
    (22,24,'Tầng con thứ nhất SELECT AVG(g.GiaTBMon) tính trung bình các giá trung bình món. FROM ( mở một bảng dẫn xuất; bảng này được tạo bởi tầng SELECT sâu hơn, không phải bảng được lưu lâu dài trong cơ sở dữ liệu.'),
    (25,25,'Tầng con thứ hai tạo mỗi dòng gồm mã món m2.MaMon và AVG(s2.GiaBan) đặt tên GiaTBMon. Đây là giá trung bình của một món, sẽ trở thành một đầu vào có trọng số bằng nhau cho AVG ở tầng phía trên.'),
    (26,27,'Đọc lại MON và SIZE_MON với bí danh riêng m2, s2. Không có điều kiện tham chiếu m của truy vấn ngoài; ngưỡng được định nghĩa chung trên toàn tập món hợp lệ, không riêng theo món đang được xét.'),
    (28,29,"Lọc lại cả hai trạng thái 'DangBan' để tập dùng tính ngưỡng thống nhất với tập dùng tính giá trung bình ở ngoài. Nếu thiếu điều kiện này, ngưỡng có thể bị ảnh hưởng bởi món hoặc size ngừng bán."),
    (30,30,'GROUP BY m2.MaMon để tầng sâu nhất xuất một dòng cho mỗi món. Chỉ chọn mã món và AVG nên không cần nhóm TenMon tại tầng này.'),
    (31,31,'Đóng bảng dẫn xuất và đặt bí danh g; bên ngoài truy cập cột bằng g.GiaTBMon. Bí danh cần có để gọi tên bảng kết quả tạm của SELECT con.'),
    (32,32,'Đóng truy vấn con tính ngưỡng. AVG không có GROUP BY ở tầng này trả một dòng tổng hợp; nếu không có giá nào thì ngưỡng là NULL và điều kiện > không đúng cho dòng nào.'),
    (33,33,'Sắp theo GiaTrungBinhMon giảm dần, sau đó mã món tăng dần để thứ tự rõ khi đồng giá. ORDER BY dùng được bí danh cột SELECT. Dấu ; kết thúc toàn bộ truy vấn gồm các tầng con.'),
    (34,34,'GO kết thúc batch, không phải tầng truy vấn con thứ ba.'),
])
h('4.3. Tính tay trên dữ liệu mẫu',2)
table(['Món','Giá trung bình size đang bán','Có lớn hơn T?'],[
    ('CF_SUA','30.000','Có'),('TRA_SUA','30.000','Có'),('TRA_DAO','37.500','Có'),
    ('BANH_QUY','15.000','Không'),('TP_TRANCHAU','5.000','Không'),('TP_THACH','6.000','Không'),
], [2800,4000,2800])
p('T = (30.000 + 30.000 + 37.500 + 15.000 + 5.000 + 6.000) / 6 = 20.583,333333… Giá trị cụ thể giữ lại phụ thuộc precision/scale của AVG; kết quả hiển thị các món được chọn lần lượt là TRA_DAO: 37.500,00; CF_SUA: 30.000,00; TRA_SUA: 30.000,00.')
p('Nếu tính trung bình trực tiếp tất cả 11 size đang bán thì ngưỡng thành 281.000 / 11 = 25.545,4545… Đây là một phép tính có trọng số khác dù ở seed này tình cờ vẫn chọn cùng ba món. Ví dụ riêng: món A có ba size đều 10.000, món B có một size 50.000; trung bình mỗi món là 30.000 nhưng trung bình từng size chỉ là 20.000. Ví dụ này nhằm phân biệt ý nghĩa hai cách tính, không bổ sung vào seed.')

page(); h('5. Hàm 1: đếm lựa chọn của danh mục và mọi cấp con')
h('5.1. Hợp đồng đầu vào, đầu ra và thuật toán',2)
p('Tên đầy đủ: dbo.fn_N5_DemLuaChonTheoDanhMuc. Đầu vào @MaDanhMuc VARCHAR(30). Đầu ra BIGINT là tổng số cặp món–size đang bán thuộc danh mục nhập và mọi cấp con. Danh mục hợp lệ không có lựa chọn trả 0; mã thiếu, rỗng, không tồn tại hoặc gặp chu trình trong phần cây duyệt trả NULL.')
p('Đây là hàm vô hướng: một lần gọi trả một giá trị để dùng trong SELECT. Hàm dùng biến bảng @HangDoi lưu các danh mục đã phát hiện cùng cờ đã duyệt. Mỗi lượt chọn một mã chưa duyệt, cộng lựa chọn của mã đó, đánh dấu xong, rồi thêm các con. Dù tên là hàng đợi, cách chọn ORDER BY MaDanhMuc không phải FIFO và không bảo đảm thứ tự theo chiều rộng. Tổng đếm vẫn đúng nếu mỗi nút được xử lý đúng một lần.')
h('5.2. Giải thích từng câu lệnh',2)
annotate(BASE/'03_Ham_1.sql',[
    (1,11,'Chú thích mô tả phiên bản, người nhận demo, kiểu trả về và phân biệt NULL với 0. Hàm chỉ đếm cấu hình thực đơn; không kiểm nguyên liệu còn đủ hoặc công thức đã sẵn sàng.'),
    (12,12,'SET ANSI_NULLS ON thiết lập quy tắc so sánh với NULL theo ANSI. Khi kiểm NULL phải dùng IS NULL, không dùng = NULL. Câu này cấu hình phiên trước khi tạo/sửa hàm.'),
    (13,13,'SET QUOTED_IDENTIFIER ON cho phép dấu ngoặc kép dùng bao tên đối tượng; chuỗi ký tự dùng dấu nháy đơn. Đây là thiết lập được ghi nhận khi tạo/sửa module.'),
    (14,14,'GO tách hai SET ra khỏi batch định nghĩa hàm, giúp CREATE OR ALTER FUNCTION bắt đầu batch riêng.'),
    (15,15,'CREATE OR ALTER FUNCTION tạo mới nếu hàm chưa có hoặc sửa định nghĩa nếu đã có. dbo là schema; fn_N5 là cách đặt tên thể hiện hàm do Người 5 phụ trách.'),
    (16,18,'Dấu ngoặc bao danh sách tham số. @MaDanhMuc là mã gốc của phần cây cần thống kê, dùng VARCHAR(30) khớp kiểu mã danh mục trong mô hình. Hàm nhận đúng một tham số.'),
    (19,19,'RETURNS BIGINT công bố một giá trị số nguyên 64 bit. Kiểu này thống nhất với COUNT_BIG và các biến cộng dồn; không phải bảng kết quả.'),
    (20,21,'AS mở định nghĩa phần thân; BEGIN bắt đầu khối câu lệnh. END cuối cùng sẽ đóng khối này.'),
    (22,23,"RTRIM bỏ dấu cách ở cuối, LTRIM bỏ ở đầu; NULLIF(chuỗi, '') biến chuỗi rỗng thành NULL. Nếu đầu vào là NULL, rỗng hoặc toàn dấu cách thông thường thì IF đúng và RETURN NULL thoát hàm ngay. Biểu thức chỉ dùng để kiểm; nó không SET lại @MaDanhMuc thành phiên bản đã cắt khoảng trắng."),
    (24,25,'NOT EXISTS kiểm tra không tìm được danh mục có mã nhập. SELECT 1 chỉ cần xác nhận có dòng, số 1 không phải mã hay số lượng danh mục. Nếu mã không tồn tại, trả NULL thay vì 0 để không nhầm với danh mục tồn tại nhưng rỗng.'),
    (27,28,'DECLARE @HangDoi TABLE khai báo biến bảng cục bộ cho lần gọi hàm. Nó giữ danh sách các danh mục đã đưa vào quá trình duyệt, không tạo bảng nghiệp vụ mới và không sửa DANH_MUC_MON.'),
    (29,29,'MaDanhMuc là khóa chính của biến bảng: mỗi mã chỉ có một dòng, không NULL. Khóa duy nhất giúp phát hiện ý đồ thêm trùng; nhánh IF phía sau sẽ trả NULL trước khi thêm nút trùng do chu trình.'),
    (30,31,'DaDuyet là cờ BIT NOT NULL: 0 nghĩa là còn chờ xử lý, 1 nghĩa là đã xử lý. Dấu ); đóng cấu trúc khai báo biến bảng.'),
    (32,32,'Đưa danh mục gốc vào biến bảng với cờ 0. Bỏ danh sách cột ở INSERT là dựa vào thứ tự cột đã khai báo: MaDanhMuc rồi DaDuyet.'),
    (34,34,'Khai báo ba biến: @MaDangDuyet lưu mã đang xử lý; @Tong khởi tạo 0 để cộng dồn; @SoLuaChon nhận số cặp món–size của một danh mục. Nếu không gán 0 cho tổng thì phép cộng với NULL sẽ làm tổng NULL.'),
    (35,36,'WHILE EXISTS tiếp tục lặp khi còn ít nhất một dòng cờ 0. BEGIN mở thân vòng lặp. Khi không còn mã chưa duyệt, điều kiện sai và đi xuống RETURN @Tong.'),
    (37,38,'SELECT TOP (1) lấy một danh mục chưa duyệt, sắp mã tăng dần, rồi gán mã vào @MaDangDuyet. TOP giới hạn đúng một dòng; ORDER BY quy định cách chọn khi có nhiều mã chờ. Đây là gán biến, không xuất bảng cho người gọi.'),
    (40,42,'SELECT gán COUNT_BIG(*) vào @SoLuaChon từ phép nối MON với SIZE_MON. Mỗi dòng ứng với một lựa chọn món–size; không có lựa chọn thì COUNT_BIG vẫn trả 0, nên biến nhận 0 thay vì giữ giá trị lượt trước.'),
    (43,45,"Chỉ đếm món gắn trực tiếp vào @MaDangDuyet và đồng thời món, size đều 'DangBan'. Phần cây con sẽ được đếm ở các lượt khác nên không gộp trực tiếp bằng điều kiện danh mục cha tại câu này."),
    (46,46,'SET cộng số lựa chọn vừa tính vào tổng chung. Mỗi danh mục được đánh dấu và xử lý một lần, nên một lựa chọn không bị đếm lại qua nhiều lượt trong cây hợp lệ.'),
    (47,47,'UPDATE chỉ thay cờ trong biến bảng cho mã vừa xử lý. Không thay trạng thái MON hoặc DANH_MUC_MON. Nếu quên đánh dấu, vòng lặp có thể chọn lại cùng mã mãi.'),
    (49,50,'Hai dòng chú thích nêu tiền đề phát hiện chu trình: mô hình cho mỗi danh mục tối đa một cha. Trigger ở tầng ghi ngăn chu trình; kiểm tra trong hàm là lớp phòng vệ thêm cho dữ liệu không hợp lệ. Không suy rộng cách này cho đồ thị cho phép một nút có nhiều cha.'),
    (51,52,'IF EXISTS mở kiểm tra có ít nhất một danh mục con nào đã nằm trong tập @HangDoi hay không. Tập này giữ cả mã đã duyệt và mã chưa duyệt.'),
    (53,55,'Đọc DANH_MUC_MON với bí danh dm, nối @HangDoi q theo mã để tìm các nút đã phát hiện; WHERE chỉ xét những nút có cha là mã đang duyệt. Vì mỗi nút chỉ có một cha, việc đi tới lại nút đã phát hiện trong phép duyệt này báo đường đi vòng.'),
    (56,57,'Đóng điều kiện EXISTS. Nếu có nút lặp, RETURN NULL kết thúc cả hàm ngay, không tiếp tục cộng hoặc INSERT trùng khóa. Hàm không trả tổng đếm dở dang khi cây không hợp lệ.'),
    (59,61,'INSERT chỉ rõ hai cột đích, rồi SELECT tất cả danh mục con trực tiếp của mã đang duyệt cùng cờ 0. Nếu không có con thì không thêm dòng nào. Con được xử lý về sau; lặp nhiều lượt giúp đi tới mọi độ sâu, không chỉ một cấp.'),
    (62,62,'END đóng thân WHILE. Sau dòng này chương trình kiểm tra lại điều kiện còn danh mục chưa duyệt hay không.'),
    (63,63,'RETURN @Tong trả số lựa chọn của toàn bộ phần cây đã duyệt và kết thúc lần gọi hàm.'),
    (64,65,'END đóng thân hàm. GO kết thúc batch định nghĩa; muốn thực sự lấy kết quả phải gọi hàm bằng SELECT sau khi tạo xong.'),
])
h('5.3. Theo dõi từng lượt với DM_DOUONG',2)
p('Cây trong seed: DM_DOUONG → DM_CAPHE và DM_TRA. Cà phê có 3 lựa chọn; trà có 5 lựa chọn. Danh mục cha không chứa món trực tiếp.')
table(['Bước','Mã xử lý','Cộng thêm','Tổng','Thay đổi tập chờ'],[
    ('Khởi tạo','Chưa xử lý',0,0,'Thêm DM_DOUONG, cờ 0'),
    ('Lượt 1','DM_DOUONG',0,0,'Đánh dấu cha; thêm DM_CAPHE, DM_TRA'),
    ('Lượt 2','DM_CAPHE',3,3,'Đánh dấu; không có con'),
    ('Lượt 3','DM_TRA',5,8,'Đánh dấu; không có con'),
    ('Kết thúc','Không còn cờ 0','—',8,'RETURN 8'),
], [1200,2000,1100,900,4400])
p('Ví dụ phòng vệ chu trình, không phải dữ liệu seed: A có con B, B lại có con A. Khởi tạo A; xử lý A rồi thêm B; khi xử lý B tìm thấy A là con nhưng A đã có trong @HangDoi nên trả NULL. Hàm chỉ phát hiện chu trình trong phần cây đi tới được từ mã nhập, không quét các danh mục không liên quan.')
p('Ví dụ gọi: SELECT dbo.fn_N5_DemLuaChonTheoDanhMuc(\'DM_DOUONG\') AS SoLuaChon; kết quả kỳ vọng 8. Đổi thành DM_RONG nhận 0; đổi thành KHONG_CO nhận NULL.')

page(); h('6. Hàm 2: tính tồn kho tại một thời điểm')
h('6.1. Ý nghĩa số tồn và quy tắc tính',2)
p('Tên đầy đủ: dbo.fn_N5_TonKhoDenThoiDiem(@MaHangHoa, @DenThoiDiem). Đầu vào là mã hàng và mốc ngày giờ. Đầu ra DECIMAL(18,6), theo đơn vị tính của mặt hàng. Mô hình chỉ có một kho nên không có @MaKho và không đọc bảng TON_KHO.')
p('Công thức: tồn tại mốc = tổng BienDongSoLuong của các dòng đúng mặt hàng, phiếu DaGhiSo và ThoiDiemGhiSo <= mốc. Lượng nhập dương, xuất âm; phiếu kiểm kê đóng góp chênh lệch đã chốt. Số mở sổ cũng được ghi bằng phiếu nên không cộng riêng TonToiThieu hoặc TonToiDa của HANG_HOA.')
p('Hàng hợp lệ chưa có dòng phù hợp trả 0. NULL nghĩa là không thể tính đáng tin theo hợp đồng: mã/mốc thiếu hoặc mã không có; phiếu đã ghi sổ của hàng nhưng thiếu thời điểm; tổng cuối âm hoặc vượt miền trả về. Không thay NULL bằng 0 khi trình bày vì sẽ biến lỗi dữ liệu thành tồn bằng không.')
h('6.2. Giải thích từng câu lệnh',2)
annotate(BASE/'04_Ham_2.sql',[
    (1,9,'Chú thích nêu quy tắc một kho, mốc bao gồm dấu bằng, kiểu kết quả và các trường hợp NULL. Hàm chỉ đọc sổ; không thực hiện khóa tồn hoặc ghi sổ. Phiếu đã ghi sổ bất biến, điều chỉnh bằng chứng từ khác để giữ lịch sử.'),
    (10,12,'SET ANSI_NULLS ON quy định cách kiểm NULL; SET QUOTED_IDENTIFIER ON quy định cách hiểu dấu ngoặc kép. GO tách batch thiết lập khỏi batch định nghĩa hàm.'),
    (13,13,'Tạo mới hoặc cập nhật hàm vô hướng trong schema dbo. CREATE OR ALTER không tự gọi hàm và không sinh phiếu kho.'),
    (14,14,'@MaHangHoa VARCHAR(30) xác định hàng; @DenThoiDiem DATETIME2(0) là mốc tới giây. Có đúng hai tham số. Chuỗi ngày YYYYMMDD trong demo được chuyển sang mốc 00:00:00 của ngày đó, không phải cuối ngày.'),
    (15,17,'RETURNS DECIMAL(18,6) trả một số chính xác với tối đa 12 chữ số phần nguyên và 6 chữ số lẻ. AS BEGIN mở thân hàm. Vì không có tham số OUTPUT, kết quả được lấy từ biểu thức gọi hàm trong SELECT.'),
    (18,19,"Kiểm mã NULL/rỗng/toàn dấu cách thông thường bằng LTRIM, RTRIM, NULLIF; hoặc mốc NULL bằng OR. Chỉ cần một nhánh đúng là RETURN NULL ngay. Kiểm không gán lại mã đã cắt khoảng trắng; không hiểu đây là bước chuẩn hóa mã."),
    (20,21,'Nếu không có dòng HANG_HOA đúng mã thì trả NULL. Nhờ bước này phân biệt mã sai với mặt hàng tồn tại nhưng chưa có phiếu, vốn phải trả 0.'),
    (22,24,'IF EXISTS kiểm sổ bất thường. Đọc đầu phiếu PHIEU_KHO p và nối chi tiết c qua MaPhieuKho để biết từng phiếu có chứa mặt hàng nào. SELECT 1 chỉ kiểm sự tồn tại, không cộng số lượng.'),
    (25,27,"Chỉ xét dòng của hàng đang hỏi và phiếu 'DaGhiSo'; nếu ThoiDiemGhiSo NULL thì trả NULL. Bước này không lọc theo mốc hỏi: chỉ cần một phiếu đã ghi sổ của hàng thiếu mốc là hàm từ chối tính, vì không xác định được nó thuộc trước hay sau mốc. Phiếu của hàng khác không kích hoạt nhánh này."),
    (28,29,'Khai báo biến bảng @BienDong: STT là BIGINT IDENTITY(1,1), tự tăng từ 1 và là khóa chính; SoLuong DECIMAL(18,6) NOT NULL giữ từng lượng biến động. Đây là tập làm việc cục bộ; không thêm bảng vật lý mới vào lược đồ.'),
    (30,32,'INSERT chỉ ghi vào cột SoLuong, còn STT do IDENTITY tạo. SELECT lấy c.BienDongSoLuong từ đầu phiếu nối chi tiết; giữ nguyên dấu đã có, không nhân dấu lần nữa theo LoaiPhieu. Nếu xuất -2,5 mà lại đổi dấu sẽ cộng sai.'),
    (33,34,"WHERE chỉ lấy đúng hàng, phiếu 'DaGhiSo' và thời điểm <= @DenThoiDiem. Dấu <= bao gồm giao dịch đúng mốc. Phiếu nháp, phiếu ngoài trạng thái này hoặc ghi sổ sau mốc đều không được cộng. Nguồn lọc là thời điểm ghi sổ, không phải thời điểm lập phiếu."),
    (35,35,'Chú thích giải thích vì sao biến tích lũy dùng DECIMAL(37,6): chừa khả năng tăng precision khi cộng mà vẫn giữ đủ sáu chữ số thập phân.'),
    (36,36,'@i=1 là chỉ số dòng đang duyệt; @n là tổng số dòng; @Luong giữ lượng của một dòng; @Ton DECIMAL(37,6)=0 là tổng cộng dồn rộng. Theo quy tắc precision của phép cộng decimal, cộng (37,6) với (18,6) cho biểu thức (38,6), còn trong giới hạn precision 38; sau đó gán về @Ton. Chọn biến tổng (38,6) có thể khiến biểu thức cần precision 39 và SQL Server phải giảm scale.'),
    (37,37,'COUNT_BIG(*) đếm số biến động đã chép vào biến bảng, gán cho @n. Khi không có dòng, @n=0; @Ton vẫn 0 và vòng lặp bị bỏ qua.'),
    (38,39,'WHILE @i<=@n chạy từ dòng 1 đến dòng n. BEGIN mở thân vòng lặp. Trong cách dùng này biến bảng mới tạo, chỉ INSERT một tập rồi không xóa dòng; STT được dùng làm chỉ số duyệt.'),
    (40,40,'SELECT gán SoLuong tại STT hiện tại vào @Luong. Khóa chính giúp mỗi STT xác định tối đa một dòng. Không có SELECT trả kết quả trung gian ra ngoài.'),
    (41,41,'Cộng lượng có dấu vào tổng. Ví dụ đang 10, đọc -2,5 thì còn 7,5. Không dùng ABS vì làm mất ý nghĩa nhập tăng, xuất giảm.'),
    (42,42,'Tăng chỉ số thêm 1 để đọc dòng kế tiếp. Nếu thiếu dòng này và n>=1 thì điều kiện WHILE không thay đổi, dẫn đến lặp không kết thúc.'),
    (43,43,'END kết thúc một lượt lặp và quay lại kiểm @i<=@n. Khi i=n+1, đi xuống bước kiểm miền kết quả.'),
    (44,44,'Nếu tổng cuối âm hoặc lớn hơn 999999999999.999999 thì trả NULL, tránh trả tồn âm hoặc ép kiểu vượt miền DECIMAL(18,6). Ngưỡng này có 12 chữ số nguyên và 6 số lẻ; đúng bằng ngưỡng vẫn được chấp nhận. Chỉ kiểm tổng cuối sau vòng lặp, không xác nhận tồn không âm ở mọi thời điểm lịch sử.'),
    (45,45,'CONVERT thu kết quả từ kiểu cộng rộng về DECIMAL(18,6) đã công bố; RETURN trả số tồn. Tổng bằng 0 là hợp lệ và trả 0.000000.'),
    (46,47,'END đóng thân hàm; GO đóng batch. Không COMMIT/ROLLBACK ở đây vì hàm không thực hiện cập nhật nghiệp vụ.'),
])
h('6.3. Tính tay tồn kho và kiểm kê',2)
table(['Mốc/phiếu','Lượng đưa vào sổ','Tồn sau cộng','Ý nghĩa'],[
    ('Trước 01/11/2026','Chưa có', '0,000000','Hàng đã có trong danh mục nhưng chưa nhập'),
    ('01/11 – PK_MO_SO','+10,000000','10,000000','Ghi sổ nhập mở đầu'),
    ('02/11 – PK_XUAT_HUY','−2,500000','7,500000','Hàng hỏng được xuất hủy'),
    ('03/11 – PK_KIEM_KE','+0,500000','8,000000','Đếm thực tế 8; 8 − 7,5 = +0,5'),
    ('04/11 – PK_NHAP','+1000 ở bản nháp','8,000000','Chưa ghi sổ nên không tham gia'),
], [2300,2000,1800,3500])
p('Seed ban đầu tạo dòng nháp kiểm kê với SoLuongThucTe=8. Khi gọi usp_N2_GhiSoPhieuKho, nghiệp vụ ghi sổ tính lại tồn trước đó dưới khóa và chốt BienDongSoLuong=0,5. Hàm 2 chỉ đọc chênh lệch đã ghi sổ; không cộng thêm 8 vào 7,5. Nếu tự đọc nhầm dữ liệu nháp để tính, sẽ ra 15,5 và sai ý nghĩa.')
p('STT trong @BienDong không được sắp theo thời gian vì INSERT SELECT không có ORDER BY. Điều đó không ảnh hưởng tổng đại số cuối khi dữ liệu nằm trong miền số, nhưng không thể dựa trên thứ tự này để chứng minh lịch sử luôn không âm. Ví dụ +10 và −2,5 có thể được duyệt theo bất kỳ thứ tự nào; chỉ tổng 7,5 là mục tiêu của hàm này.')
h('6.4. Mốc thời gian và các giới hạn cần hiểu',2)
p("'20261103' nghĩa là 03/11/2026 00:00:00. Với seed ghi sổ đúng đầu ngày, mốc này đã bao gồm kiểm kê. Nếu có phiếu ghi lúc 15:00 cùng ngày thì mốc đầu ngày không bao gồm phiếu đó. Muốn hỏi tới 15:00 phải truyền đầy đủ '2026-11-03T15:00:00'.")
p('Kiểu tổng rộng giảm rủi ro tràn số trung gian, nhưng không bảo đảm vô hạn: nếu @Ton vượt miền DECIMAL(37,6), lỗi số học có thể phát sinh trước nhánh kiểm cuối. Hàm chỉ chủ động trả NULL cho các điều kiện được viết rõ. Không nhận xét rằng mọi lỗi SQL Server đều được bắt và chuyển thành NULL.')
p('Không dùng hàm đọc tồn như một thao tác giữ chỗ hàng. Hai phiên cùng đọc một số tồn rồi cùng xuất có thể tranh chấp; thủ tục ghi sổ phải kiểm và khóa dữ liệu trong giao dịch. Việc đọc lại sổ theo phiếu hiện đang DaGhiSo cũng không tự tạo cơ chế phục dựng mọi lần thay đổi trạng thái trong quá khứ; mô hình dựa vào tính bất biến của phiếu đã ghi sổ.')

page(); h('7. Giải thích từng câu lệnh kiểm thử Hàm 2')
p('File này do Người 5 chuẩn bị để bàn giao Người 4. Các dữ liệu HH_KIEMTHU, HH_CHUA_NHAP, HH_TINY phải được tạo bởi seed chung; hàm phải được cài trước. Script chỉ gọi hàm và lưu kết quả vào biến bảng để so sánh, không tạo/hủy các phiếu đã ghi sổ.')
annotate(BASE/'05_Demo_Ham_2_ban_giao.sql',[
    (1,2,'Chú thích xác định quyền tác giả và người nhận demo: Người 5 chuẩn bị test Hàm 2, Người 4 thực hiện demo khi tích hợp. Không sửa/hủy phiếu đã ghi sổ để làm khớp kỳ vọng.'),
    (3,3,'DECLARE @KQ TABLE tạo bảng kết quả tạm của batch: Ca NVARCHAR(100) chứa tên ca tiếng Việt, KyVong là số tính trước, ThucTe là giá trị hàm trả. Hai cột số cùng DECIMAL(18,6), mặc định có thể NULL để biểu diễn trường hợp đầu vào sai.'),
    (4,4,'INSERT @KQ VALUES bắt đầu chèn nhiều bộ ba theo thứ tự cột đã khai báo: tên ca, kỳ vọng, thực tế. Mỗi biểu thức gọi hàm ở các dòng sau được tính để điền cột ThucTe.'),
    (5,5,"Ca 'Trước nhập': hàng đã tồn tại nhưng mốc 31/10 trước phiếu mở sổ 01/11, nên kỳ vọng 0. Tiền tố N trước nhãn giữ chữ tiếng Việt; mã và ngày dùng chuỗi thông thường."),
    (6,6,"Ca 'Đúng mốc nhập': dùng 01/11 đúng thời điểm nhập seed; dấu <= trong hàm phải lấy phiếu nên trả 10. Đây là kiểm tra biên có dấu bằng."),
    (7,7,"Ca 'Sau xuất hủy': tại 02/11 đã có +10 và −2,5; kỳ vọng 7,5. Trong SQL dùng dấu chấm 7.5 cho số thập phân, không dùng dấu phẩy 7,5."),
    (8,8,"Ca 'Sau kiểm kê': tổng bằng 8 nhờ chênh lệch kiểm kê +0,5. Không cộng số đếm thực tế 8 như một lần nhập mới."),
    (9,9,"Ca 'Phiếu nháp không tính tồn': tới 30/11 vẫn là 8; bản nháp +1000 không làm tồn thành 1008. Kiểm điều kiện trạng thái DaGhiSo."),
    (10,10,"Ca 'Hàng chưa nhập': HH_CHUA_NHAP là mã có thật nhưng chưa có biến động, nên kỳ vọng 0. Phân biệt với mã không tồn tại ở dòng 12."),
    (11,11,"Ca 'Giữ đủ sáu số lẻ': HH_TINY đã nhập 0.000001, kỳ vọng giữ đúng 0.000001, không làm tròn thành 0. Nhằm kiểm kiểu DECIMAL có scale 6."),
    (12,12,"Ca 'Mã không có': KHONG_CO không tồn tại trong HANG_HOA nên kỳ vọng NULL."),
    (13,13,"Ca 'Mã NULL': thiếu mã đầu vào, kỳ vọng NULL theo nhánh kiểm đầu hàm."),
    (14,14,"Ca 'Mốc NULL': có mã đúng nhưng thiếu thời điểm, kỳ vọng NULL. Dấu ; kết thúc câu INSERT nhiều dòng."),
    (15,15,"SELECT * hiển thị tên ca, kỳ vọng và thực tế. CASE thêm KetQua: PASS khi hai số bằng nhau hoặc cả hai đều NULL, còn lại FAIL. Phải viết riêng nhánh hai NULL vì NULL = NULL không cho TRUE trong so sánh SQL."),
    (16,16,'IF EXISTS tìm ít nhất một ca sai. Ba khả năng là hai số khác nhau; kỳ vọng NULL nhưng thực tế có số; hoặc kỳ vọng có số nhưng thực tế NULL. Chỉ KyVong<>ThucTe không bắt được hai trường hợp lệch NULL, vì phép so sánh đó trả UNKNOWN.'),
    (17,17,"Nếu có ca sai thì THROW phát sinh lỗi 51993, thông báo tiếng Việt và state 1. Đây là mã lỗi tự chọn >=50000 cho test. THROW nằm trong batch kiểm thử bên ngoài hàm; không nằm trong scalar UDF. Câu lệnh trước THROW đã kết thúc bằng dấu ; ở SELECT dòng 15."),
    (18,18,'GO kết thúc batch; @KQ không còn dùng được ở batch sau. Nếu mọi ca khớp thì không chạy THROW. Cần kiểm cả cột PASS/FAIL và lỗi trong Messages khi demo.'),
])
p('Phạm vi test hiện có: 10 ca nêu trên. Chưa có ca trực tiếp cho mã chuỗi rỗng, phiếu ghi sổ thiếu mốc, tổng âm hay vượt miền trả về. Các nhánh đó được giải thích từ code, không tuyên bố bộ test này đã bao phủ toàn bộ. Một số dữ liệu sai bị ràng buộc/trigger ngăn từ trước nên không nên vô hiệu hóa chúng để dựng demo.')

page(); h('8. Giải thích mã demo Hàm 1 được bàn giao cho Người 3')
p('Phần này giúp Người 5 giải thích hợp đồng bàn giao. Mã demo nằm trong thư mục Người 3 và vẫn do Người 3 thực hiện theo phân công; tác giả Hàm 1 là Người 5.')
annotate(BASE.parent/'nguoi3/07_Demo_Ham_1.sql',[
    (1,2,'Chú thích xác định đây là nhiệm vụ demo Hàm 1 của Người 3, nhận hàm từ Người 5. Phải tạo hàm trước, dùng seed hiện tại thay vì mã ROOT/CHILD của dữ liệu cũ.'),
    (3,3,'Tạo @KQ với nhãn ca Unicode và hai cột BIGINT là kỳ vọng/thực tế, khớp kiểu trả về của Hàm 1. Cho phép NULL để kiểm đầu vào sai.'),
    (4,4,'Bắt đầu INSERT nhiều ca kiểm thử; thứ tự mỗi bộ là Ca, KyVong, ThucTe.'),
    (5,5,'DM_DOUONG kỳ vọng 8: 3 lựa chọn cà phê + 5 lựa chọn trà. Kiểm việc duyệt xuống danh mục con dù cha không chứa món trực tiếp.'),
    (6,6,'DM_TRA kỳ vọng 5: trà sữa 3 size đang bán và trà đào 2 size đang bán. Size S trà đào ngừng bán không được tính.'),
    (7,7,'DM_TOPPING kỳ vọng 2: hai topping, mỗi topping một cấu hình TC. Chỉ đếm cấu hình, không khẳng định bán riêng.'),
    (8,8,'DM_RONG tồn tại nhưng không có lựa chọn, kỳ vọng 0. Kiểm đường đi hợp lệ mà tổng không tăng.'),
    (9,9,'KHONG_CO không có trong bảng danh mục, kỳ vọng NULL; không đồng nhất với danh mục rỗng.'),
    (10,10,'Truyền NULL làm tham số; kỳ vọng RETURN NULL ngay nhánh kiểm đầu vào.'),
    (11,11,"Truyền chuỗi hai dấu cách; RTRIM/LTRIM làm rỗng, NULLIF chuyển thành NULL, nên kỳ vọng NULL. Dấu ; kết thúc toàn bộ INSERT."),
    (12,12,'Xuất tất cả ca và cột CASE PASS/FAIL. Hai số bằng nhau hoặc cả hai NULL được xem là khớp. Nhánh ELSE nhận mọi trường hợp còn lại.'),
    (13,13,'IF EXISTS tìm ít nhất một trường hợp lệch giá trị hoặc lệch trạng thái NULL. Dù SELECT trước đó đã in bảng kết quả, dòng này vẫn cần để script phát sinh lỗi có thể kiểm được.'),
    (14,14,'THROW 51993 với thông báo Demo Hàm 1 không khớp kỳ vọng, state 1. Không chạy nếu tất cả ca đúng. Đây là lỗi của kiểm thử bên ngoài hàm.'),
    (15,15,'GO kết thúc batch và phạm vi biến bảng @KQ.'),
])
p('Bảy ca hiện tại không dựng chu trình. Khi dữ liệu được bảo vệ đúng, thao tác tạo chu trình sẽ bị chặn ở tầng ghi. Kiểm tra chu trình trong hàm là phòng vệ và được phân tích bằng ví dụ A → B → A ở mục 5, không được mô tả như đã chạy một ca phá ràng buộc.')

page(); h('9. Cách chạy, giới hạn và câu hỏi vấn đáp')
h('9.1. Cách xem và chạy trong đúng ngữ cảnh',2)
for text in [
    'Bước 1. Dùng bộ tích hợp fix/BTL2_FIX_NGUOI_1_2_3_4_5.sql để tạo một CSDL mới theo README. File này có guard tránh chạy vào tên CSDL đã tồn tại. Không ghép lại các module rời vào cùng lần cài rồi lại chạy file tổng hợp.',
    'Bước 2. Trong SSMS chọn đúng CSDL vừa được tạo. Các file Người 5 không có USE nên luôn thực hiện trong CSDL đang chọn. Cấu trúc, ràng buộc, seed và hàm phải khớp phiên bản fix.',
    'Bước 3. Có thể chạy riêng hai file truy vấn 01 và 02 để xem bảng kết quả. Chúng không cập nhật dữ liệu. Nếu file tổng hợp đã cài hàm thì không cần tạo lại chỉ để gọi demo.',
    'Bước 4. Chạy nguoi3/07_Demo_Ham_1.sql và nguoi5/05_Demo_Ham_2_ban_giao.sql hoặc demo nhận tương ứng của Người 4. Kiểm tra cả Result và Messages; đối chiếu seed nếu kết quả lệch.',
    'Bước 5. Khi thuyết trình, cho thấy dữ liệu nguồn liên quan, câu SQL, kết quả và giải thích tại sao từng giá trị xuất hiện. Tài liệu này không thay cho minh chứng chạy DBMS thực tế.',
]: p(text)
h('9.2. Các điểm dễ hiểu nhầm',2)
table(['Điểm cần phân biệt','Cách giải thích chính xác'],[
    ('WHERE và HAVING','WHERE loại dòng trước khi nhóm; HAVING loại nhóm sau tổng hợp.'),
    ('COUNT món và COUNT size','DISTINCT MaMon đếm món; COUNT_BIG(*) trên phép nối đếm lựa chọn món–size.'),
    ('Truy vấn 4 và Hàm 1','Truy vấn 4 nhóm danh mục trực tiếp; Hàm 1 cộng cả phần cây con.'),
    ('Trung bình size và trung bình món','Truy vấn 4 tính trên các size; ngưỡng Truy vấn 5 tính trên giá trung bình của từng món.'),
    ('0 và NULL','0 là phép tính hợp lệ cho kết quả không có; NULL là thiếu/sai đầu vào hoặc dữ liệu không cho tính theo hợp đồng.'),
    ('Số kiểm kê và biến động kiểm kê','Thực tế 8 không có nghĩa nhập thêm 8; nếu tồn trước 7,5 thì chênh lệch cộng là 0,5.'),
    ('Thời điểm lập và ghi sổ','Tồn xét ThoiDiemGhiSo. Phiếu lập rồi nhưng còn nháp chưa làm tăng/giảm tồn.'),
    ('Mốc ngày và cuối ngày','Chuỗi YYYYMMDD là đầu ngày; phải chỉ rõ giờ nếu cần mốc trong ngày.'),
    ('Đọc tồn và giữ tồn','Hàm SELECT không thực hiện cơ chế khóa/kiểm xuất của thủ tục ghi sổ.'),
], [3000,6600])
h('9.3. Hỏi–đáp để chuẩn bị vấn đáp',2)
for question,answer in [
    ('Vì sao Hàm 1 cần WHILE?', 'Số cấp danh mục chưa biết trước. WHILE mở rộng tập danh mục tới khi không còn mã chờ; một JOIN cha–con đơn lẻ chỉ đi được một cấp.'),
    ('Có bắt buộc Cursor trong hai hàm không?', 'Phân công không bắt buộc Cursor cho mọi hàm. Hai hàm dùng IF và WHILE, có truy xuất dữ liệu và kiểu đầu ra rõ. Hàm 1 dùng tập mã chờ; Hàm 2 dùng các dòng biến động đã đánh STT.'),
    ('Tại sao Hàm 2 không viết một SUM?', 'Về mục tiêu tổng đại số có thể nghiên cứu cách viết theo tập với SUM, giữ nguyên kiểm đầu vào và kiểu tổng. Bản nộp dùng WHILE để thể hiện điều kiện/vòng lặp theo yêu cầu môn học. Không kết luận WHILE nhanh hơn SUM.'),
    ('Hàm có thay đổi dữ liệu thật không?', 'Không. INSERT/UPDATE trong Hàm 1 và INSERT trong Hàm 2 tác động biến bảng cục bộ. MON, SIZE_MON, DANH_MUC_MON và các phiếu kho chỉ được đọc.'),
    ('Vì sao không THROW bên trong hàm?', 'Bản triển khai scalar UDF trả NULL theo hợp đồng khi gặp các điều kiện không hợp lệ; THROW được đặt ở batch demo bên ngoài để báo ca không khớp. Người gọi phải diễn giải NULL rõ ràng.'),
    ('Bỏ DISTINCT ở Truy vấn 4 có được không?', 'Khi một món có nhiều size, COUNT(MaMon) sẽ đếm nhiều lần và gần với số lựa chọn. Muốn số món thì phải loại trùng mã món.'),
    ('Tại sao cùng cần kiểm trạng thái món và trạng thái size?', 'Món đang bán có thể có size ngừng bán; ngược lại không được coi size đang bán của món ngừng bán là lựa chọn hợp lệ. Hai điều kiện biểu diễn hai cấp cấu hình khác nhau.'),
    ('Hàm 1 có thật sự duyệt theo hàng đợi FIFO không?', 'Không. Nó chọn mã chưa duyệt nhỏ nhất theo ORDER BY MaDanhMuc. @HangDoi là tên biến; không có cột thứ tự thêm để bảo đảm FIFO.'),
    ('Hàm 2 có chứng minh tồn lịch sử luôn không âm không?', 'Không. Nó cộng các biến động được chọn và kiểm tổng cuối. Thứ tự STT không bảo đảm thời gian; lịch sử và cạnh tranh giao dịch do quy trình ghi sổ bảo vệ.'),
    ('Có thể nói mã này luôn trả NULL khi lỗi không?', 'Không. Chỉ các nhánh RETURN NULL được chủ động xử lý. Lỗi engine khác như tràn biến tổng cực lớn, thiếu quyền hoặc thiếu bảng vẫn có thể làm câu gọi thất bại.'),
]:
    p(question,'Label'); p(answer)
h('9.4. Diễn giải ngắn cho từng sản phẩm',2)
p('Truy vấn 4: “Em nối danh mục, món và size; lọc cả món lẫn size đang bán; nhóm theo danh mục trực tiếp để đếm số món riêng biệt, số lựa chọn và các mức giá; sắp danh mục nhiều lựa chọn lên trước.”')
p('Truy vấn 5: “Em tính giá trung bình size đang bán của từng món. Một truy vấn con sâu hơn lập bảng giá trung bình mỗi món; tầng kế lấy trung bình bảng đó làm ngưỡng chung. HAVING giữ các món cao hơn ngưỡng, nên mỗi món có trọng số ngang nhau.”')
p('Hàm 1: “Em kiểm mã danh mục, lưu danh mục gốc vào biến bảng rồi dùng WHILE để đếm và mở rộng xuống con. Cờ đã duyệt tránh xử lý lại, kiểm nút đã phát hiện để phòng chu trình. Hợp lệ rỗng trả 0; mã sai hoặc chu trình trả NULL.”')
p('Hàm 2: “Em kiểm hàng và mốc, chỉ lấy dòng phiếu đã ghi sổ không muộn hơn mốc, cộng lượng tăng giảm bằng WHILE với DECIMAL rộng. Sau khi kiểm tổng không âm và không vượt miền thì trả DECIMAL(18,6). Phiếu nháp không tham gia; NULL không có nghĩa là hết hàng.”')
h('10. Danh sách nguồn đối chiếu trong dự án')
for text in [
    'Phan_cong_BTL2_Database_SQL_Server (1).docx – phân công; nội dung đọc từ bản trích audit/sources cùng tên.',
    'fix/README.md – xác định bộ tích hợp và quy tắc chạy/kiểm thử.',
    'fix/nguoi5/BAO_CAO.md – hợp đồng hai hàm và mục tiêu hai truy vấn.',
    'fix/nguoi5/01_Truy_van_4.sql; 02_Truy_van_5.sql; 03_Ham_1.sql; 04_Ham_2.sql; 05_Demo_Ham_2_ban_giao.sql – mã được chép và giải thích.',
    'fix/nguoi3/07_Demo_Ham_1.sql – mã demo liên quan bàn giao cho Người 3.',
    'fix/chung/05_Du_lieu_mau.sql – giá, cây danh mục, mặt hàng, phiếu và thời điểm ghi sổ dùng để suy ra ví dụ.',
    'EERD_UPDATE.xlsx và EERD_VE_LAI.drawio – chuẩn mô hình được các module fix dẫn chiếu; tài liệu này tập trung diễn giải SQL hiện có, không thực hiện một cuộc kiểm toán mô hình mới.',
]: p(text)
p('Kiểm tra biên soạn: tất cả dòng không trống của sáu file SQL nêu trên đều có khối giải thích theo số dòng. Công cụ sinh tài liệu kiểm tra độ bao phủ và lưu SHA256 nguồn; các kết quả ví dụ được tính từ seed, không dùng lại log cũ để nhận là lần chạy mới.', 'Note')

sect=el(body,'sectPr')
for tag,ident in [('headerReference','rIdHeader'),('footerReference','rIdFooter')]:
    node=el(sect,tag,type='default'); node.set('{'+R+'}id',ident)
el(sect,'pgSz',w=11906,h=16838)
el(sect,'pgMar',top=1134,right=1134,bottom=1134,left=1134,header=540,footer=540,gutter=0)

styles=E.Element('{'+W+'}styles')
defaults=el(styles,'docDefaults'); rp=el(el(defaults,'rPrDefault'),'rPr')
el(rp,'rFonts',ascii='Times New Roman',hAnsi='Times New Roman',eastAsia='Times New Roman'); el(rp,'sz',val=24)
el(rp,'lang',val='vi-VN')
pp=el(el(defaults,'pPrDefault'),'pPr'); el(pp,'spacing',after=100,line=276,lineRule='auto')
for ident,size,color,bold in [
    ('Normal',24,'222B36',False),('Title',44,'17365D',True),('Subtitle',28,'52657C',False),
    ('Heading1',32,'17365D',True),('Heading2',27,'245A81',True),
    ('Label',24,'245A81',True),('Code',18,'23364B',False),('Small',20,'5C6876',False),
    ('Note',22,'465C72',False),('TableText',21,'222B36',False),
]:
    s=el(styles,'style',type='paragraph',styleId=ident)
    if ident=='Normal': s.set('{'+W+'}default','1')
    el(s,'name',val=ident)
    if ident!='Normal': el(s,'basedOn',val='Normal')
    el(s,'next',val='Normal')
    pr=el(s,'pPr')
    if ident.startswith('Heading') or ident=='Label':
        el(pr,'keepNext')
    el(pr,'widowControl')
    if ident.startswith('Heading') or ident=='Label':
        el(pr,'spacing',before=180,after=90)
    if ident=='Code':
        el(pr,'shd',val='clear',fill='F1F5F9')
        el(pr,'spacing',before=0,after=25,line=230,lineRule='auto')
        el(pr,'ind',left=100,right=100)
    if ident=='TableText': el(pr,'spacing',after=50,line=240,lineRule='auto')
    if ident.startswith('Heading'): el(pr,'outlineLvl',val=int(ident[-1])-1)
    rpr=el(s,'rPr')
    if ident=='Code': el(rpr,'rFonts',ascii='Consolas',hAnsi='Consolas')
    if bold: el(rpr,'b')
    el(rpr,'color',val=color); el(rpr,'sz',val=size)

header=E.Element('{'+W+'}hdr'); p('NGƯỜI 5  |  GIẢI THÍCH CODE SQL  |  BẢN FIX','Small',header)
footer=E.Element('{'+W+'}ftr'); fp=p('Người 5 • Tài liệu giải thích mã nguồn     |     Trang ','Small',footer)
el(fp.find('{'+W+'}pPr'),'jc',val='right')
run=el(fp,'r'); el(run,'fldChar',fldCharType='begin')
run=el(fp,'r'); el(run,'instrText',' PAGE ')
run=el(fp,'r'); el(run,'fldChar',fldCharType='end')

def xml(node): return E.tostring(node,encoding='utf-8',xml_declaration=True)
CT='http://schemas.openxmlformats.org/package/2006/content-types'
types=E.Element('{'+CT+'}Types')
for ext,kind in [('rels','application/vnd.openxmlformats-package.relationships+xml'),('xml','application/xml')]:
    E.SubElement(types,'{'+CT+'}Default',Extension=ext,ContentType=kind)
for part,kind in [('document','document.main'),('styles','styles'),('header1','header'),('footer1','footer')]:
    E.SubElement(types,'{'+CT+'}Override',PartName='/word/'+part+'.xml',ContentType='application/vnd.openxmlformats-officedocument.wordprocessingml.'+kind+'+xml')
REL='http://schemas.openxmlformats.org/package/2006/relationships'
def rels(rows):
    E.register_namespace('',REL)
    root=E.Element('{'+REL+'}Relationships')
    for ident,kind,target in rows: E.SubElement(root,'{'+REL+'}Relationship',Id=ident,Type=R+'/'+kind,Target=target)
    return xml(root)
with ZipFile(OUT,'w',ZIP_DEFLATED) as z:
    E.register_namespace('',CT)
    z.writestr('[Content_Types].xml',xml(types))
    z.writestr('_rels/.rels',rels([('rId1','officeDocument','word/document.xml')]))
    z.writestr('word/document.xml',xml(doc))
    z.writestr('word/styles.xml',xml(styles))
    z.writestr('word/header1.xml',xml(header))
    z.writestr('word/footer1.xml',xml(footer))
    z.writestr('word/_rels/document.xml.rels',rels([
        ('rIdStyles','styles','styles.xml'),('rIdHeader','header','header1.xml'),('rIdFooter','footer','footer1.xml')]))
(BASE/'Kiem_tra_tai_lieu_giai_thich.json').write_text(json.dumps(coverage,ensure_ascii=False,indent=2),encoding='utf-8')
print(OUT)
print('Explained nonempty source lines:',sum(row['explained_nonempty_lines'] for row in coverage.values()))
print('Document paragraphs:',len(doc.findall('.//{'+W+'}p')))
