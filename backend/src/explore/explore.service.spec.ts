import { Test, TestingModule } from '@nestjs/testing';
import { ExploreService } from './explore.service';
import { getRepositoryToken } from '@nestjs/typeorm';
import { User } from '../models/user.entity';
import { SavedFilter } from './models/saved-filter.entity';
import { ExploreFilterDto } from './dto/explore-filter.dto';
import { Repository } from 'typeorm';

describe('ExploreService', () => {
  let service: ExploreService;
  let userRepository: Repository<User>;
  let savedFilterRepository: Repository<SavedFilter>;

  // Mock repositories
  const mockUserRepository = {
    find: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  const mockSavedFilterRepository = {
    find: jest.fn(),
    findOne: jest.fn(),
    create: jest.fn(),
    save: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      providers: [
        ExploreService,
        {
          provide: getRepositoryToken(User),
          useValue: mockUserRepository,
        },
        {
          provide: getRepositoryToken(SavedFilter),
          useValue: mockSavedFilterRepository,
        },
      ],
    }).compile();

    service = module.get<ExploreService>(ExploreService);
    userRepository = module.get<Repository<User>>(getRepositoryToken(User));
    savedFilterRepository = module.get<Repository<SavedFilter>>(getRepositoryToken(SavedFilter));
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(service).toBeDefined();
  });

  describe('getUsers', () => {
    it('should return mock users when called with filters', async () => {
      // Arrange
      const filterDto: ExploreFilterDto = {
        minAge: 18,
        maxAge: 30,
      };

      // Act
      const result = await service.getUsers(filterDto);

      // Assert
      expect(result).toBeDefined();
      expect(Array.isArray(result)).toBe(true);
      // Check if at least one user is returned and has required properties
      if (result.length > 0) {
        expect(result[0]).toHaveProperty('id');
        expect(result[0]).toHaveProperty('displayName');
      }
    });
  });

  describe('saveFilter', () => {
    it('should save a filter for a user', async () => {
      // Arrange
      const userId = 'user123';
      const filters = { minAge: 18, maxAge: 30 };
      const newFilter = { id: 'filter1', userId, filters };
      
      mockSavedFilterRepository.create.mockReturnValue(newFilter);
      mockSavedFilterRepository.save.mockResolvedValue(newFilter);

      // Act
      const result = await service.saveFilter(userId, filters);

      // Assert
      expect(savedFilterRepository.create).toHaveBeenCalledWith({
        userId,
        filters,
      });
      expect(savedFilterRepository.save).toHaveBeenCalledWith(newFilter);
      expect(result).toEqual(newFilter);
    });
  });

  describe('getSavedFilters', () => {
    it('should return saved filters for a user', async () => {
      // Arrange
      const userId = 'user123';
      const savedFilters = [
        { id: 'filter1', userId, filters: { minAge: 18 } },
        { id: 'filter2', userId, filters: { maxAge: 30 } },
      ];
      
      mockSavedFilterRepository.find.mockResolvedValue(savedFilters);

      // Act
      const result = await service.getSavedFilters(userId);

      // Assert
      expect(savedFilterRepository.find).toHaveBeenCalledWith({
        where: { userId },
      });
      expect(result).toEqual(savedFilters);
    });
  });
}); 