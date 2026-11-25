import { spawn } from 'node:child_process';
import { fileURLToPath } from 'node:url';
import sql from 'mssql';

const windowsScript = fileURLToPath(new URL('./query-windows.ps1', import.meta.url));
const database = process.env.DB_NAME ?? 'BTL2_FIX_12345';
let connection;

function getPool() {
  if (!connection) {
    connection = new sql.ConnectionPool({
      server: process.env.DB_HOST ?? '127.0.0.1',
      port: Number(process.env.DB_PORT ?? 1433),
      database,
      user: process.env.DB_USER,
      password: process.env.DB_PASSWORD,
      options: {
        encrypt: process.env.DB_ENCRYPT !== 'false',
        trustServerCertificate: process.env.DB_TRUST_SERVER_CERTIFICATE === 'true',
      },
    }).connect().catch((error) => {
      connection = undefined;
      throw error;
    });
  }
  return connection;
}

export function createPoolQuery(getSharedPool) {
  return async (text, parameters = {}) => {
    const pool = await getSharedPool();
    const request = pool.request();
    for (const [name, value] of Object.entries(parameters)) {
      request.input(name, typeof value === 'number' ? sql.BigInt : sql.NVarChar(200), value);
    }
    const { recordset } = await request.query(text);
    return recordset ?? [];
  };
}

function queryWindows(text, parameters = {}) {
  const instance = process.env.DB_INSTANCE ?? 'localhost\\SQLEXPRESS';
  return new Promise((resolve, reject) => {
    const child = spawn(
      'powershell.exe',
      ['-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'RemoteSigned', '-File', windowsScript,
        '-Instance', instance, '-Database', database],
      { windowsHide: true, timeout: 40000, stdio: ['pipe', 'pipe', 'ignore'] },
    );
    let output = '';
    child.stdout.setEncoding('utf8').on('data', (chunk) => { output += chunk; });
    child.stdin.on('error', reject);
    child.on('error', reject);
    child.on('close', (code) => {
      let result;
      try {
        result = JSON.parse(output);
      } catch {
        reject(new Error('Không nhận được kết quả từ SQL Server.'));
        return;
      }
      if (code !== 0 || result.error) {
        reject(Object.assign(new Error(result.error?.message), { number: result.error?.number }));
        return;
      }
      resolve(result);
    });
    child.stdin.end(JSON.stringify({ text, parameters }));
  });
}

const auth = process.env.DB_AUTH ?? 'windows';
if (!['windows', 'sql'].includes(auth)) throw new Error('DB_AUTH chỉ nhận windows hoặc sql.');

export const query = auth === 'windows' ? queryWindows : createPoolQuery(getPool);
