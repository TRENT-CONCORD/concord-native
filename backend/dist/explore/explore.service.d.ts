import { Repository } from 'typeorm';
import { User } from '../models/user.entity';
import { ExploreFilterDto } from './dto/explore-filter.dto';
import { SavedFilter } from './models/saved-filter.entity';
export declare class ExploreService {
    private usersRepository;
    private savedFiltersRepository;
    constructor(usersRepository: Repository<User>, savedFiltersRepository: Repository<SavedFilter>);
    getUsers(filterDto: ExploreFilterDto): Promise<any[]>;
    private calculateDistance;
    private degreesToRadians;
    saveFilter(userId: string, filters: Record<string, any>): Promise<SavedFilter>;
    getSavedFilters(userId: string): Promise<SavedFilter[]>;
}
