const apiBase = (import.meta.env.VITE_API_BASE_URL ?? '').replace(/\/+$/, '');
const base = `${apiBase}/api/trigger-mon`;

async function request(url, options) {
  let response;
  try {
    response = await fetch(url, options);
  } catch (error) {
    if (error.name === 'AbortError') throw error;
    throw new Error('Không kết nối được máy chủ.');
  }
  const body = await response.json().catch(() => null);
  if (!response.ok) {
    const error = new Error(body?.error?.message ?? 'Máy chủ không xử lý được yêu cầu.');
    error.code = body?.error?.code;
    throw error;
  }
  if (response.status === 204) return;
  if (!body || !Object.hasOwn(body, 'data')) throw new Error('API trả về dữ liệu không đúng định dạng.');
  return body.data;
}

function send(url, method, payload) {
  return request(url, {
    method,
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });
}

function monPath(code) {
  return `${base}/mon/${encodeURIComponent(code)}`;
}

export const triggerMonApi = {
  list: (signal) => request(`${base}/mon`, { signal }),
  categories: (signal) => request(`${base}/danh-muc`, { signal }),
  create: (payload) => send(`${base}/mon`, 'POST', payload),
  addSize: (code, payload) => send(`${monPath(code)}/size`, 'POST', payload),
  setSize: (code, size, payload) => send(`${monPath(code)}/size/${encodeURIComponent(size)}`, 'PUT', payload),
  deleteSize: (code, size) => request(`${monPath(code)}/size/${encodeURIComponent(size)}`, { method: 'DELETE' }),
  setStatus: (code, trangThaiKinhDoanh) => send(`${monPath(code)}/trang-thai`, 'PATCH', { trangThaiKinhDoanh }),
};
