import * as dotenv from 'dotenv';

// Load test environment variables
process.env.NODE_ENV = 'test';
dotenv.config({ path: '.env.test' });

// Set default test environment variables if not provided
process.env.TYPEORM_HOST = process.env.TYPEORM_HOST || 'localhost';
process.env.TYPEORM_PORT = process.env.TYPEORM_PORT || '5432';
process.env.TYPEORM_USERNAME = process.env.TYPEORM_USERNAME || 'test';
process.env.TYPEORM_PASSWORD = process.env.TYPEORM_PASSWORD || 'test';
process.env.TYPEORM_DATABASE = process.env.TYPEORM_DATABASE || 'concord_test';
process.env.TYPEORM_SYNCHRONIZE = 'true';
process.env.TYPEORM_LOGGING = 'false'; 