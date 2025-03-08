import { Controller, Get, Query, Post, Body, Param } from '@nestjs/common';
import { ExploreService } from './explore.service';
import { ExploreFilterDto } from './dto/explore-filter.dto';

@Controller('explore')
export class ExploreController {
  constructor(private readonly exploreService: ExploreService) {}

  @Get()
  async getUsers(@Query() filterDto: ExploreFilterDto) {
    return this.exploreService.getUsers(filterDto);
  }

  @Post('filters')
  async saveFilter(@Body() body: { userId: string; filters: Record<string, any> }) {
    return this.exploreService.saveFilter(body.userId, body.filters);
  }

  @Get('filters/:userId')
  async getSavedFilters(@Param('userId') userId: string) {
    return this.exploreService.getSavedFilters(userId);
  }
} 