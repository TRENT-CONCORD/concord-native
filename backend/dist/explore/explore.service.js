"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
var __metadata = (this && this.__metadata) || function (k, v) {
    if (typeof Reflect === "object" && typeof Reflect.metadata === "function") return Reflect.metadata(k, v);
};
var __param = (this && this.__param) || function (paramIndex, decorator) {
    return function (target, key) { decorator(target, key, paramIndex); }
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExploreService = void 0;
const common_1 = require("@nestjs/common");
const typeorm_1 = require("@nestjs/typeorm");
const typeorm_2 = require("typeorm");
const user_entity_1 = require("../models/user.entity");
const saved_filter_entity_1 = require("./models/saved-filter.entity");
let ExploreService = class ExploreService {
    constructor(usersRepository, savedFiltersRepository) {
        this.usersRepository = usersRepository;
        this.savedFiltersRepository = savedFiltersRepository;
    }
    async getUsers(filterDto) {
        const mockUsers = [
            {
                id: '1',
                displayName: 'John Doe',
                username: 'johndoe',
                photoURL: 'https://randomuser.me/api/portraits/men/1.jpg',
                gender: 'man',
                age: 28,
                distance: '5 km',
                latitude: 40.7128,
                longitude: -74.0060,
                interests: ['hiking', 'photography', 'cooking'],
                bio: 'I love hiking and taking photos of nature. Also enjoy cooking in my free time.',
                educationLevels: ['bachelors'],
                communicationStyles: ['assertive'],
                smokingHabit: 'never',
                drinkingHabit: 'socially',
                workoutHabit: 'regularly',
                dietaryPreference: 'none',
                sleepingHabit: 'earlyBird',
                loveLanguages: ['qualityTime', 'actsOfService'],
            },
            {
                id: '2',
                displayName: 'Jane Smith',
                username: 'janesmith',
                photoURL: 'https://randomuser.me/api/portraits/women/2.jpg',
                gender: 'woman',
                age: 25,
                distance: '3 km',
                latitude: 34.0522,
                longitude: -118.2437,
                interests: ['reading', 'yoga', 'traveling'],
                bio: 'Yoga instructor who loves to read and travel whenever possible.',
                educationLevels: ['masters'],
                communicationStyles: ['assertive', 'passive'],
                smokingHabit: 'never',
                drinkingHabit: 'never',
                workoutHabit: 'daily',
                dietaryPreference: 'vegetarian',
                sleepingHabit: 'earlyBird',
                loveLanguages: ['wordsOfAffirmation', 'qualityTime'],
            },
            {
                id: '3',
                displayName: 'Alex Johnson',
                username: 'alexj',
                photoURL: 'https://randomuser.me/api/portraits/men/3.jpg',
                gender: 'beyondBinary',
                age: 30,
                distance: '8 km',
                interests: ['music', 'programming', 'dancing'],
                bio: 'Software developer by day, musician by night. Always up for a good dance party.',
                educationLevels: ['masters'],
                communicationStyles: ['assertive'],
                smokingHabit: 'never',
                drinkingHabit: 'socially',
                workoutHabit: 'sometimes',
                dietaryPreference: 'none',
                sleepingHabit: 'nightOwl',
                loveLanguages: ['actsOfService', 'physicalTouch'],
            },
            {
                id: '4',
                displayName: 'Emily Chen',
                username: 'emilyc',
                photoURL: 'https://randomuser.me/api/portraits/women/4.jpg',
                gender: 'woman',
                age: 27,
                distance: '6 km',
                interests: ['painting', 'cooking', 'hiking'],
                bio: 'Artist who loves nature and cooking. Looking for someone to share adventures with.',
                educationLevels: ['bachelors'],
                communicationStyles: ['passive'],
                smokingHabit: 'never',
                drinkingHabit: 'socially',
                workoutHabit: 'regularly',
                dietaryPreference: 'none',
                sleepingHabit: 'earlyBird',
                loveLanguages: ['receivingGifts', 'qualityTime'],
            },
            {
                id: '5',
                displayName: 'Michael Brown',
                username: 'mikeb',
                photoURL: 'https://randomuser.me/api/portraits/men/5.jpg',
                gender: 'man',
                age: 32,
                distance: '10 km',
                interests: ['sports', 'movies', 'cooking'],
                bio: 'Sports enthusiast who also enjoys a good movie night. Can cook a mean pasta dish.',
                educationLevels: ['bachelors'],
                communicationStyles: ['assertive'],
                smokingHabit: 'sometimes',
                drinkingHabit: 'socially',
                workoutHabit: 'daily',
                dietaryPreference: 'none',
                sleepingHabit: 'earlyBird',
                loveLanguages: ['physicalTouch', 'actsOfService'],
            },
        ];
        let filteredUsers = [...mockUsers];
        if (filterDto.genders && filterDto.genders.length > 0) {
            filteredUsers = filteredUsers.filter(user => filterDto.genders.includes(user.gender));
        }
        if (filterDto.minAge) {
            filteredUsers = filteredUsers.filter(user => user.age >= filterDto.minAge);
        }
        if (filterDto.maxAge) {
            filteredUsers = filteredUsers.filter(user => user.age <= filterDto.maxAge);
        }
        if (filterDto.latitude && filterDto.longitude && filterDto.maxDistance) {
            const { latitude, longitude, maxDistance } = filterDto;
            filteredUsers = filteredUsers.filter(user => {
                if (!user.latitude || !user.longitude)
                    return false;
                const distance = this.calculateDistance(latitude, longitude, user.latitude, user.longitude);
                return distance <= maxDistance;
            });
        }
        const limit = filterDto.limit || 20;
        const offset = filterDto.offset || 0;
        return filteredUsers.slice(offset, offset + limit);
    }
    calculateDistance(lat1, lon1, lat2, lon2) {
        const earthRadius = 6371;
        const dLat = this.degreesToRadians(lat2 - lat1);
        const dLon = this.degreesToRadians(lon2 - lon1);
        const a = Math.sin(dLat / 2) * Math.sin(dLat / 2) +
            Math.cos(this.degreesToRadians(lat1)) *
                Math.cos(this.degreesToRadians(lat2)) *
                Math.sin(dLon / 2) *
                Math.sin(dLon / 2);
        const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
        return earthRadius * c;
    }
    degreesToRadians(degrees) {
        return degrees * (Math.PI / 180);
    }
    async saveFilter(userId, filters) {
        const savedFilter = this.savedFiltersRepository.create({ userId, filters });
        return this.savedFiltersRepository.save(savedFilter);
    }
    async getSavedFilters(userId) {
        return this.savedFiltersRepository.find({ where: { userId } });
    }
};
exports.ExploreService = ExploreService;
exports.ExploreService = ExploreService = __decorate([
    (0, common_1.Injectable)(),
    __param(0, (0, typeorm_1.InjectRepository)(user_entity_1.User)),
    __param(1, (0, typeorm_1.InjectRepository)(saved_filter_entity_1.SavedFilter)),
    __metadata("design:paramtypes", [typeorm_2.Repository,
        typeorm_2.Repository])
], ExploreService);
//# sourceMappingURL=explore.service.js.map