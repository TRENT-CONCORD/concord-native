"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv = require("dotenv");
const path = require("path");
const data_source_1 = require("./data-source");
dotenv.config({ path: path.resolve(__dirname, '../.env') });
console.log('Environment Variables in CLI:', {
    host: process.env.TYPEORM_HOST,
    username: process.env.TYPEORM_USERNAME,
    password: process.env.TYPEORM_PASSWORD,
    database: process.env.TYPEORM_DATABASE,
});
exports.default = data_source_1.default;
//# sourceMappingURL=cli-config.js.map