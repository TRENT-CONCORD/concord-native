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
function testTypeORMConnection() {
    return __awaiter(this, void 0, void 0, function* () {
        // Create a new DataSource with hardcoded credentials
        const dataSource = new typeorm_1.DataSource({
            type: "postgres",
            host: 'concord-dev-db.postgres.database.azure.com',
            port: 5432,
            username: 'concordadmindev',
            password: 'Jhvaj8zZrGm4',
            database: 'concord_dev',
            ssl: {
                rejectUnauthorized: true
            }
        });
        try {
            console.log('Initializing TypeORM DataSource...');
            yield dataSource.initialize();
            console.log('✅ TypeORM DataSource initialized successfully!');
            // Run a simple query to verify the connection
            const result = yield dataSource.query('SELECT NOW() as current_time');
            console.log('Current time from database:', result[0].current_time);
            yield dataSource.destroy();
            console.log('Connection closed.');
        }
        catch (error) {
            console.error('❌ Error initializing TypeORM DataSource:', error);
        }
    });
}
testTypeORMConnection();
