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
var __importDefault = (this && this.__importDefault) || function (mod) {
    return (mod && mod.__esModule) ? mod : { "default": mod };
};
Object.defineProperty(exports, "__esModule", { value: true });
const data_source_1 = __importDefault(require("./data-source"));
const testConnection = () => __awaiter(void 0, void 0, void 0, function* () {
    try {
        console.log('Attempting to connect to the database...');
        yield data_source_1.default.initialize();
        console.log('✅ Database connection successful!');
        // Run a simple query to verify the connection
        const result = yield data_source_1.default.query('SELECT NOW() as current_time');
        console.log('Current time from database:', result[0].current_time);
        yield data_source_1.default.destroy();
        console.log('Connection closed.');
        process.exit(0);
    }
    catch (error) {
        console.error('❌ Database connection failed:', error);
        process.exit(1);
    }
});
testConnection();
