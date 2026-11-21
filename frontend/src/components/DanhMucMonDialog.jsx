import { useEffect, useId, useRef } from 'react';

export default function DanhMucMonDialog({ mode, row, categories, busy, error, onCancel, onSave }) {
  const dialog = useRef(null);
  const titleId = useId();
  const descriptionId = useId();
  const isDelete = mode === 'delete';
  const isEdit = mode === 'edit';
  const title = { create: 'Thêm danh mục', edit: 'Sửa danh mục', delete: 'Xoá danh mục' }[mode];
  const submitLabel = isEdit ? 'Lưu thay đổi' : title;

  useEffect(() => {
    dialog.current.showModal();
  }, []);

  function submit(event) {
    event.preventDefault();
    if (isDelete) {
      onSave();
      return;
    }

    const form = new FormData(event.currentTarget);
    onSave({
      ...(isEdit ? {} : { maDanhMuc: form.get('maDanhMuc') }),
      tenDanhMuc: form.get('tenDanhMuc'),
      maDanhMucCha: form.get('maDanhMucCha') || null,
    });
  }

  return (
    <dialog
      className="dm-dialog"
      ref={dialog}
      aria-labelledby={titleId}
      aria-describedby={isDelete ? descriptionId : undefined}
      onCancel={(event) => {
        event.preventDefault();
        if (!busy) onCancel();
      }}
    >
      <form onSubmit={submit}>
        <header className="dm-dialog-header">
          <h2 id={titleId}>{title}</h2>
          <button
            type="button"
            className="dm-close"
            aria-label="Đóng"
            onClick={onCancel}
            disabled={busy}
          >
            ×
          </button>
        </header>

        {isDelete ? (
          <p id={descriptionId} className="dm-confirm">
            Xoá danh mục <strong>{row.tenDanhMuc}</strong> ({row.maDanhMuc})?
          </p>
        ) : (
          <fieldset disabled={busy} className="dm-fields">
            <label>
              Mã danh mục
              <input
                name="maDanhMuc"
                autoComplete="off"
                defaultValue={row?.maDanhMuc ?? ''}
                readOnly={isEdit}
                autoFocus={!isEdit}
                required
              />
            </label>
            <label>
              Tên danh mục
              <input
                name="tenDanhMuc"
                autoComplete="off"
                defaultValue={row?.tenDanhMuc ?? ''}
                autoFocus={isEdit}
                required
              />
            </label>
            <label>
              Danh mục cha
              <select name="maDanhMucCha" defaultValue={row?.maDanhMucCha ?? ''}>
                <option value="">Không có danh mục cha</option>
                {categories.map((category) => (
                  <option key={category.maDanhMuc} value={category.maDanhMuc}>
                    {category.tenDanhMuc} ({category.maDanhMuc})
                  </option>
                ))}
              </select>
            </label>
          </fieldset>
        )}

        {error && (
          <p className="dm-message dm-message-error" role="alert">
            {error.message}
            {error.code != null && <span className="dm-error-code">Mã lỗi {error.code}</span>}
          </p>
        )}

        <footer className="dm-dialog-footer">
          <button type="button" className="dm-button dm-secondary" onClick={onCancel} disabled={busy}>
            Huỷ
          </button>
          <button
            type="submit"
            className={isDelete ? 'dm-button dm-danger' : 'dm-button dm-primary'}
            disabled={busy}
          >
            {busy ? 'Đang xử lý…' : submitLabel}
          </button>
        </footer>
      </form>
    </dialog>
  );
}
