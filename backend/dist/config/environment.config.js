"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.loadEnvironment = loadEnvironment;
exports.getDatabaseConfig = getDatabaseConfig;
exports.getServerConfig = getServerConfig;
const dotenv = require("dotenv");
const path = require("path");
const fs = require("fs");
function loadEnvironment() {
    const nodeEnv = process.env.NODE_ENV || 'development';
    console.log(`Loading environment for: ${nodeEnv}`);
    const envFile = nodeEnv === 'production' ? '.env.production' : '.env';
    const envPath = path.resolve(process.cwd(), envFile);
    if (fs.existsSync(envPath)) {
        console.log(`Loading environment from: ${envPath}`);
        dotenv.config({ path: envPath });
    }
    else {
        console.warn(`Environment file not found: ${envPath}`);
        dotenv.config();
    }
}
function getDatabaseConfig() {
    const nodeEnv = process.env.NODE_ENV || 'development';
    const dbConfig = {
        development: {
            type: 'postgres',
            host: process.env.TYPEORM_HOST || 'concord-dev-db.postgres.database.azure.com',
            port: parseInt(process.env.TYPEORM_PORT || '5432'),
            username: process.env.TYPEORM_USERNAME || 'concordadmindev',
            password: process.env.TYPEORM_PASSWORD || 'Jhvaj8zZrGm4',
            database: process.env.TYPEORM_DATABASE || 'concord_dev',
            synchronize: process.env.TYPEORM_SYNCHRONIZE === 'true',
            logging: process.env.TYPEORM_LOGGING === 'true',
            ssl: { rejectUnauthorized: true },
            autoLoadEntities: true,
            migrationsRun: process.env.TYPEORM_MIGRATIONS_RUN === 'true',
            migrationsTableName: 'migrations',
            migrations: [path.join(__dirname, '../migrations/**/*.js')],
            entities: [
                path.join(__dirname, '../models/**/*.entity.{js,ts}'),
                path.join(__dirname, '../explore/models/**/*.entity.{js,ts}')
            ],
        },
        production: {
            type: 'postgres',
            host: process.env.TYPEORM_HOST || 'concord-api.postgres.database.azure.com',
            port: parseInt(process.env.TYPEORM_PORT || '5432'),
            username: process.env.TYPEORM_USERNAME || 'concordadmin',
            password: process.env.TYPEORM_PASSWORD || '',
            database: process.env.TYPEORM_DATABASE || 'concord',
            synchronize: false,
            logging: process.env.TYPEORM_LOGGING === 'true',
            ssl: { rejectUnauthorized: true },
            autoLoadEntities: true,
            migrationsRun: true,
            migrationsTableName: 'migrations',
            migrations: [path.join(__dirname, '../migrations/**/*.js')],
            entities: [
                path.join(__dirname, '../models/**/*.entity.{js,ts}'),
                path.join(__dirname, '../explore/models/**/*.entity.{js,ts}')
            ],
        }
    };
    const config = nodeEnv === 'production' ? dbConfig.production : dbConfig.development;
    console.log('Database Config:', {
        environment: nodeEnv,
        host: config.host,
        username: config.username,
        database: config.database,
    });
    return config;
}
function getServerConfig() {
    return {
        port: parseInt(process.env.PORT || '3000'),
        cors: {
            origin: '*',
            methods: 'GET,HEAD,PUT,PATCH,POST,DELETE',
            credentials: true,
        },
        rateLimits: {
            windowMs: 15 * 60 * 1000,
            max: 100,
        }
    };
}
loadEnvironment();
//# sourceMappingURL=environment.config.js.map