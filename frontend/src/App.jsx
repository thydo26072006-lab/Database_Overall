import AppLayout from './components/AppLayout.jsx';
import HomePage from './pages/HomePage.jsx';
import DanhMucMonPage from './pages/DanhMucMonPage.jsx';
import TriggerMonPage from './pages/TriggerMonPage.jsx';
import ShiftReportPage from './pages/ShiftReportPage.jsx';

const features = [
  {
    path: '/danh-muc-mon',
    label: 'Quản lý danh mục món',
    Component: DanhMucMonPage,
    description: 'Xem, thêm, sửa và xóa danh mục trong thực đơn.',
    sql: ['usp_N1_ThemDanhMuc', 'usp_N2_CapNhatDanhMuc', 'usp_N3_XoaDanhMuc'],
  },
  {
    path: '/mon-va-size',
    label: 'Quản lý món và size',
    Component: TriggerMonPage,
    description: 'Thêm món, cập nhật trạng thái bán và quản lý size. SQL Server tự thêm size mặc định cho món mới.',
    sql: ['trg_N2_Mon_TaoSizeMacDinh', 'trg_N2_Size_DungLoai'],
  },
  {
    path: '/phan-cong-theo-ca',
    label: 'Tổng hợp phân công theo ca',
    Component: ShiftReportPage,
    description: 'Chọn khoảng ngày để xem tình trạng phân công và số bàn được bố trí theo ca.',
    sql: ['usp_N3_TongHopPhanCongTheoCa'],
  },
];

const pages = [{ path: '/', label: 'Trang chủ' }, ...features];

export default function App() {
  const path = window.location.pathname.replace(/\/+$/, '') || '/';
  const Component = features.find(feature => feature.path === path)?.Component;

  return (
    <AppLayout currentPath={path} pages={pages}>
      {path === '/' && <HomePage features={features} />}
      {Component && <Component />}
      {path !== '/' && !Component && <h1 className="app-page-heading">Không tìm thấy trang</h1>}
    </AppLayout>
  );
}
