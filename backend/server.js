const express = require('express');
const cors = require('cors');
const app = express();
const PORT = process.env.PORT || 3000;

// Enable CORS for all routes
app.use(cors());
app.use(express.json());

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

// Filter options
const filterOptions = {
  genders: ['man', 'woman', 'beyondBinary'],
  ageRange: { min: 18, max: 99 },
  educationLevels: ['highSchool', 'higherCertificate', 'bachelors', 'masters', 'doctorate'],
  communicationStyles: ['assertive', 'passive', 'aggressive', 'passiveAggressive'],
  interests: ['music', 'travel', 'food', 'fitness', 'reading', 'movies'],
  smokingHabits: ['never', 'sometimes', 'regularly', 'tryingToQuit'],
  drinkingHabits: ['never', 'socially', 'regularly'],
  workoutHabits: ['never', 'sometimes', 'regularly', 'daily'],
  dietaryPreferences: ['none', 'vegetarian', 'vegan', 'pescatarian', 'glutenFree'],
  sleepingHabits: ['earlyBird', 'nightOwl', 'irregular'],
  loveLanguages: ['wordsOfAffirmation', 'qualityTime', 'receivingGifts', 'actsOfService', 'physicalTouch'],
};

// Root endpoint to indicate the server is running
app.get('/', (req, res) => {
  res.json({
    message: 'Concord API is running!',
    endpoints: [
      '/api/explore - Get list of users',
      '/api/filters - Get filter options'
    ]
  });
});

// API routes
app.get('/api/explore', (req, res) => {
  // Get query parameters for filtering
  const { gender, minAge, maxAge, limit = 20, offset = 0 } = req.query;
  
  // Apply filters
  let filteredUsers = [...mockUsers];
  
  if (gender) {
    const genders = Array.isArray(gender) ? gender : [gender];
    filteredUsers = filteredUsers.filter(user => genders.includes(user.gender));
  }
  
  if (minAge) {
    filteredUsers = filteredUsers.filter(user => user.age >= parseInt(minAge));
  }
  
  if (maxAge) {
    filteredUsers = filteredUsers.filter(user => user.age <= parseInt(maxAge));
  }
  
  // Apply pagination
  const paginatedUsers = filteredUsers.slice(
    parseInt(offset), 
    parseInt(offset) + parseInt(limit)
  );
  
  res.json(paginatedUsers);
});

app.get('/api/filters', (req, res) => {
  res.json(filterOptions);
});

// Start the server
app.listen(PORT, () => {
  console.log(`Server is running on http://localhost:${PORT}`);
}); 