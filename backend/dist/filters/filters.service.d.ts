import { GenderOption, EducationLevel, CommunicationStyle, Interest, SmokingHabit, DrinkingHabit, WorkoutHabit, DietaryPreference, SleepingHabit, LoveLanguage } from '../models/user.entity';
export declare class FiltersService {
    getFilters(): {
        genders: GenderOption[];
        ageRange: {
            min: number;
            max: number;
        };
        educationLevels: EducationLevel[];
        communicationStyles: CommunicationStyle[];
        interests: Interest[];
        smokingHabits: SmokingHabit[];
        drinkingHabits: DrinkingHabit[];
        workoutHabits: WorkoutHabit[];
        dietaryPreferences: DietaryPreference[];
        sleepingHabits: SleepingHabit[];
        loveLanguages: LoveLanguage[];
    };
}
