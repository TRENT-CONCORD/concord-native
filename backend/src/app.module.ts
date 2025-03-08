import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExploreModule } from './explore/explore.module';
import { FiltersModule } from './filters/filters.module';
import { getDatabaseConfig } from './config/environment.config';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: process.env.NODE_ENV === 'production' ? '.env.production' : '.env',
    }),
    TypeOrmModule.forRoot(getDatabaseConfig() as any),
    ExploreModule,
    FiltersModule,
  ],
})
export class AppModule {} 