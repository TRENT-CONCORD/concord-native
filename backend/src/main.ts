import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { ValidationPipe } from '@nestjs/common';
import { getServerConfig } from './config/environment.config';
import helmet from 'helmet';
import rateLimit from 'express-rate-limit';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  const config = getServerConfig();
  
  // Security - add Helmet middleware
  app.use(helmet());
  
  // Rate limiting to prevent abuse
  app.use(
    rateLimit({
      windowMs: config.rateLimits.windowMs,
      max: config.rateLimits.max,
      message: 'Too many requests from this IP, please try again later',
    }),
  );
  
  // Enable CORS for the Flutter app
  app.enableCors(config.cors);
  
  // Use validation pipe for DTOs
  app.useGlobalPipes(new ValidationPipe({
    whitelist: true,
    transform: true,
  }));
  
  // Configure the API prefix
  app.setGlobalPrefix('api');
  
  await app.listen(config.port);
  console.log(`Application is running in ${process.env.NODE_ENV || 'development'} mode on: http://localhost:${config.port}/api`);
}

bootstrap(); 