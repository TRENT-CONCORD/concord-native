// Mock User entity
export class User {
  id: string;
  displayName: string;
  username: string;
  photoURL: string;
  gender: string;
  age: number;
  distance: string;
  latitude: number;
  longitude: number;
  interests: string[];
  bio: string;
  educationLevels: string[];
  communicationStyles: string[];
  smokingHabit: string;
  drinkingHabit: string;
  workoutHabit: string;
  dietaryPreference: string;
  sleepingHabit: string;
  loveLanguages: string[];
}

// Mock SavedFilter entity
export class SavedFilter {
  id: string;
  userId: string;
  filters: Record<string, any>;
  createdAt: Date;
  updatedAt: Date;
} 