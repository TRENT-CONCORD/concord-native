"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const typeorm_1 = require("typeorm");
async function testTypeORMConnection() {
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
        await dataSource.initialize();
        console.log('✅ TypeORM DataSource initialized successfully!');
        const result = await dataSource.query('SELECT NOW() as current_time');
        console.log('Current time from database:', result[0].current_time);
        await dataSource.destroy();
        console.log('Connection closed.');
    }
    catch (error) {
        console.error('❌ Error initializing TypeORM DataSource:', error);
    }
}
testTypeORMConnection();
//# sourceMappingURL=typeorm-test.js.map