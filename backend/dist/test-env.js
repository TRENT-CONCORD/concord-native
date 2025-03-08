"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv = require("dotenv");
const path = require("path");
dotenv.config({ path: path.resolve(__dirname, '../.env') });
console.log('Loaded Environment Variables:', process.env);
//# sourceMappingURL=test-env.js.map