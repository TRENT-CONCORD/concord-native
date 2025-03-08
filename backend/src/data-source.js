"use strict";
var __createBinding = (this && this.__createBinding) || (Object.create ? (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    var desc = Object.getOwnPropertyDescriptor(m, k);
    if (!desc || ("get" in desc ? !m.__esModule : desc.writable || desc.configurable)) {
      desc = { enumerable: true, get: function() { return m[k]; } };
    }
    Object.defineProperty(o, k2, desc);
}) : (function(o, m, k, k2) {
    if (k2 === undefined) k2 = k;
    o[k2] = m[k];
}));
var __setModuleDefault = (this && this.__setModuleDefault) || (Object.create ? (function(o, v) {
    Object.defineProperty(o, "default", { enumerable: true, value: v });
}) : function(o, v) {
    o["default"] = v;
});
var __importStar = (this && this.__importStar) || (function () {
    var ownKeys = function(o) {
        ownKeys = Object.getOwnPropertyNames || function (o) {
            var ar = [];
            for (var k in o) if (Object.prototype.hasOwnProperty.call(o, k)) ar[ar.length] = k;
            return ar;
        };
        return ownKeys(o);
    };
    return function (mod) {
        if (mod && mod.__esModule) return mod;
        var result = {};
        if (mod != null) for (var k = ownKeys(mod), i = 0; i < k.length; i++) if (k[i] !== "default") __createBinding(result, mod, k[i]);
        __setModuleDefault(result, mod);
        return result;
    };
})();
Object.defineProperty(exports, "__esModule", { value: true });
require("reflect-metadata");
const typeorm_1 = require("typeorm");
const dotenv = __importStar(require("dotenv"));
const path = __importStar(require("path"));
const fs = __importStar(require("fs"));
// Determine which environment we're in
const nodeEnv = process.env.NODE_ENV || 'development';
console.log(`Current environment: ${nodeEnv}`);
// Load the appropriate .env file
const envFile = nodeEnv === 'production' ? '.env.production' : '.env';
const envPath = path.resolve(__dirname, `../${envFile}`);
console.log(`Loading environment from: ${envPath}`);
console.log(`File exists: ${fs.existsSync(envPath)}`);
dotenv.config({ path: envPath });
// Configuration for different environments
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
        password: process.env.TYPEORM_PASSWORD || '', // Always use env variable for production password
        database: process.env.TYPEORM_DATABASE || 'concord',
        synchronize: false, // Never auto-synchronize in production
        logging: process.env.TYPEORM_LOGGING === 'true' || false,
    }
};
// Select the configuration based on environment
const config = nodeEnv === 'production' ? dbConfig.production : dbConfig.development;
// Debug log to check the loaded configuration
console.log('Database Config:', {
    environment: nodeEnv,
    host: config.host,
    username: config.username,
    database: config.database,
    // Don't log the password
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
    entities: ["src/entity/**/*.ts"],
    migrations: ["src/migration/**/*.ts"],
    subscribers: ["src/subscriber/**/*.ts"],
    ssl: {
        rejectUnauthorized: true
    }
});
exports.default = AppDataSource;
