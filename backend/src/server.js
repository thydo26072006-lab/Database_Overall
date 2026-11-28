import { once } from 'node:events';
import { createServer } from 'node:http';
import process from 'node:process';
import { createApp } from './app.js';
import { loadEnv } from './config/load-env.js';
import { closeSqlServer, connectSqlServer, createQuery, getPool, loadSqlDriver } from './config/sql-server.js';
import { createDanhMucMonRouter } from './routes/danh-muc-mon.js';
import { createShiftReportRouter } from './routes/phan-cong-theo-ca.js';
import { createTriggerMonRouter } from './routes/trigger-mon.js';

const host = '127.0.0.1';
const shutdown = new AbortController();
const stopRequested = once(shutdown.signal, 'abort');
const stop = signal => shutdown.abort(signal);
process.on('SIGINT', stop);
process.on('SIGTERM', stop);

async function closeBackend(server) {
  try {
    if (server?.listening) {
      await new Promise((resolve, reject) => {
        server.close(error => error ? reject(error) : resolve());
      });
    }
  } finally {
    await closeSqlServer();
  }
}

let server;
let phase = 'config';
try {
  const config = loadEnv();

  phase = 'sql';
  const sql = await loadSqlDriver(config.db.auth);
  const pool = await connectSqlServer(config.db);
  if (!shutdown.signal.aborted) await pool.request().query('SELECT 1');

  if (!shutdown.signal.aborted) {
    phase = 'http';
    const routers = {
      danhMucMon: createDanhMucMonRouter(pool, sql),
      triggerMon: createTriggerMonRouter(createQuery()),
      shiftReport: createShiftReportRouter(getPool, sql),
    };
    server = createServer(createApp({ corsOrigins: config.corsOrigins, routers }));
    server.listen(config.appPort, host);
    await once(server, 'listening');

    if (!shutdown.signal.aborted) {
      console.log('Backend đang chạy tại http://' + host + ':' + config.appPort);
      await Promise.race([
        stopRequested,
        once(server, 'error').then(([error]) => { throw error; }),
      ]);
    }
  }
} catch (error) {
  if (!shutdown.signal.aborted) {
    if (phase === 'config') {
      console.error('Cấu hình backend không hợp lệ. ' + error.message);
    } else if (phase === 'sql') {
      console.error('Không thể xác minh kết nối SQL Server. Hãy kiểm tra cấu hình và driver.');
    } else {
      console.error(error.code === 'EADDRINUSE' ? 'Cổng backend đang được sử dụng.' : 'Không thể chạy máy chủ HTTP.');
    }
    process.exitCode = 1;
  }
} finally {
  try {
    await closeBackend(server);
    if (shutdown.signal.aborted && !process.exitCode) console.log('Đã dừng backend và đóng pool SQL Server.');
  } catch {
    console.error('Không thể đóng hoàn toàn backend.');
    process.exitCode = 1;
  } finally {
    process.off('SIGINT', stop);
    process.off('SIGTERM', stop);
  }
}
