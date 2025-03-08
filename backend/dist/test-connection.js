"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const data_source_1 = require("./data-source");
const testConnection = async () => {
    try {
        console.log('Attempting to connect to the database...');
        await data_source_1.default.initialize();
        console.log('✅ Database connection successful!');
        const result = await data_source_1.default.query('SELECT NOW() as current_time');
        console.log('Current time from database:', result[0].current_time);
        await data_source_1.default.destroy();
        console.log('Connection closed.');
        process.exit(0);
    }
    catch (error) {
        console.error('❌ Database connection failed:', error);
        process.exit(1);
    }
};
testConnection();
//# sourceMappingURL=test-connection.js.map