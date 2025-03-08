"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
const typeorm_1 = require("typeorm");
const dotenv = require("dotenv");
const path = require("path");
const fs = require("fs");
const nodeEnv = process.env.NODE_ENV || 'development';
console.log(`Current environment: ${nodeEnv}`);
const envFile = nodeEnv === 'production' ? '.env.production' : '.env';
const envPath = path.resolve(__dirname, `../${envFile}`);
console.log(`Loading environment from: ${envPath}`);
console.log(`File exists: ${fs.existsSync(envPath)}`);
dotenv.config({ path: envPath });
const dbConfig = {
    development: {
        host: process.env.TYPEORM_HOST || 'concord-dev-db.postgres.database.azure.com',
        port: parseInt(process.env.TYPEORM_PORT || '5432'),
        username: process.env.TYPEORM_USERNAME || 'concordadmindev',
        password: process.env.TYPEORM_PASSWORD || 'Jhvaj8zZrGm4',
        database: process.env.TYPEORM_DATABASE || 'concord_dev',
        synchronize: process.env.TYPEORM_SYNCHRONIZE === 'true' || false,
        logging: process.env.TYPEORM_LOGGING === 'true' || true,
    },
    production: {
        host: process.env.TYPEORM_HOST || 'concord-api.postgres.database.azure.com',
        port: parseInt(process.env.TYPEORM_PORT || '5432'),
        username: process.env.TYPEORM_USERNAME || 'concordadmin',
        password: process.env.TYPEORM_PASSWORD || '',
        database: process.env.TYPEORM_DATABASE || 'concord',
        synchronize: false,
        logging: process.env.TYPEORM_LOGGING === 'true' || false,
    }
};
const config = nodeEnv === 'production' ? dbConfig.production : dbConfig.development;
console.log('Database Config:', {
    environment: nodeEnv,
    host: config.host,
    username: config.username,
    database: config.database,
});
const AppDataSource = new typeorm_1.DataSource({
    type: "postgres",
    host: config.host,
    port: config.port,
    username: config.username,
    password: config.password,
    database: config.database,
    synchronize: config.synchronize,
    logging: config.logging,
    entities: ["src/models/**/*.entity.ts", "src/explore/models/**/*.entity.ts"],
    migrations: ["src/migrations/**/*.ts"],
    subscribers: ["src/subscriber/**/*.ts"],
    ssl: {
        rejectUnauthorized: true
    }
});
exports.default = AppDataSource;
//# sourceMappingURL=data-source.js.map