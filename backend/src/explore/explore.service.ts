import { Injectable } from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../models/user.entity';
import { ExploreFilterDto } from './dto/explore-filter.dto';

@Injectable()
export class ExploreService {
  constructor(
    @InjectRepository(User)
    private usersRepository: Repository<User>,
  ) {}

  async getUsers(filterDto: ExploreFilterDto): Promise<any[]> {
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
      filteredUsers = filteredUsers.filter(user => 
        filterDto.genders.includes(user.gender as any)
      );
    }

    if (filterDto.minAge) {
      filteredUsers = filteredUsers.filter(user => user.age >= filterDto.minAge);
    }

    if (filterDto.maxAge) {
      filteredUsers = filteredUsers.filter(user => user.age <= filterDto.maxAge);
    }

    // Apply pagination
    const limit = filterDto.limit || 20;
    const offset = filterDto.offset || 0;
    
    return filteredUsers.slice(offset, offset + limit);
  }
} 