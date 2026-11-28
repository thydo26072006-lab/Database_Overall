import sql from 'mssql';

let connection;

export function getPool() {
  if (!connection) {
    const pool = new sql.ConnectionPool({
      server: process.env.DB_HOST ?? '127.0.0.1',
      port: Number(process.env.DB_PORT ?? 1433),
      database: process.env.DB_NAME ?? 'BTL2_FIX_12345',
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      options: {
        encrypt: true,
        trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true',
        useUTC: true,
      },
    });
    pool.on('error', (error) => console.error('SQL pool:', error.code));
    connection = pool.connect().catch((error) => {
      connection = undefined;
      throw error;
    });
  }
  return connection;
}
