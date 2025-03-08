import { FiltersService } from './filters.service';
export declare class FiltersController {
    private readonly filtersService;
    constructor(filtersService: FiltersService);
    getFilters(): Promise<{
        genders: import("../models/user.entity").GenderOption[];
        ageRange: {
            min: number;
            max: number;
        };
        educationLevels: import("../models/user.entity").EducationLevel[];
        communicationStyles: import("../models/user.entity").CommunicationStyle[];
        interests: import("../models/user.entity").Interest[];
        smokingHabits: import("../models/user.entity").SmokingHabit[];
        drinkingHabits: import("../models/user.entity").DrinkingHabit[];
        workoutHabits: import("../models/user.entity").WorkoutHabit[];
        dietaryPreferences: import("../models/user.entity").DietaryPreference[];
        sleepingHabits: import("../models/user.entity").SleepingHabit[];
        loveLanguages: import("../models/user.entity").LoveLanguage[];
    }>;
}
