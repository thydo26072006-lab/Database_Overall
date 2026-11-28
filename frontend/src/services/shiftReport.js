const apiBase = (import.meta.env.VITE_API_BASE_URL ?? '').trim().replace(/\/+$/, '');
const reportPath = `${apiBase}/api/bao-cao/phan-cong-theo-ca`;
const fallbackMessage = 'Không thể tải báo cáo. Kiểm tra kết nối và thử lại.';

export async function fetchShiftReport(tuNgay, denNgay) {
  const query = new URLSearchParams({ tuNgay, denNgay });
  let response;
  try {
    response = await fetch(`${reportPath}?${query}`);
  } catch (error) {
    throw new Error(fallbackMessage, { cause: error });
  }
  const result = await response.json().catch(() => null);
  if (!response.ok || !Array.isArray(result?.data)) {
    const error = new Error(result?.error?.message ?? result?.message ?? fallbackMessage);
    error.code = result?.error?.code ?? result?.code;
    throw error;
  }
  return result;
}
