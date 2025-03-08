"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const explore_service_1 = require("./explore.service");
const typeorm_1 = require("@nestjs/typeorm");
const user_entity_1 = require("../models/user.entity");
const saved_filter_entity_1 = require("./models/saved-filter.entity");
describe('ExploreService', () => {
    let service;
    let userRepository;
    let savedFilterRepository;
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
        const module = await testing_1.Test.createTestingModule({
            providers: [
                explore_service_1.ExploreService,
                {
                    provide: (0, typeorm_1.getRepositoryToken)(user_entity_1.User),
                    useValue: mockUserRepository,
                },
                {
                    provide: (0, typeorm_1.getRepositoryToken)(saved_filter_entity_1.SavedFilter),
                    useValue: mockSavedFilterRepository,
                },
            ],
        }).compile();
        service = module.get(explore_service_1.ExploreService);
        userRepository = module.get((0, typeorm_1.getRepositoryToken)(user_entity_1.User));
        savedFilterRepository = module.get((0, typeorm_1.getRepositoryToken)(saved_filter_entity_1.SavedFilter));
    });
    afterEach(() => {
        jest.clearAllMocks();
    });
    it('should be defined', () => {
        expect(service).toBeDefined();
    });
    describe('getUsers', () => {
        it('should return mock users when called with filters', async () => {
            const filterDto = {
                minAge: 18,
                maxAge: 30,
            };
            const result = await service.getUsers(filterDto);
            expect(result).toBeDefined();
            expect(Array.isArray(result)).toBe(true);
            if (result.length > 0) {
                expect(result[0]).toHaveProperty('id');
                expect(result[0]).toHaveProperty('displayName');
            }
        });
    });
    describe('saveFilter', () => {
        it('should save a filter for a user', async () => {
            const userId = 'user123';
            const filters = { minAge: 18, maxAge: 30 };
            const newFilter = { id: 'filter1', userId, filters };
            mockSavedFilterRepository.create.mockReturnValue(newFilter);
            mockSavedFilterRepository.save.mockResolvedValue(newFilter);
            const result = await service.saveFilter(userId, filters);
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
            const userId = 'user123';
            const savedFilters = [
                { id: 'filter1', userId, filters: { minAge: 18 } },
                { id: 'filter2', userId, filters: { maxAge: 30 } },
            ];
            mockSavedFilterRepository.find.mockResolvedValue(savedFilters);
            const result = await service.getSavedFilters(userId);
            expect(savedFilterRepository.find).toHaveBeenCalledWith({
                where: { userId },
            });
            expect(result).toEqual(savedFilters);
        });
    });
});
//# sourceMappingURL=explore.service.spec.js.map