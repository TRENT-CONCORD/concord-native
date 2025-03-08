"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
const testing_1 = require("@nestjs/testing");
const explore_controller_1 = require("./explore.controller");
const explore_service_1 = require("./explore.service");
describe('ExploreController', () => {
    let controller;
    let service;
    const mockExploreService = {
        getUsers: jest.fn(),
        saveFilter: jest.fn(),
        getSavedFilters: jest.fn(),
    };
    beforeEach(async () => {
        const module = await testing_1.Test.createTestingModule({
            controllers: [explore_controller_1.ExploreController],
            providers: [
                {
                    provide: explore_service_1.ExploreService,
                    useValue: mockExploreService,
                },
            ],
        }).compile();
        controller = module.get(explore_controller_1.ExploreController);
        service = module.get(explore_service_1.ExploreService);
    });
    afterEach(() => {
        jest.clearAllMocks();
    });
    it('should be defined', () => {
        expect(controller).toBeDefined();
    });
    describe('getUsers', () => {
        it('should call ExploreService.getUsers with the provided filters', async () => {
            const filterDto = {
                minAge: 18,
                maxAge: 30,
            };
            const expectedResult = [
                { id: '1', name: 'User 1' },
                { id: '2', name: 'User 2' },
            ];
            mockExploreService.getUsers.mockResolvedValue(expectedResult);
            const result = await controller.getUsers(filterDto);
            expect(service.getUsers).toHaveBeenCalledWith(filterDto);
            expect(result).toEqual(expectedResult);
        });
    });
    describe('saveFilter', () => {
        it('should call ExploreService.saveFilter with userId and filters', async () => {
            const body = {
                userId: 'user123',
                filters: { minAge: 18, maxAge: 30 },
            };
            const expectedResult = { id: 'filter1', ...body };
            mockExploreService.saveFilter.mockResolvedValue(expectedResult);
            const result = await controller.saveFilter(body);
            expect(service.saveFilter).toHaveBeenCalledWith(body.userId, body.filters);
            expect(result).toEqual(expectedResult);
        });
    });
    describe('getSavedFilters', () => {
        it('should call ExploreService.getSavedFilters with userId', async () => {
            const userId = 'user123';
            const expectedResult = [
                { id: 'filter1', userId, filters: { minAge: 18 } },
                { id: 'filter2', userId, filters: { maxAge: 30 } },
            ];
            mockExploreService.getSavedFilters.mockResolvedValue(expectedResult);
            const result = await controller.getSavedFilters(userId);
            expect(service.getSavedFilters).toHaveBeenCalledWith(userId);
            expect(result).toEqual(expectedResult);
        });
    });
});
//# sourceMappingURL=explore.controller.spec.js.map