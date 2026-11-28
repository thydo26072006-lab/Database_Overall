import { useState } from 'react';
import { fetchShiftReport } from '../services/shiftReport.js';
import StatusBadge from '../components/StatusBadge.jsx';
import './shiftReport.css';

const columns = [
  ['MaCa', 'Mã ca'],
  ['NgayLam', 'Ngày làm'],
  ['GioBatDau', 'Bắt đầu'],
  ['GioKetThuc', 'Kết thúc'],
  ['SoNhanVienPhucVu', 'Nhân viên phục vụ'],
  ['SoBanDuocPhanCong', 'Bàn được phân công'],
  ['SoLuotPhanCong', 'Lượt phân công'],
  ['TinhTrang', 'Tình trạng'],
];

function formatDate(isoDate) {
  return isoDate.split('-').reverse().join('/');
}

export default function ShiftReportPage() {
  const [from, setFrom] = useState('');
  const [to, setTo] = useState('');
  const [result, setResult] = useState(null);
  const [error, setError] = useState('');
  const [loading, setLoading] = useState(false);

  async function submit(event) {
    event.preventDefault();
    setResult(null);
    setError('');
    setLoading(true);
    try {
      const report = await fetchShiftReport(from, to);
      setResult({ ...report, from, to });
    } catch (requestError) {
      setError(requestError.message);
    } finally {
      setLoading(false);
    }
  }

  return (
    <section className="shift-report" aria-labelledby="shift-report-title">
      <h1 id="shift-report-title">Tổng hợp phân công theo ca</h1>
      <form onSubmit={submit} aria-label="Khoảng ngày báo cáo">
        <label>Từ ngày<input type="date" value={from} onChange={(event) => setFrom(event.target.value)} disabled={loading} /></label>
        <label>Đến ngày<input type="date" value={to} onChange={(event) => setTo(event.target.value)} disabled={loading} /></label>
        <button type="submit" disabled={loading}>Xem báo cáo</button>
      </form>

      <section className="report-results" aria-label="Kết quả báo cáo" aria-busy={loading}>
        {loading && <p className="report-message" role="status">Đang tải báo cáo…</p>}
        {error && <p className="report-message report-error" role="alert">{error}</p>}
        {result && (
          <>
            <h2>{formatDate(result.from)} – {formatDate(result.to)}</h2>
            {result.data.length === 0 ? (
              <p className="report-message" role="status">{result.message ?? 'Không có ca làm trong khoảng ngày đã chọn.'}</p>
            ) : (
              <div className="report-table" tabIndex={0} role="region" aria-label="Bảng phân công theo ca">
                <table>
                  <caption>{result.data.length} ca làm</caption>
                  <thead>
                    <tr>{columns.map(([key, label]) => <th key={key} scope="col">{label}</th>)}</tr>
                  </thead>
                  <tbody>
                    {result.data.map((row) => (
                      <tr key={row.MaCa}>
                        {columns.map(([key]) => {
                          let value = row[key];
                          if (key === 'NgayLam') value = formatDate(value);
                          if (key === 'TinhTrang') value = <StatusBadge active={value === 'Đã phân công'}>{value}</StatusBadge>;
                          return <td key={key}>{value}</td>;
                        })}
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            )}
          </>
        )}
      </section>
    </section>
  );
}
