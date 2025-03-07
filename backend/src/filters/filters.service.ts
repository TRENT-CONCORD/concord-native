import { Injectable } from '@nestjs/common';
import { GenderOption, EducationLevel, CommunicationStyle, Interest, SmokingHabit, DrinkingHabit, WorkoutHabit, DietaryPreference, SleepingHabit, LoveLanguage } from '../models/user.entity';

@Injectable()
export class FiltersService {
  getFilters() {
    // Return all available filter options
    return {
      genders: Object.values(GenderOption),
      ageRange: { min: 18, max: 99 },
      educationLevels: Object.values(EducationLevel),
      communicationStyles: Object.values(CommunicationStyle),
      interests: Object.values(Interest),
      smokingHabits: Object.values(SmokingHabit),
      drinkingHabits: Object.values(DrinkingHabit),
      workoutHabits: Object.values(WorkoutHabit),
      dietaryPreferences: Object.values(DietaryPreference),
      sleepingHabits: Object.values(SleepingHabit),
      loveLanguages: Object.values(LoveLanguage),
    };
  }
} 