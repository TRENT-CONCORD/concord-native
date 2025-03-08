"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const pg_1 = require("pg");
async function testDirectConnection() {
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
        await client.connect();
        console.log('✅ Connected to PostgreSQL successfully!');
        const result = await client.query('SELECT NOW() as current_time');
        console.log('Current time from database:', result.rows[0].current_time);
        await client.end();
        console.log('Connection closed.');
    }
    catch (error) {
        console.error('❌ Error connecting to PostgreSQL:', error);
    }
}
testDirectConnection();
//# sourceMappingURL=direct-test.js.map