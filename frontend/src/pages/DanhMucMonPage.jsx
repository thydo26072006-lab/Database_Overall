import { useCallback, useEffect, useId, useRef, useState } from 'react';
import { danhMucMon } from '../services/danhMucMon.js';
import DanhMucMonDialog from '../components/DanhMucMonDialog.jsx';
import './danhMucMon.css';

export default function DanhMucMonPage() {
  const titleId = useId();
  const [rows, setRows] = useState([]);
  const [loading, setLoading] = useState(true);
  const [loadError, setLoadError] = useState(null);
  const [notice, setNotice] = useState('');
  const [activeDialog, setActiveDialog] = useState(null);
  const [busy, setBusy] = useState(false);
  const [saveError, setSaveError] = useState(null);
  const lastListRequest = useRef(null);

  const reload = useCallback(async () => {
    lastListRequest.current?.abort();
    const controller = new AbortController();
    lastListRequest.current = controller;
    setLoading(true);
    setLoadError(null);

    try {
      const categories = await danhMucMon.list(controller.signal);
      if (!Array.isArray(categories)) throw new Error('Máy chủ không trả về danh sách danh mục.');
      if (!controller.signal.aborted) setRows(categories);
    } catch (error) {
      if (!controller.signal.aborted) setLoadError(error);
    } finally {
      if (!controller.signal.aborted) setLoading(false);
    }
  }, []);

  useEffect(() => {
    reload();
    return () => lastListRequest.current?.abort();
  }, [reload]);

  function openDialog(mode, row) {
    setSaveError(null);
    setActiveDialog({ mode, row });
  }

  async function save(fields) {
    if (busy) return;
    setBusy(true);
    setSaveError(null);
    setNotice('');
    const { mode, row } = activeDialog;

    try {
      if (mode === 'create') {
        const created = await danhMucMon.create(fields);
        setNotice(`Đã thêm danh mục ${created.maDanhMuc}.`);
      } else if (mode === 'edit') {
        await danhMucMon.update(row.maDanhMuc, fields);
        setNotice(`Đã cập nhật danh mục ${row.maDanhMuc}.`);
      } else {
        await danhMucMon.remove(row.maDanhMuc);
        setNotice(`Đã xoá danh mục ${row.maDanhMuc}.`);
      }

      setActiveDialog(null);
      await reload();
    } catch (error) {
      setSaveError(error);
    } finally {
      setBusy(false);
    }
  }

  const byCode = new Map(rows.map((row) => [row.maDanhMuc, row.tenDanhMuc]));

  return (
    <section className="dm-page" aria-labelledby={titleId}>
      <div className="dm-layout">
        <header className="dm-heading">
          <div>
            <p className="dm-context">Quản lý thực đơn</p>
            <h1 id={titleId}>Danh mục món</h1>
          </div>
          <button
            className="dm-button dm-primary"
            type="button"
            onClick={() => openDialog('create')}
            disabled={loading || busy || Boolean(loadError)}
          >
            <span aria-hidden="true">+</span> Thêm danh mục
          </button>
        </header>

        {notice && <p className="dm-message dm-message-success" role="status">{notice}</p>}
        {loadError && (
          <p className="dm-message dm-message-error" role="alert">
            {loadError.message}
            {rows.length > 0 && <span> Dữ liệu bên dưới là lần tải gần nhất.</span>}
          </p>
        )}

        <div className="dm-panel" aria-busy={loading}>
          <div className="dm-panel-header">
            <p className="dm-count">
              {loading ? 'Đang tải danh mục…' : `${rows.length} danh mục`}
            </p>
            <button className="dm-button dm-secondary" type="button" onClick={reload} disabled={loading || busy}>
              Tải lại
            </button>
          </div>
          <div className="dm-table-scroll">
            <table aria-label="Danh sách danh mục món">
              <thead>
                <tr>
                  <th scope="col">Mã danh mục</th>
                  <th scope="col">Tên danh mục</th>
                  <th scope="col">Danh mục cha</th>
                  <th scope="col" className="dm-actions">Thao tác</th>
                </tr>
              </thead>
              <tbody>
                {!loading && !loadError && rows.length === 0 && (
                  <tr><td colSpan="4" className="dm-empty">Chưa có danh mục món.</td></tr>
                )}
                {rows.map((row) => (
                  <tr key={row.maDanhMuc}>
                    <td><code className="dm-code">{row.maDanhMuc}</code></td>
                    <th className="dm-category" scope="row">{row.tenDanhMuc}</th>
                    <td className="dm-parent">
                      {row.maDanhMucCha ? (byCode.get(row.maDanhMucCha) ?? row.maDanhMucCha) : '—'}
                    </td>
                    <td className="dm-actions">
                      <button
                        type="button"
                        className="dm-text-button"
                        aria-label={`Sửa ${row.tenDanhMuc}`}
                        disabled={busy || loading || Boolean(loadError)}
                        onClick={() => openDialog('edit', row)}
                      >
                        Sửa
                      </button>
                      <button
                        type="button"
                        className="dm-text-button dm-delete"
                        aria-label={`Xoá ${row.tenDanhMuc}`}
                        disabled={busy || loading || Boolean(loadError)}
                        onClick={() => openDialog('delete', row)}
                      >
                        Xoá
                      </button>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </div>

      {activeDialog && (
        <DanhMucMonDialog
          {...activeDialog}
          categories={rows}
          busy={busy}
          error={saveError}
          onCancel={() => setActiveDialog(null)}
          onSave={save}
        />
      )}
    </section>
  );
}
