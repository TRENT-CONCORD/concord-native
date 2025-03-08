import * as dotenv from 'dotenv';
import * as path from 'path';
import AppDataSource from './data-source';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

console.log('Environment Variables in CLI:', {
  host: process.env.TYPEORM_HOST,
  username: process.env.TYPEORM_USERNAME,
  password: process.env.TYPEORM_PASSWORD,
  database: process.env.TYPEORM_DATABASE,
});

export default AppDataSource; 