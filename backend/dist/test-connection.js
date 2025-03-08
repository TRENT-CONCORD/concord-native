"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const dotenv = require("dotenv");
const path = require("path");
dotenv.config({ path: path.resolve(__dirname, '../.env') });
const data_source_1 = require("./data-source");
(async () => {
    try {
        console.log('Testing database connection...');
        await data_source_1.default.initialize();
        console.log('Database connection successful!');
        await data_source_1.default.destroy();
    }
    catch (error) {
        console.error('Error connecting to the database:', error);
    }
})();
//# sourceMappingURL=test-connection.js.map