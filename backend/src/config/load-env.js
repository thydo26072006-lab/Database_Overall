import { readFileSync } from 'node:fs';
import { isIP } from 'node:net';
import { parseEnv } from 'node:util';

const defaultEnvFile = new URL('../../.env', import.meta.url);
const defaultCorsOrigins = 'http://127.0.0.1:5173,http://localhost:5173';

function readEnvFile(path) {
  try {
    return parseEnv(readFileSync(path, 'utf8').replace(/^\uFEFF/, ''));
  } catch (error) {
    if (error.code === 'ENOENT') return {};
    throw new Error('Không thể đọc tệp cấu hình .env.');
  }
}

function readPort(value, name) {
  const port = Number(value);
  if (!/^\d+$/.test(value) || !Number.isInteger(port) || port < 1 || port > 65535) {
    throw new Error(name + ' phải là số nguyên từ 1 đến 65535.');
  }
  return port;
}

function readBoolean(value, name) {
  if (value === 'true') return true;
  if (value === 'false') return false;
  throw new Error(name + ' phải là true hoặc false.');
}

function requireText(value, name) {
  if (!value?.trim()) throw new Error('Cần cấu hình ' + name + '.');
  return value;
}

function isHost(host) {
  if (isIP(host)) return true;
  // Một địa chỉ IPv4 sai không được chấp nhận như tên máy.
  if (/^[0-9.]+$/.test(host)) return false;
  const name = host.replace(/\.$/, '');
  return name.length <= 253 && name.split('.').every(label =>
    /^[a-z\d](?:[a-z\d-]{0,61}[a-z\d])?$/i.test(label),
  );
}

function readInstance(value) {
  const instance = requireText(value, 'DB_INSTANCE');
  const [host, name, ...rest] = instance.split('\\');
  if (
    (!isHost(host) && host !== '.' && host !== '(local)') ||
    (name !== undefined && !/^[a-z\d_][a-z\d_$-]*$/i.test(name)) ||
    rest.length
  ) {
    throw new Error('DB_INSTANCE phải là tên máy hoặc máy\\instance hợp lệ.');
  }
  return instance;
}

function readCorsOrigins(value) {
  if (!value.trim()) return [];
  const origins = value.split(',').map(entry => {
    const origin = entry.trim();
    if (/^https?:\/\/[^\s@/\\?#]+\/?$/i.test(origin)) {
      const url = URL.parse(origin);
      if (url) return url.origin;
    }
    throw new Error('CORS_ORIGIN phải là danh sách origin HTTP(S) cách nhau bằng dấu phẩy.');
  });
  return [...new Set(origins)];
}

export function loadEnv({ env = process.env, envFile = defaultEnvFile } = {}) {
  // Biến môi trường của tiến trình ưu tiên hơn tệp .env.
  const settings = { ...readEnvFile(envFile), ...env };
  const appPort = readPort((settings.APP_PORT ?? '3001').trim(), 'APP_PORT');
  const corsOrigins = readCorsOrigins(settings.CORS_ORIGIN ?? defaultCorsOrigins);
  const auth = (settings.DB_AUTH ?? 'sql').trim();
  if (auth !== 'sql' && auth !== 'windows') {
    throw new Error('DB_AUTH phải là sql hoặc windows.');
  }

  const db = {
    auth,
    name: requireText(settings.DB_NAME?.trim(), 'DB_NAME'),
    encrypt: readBoolean((settings.DB_ENCRYPT ?? 'true').trim(), 'DB_ENCRYPT'),
    trustServerCertificate: readBoolean(
      (settings.DB_TRUST_SERVER_CERTIFICATE ?? 'false').trim(),
      'DB_TRUST_SERVER_CERTIFICATE',
    ),
  };

  if (auth === 'windows') {
    db.instance = readInstance(settings.DB_INSTANCE?.trim());
  } else {
    db.host = (settings.DB_HOST ?? '127.0.0.1').trim();
    if (!isHost(db.host)) throw new Error('DB_HOST phải là tên máy hoặc địa chỉ IP hợp lệ.');
    db.port = readPort((settings.DB_PORT ?? '1433').trim(), 'DB_PORT');
    db.user = requireText(settings.DB_USER, 'DB_USER');
    db.password = requireText(settings.DB_PASSWORD, 'DB_PASSWORD');
  }

  return { appPort, corsOrigins, db };
}
