import * as dotenv from 'dotenv';
import * as path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../.env') });

import AppDataSource from './data-source';

(async () => {
  try {
    console.log('Testing database connection...');
    await AppDataSource.initialize();
    console.log('Database connection successful!');
    await AppDataSource.destroy();
  } catch (error) {
    console.error('Error connecting to the database:', error);
  }
})(); 