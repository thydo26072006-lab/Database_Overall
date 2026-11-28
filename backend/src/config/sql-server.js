let connection;
let closing;

function odbcValue(value) {
  return '{' + value.replaceAll('}', '}}') + '}';
}

export async function loadSqlDriver(auth) {
  // Các entry point của mssql thay đổi driver mặc định trong cùng tiến trình.
  if (auth === 'windows') {
    try {
      return (await import('mssql/msnodesqlv8.js')).default;
    } catch {
      throw new Error('DB_AUTH=windows cần msnodesqlv8 và ODBC Driver 18 for SQL Server.');
    }
  }

  return (await import('mssql')).default;
}

async function openPool(db) {
  const driver = await loadSqlDriver(db.auth);
  const options = {
    useUTC: true,
    encrypt: db.encrypt,
    trustServerCertificate: db.trustServerCertificate,
  };
  let config;
  if (db.auth === 'windows') {
    config = {
      server: db.instance,
      database: db.name,
      options,
      connectionString: [
        'Driver={ODBC Driver 18 for SQL Server}',
        'Server=' + odbcValue(db.instance),
        'Database=' + odbcValue(db.name),
        'Trusted_Connection=Yes',
        'Encrypt=' + (db.encrypt ? 'Yes' : 'No'),
        'TrustServerCertificate=' + (db.trustServerCertificate ? 'Yes' : 'No'),
      ].join(';'),
    };
  } else {
    config = {
      server: db.host,
      port: db.port,
      database: db.name,
      user: db.user,
      password: db.password,
      options,
    };
  }

  const pool = new driver.ConnectionPool(config);
  pool.on('error', () => console.error('Pool SQL Server gặp lỗi kết nối.'));
  return pool.connect();
}

// Truyền cấu hình db đã kiểm tra bởi loadEnv() khi khởi động backend.
export function connectSqlServer(db) {
  if (closing) return Promise.reject(new Error('Pool SQL Server đang đóng.'));
  connection ??= openPool(db).catch(error => {
    connection = undefined;
    throw error;
  });
  return connection;
}

export function getPool() {
  if (closing) return Promise.reject(new Error('Pool SQL Server đang đóng.'));
  return connection ?? Promise.reject(new Error('Pool SQL Server chưa được khởi tạo.'));
}

export function closeSqlServer() {
  if (!closing && connection) {
    // Driver yêu cầu chờ kết nối ban đầu kết thúc trước khi đóng pool.
    closing = connection.then(pool => pool.close(), () => {}).finally(() => {
      connection = undefined;
      closing = undefined;
    });
  }
  return closing ?? Promise.resolve();
}

export function createQuery(getSharedPool = getPool) {
  return async (text, parameters = {}) => {
    const pool = await getSharedPool();
    const request = pool.request();
    for (const [name, value] of Object.entries(parameters)) {
      request.input(name, value);
    }
    const { recordset } = await request.query(text);
    return recordset ?? [];
  };
}
