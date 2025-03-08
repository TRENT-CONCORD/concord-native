"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const core_1 = require("@nestjs/core");
const app_module_1 = require("./app.module");
const common_1 = require("@nestjs/common");
const environment_config_1 = require("./config/environment.config");
const helmet_1 = require("helmet");
const rateLimit = require("express-rate-limit");
async function bootstrap() {
    const app = await core_1.NestFactory.create(app_module_1.AppModule);
    const config = (0, environment_config_1.getServerConfig)();
    app.use((0, helmet_1.default)());
    app.use(rateLimit({
        windowMs: config.rateLimits.windowMs,
        max: config.rateLimits.max,
        message: 'Too many requests from this IP, please try again later',
    }));
    app.enableCors(config.cors);
    app.useGlobalPipes(new common_1.ValidationPipe({
        whitelist: true,
        transform: true,
    }));
    app.setGlobalPrefix('api');
    await app.listen(config.port);
    console.log(`Application is running in ${process.env.NODE_ENV || 'development'} mode on: http://localhost:${config.port}/api`);
}
bootstrap();
//# sourceMappingURL=main.js.map