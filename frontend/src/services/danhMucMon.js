const apiBase = (import.meta.env.VITE_API_BASE_URL ?? '').replace(/\/+$/, '');
const path = `${apiBase}/api/danh-muc-mon`;

async function request(url, options) {
  let response;
  try {
    response = await fetch(url, options);
  } catch (error) {
    if (error.name === 'AbortError') throw error;
    throw new Error('Không kết nối được với máy chủ. Vui lòng thử lại.');
  }

  if (response.status === 204) return;

  const body = await response.json().catch(() => null);
  if (!response.ok) {
    const error = new Error(body?.error?.message || 'Máy chủ không xử lý được yêu cầu. Vui lòng thử lại.');
    error.code = body?.error?.code;
    throw error;
  }

  if (!body || !Object.hasOwn(body, 'data')) {
    throw new Error('Máy chủ trả về dữ liệu không đúng định dạng.');
  }

  return body.data;
}

function sendJson(url, method, fields) {
  return request(url, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(fields),
  });
}

function rowPath(code) {
  // Browsers normalize dot segments. The SQL procedures trim the added space.
  const segment = code === '.' || code === '..' ? `${code} ` : code;
  return `${path}/${encodeURIComponent(segment)}`;
}

export const danhMucMon = {
  list: (signal) => request(path, { signal, cache: 'no-store' }),
  create: (fields) => sendJson(path, 'POST', fields),
  update: (code, fields) => sendJson(rowPath(code), 'PUT', fields),
  remove: (code) => request(rowPath(code), { method: 'DELETE' }),
};
