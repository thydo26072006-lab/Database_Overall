const sqlErrors = new Map([
  [51001, [422, 'Mã danh mục không được để trống.']],
  [51002, [422, 'Tên danh mục không được để trống.']],
  [51003, [422, 'Tên danh mục vượt quá độ dài cho phép.']],
  [51004, [422, 'Mã danh mục phải lưu được nguyên vẹn trong VARCHAR(30).']],
  [51005, [422, 'Mã danh mục cha không hợp lệ.']],
  [51006, [422, 'Danh mục không thể làm cha của chính nó.']],
  [51007, [409, 'Mã danh mục đã tồn tại.']],
  [51008, [422, 'Danh mục cha không tồn tại.']],
  [51010, [422, 'Thao tác này tạo vòng lặp giữa các danh mục cha và con.']],
  [51201, [422, 'Mã danh mục không được để trống.']],
  [51202, [422, 'Tên danh mục phải có nội dung và nằm trong độ dài cho phép.']],
  [51203, [404, 'Không tìm thấy danh mục cần sửa.']],
  [51204, [422, 'Danh mục không thể làm cha của chính nó.']],
  [51205, [422, 'Danh mục cha không tồn tại.']],
  [51206, [422, 'Mã danh mục hoặc mã cha không hợp lệ.']],
  [51301, [422, 'Mã danh mục không hợp lệ.']],
  [51302, [404, 'Không tìm thấy danh mục cần xóa.']],
  [51303, [409, 'Danh mục còn danh mục con hoặc món.']],
]);

function writePayload(body, maDanhMuc) {
  const { tenDanhMuc, maDanhMucCha } = body ?? {};
  if (typeof maDanhMuc !== 'string' || typeof tenDanhMuc !== 'string' ||
      (maDanhMucCha !== undefined && maDanhMucCha !== null && typeof maDanhMucCha !== 'string')) {
    return null;
  }
  return { maDanhMuc, tenDanhMuc, maDanhMucCha: maDanhMucCha ?? null };
}

function requestError(response) {
  response.status(400).json({ error: { code: 'INVALID_INPUT', message: 'Mã, tên hoặc mã cha sai kiểu dữ liệu.' } });
}

export function createDanhMucMonController(service) {
  return {
    async list(_request, response) {
      response.json({ data: await service.list() });
    },
    async create(request, response) {
      const category = writePayload(request.body, request.body?.maDanhMuc);
      if (!category) return requestError(response);
      response.status(201).json({ data: await service.create(category) });
    },
    async update(request, response) {
      const category = writePayload(request.body, request.params.maDanhMuc);
      if (!category) return requestError(response);
      response.json({ data: await service.update(category) });
    },
    async remove(request, response) {
      await service.remove(request.params.maDanhMuc);
      response.status(204).end();
    },
  };
}

export function handleDanhMucMonError(error, _request, response, next) {
  const mapped = sqlErrors.get(error.number);
  if (!mapped) return next(error);
  const [status, message] = mapped;
  response.status(status).json({ error: { code: error.number, message } });
}
