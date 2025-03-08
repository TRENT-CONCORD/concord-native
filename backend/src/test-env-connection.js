"use strict";
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
Object.defineProperty(exports, "__esModule", { value: true });
const typeorm_1 = require("typeorm");
function testConnection(env) {
    return __awaiter(this, void 0, void 0, function* () {
        // Configuration based on environment
        const config = env === 'production'
            ? {
                host: 'concord-api.postgres.database.azure.com',
                port: 5432,
                username: 'concordadmin',
                password: '8J09#8@!k', // Set this manually when testing production
                database: 'concord',
            }
            : {
                host: 'concord-dev-db.postgres.database.azure.com',
                port: 5432,
                username: 'concordadmindev',
                password: 'Jhvaj8zZrGm4',
                database: 'concord_dev',
            };
        // Create DataSource for the current environment
        const dataSource = new typeorm_1.DataSource({
            type: "postgres",
            host: config.host,
            port: config.port,
            username: config.username,
            password: config.password,
            database: config.database,
            ssl: {
                rejectUnauthorized: true
            }
        });
        try {
            console.log(`\n--- Testing ${env.toUpperCase()} Database Connection ---`);
            console.log(`Host: ${config.host}`);
            console.log(`Database: ${config.database}`);
            console.log(`Username: ${config.username}`);
            console.log('Initializing connection...');
            yield dataSource.initialize();
            console.log('✅ Connection successful!');
            // Run a simple query to verify the connection
            const result = yield dataSource.query('SELECT NOW() as current_time');
            console.log(`Current time from database: ${result[0].current_time}`);
            yield dataSource.destroy();
            console.log('Connection closed.');
            return true;
        }
        catch (error) {
            console.error(`❌ Error connecting to ${env} database:`, error);
            return false;
        }
    });
}
function runTests() {
    return __awaiter(this, void 0, void 0, function* () {
        console.log('=== Database Connection Test ===');
        // Test development connection
        const devSuccess = yield testConnection('development');
        // Test production connection if you have the credentials
        const prodSuccess = yield testConnection('production');
        console.log(`Production: ${prodSuccess ? '✅ Connected' : '❌ Failed'}`);
        console.log('\n=== Test Results ===');
        console.log(`Development: ${devSuccess ? '✅ Connected' : '❌ Failed'}`);
    });
}
runTests();
