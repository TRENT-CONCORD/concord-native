export declare enum GenderOption {
    MAN = "man",
    WOMAN = "woman",
    BEYOND_BINARY = "beyondBinary"
}
export declare enum EducationLevel {
    HIGH_SCHOOL = "highSchool",
    HIGHER_CERTIFICATE = "higherCertificate",
    BACHELORS = "bachelors",
    MASTERS = "masters",
    DOCTORATE = "doctorate"
}
export declare enum CommunicationStyle {
    ASSERTIVE = "assertive",
    PASSIVE = "passive",
    AGGRESSIVE = "aggressive",
    PASSIVE_AGGRESSIVE = "passiveAggressive"
}
export declare enum Interest {
    MUSIC = "music",
    TRAVEL = "travel",
    FOOD = "food",
    FITNESS = "fitness",
    READING = "reading",
    MOVIES = "movies"
}
export declare enum SmokingHabit {
    NEVER = "never",
    SOMETIMES = "sometimes",
    REGULARLY = "regularly",
    TRYING_TO_QUIT = "tryingToQuit"
}
export declare enum DrinkingHabit {
    NEVER = "never",
    SOCIALLY = "socially",
    REGULARLY = "regularly"
}
export declare enum WorkoutHabit {
    NEVER = "never",
    SOMETIMES = "sometimes",
    REGULARLY = "regularly",
    DAILY = "daily"
}
export declare enum DietaryPreference {
    NONE = "none",
    VEGETARIAN = "vegetarian",
    VEGAN = "vegan",
    PESCATARIAN = "pescatarian",
    GLUTEN_FREE = "glutenFree"
}
export declare enum SleepingHabit {
    EARLY_BIRD = "earlyBird",
    NIGHT_OWL = "nightOwl",
    IRREGULAR = "irregular"
}
export declare enum LoveLanguage {
    WORDS_OF_AFFIRMATION = "wordsOfAffirmation",
    QUALITY_TIME = "qualityTime",
    RECEIVING_GIFTS = "receivingGifts",
    ACTS_OF_SERVICE = "actsOfService",
    PHYSICAL_TOUCH = "physicalTouch"
}
export declare class User {
    id: string;
    displayName: string;
    username: string;
    photoURL: string;
    gender: GenderOption;
    dateOfBirth: Date;
    bio: string;
    location: string;
    latitude: number;
    longitude: number;
    interests: Interest[];
    educationLevels: EducationLevel[];
    communicationStyles: CommunicationStyle[];
    smokingHabit: SmokingHabit;
    drinkingHabit: DrinkingHabit;
    workoutHabit: WorkoutHabit;
    dietaryPreference: DietaryPreference;
    sleepingHabit: SleepingHabit;
    loveLanguages: LoveLanguage[];
    additionalPhotos: string[];
    createdAt: Date;
    updatedAt: Date;
    lastActive: Date;
}
