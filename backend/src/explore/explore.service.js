"use strict";
var __esDecorate = (this && this.__esDecorate) || function (ctor, descriptorIn, decorators, contextIn, initializers, extraInitializers) {
    function accept(f) { if (f !== void 0 && typeof f !== "function") throw new TypeError("Function expected"); return f; }
    var kind = contextIn.kind, key = kind === "getter" ? "get" : kind === "setter" ? "set" : "value";
    var target = !descriptorIn && ctor ? contextIn["static"] ? ctor : ctor.prototype : null;
    var descriptor = descriptorIn || (target ? Object.getOwnPropertyDescriptor(target, contextIn.name) : {});
    var _, done = false;
    for (var i = decorators.length - 1; i >= 0; i--) {
        var context = {};
        for (var p in contextIn) context[p] = p === "access" ? {} : contextIn[p];
        for (var p in contextIn.access) context.access[p] = contextIn.access[p];
        context.addInitializer = function (f) { if (done) throw new TypeError("Cannot add initializers after decoration has completed"); extraInitializers.push(accept(f || null)); };
        var result = (0, decorators[i])(kind === "accessor" ? { get: descriptor.get, set: descriptor.set } : descriptor[key], context);
        if (kind === "accessor") {
            if (result === void 0) continue;
            if (result === null || typeof result !== "object") throw new TypeError("Object expected");
            if (_ = accept(result.get)) descriptor.get = _;
            if (_ = accept(result.set)) descriptor.set = _;
            if (_ = accept(result.init)) initializers.unshift(_);
        }
        else if (_ = accept(result)) {
            if (kind === "field") initializers.unshift(_);
            else descriptor[key] = _;
        }
    }
    if (target) Object.defineProperty(target, contextIn.name, descriptor);
    done = true;
};
var __runInitializers = (this && this.__runInitializers) || function (thisArg, initializers, value) {
    var useValue = arguments.length > 2;
    for (var i = 0; i < initializers.length; i++) {
        value = useValue ? initializers[i].call(thisArg, value) : initializers[i].call(thisArg);
    }
    return useValue ? value : void 0;
};
var __awaiter = (this && this.__awaiter) || function (thisArg, _arguments, P, generator) {
    function adopt(value) { return value instanceof P ? value : new P(function (resolve) { resolve(value); }); }
    return new (P || (P = Promise))(function (resolve, reject) {
        function fulfilled(value) { try { step(generator.next(value)); } catch (e) { reject(e); } }
        function rejected(value) { try { step(generator["throw"](value)); } catch (e) { reject(e); } }
        function step(result) { result.done ? resolve(result.value) : adopt(result.value).then(fulfilled, rejected); }
        step((generator = generator.apply(thisArg, _arguments || [])).next());
    });
};
var __setFunctionName = (this && this.__setFunctionName) || function (f, name, prefix) {
    if (typeof name === "symbol") name = name.description ? "[".concat(name.description, "]") : "";
    return Object.defineProperty(f, "name", { configurable: true, value: prefix ? "".concat(prefix, " ", name) : name });
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.ExploreService = void 0;
const common_1 = require("@nestjs/common");
let ExploreService = (() => {
    let _classDecorators = [(0, common_1.Injectable)()];
    let _classDescriptor;
    let _classExtraInitializers = [];
    let _classThis;
    var ExploreService = _classThis = class {
        constructor(usersRepository, savedFiltersRepository) {
            this.usersRepository = usersRepository;
            this.savedFiltersRepository = savedFiltersRepository;
        }
        getUsers(filterDto) {
            return __awaiter(this, void 0, void 0, function* () {
                // For now, return mock data since we don't have a real database yet
                // In a real implementation, we would query the database using the filters
                // Mock user data
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
                // Apply filters (simplified for mock data)
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
                // Proximity-based filtering
                if (filterDto.latitude && filterDto.longitude && filterDto.maxDistance) {
                    const { latitude, longitude, maxDistance } = filterDto;
                    filteredUsers = filteredUsers.filter(user => {
                        if (!user.latitude || !user.longitude)
                            return false;
                        const distance = this.calculateDistance(latitude, longitude, user.latitude, user.longitude);
                        return distance <= maxDistance;
                    });
                }
                // Apply pagination
                const limit = filterDto.limit || 20;
                const offset = filterDto.offset || 0;
                return filteredUsers.slice(offset, offset + limit);
            });
        }
        calculateDistance(lat1, lon1, lat2, lon2) {
            const earthRadius = 6371; // Earth's radius in kilometers
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
        saveFilter(userId, filters) {
            return __awaiter(this, void 0, void 0, function* () {
                const savedFilter = this.savedFiltersRepository.create({ userId, filters });
                return this.savedFiltersRepository.save(savedFilter);
            });
        }
        getSavedFilters(userId) {
            return __awaiter(this, void 0, void 0, function* () {
                return this.savedFiltersRepository.find({ where: { userId } });
            });
        }
    };
    __setFunctionName(_classThis, "ExploreService");
    (() => {
        const _metadata = typeof Symbol === "function" && Symbol.metadata ? Object.create(null) : void 0;
        __esDecorate(null, _classDescriptor = { value: _classThis }, _classDecorators, { kind: "class", name: _classThis.name, metadata: _metadata }, null, _classExtraInitializers);
        ExploreService = _classThis = _classDescriptor.value;
        if (_metadata) Object.defineProperty(_classThis, Symbol.metadata, { enumerable: true, configurable: true, writable: true, value: _metadata });
        __runInitializers(_classThis, _classExtraInitializers);
    })();
    return ExploreService = _classThis;
})();
exports.ExploreService = ExploreService;
