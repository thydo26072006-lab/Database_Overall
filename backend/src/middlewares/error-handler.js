const bodyErrors = new Map([
  ['entity.parse.failed', [400, 'Dữ liệu JSON không hợp lệ.']],
  ['request.aborted', [400, 'Yêu cầu gửi lên chưa hoàn tất.']],
  ['request.size.invalid', [400, 'Kích thước dữ liệu gửi lên không hợp lệ.']],
  ['entity.too.large', [413, 'Dữ liệu gửi lên vượt quá giới hạn.']],
  ['encoding.unsupported', [415, 'Kiểu mã hóa dữ liệu gửi lên không được hỗ trợ.']],
  ['charset.unsupported', [415, 'Bộ ký tự của dữ liệu gửi lên không được hỗ trợ.']],
]);

export function notFound(_request, response) {
  return response.status(404).json({
    error: { code: 'NOT_FOUND', message: 'Không tìm thấy địa chỉ API.' },
  });
}

export function errorHandler(error, _request, response, next) {
  if (response.headersSent) return next(error);

  const bodyError = bodyErrors.get(error.type);
  if (bodyError) {
    const [status, message] = bodyError;
    return response.status(status).json({ error: { code: 'INVALID_REQUEST', message } });
  }

  if (error instanceof URIError && error.status === 400) {
    return response.status(400).json({
      error: { code: 'INVALID_REQUEST', message: 'Đường dẫn yêu cầu không hợp lệ.' },
    });
  }

  console.error('Lỗi khi xử lý yêu cầu API.');
  return response.status(500).json({
    error: { code: 'SERVER_ERROR', message: 'Không thể xử lý yêu cầu. Vui lòng thử lại.' },
  });
}
