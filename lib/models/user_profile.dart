import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String displayName;
  String? photoURL;
  List<String> additionalPhotos;
  String? bio;
  DateTime? dateOfBirth;
  GeoPoint? location;
  List<String> interests;
  DateTime createdAt;
  DateTime lastUpdated;
  DateTime lastActive;
  bool isProfileComplete;
  
  // Personal Details
  String? gender;
  String? orientation;
  int? heightCm;
  
  // Occupation & Education
  String? occupation;
  String? education;
  
  // Lifestyle
  String? zodiacSign;
  String? smokingHabit;
  String? activityLevel;
  String? dietaryPreference;
  String? personalityType;
  List<String> pets;

  // Additional fields for user preferences
  String? familyPlans;
  String? communicationStyle;
  String? loveLanguage;
  String? drinkingHabits;
  String? sleepingHabits;

  UserProfile({
    required this.uid,
    required this.displayName,
    this.photoURL,
    List<String>? additionalPhotos,
    this.bio,
    this.dateOfBirth,
    this.location,
    List<String>? interests,
    DateTime? createdAt,
    DateTime? lastUpdated,
    DateTime? lastActive,
    this.isProfileComplete = false,
    this.gender,
    this.orientation,
    this.heightCm,
    this.occupation,
    this.education,
    this.zodiacSign,
    this.smokingHabit,
    this.activityLevel,
    this.dietaryPreference,
    this.personalityType,
    List<String>? pets,
    this.familyPlans,
    this.communicationStyle,
    this.loveLanguage,
    this.drinkingHabits,
    this.sleepingHabits,
  })  : additionalPhotos = additionalPhotos ?? [],
        interests = interests ?? [],
        pets = pets ?? [],
        createdAt = createdAt ?? DateTime.now(),
        lastUpdated = lastUpdated ?? DateTime.now(),
        lastActive = lastActive ?? DateTime.now();

  // Create a UserProfile from a Firebase User
  factory UserProfile.fromFirebaseUser(String uid, String displayName) {
    return UserProfile(
      uid: uid,
      displayName: displayName,
      lastActive: DateTime.now(),
    );
  }

  // Convert UserProfile to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'photoURL': photoURL,
      'additionalPhotos': additionalPhotos,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'location': location,
      'interests': interests,
      'createdAt': createdAt.toIso8601String(),
      'lastUpdated': lastUpdated.toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'isProfileComplete': isProfileComplete,
      'gender': gender,
      'orientation': orientation,
      'heightCm': heightCm,
      'occupation': occupation,
      'education': education,
      'zodiacSign': zodiacSign,
      'smokingHabit': smokingHabit,
      'activityLevel': activityLevel,
      'dietaryPreference': dietaryPreference,
      'personalityType': personalityType,
      'pets': pets,
      'familyPlans': familyPlans,
      'communicationStyle': communicationStyle,
      'loveLanguage': loveLanguage,
      'drinkingHabits': drinkingHabits,
      'sleepingHabits': sleepingHabits,
    };
  }

  // Create a UserProfile from a Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      uid: map['uid'] as String,
      displayName: map['displayName'] as String,
      photoURL: map['photoURL'] as String?,
      additionalPhotos: List<String>.from(map['additionalPhotos'] ?? []),
      bio: map['bio'] as String?,
      dateOfBirth: map['dateOfBirth'] != null
          ? DateTime.parse(map['dateOfBirth'] as String)
          : null,
      location: map['location'] as GeoPoint?,
      interests: List<String>.from(map['interests'] ?? []),
      createdAt: DateTime.parse(map['createdAt'] as String),
      lastUpdated: DateTime.parse(map['lastUpdated'] as String),
      lastActive: DateTime.parse(map['lastActive'] as String),
      isProfileComplete: map['isProfileComplete'] as bool? ?? false,
      gender: map['gender'] as String?,
      orientation: map['orientation'] as String?,
      heightCm: map['heightCm'] as int?,
      occupation: map['occupation'] as String?,
      education: map['education'] as String?,
      zodiacSign: map['zodiacSign'] as String?,
      smokingHabit: map['smokingHabit'] as String?,
      activityLevel: map['activityLevel'] as String?,
      dietaryPreference: map['dietaryPreference'] as String?,
      personalityType: map['personalityType'] as String?,
      pets: List<String>.from(map['pets'] ?? []),
      familyPlans: map['familyPlans'] as String?,
      communicationStyle: map['communicationStyle'] as String?,
      loveLanguage: map['loveLanguage'] as String?,
      drinkingHabits: map['drinkingHabits'] as String?,
      sleepingHabits: map['sleepingHabits'] as String?,
    );
  }

  // Create a copy of UserProfile with some updated fields
  UserProfile copyWith({
    String? displayName,
    String? photoURL,
    List<String>? additionalPhotos,
    String? bio,
    DateTime? dateOfBirth,
    GeoPoint? location,
    List<String>? interests,
    bool? isProfileComplete,
    String? gender,
    String? orientation,
    int? heightCm,
    String? occupation,
    String? education,
    String? zodiacSign,
    String? smokingHabit,
    String? activityLevel,
    String? dietaryPreference,
    String? personalityType,
    List<String>? pets,
    String? familyPlans,
    String? communicationStyle,
    String? loveLanguage,
    String? drinkingHabits,
    String? sleepingHabits,
  }) {
    return UserProfile(
      uid: uid,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      additionalPhotos: additionalPhotos ?? List<String>.from(this.additionalPhotos),
      bio: bio ?? this.bio,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      location: location ?? this.location,
      interests: interests ?? List<String>.from(this.interests),
      createdAt: createdAt,
      lastUpdated: DateTime.now(),
      lastActive: lastActive,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      gender: gender ?? this.gender,
      orientation: orientation ?? this.orientation,
      heightCm: heightCm ?? this.heightCm,
      occupation: occupation ?? this.occupation,
      education: education ?? this.education,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      activityLevel: activityLevel ?? this.activityLevel,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      personalityType: personalityType ?? this.personalityType,
      pets: pets ?? List<String>.from(this.pets),
      familyPlans: familyPlans ?? this.familyPlans,
      communicationStyle: communicationStyle ?? this.communicationStyle,
      loveLanguage: loveLanguage ?? this.loveLanguage,
      drinkingHabits: drinkingHabits ?? this.drinkingHabits,
      sleepingHabits: sleepingHabits ?? this.sleepingHabits,
    );
  }

  // Add logic to handle optional sub-choices for gender
  String get displayGender {
    if (gender == null) return 'N/A';
    if (gender == 'Man' && orientation != null) return orientation!;
    if (gender == 'Woman' && orientation != null) return orientation!;
    if (gender == 'Beyond Binary' && orientation != null) return orientation!;
    return gender!;
  }
} 