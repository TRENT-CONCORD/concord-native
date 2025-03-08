import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { ExploreController } from './explore.controller';
import { ExploreService } from './explore.service';
import { User } from '../models/user.entity';
import { ExploreGateway } from './explore.gateway';
import { SavedFilter } from './models/saved-filter.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, SavedFilter])],
  controllers: [ExploreController],
  providers: [ExploreService, ExploreGateway],
  exports: [ExploreService],
})
export class ExploreModule {} 