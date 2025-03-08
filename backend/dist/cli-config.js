"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv = require("dotenv");
const path = require("path");
const fs = require("fs");
const data_source_1 = require("./data-source");
const nodeEnv = process.env.NODE_ENV || 'development';
console.log(`CLI current environment: ${nodeEnv}`);
const envFile = nodeEnv === 'production' ? '.env.production' : '.env';
const envPath = path.resolve(__dirname, `../${envFile}`);
console.log(`CLI loading environment from: ${envPath}`);
console.log(`File exists: ${fs.existsSync(envPath)}`);
dotenv.config({ path: envPath });
console.log('Environment Variables in CLI:', {
    environment: nodeEnv,
    host: process.env.TYPEORM_HOST,
    username: process.env.TYPEORM_USERNAME,
    database: process.env.TYPEORM_DATABASE,
});
exports.default = data_source_1.default;
//# sourceMappingURL=cli-config.js.map