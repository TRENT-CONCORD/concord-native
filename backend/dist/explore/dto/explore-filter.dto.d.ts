import { GenderOption, EducationLevel, CommunicationStyle, Interest, SmokingHabit, DrinkingHabit, WorkoutHabit, DietaryPreference, SleepingHabit, LoveLanguage } from '../../models/user.entity';
export declare class ExploreFilterDto {
    genders?: GenderOption[];
    minAge?: number;
    maxAge?: number;
    educationLevels?: EducationLevel[];
    communicationStyles?: CommunicationStyle[];
    interests?: Interest[];
    smokingHabit?: SmokingHabit;
    drinkingHabit?: DrinkingHabit;
    workoutHabit?: WorkoutHabit;
    dietaryPreference?: DietaryPreference;
    sleepingHabit?: SleepingHabit;
    loveLanguages?: LoveLanguage[];
    limit?: number;
    offset?: number;
    latitude?: number;
    longitude?: number;
    maxDistance?: number;
}
