import { useCallback, useEffect, useId, useRef, useState } from 'react';
import { triggerMonApi } from '../services/triggerMon.js';
import StatusBadge from '../components/StatusBadge.jsx';
import './triggerMon.css';

const types = { DoUong: 'Đồ uống', DoAn: 'Đồ ăn', Topping: 'Topping' };
const statuses = { NgungBan: 'Ngừng bán', DangBan: 'Đang bán' };
const regularSizeCodes = ['S', 'M', 'L'];
const toppingSizeCodes = ['TC'];
const priceInDong = new Intl.NumberFormat('vi-VN', { style: 'currency', currency: 'VND' });

function StatusSelect({ name, label, value = 'NgungBan' }) {
  return (
    <label>
      {label}
      <select name={name} defaultValue={value}>
        {Object.entries(statuses).map(([code, text]) => <option key={code} value={code}>{text}</option>)}
      </select>
    </label>
  );
}

export default function TriggerMonPage() {
  const titleId = useId();
  const sizeErrorId = useId();
  const [data, setData] = useState({ items: [], categories: [] });
  const [selectedCode, setSelectedCode] = useState(null);
  const [editCode, setEditCode] = useState(null);
  const [loading, setLoading] = useState(true);
  const [busy, setBusy] = useState(false);
  const [loadError, setLoadError] = useState('');
  const [feedback, setFeedback] = useState(null);
  const activeRead = useRef(null);

  const load = useCallback(async () => {
    activeRead.current?.abort();
    const controller = new AbortController();
    activeRead.current = controller;
    const { signal } = controller;
    setLoading(true);
    setLoadError('');
    try {
      const [items, categories] = await Promise.all([
        triggerMonApi.list(signal),
        triggerMonApi.categories(signal),
      ]);
      if (!signal.aborted) setData({ items, categories });
    } catch (error) {
      if (!signal.aborted) setLoadError(error.message);
    } finally {
      if (!signal.aborted) setLoading(false);
    }
  }, []);

  useEffect(() => {
    load();
    return () => activeRead.current?.abort();
  }, [load]);

  const selected = data.items.find((item) => item.maMon === selectedCode);
  const editing = selected?.sizes.find((size) => size.maSize === editCode);
  const allowedSizes = selected?.loaiMon === 'Topping' ? toppingSizeCodes : regularSizeCodes;
  const availableSizes = selected
    ? allowedSizes.filter((code) => !selected.sizes.some((size) => size.maSize === code))
    : [];
  const locked = busy || loading || Boolean(loadError);

  function clearInvalidSizeFeedback() {
    setFeedback((current) => current?.invalidSize ? null : current);
  }

  function selectItem(code) {
    clearInvalidSizeFeedback();
    setSelectedCode(code);
    setEditCode(null);
  }

  async function run(action, message, { addingSize = false } = {}) {
    if (locked) return false;
    setBusy(true);
    setFeedback(null);
    try {
      await action();
      setFeedback({ message });
      return true;
    } catch (error) {
      const code = error.code ? ` (${error.code})` : '';
      setFeedback({
        message: `${error.message}${code}`,
        error: true,
        invalidSize: addingSize && String(error.code) === '51213',
      });
      return false;
    } finally {
      await load();
      setBusy(false);
    }
  }

  async function createItem(event) {
    event.preventDefault();
    const form = event.currentTarget;
    const fields = Object.fromEntries(new FormData(form));
    const code = fields.maMon.trim();
    if (await run(() => triggerMonApi.create({ ...fields, maMon: code }), `Đã thêm món ${code}.`)) {
      selectItem(code);
      form.reset();
    }
  }

  async function saveSize(event) {
    event.preventDefault();
    const form = event.currentTarget;
    const fields = new FormData(form);
    const code = editing?.maSize ?? fields.get('maSize');
    const payload = {
      giaBan: Number(fields.get('giaBan')),
      trangThaiSize: fields.get('trangThaiSize'),
    };
    const action = editing
      ? () => triggerMonApi.setSize(selected.maMon, code, payload)
      : () => triggerMonApi.addSize(selected.maMon, { ...payload, maSize: code });
    const verb = editing ? 'cập nhật' : 'thêm';
    if (await run(action, `Đã ${verb} size ${code} của ${selected.maMon}.`, { addingSize: !editing })) {
      setEditCode(null);
      form.reset();
    }
  }

  async function deleteSize(code) {
    if (!window.confirm(`Xóa size ${code} của món ${selected.maMon}?`)) return;
    if (await run(() => triggerMonApi.deleteSize(selected.maMon, code), `Đã xóa size ${code} của ${selected.maMon}.`)) {
      setEditCode(null);
    }
  }

  function changeStatus() {
    const status = selected.trangThaiKinhDoanh === 'DangBan' ? 'NgungBan' : 'DangBan';
    run(
      () => triggerMonApi.setStatus(selected.maMon, status),
      `Đã ${status === 'DangBan' ? 'bật bán' : 'ngừng bán'} món ${selected.maMon}.`,
    );
  }

  return (
    <section className="trigger-mon" aria-labelledby={titleId}>
      <header className="trigger-mon-heading">
        <h1 id={titleId}>Quản lý món và size</h1>
        <button type="button" onClick={load} disabled={loading || busy}>Tải lại</button>
      </header>

      {feedback && !feedback.invalidSize && (
        <p className={feedback.error ? 'trigger-mon-error' : 'trigger-mon-success'} role={feedback.error ? 'alert' : 'status'}>
          {feedback.message}
        </p>
      )}
      {loadError && <p className="trigger-mon-error" role="alert">Không tải được dữ liệu. {loadError}</p>}

      <form onSubmit={createItem} aria-label="Thêm món">
        <fieldset disabled={locked || data.categories.length === 0}>
          <legend>Thêm món</legend>
          <div className="trigger-mon-fields">
            <label>Mã món<input name="maMon" required maxLength={30} /></label>
            <label>Tên món<input name="tenMon" required maxLength={200} /></label>
            <label>
              Loại món
              <select name="loaiMon">
                {Object.entries(types).map(([code, text]) => <option key={code} value={code}>{text}</option>)}
              </select>
            </label>
            <label>
              Danh mục
              <select name="maDanhMuc" required defaultValue="">
                <option value="" disabled>Chọn danh mục</option>
                {data.categories.map((row) => <option key={row.maDanhMuc} value={row.maDanhMuc}>{row.tenDanhMuc}</option>)}
              </select>
            </label>
            <StatusSelect name="trangThaiKinhDoanh" label="Trạng thái món" />
            <button type="submit" className="trigger-mon-primary">Thêm món</button>
          </div>
          <p className="trigger-mon-note">Tạo món ở trạng thái ngừng bán. SQL Server tự tạo size S cho món thường hoặc TC cho topping.</p>
          {!loading && !loadError && data.categories.length === 0 && (
            <p className="trigger-mon-note">Cần có danh mục để thêm món.</p>
          )}
        </fieldset>
      </form>

      <section className="trigger-mon-content" aria-busy={loading || busy}>
        <div>
          <h2>Danh sách món</h2>
          {loading && <p role="status">Đang tải dữ liệu…</p>}
          {!loading && !loadError && data.items.length === 0 && <p>Chưa có món.</p>}
          {data.items.length > 0 && (
            <div className="trigger-mon-table" role="region" aria-label="Bảng món" tabIndex={0}>
              <table aria-label="Danh sách món">
                <thead>
                  <tr><th scope="col">Mã món</th><th scope="col">Tên món</th><th scope="col">Loại</th><th scope="col">Trạng thái</th><th scope="col">Chi tiết</th></tr>
                </thead>
                <tbody>
                  {data.items.map((item) => (
                    <tr key={item.maMon} className={item.maMon === selectedCode ? 'trigger-mon-selected' : undefined}>
                      <th scope="row">{item.maMon}</th>
                      <td>{item.tenMon}<small>{item.tenDanhMuc}</small></td>
                      <td>{types[item.loaiMon]}</td>
                      <td>
                        <StatusBadge active={item.trangThaiKinhDoanh === 'DangBan'} inactiveWarning>
                          {statuses[item.trangThaiKinhDoanh]}
                        </StatusBadge>
                      </td>
                      <td>
                        <button type="button" disabled={busy} aria-pressed={item.maMon === selectedCode} aria-label={`Xem size món ${item.maMon}`} onClick={() => selectItem(item.maMon)}>
                          Xem size
                        </button>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          )}
        </div>

        <div>
          <h2>{selected ? `Size của ${selected.tenMon}` : 'Size của món'}</h2>
          {selected ? (
            <>
              <div className="trigger-mon-heading trigger-mon-meta">
                <span>{selected.maMon} · {statuses[selected.trangThaiKinhDoanh]}</span>
                <button type="button" className="trigger-mon-primary" disabled={locked} onClick={changeStatus}>
                  {selected.trangThaiKinhDoanh === 'DangBan' ? 'Ngừng bán món' : 'Bật bán món'}
                </button>
              </div>
              {selected.sizes.length === 0 ? <p>Món chưa có size.</p> : (
                <div className="trigger-mon-table" role="region" aria-label="Bảng size" tabIndex={0}>
                  <table aria-label={`Danh sách size của ${selected.maMon}`}>
                    <thead>
                      <tr><th scope="col">Size</th><th scope="col">Giá bán</th><th scope="col">Trạng thái</th><th scope="col">Thao tác</th></tr>
                    </thead>
                    <tbody>
                      {selected.sizes.map((size) => (
                        <tr key={size.maSize}>
                          <th scope="row">{size.maSize}</th>
                          <td>{priceInDong.format(size.giaBan)}</td>
                          <td>
                            <StatusBadge active={size.trangThaiSize === 'DangBan'} inactiveWarning>
                              {statuses[size.trangThaiSize]}
                            </StatusBadge>
                          </td>
                          <td className="trigger-mon-actions">
                            <button type="button" aria-label={`Sửa size ${size.maSize}`} disabled={locked} onClick={() => {
                              clearInvalidSizeFeedback();
                              setEditCode(size.maSize);
                            }}>Sửa</button>
                            <button type="button" className="trigger-mon-delete" aria-label={`Xóa size ${size.maSize}`} disabled={locked} onClick={() => deleteSize(size.maSize)}>Xóa</button>
                          </td>
                        </tr>
                      ))}
                    </tbody>
                  </table>
                </div>
              )}
              {(editing || availableSizes.length > 0) && (
                <form key={`${selected.maMon}:${editing?.maSize ?? 'new'}`} className="trigger-mon-size-form" onSubmit={saveSize} aria-label={editing ? `Sửa size ${editing.maSize}` : 'Thêm size'}>
                  <fieldset disabled={locked}>
                    <legend>{editing ? `Sửa size ${editing.maSize}` : 'Thêm size'}</legend>
                    <div className="trigger-mon-fields">
                      {!editing && (
                        <label>
                          Size
                          <select
                            name="maSize"
                            aria-invalid={feedback?.invalidSize || undefined}
                            aria-describedby={feedback?.invalidSize ? sizeErrorId : undefined}
                            onChange={clearInvalidSizeFeedback}
                          >
                            {availableSizes.map((code) => <option key={code}>{code}</option>)}
                          </select>
                        </label>
                      )}
                      <label>Giá bán (đồng)<input name="giaBan" type="number" min="0" max={Number.MAX_SAFE_INTEGER} step="1" defaultValue={editing?.giaBan ?? 0} required /></label>
                      <StatusSelect name="trangThaiSize" label="Trạng thái size" value={editing?.trangThaiSize} />
                      <button type="submit" className="trigger-mon-primary">{editing ? 'Lưu size' : 'Thêm size'}</button>
                      {editing && <button type="button" onClick={() => setEditCode(null)}>Hủy</button>}
                    </div>
                    {!editing && feedback?.invalidSize && (
                      <p id={sizeErrorId} className="trigger-mon-error" role="alert">{feedback.message}</p>
                    )}
                  </fieldset>
                </form>
              )}
            </>
          ) : <p>Chọn một món để xem và chỉnh sửa size.</p>}
        </div>
      </section>
    </section>
  );
}
