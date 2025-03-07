import { Entity, Column, PrimaryGeneratedColumn, CreateDateColumn, UpdateDateColumn } from 'typeorm';

export enum GenderOption {
  MAN = 'man',
  WOMAN = 'woman',
  BEYOND_BINARY = 'beyondBinary',
}

export enum EducationLevel {
  HIGH_SCHOOL = 'highSchool',
  HIGHER_CERTIFICATE = 'higherCertificate',
  BACHELORS = 'bachelors',
  MASTERS = 'masters',
  DOCTORATE = 'doctorate',
}

export enum CommunicationStyle {
  ASSERTIVE = 'assertive',
  PASSIVE = 'passive',
  AGGRESSIVE = 'aggressive',
  PASSIVE_AGGRESSIVE = 'passiveAggressive',
}

export enum Interest {
  MUSIC = 'music',
  TRAVEL = 'travel',
  FOOD = 'food',
  FITNESS = 'fitness',
  READING = 'reading',
  MOVIES = 'movies',
}

export enum SmokingHabit {
  NEVER = 'never',
  SOMETIMES = 'sometimes',
  REGULARLY = 'regularly',
  TRYING_TO_QUIT = 'tryingToQuit',
}

export enum DrinkingHabit {
  NEVER = 'never',
  SOCIALLY = 'socially',
  REGULARLY = 'regularly',
}

export enum WorkoutHabit {
  NEVER = 'never',
  SOMETIMES = 'sometimes',
  REGULARLY = 'regularly',
  DAILY = 'daily',
}

export enum DietaryPreference {
  NONE = 'none',
  VEGETARIAN = 'vegetarian',
  VEGAN = 'vegan',
  PESCATARIAN = 'pescatarian',
  GLUTEN_FREE = 'glutenFree',
}

export enum SleepingHabit {
  EARLY_BIRD = 'earlyBird',
  NIGHT_OWL = 'nightOwl',
  IRREGULAR = 'irregular',
}

export enum LoveLanguage {
  WORDS_OF_AFFIRMATION = 'wordsOfAffirmation',
  QUALITY_TIME = 'qualityTime',
  RECEIVING_GIFTS = 'receivingGifts',
  ACTS_OF_SERVICE = 'actsOfService',
  PHYSICAL_TOUCH = 'physicalTouch',
}

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  displayName: string;

  @Column()
  username: string;

  @Column({ nullable: true })
  photoURL: string;

  @Column({
    type: 'enum',
    enum: GenderOption,
    default: GenderOption.MAN,
  })
  gender: GenderOption;

  @Column({ type: 'date', nullable: true })
  dateOfBirth: Date;

  @Column({ nullable: true })
  bio: string;

  @Column({ nullable: true })
  location: string;

  @Column('float', { nullable: true })
  latitude: number;

  @Column('float', { nullable: true })
  longitude: number;

  @Column({ type: 'json', nullable: true })
  interests: Interest[];

  @Column({ type: 'json', nullable: true })
  educationLevels: EducationLevel[];

  @Column({ type: 'json', nullable: true })
  communicationStyles: CommunicationStyle[];

  @Column({ type: 'enum', enum: SmokingHabit, nullable: true })
  smokingHabit: SmokingHabit;

  @Column({ type: 'enum', enum: DrinkingHabit, nullable: true })
  drinkingHabit: DrinkingHabit;

  @Column({ type: 'enum', enum: WorkoutHabit, nullable: true })
  workoutHabit: WorkoutHabit;

  @Column({ type: 'enum', enum: DietaryPreference, nullable: true })
  dietaryPreference: DietaryPreference;

  @Column({ type: 'enum', enum: SleepingHabit, nullable: true })
  sleepingHabit: SleepingHabit;

  @Column({ type: 'json', nullable: true })
  loveLanguages: LoveLanguage[];

  @Column({ type: 'json', nullable: true })
  additionalPhotos: string[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @Column({ type: 'timestamp', nullable: true })
  lastActive: Date;
} 