import { ExploreService } from './explore.service';
import { ExploreFilterDto } from './dto/explore-filter.dto';
export declare class ExploreController {
    private readonly exploreService;
    constructor(exploreService: ExploreService);
    getUsers(filterDto: ExploreFilterDto): Promise<any[]>;
    saveFilter(body: {
        userId: string;
        filters: Record<string, any>;
    }): Promise<import("./models/saved-filter.entity").SavedFilter>;
    getSavedFilters(userId: string): Promise<import("./models/saved-filter.entity").SavedFilter[]>;
}
