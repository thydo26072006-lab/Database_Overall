import sql from 'mssql';

export function connectSqlServer(env = process.env) {
  for (const key of ['DB_HOST', 'DB_NAME', 'DB_USER', 'DB_PASSWORD']) {
    if (!env[key]) throw new Error(`Thiếu biến môi trường ${key}.`);
  }

  const port = Number(env.DB_PORT ?? 1433);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error('DB_PORT phải là số cổng hợp lệ.');
  }

  return new sql.ConnectionPool({
    server: env.DB_HOST,
    port,
    database: env.DB_NAME,
    user: env.DB_USER,
    password: env.DB_PASSWORD,
    options: {
      encrypt: env.DB_ENCRYPT !== 'false',
      trustServerCertificate: env.DB_TRUST_SERVER_CERTIFICATE === 'true',
    },
  }).connect();
}
