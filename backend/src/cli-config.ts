import * as dotenv from 'dotenv';
import * as path from 'path';
import * as fs from 'fs';
import AppDataSource from './data-source';

// Determine which environment we're in
const nodeEnv = process.env.NODE_ENV || 'development';
console.log(`CLI current environment: ${nodeEnv}`);

// Load the appropriate .env file
const envFile = nodeEnv === 'production' ? '.env.production' : '.env';
const envPath = path.resolve(__dirname, `../${envFile}`);
console.log(`CLI loading environment from: ${envPath}`);
console.log(`File exists: ${fs.existsSync(envPath)}`);
dotenv.config({ path: envPath });

// Log the configuration being used
console.log('Environment Variables in CLI:', {
  environment: nodeEnv,
  host: process.env.TYPEORM_HOST,
  username: process.env.TYPEORM_USERNAME,
  database: process.env.TYPEORM_DATABASE,
});

export default AppDataSource; 