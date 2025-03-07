import { Controller, Get, Query } from '@nestjs/common';
import { ExploreService } from './explore.service';
import { ExploreFilterDto } from './dto/explore-filter.dto';

@Controller('explore')
export class ExploreController {
  constructor(private readonly exploreService: ExploreService) {}

  @Get()
  async getUsers(@Query() filterDto: ExploreFilterDto) {
    return this.exploreService.getUsers(filterDto);
  }
} 