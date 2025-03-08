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
const pg_1 = require("pg");
function testDirectConnection() {
    return __awaiter(this, void 0, void 0, function* () {
        const client = new pg_1.Client({
            host: 'concord-dev-db.postgres.database.azure.com',
            port: 5432,
            user: 'concordadmindev',
            password: 'Jhvaj8zZrGm4',
            database: 'concord_dev',
            ssl: {
                rejectUnauthorized: true
            }
        });
        try {
            console.log('Connecting to PostgreSQL...');
            yield client.connect();
            console.log('✅ Connected to PostgreSQL successfully!');
            const result = yield client.query('SELECT NOW() as current_time');
            console.log('Current time from database:', result.rows[0].current_time);
            yield client.end();
            console.log('Connection closed.');
        }
        catch (error) {
            console.error('❌ Error connecting to PostgreSQL:', error);
        }
    });
}
testDirectConnection();
