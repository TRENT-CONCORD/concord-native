import { Test, TestingModule } from '@nestjs/testing';
import { ExploreController } from './explore.controller';
import { ExploreService } from './explore.service';
import { ExploreFilterDto } from './dto/explore-filter.dto';

describe('ExploreController', () => {
  let controller: ExploreController;
  let service: ExploreService;

  // Mock ExploreService
  const mockExploreService = {
    getUsers: jest.fn(),
    saveFilter: jest.fn(),
    getSavedFilters: jest.fn(),
  };

  beforeEach(async () => {
    const module: TestingModule = await Test.createTestingModule({
      controllers: [ExploreController],
      providers: [
        {
          provide: ExploreService,
          useValue: mockExploreService,
        },
      ],
    }).compile();

    controller = module.get<ExploreController>(ExploreController);
    service = module.get<ExploreService>(ExploreService);
  });

  afterEach(() => {
    jest.clearAllMocks();
  });

  it('should be defined', () => {
    expect(controller).toBeDefined();
  });

  describe('getUsers', () => {
    it('should call ExploreService.getUsers with the provided filters', async () => {
      // Arrange
      const filterDto: ExploreFilterDto = {
        minAge: 18,
        maxAge: 30,
      };
      const expectedResult = [
        { id: '1', name: 'User 1' },
        { id: '2', name: 'User 2' },
      ];
      mockExploreService.getUsers.mockResolvedValue(expectedResult);

      // Act
      const result = await controller.getUsers(filterDto);

      // Assert
      expect(service.getUsers).toHaveBeenCalledWith(filterDto);
      expect(result).toEqual(expectedResult);
    });
  });

  describe('saveFilter', () => {
    it('should call ExploreService.saveFilter with userId and filters', async () => {
      // Arrange
      const body = {
        userId: 'user123',
        filters: { minAge: 18, maxAge: 30 },
      };
      const expectedResult = { id: 'filter1', ...body };
      mockExploreService.saveFilter.mockResolvedValue(expectedResult);

      // Act
      const result = await controller.saveFilter(body);

      // Assert
      expect(service.saveFilter).toHaveBeenCalledWith(body.userId, body.filters);
      expect(result).toEqual(expectedResult);
    });
  });

  describe('getSavedFilters', () => {
    it('should call ExploreService.getSavedFilters with userId', async () => {
      // Arrange
      const userId = 'user123';
      const expectedResult = [
        { id: 'filter1', userId, filters: { minAge: 18 } },
        { id: 'filter2', userId, filters: { maxAge: 30 } },
      ];
      mockExploreService.getSavedFilters.mockResolvedValue(expectedResult);

      // Act
      const result = await controller.getSavedFilters(userId);

      // Assert
      expect(service.getSavedFilters).toHaveBeenCalledWith(userId);
      expect(result).toEqual(expectedResult);
    });
  });
}); 