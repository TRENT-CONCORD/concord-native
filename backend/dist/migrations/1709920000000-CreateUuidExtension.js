"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.CreateUuidExtension1709920000000 = void 0;
class CreateUuidExtension1709920000000 {
    async up(queryRunner) {
        await queryRunner.query(`CREATE EXTENSION IF NOT EXISTS "uuid-ossp"`);
    }
    async down(queryRunner) {
        await queryRunner.query(`DROP EXTENSION IF EXISTS "uuid-ossp"`);
    }
}
exports.CreateUuidExtension1709920000000 = CreateUuidExtension1709920000000;
//# sourceMappingURL=1709920000000-CreateUuidExtension.js.map