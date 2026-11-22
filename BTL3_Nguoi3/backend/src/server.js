import express from 'express';
import { getPool } from './config/db.js';
import { createShiftReportRouter } from './routes/phan-cong-theo-ca.js';

const app = express();
app.use('/api/bao-cao/phan-cong-theo-ca', createShiftReportRouter(getPool));
app.listen(3001, '127.0.0.1', () => console.log('API: http://127.0.0.1:3001'));
