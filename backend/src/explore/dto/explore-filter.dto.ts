import { IsOptional, IsEnum, IsArray, IsInt, Min, Max, ArrayMinSize, ArrayMaxSize } from 'class-validator';
import { Type } from 'class-transformer';
import { GenderOption, EducationLevel, CommunicationStyle, Interest, SmokingHabit, DrinkingHabit, WorkoutHabit, DietaryPreference, SleepingHabit, LoveLanguage } from '../../models/user.entity';

export class ExploreFilterDto {
  @IsOptional()
  @IsArray()
  @IsEnum(GenderOption, { each: true })
  genders?: GenderOption[];

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(18)
  @Max(100)
  minAge?: number;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(18)
  @Max(100)
  maxAge?: number;

  @IsOptional()
  @IsArray()
  @IsEnum(EducationLevel, { each: true })
  @ArrayMinSize(0)
  @ArrayMaxSize(5)
  educationLevels?: EducationLevel[];

  @IsOptional()
  @IsArray()
  @IsEnum(CommunicationStyle, { each: true })
  @ArrayMinSize(0)
  @ArrayMaxSize(4)
  communicationStyles?: CommunicationStyle[];

  @IsOptional()
  @IsArray()
  @IsEnum(Interest, { each: true })
  @ArrayMinSize(0)
  @ArrayMaxSize(10)
  interests?: Interest[];

  @IsOptional()
  @IsEnum(SmokingHabit)
  smokingHabit?: SmokingHabit;

  @IsOptional()
  @IsEnum(DrinkingHabit)
  drinkingHabit?: DrinkingHabit;

  @IsOptional()
  @IsEnum(WorkoutHabit)
  workoutHabit?: WorkoutHabit;

  @IsOptional()
  @IsEnum(DietaryPreference)
  dietaryPreference?: DietaryPreference;

  @IsOptional()
  @IsEnum(SleepingHabit)
  sleepingHabit?: SleepingHabit;

  @IsOptional()
  @IsArray()
  @IsEnum(LoveLanguage, { each: true })
  @ArrayMinSize(0)
  @ArrayMaxSize(5)
  loveLanguages?: LoveLanguage[];

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(1)
  @Max(100)
  limit?: number = 20;

  @IsOptional()
  @Type(() => Number)
  @IsInt()
  @Min(0)
  offset?: number = 0;
} 