"use strict";
var __decorate = (this && this.__decorate) || function (decorators, target, key, desc) {
    var c = arguments.length, r = c < 3 ? target : desc === null ? desc = Object.getOwnPropertyDescriptor(target, key) : desc, d;
    if (typeof Reflect === "object" && typeof Reflect.decorate === "function") r = Reflect.decorate(decorators, target, key, desc);
    else for (var i = decorators.length - 1; i >= 0; i--) if (d = decorators[i]) r = (c < 3 ? d(r) : c > 3 ? d(target, key, r) : d(target, key)) || r;
    return c > 3 && r && Object.defineProperty(target, key, r), r;
};
Object.defineProperty(exports, "__esModule", { value: true });
exports.FiltersService = void 0;
const common_1 = require("@nestjs/common");
const user_entity_1 = require("../models/user.entity");
let FiltersService = class FiltersService {
    getFilters() {
        return {
            genders: Object.values(user_entity_1.GenderOption),
            ageRange: { min: 18, max: 99 },
            educationLevels: Object.values(user_entity_1.EducationLevel),
            communicationStyles: Object.values(user_entity_1.CommunicationStyle),
            interests: Object.values(user_entity_1.Interest),
            smokingHabits: Object.values(user_entity_1.SmokingHabit),
            drinkingHabits: Object.values(user_entity_1.DrinkingHabit),
            workoutHabits: Object.values(user_entity_1.WorkoutHabit),
            dietaryPreferences: Object.values(user_entity_1.DietaryPreference),
            sleepingHabits: Object.values(user_entity_1.SleepingHabit),
            loveLanguages: Object.values(user_entity_1.LoveLanguage),
        };
    }
};
exports.FiltersService = FiltersService;
exports.FiltersService = FiltersService = __decorate([
    (0, common_1.Injectable)()
], FiltersService);
//# sourceMappingURL=filters.service.js.map