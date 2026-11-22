export async function fetchShiftReport(tuNgay, denNgay) {
  const query = new URLSearchParams({ tuNgay, denNgay });
  const response = await fetch('/api/bao-cao/phan-cong-theo-ca?' + query);
  const result = await response.json().catch(() => null);
  if (!response.ok || !Array.isArray(result?.data)) {
    throw new Error(result?.message ?? 'Không thể tải báo cáo. Kiểm tra kết nối và thử lại.');
  }
  return result;
}
