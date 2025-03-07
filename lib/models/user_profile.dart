import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'profile_enums.dart';

enum GenderOption {
  man('Man'),
  woman('Woman'),
  beyondBinary('Beyond Binary');

  final String display;
  const GenderOption(this.display);
}

enum GenderSubOptionMan {
  cisman('Cis Man'),
  intersexMan('Intersex Man'),
  transMan('Trans Man'),
  transmasculine('Transmasculine'),
  otherMan('Other (Man)');

  final String display;
  const GenderSubOptionMan(this.display);
}

enum GenderSubOptionWoman {
  ciswoman('Cis Woman'),
  intersexWoman('Intersex Woman'),
  transWoman('Trans Woman'),
  transfeminine('Transfeminine'),
  otherWoman('Other (Woman)');

  final String display;
  const GenderSubOptionWoman(this.display);
}

enum GenderSubOptionBeyondBinary {
  agender('Agender'),
  bigender('Bigender'),
  genderfluid('Genderfluid'),
  genderQuestioning('Gender Questioning'),
  genderqueer('Genderqueer'),
  intersex('Intersex'),
  nonbinary('Nonbinary'),
  pangender('Pangender'),
  transPerson('Trans Person'),
  transfeminine('Transfeminine'),
  transmasculine('Transmasculine'),
  twoSpirit('Two-Spirit'),
  other('Other');

  final String display;
  const GenderSubOptionBeyondBinary(this.display);
}

enum LookingForOption {
  fun('Fun'),
  chats('Chats'),
  digitalFriends('Digital Friends'),
  inPersonFriends('In-person Friends'),
  dates('Dates'),
  longDistancePartner('Long-distance Partner'),
  inPersonPartner('In-person Partner'),
  notSureYet('Not sure yet');

  final String display;
  const LookingForOption(this.display);
}

class UserProfile {
  String uid;
  String displayName;
  String? username;
  DateTime? dateOfBirth;
  DateTime lastActive;
  List<String> additionalPhotos;
  String? mainPhotoUrl;

  // Account deletion tracking
  bool scheduledForDeletion;
  DateTime? deletionScheduledAt;

  // Calculate days remaining until permanent deletion (90 days total)
  int get daysUntilPermanentDeletion {
    if (!scheduledForDeletion || deletionScheduledAt == null) return 0;

    final DateTime deletionDate = deletionScheduledAt!.add(Duration(days: 90));
    final int daysRemaining = deletionDate.difference(DateTime.now()).inDays;
    return daysRemaining > 0 ? daysRemaining : 0;
  }

  // Username change tracking
  List<DateTime> usernameChangeHistory;
  int get remainingUsernameChanges {
    // Filter for changes in the last 30 days
    final changesInLast30Days = usernameChangeHistory
        .where(
            (date) => date.isAfter(DateTime.now().subtract(Duration(days: 30))))
        .length;
    // Allow 2 changes per 30 days
    return 2 - changesInLast30Days;
  }

  // Gender information
  GenderOption? gender;
  String? genderSubOption;
  SexualityOption? sexuality;

  // Looking for options
  List<LookingForOption> lookingFor;

  // Occupation
  String? jobTitle;
  String? company;

  // Education
  List<EducationLevel> educationLevels;
  String? school;

  // Location
  double? latitude;
  double? longitude;

  // Physical attributes
  int? height;

  // Other fields
  String? bio;
  ZodiacSign? zodiacSign;
  List<Interest> interests;
  List<PetOption> pets;
  List<CommunicationStyle> communicationStyles;
  List<LoveLanguage> loveLanguages;
  DrinkingHabit? drinkingHabit;
  SmokingHabit? smokingHabit;
  WorkoutHabit? workoutHabit;
  DietaryPreference? dietaryPreference;
  SleepingHabit? sleepingHabit;
  FamilyPlanOption? familyPlan;

  // Add validation methods
  bool get isValid => _validateRequiredFields().isEmpty;

  List<String> _validateRequiredFields() {
    List<String> errors = [];

    if (displayName.trim().isEmpty) {
      errors.add('Display name is required');
    }

    if (username == null || username!.trim().isEmpty) {
      errors.add('Username is required');
    }

    // Make these validations conditional for profile updates but not initial creation
    bool isStrictValidation =
        lastActive.difference(DateTime.now()).inDays.abs() > 1;

    if (isStrictValidation) {
      if (dateOfBirth == null) {
        errors.add('Date of birth is required');
      }

      if (gender == null) {
        errors.add('Gender is required');
      }

      if (lookingFor.isEmpty) {
        errors.add('Looking for is required');
      }

      if (mainPhotoUrl == null) {
        errors.add('Main profile photo is required');
      }
    }

    return errors;
  }

  // Add method to check if profile is complete for first time creation
  bool get isProfileComplete => isValid;

  // Add method to get validation errors
  List<String> getValidationErrors() => _validateRequiredFields();

  UserProfile({
    required this.uid,
    required this.displayName,
    required this.username,
    this.dateOfBirth,
    required this.lastActive,
    this.gender,
    this.genderSubOption,
    this.sexuality,
    required this.lookingFor,
    this.jobTitle,
    this.company,
    this.educationLevels = const [],
    this.school,
    this.mainPhotoUrl,
    this.additionalPhotos = const [],
    this.latitude,
    this.longitude,
    this.height,
    this.bio,
    this.zodiacSign,
    this.interests = const [],
    this.pets = const [],
    this.communicationStyles = const [],
    this.loveLanguages = const [],
    this.drinkingHabit,
    this.smokingHabit,
    this.workoutHabit,
    this.dietaryPreference,
    this.sleepingHabit,
    this.familyPlan,
    this.usernameChangeHistory = const [],
    this.scheduledForDeletion = false,
    this.deletionScheduledAt,
  }) {
    // Validate required fields in constructor
    final errors = _validateRequiredFields();
    if (errors.isNotEmpty) {
      throw ArgumentError('Invalid profile: ${errors.join(', ')}');
    }
  }

  // Create a UserProfile from a Firebase User
  factory UserProfile.fromFirebaseUser(User user) {
    return UserProfile(
      uid: user.uid,
      displayName: user.displayName ?? '',
      username: user.uid, // Temporary username, should be changed by user
      dateOfBirth: DateTime.now(),
      lastActive: DateTime.now(),
      gender: GenderOption.man,
      lookingFor: [LookingForOption.notSureYet],
      additionalPhotos: [],
      interests: [],
      pets: [],
      educationLevels: [],
      communicationStyles: [],
      loveLanguages: [],
      mainPhotoUrl: user.photoURL,
    );
  }

  // Convert UserProfile to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'displayName': displayName,
      'username': username,
      'photoURL': mainPhotoUrl,
      'additionalPhotos': additionalPhotos,
      'bio': bio,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'location': GeoPoint(latitude ?? 0, longitude ?? 0),
      'height': height,
      'interests': interests.map((e) => e.name).toList(),
      'createdAt': DateTime.now().toIso8601String(),
      'lastUpdated': DateTime.now().toIso8601String(),
      'lastActive': lastActive.toIso8601String(),
      'gender': gender?.name,
      'genderSubOption': genderSubOption,
      'sexuality': sexuality?.name,
      'lookingFor': lookingFor.map((e) => e.name).toList(),
      'jobTitle': jobTitle,
      'company': company,
      'school': school,
      'educationLevels': educationLevels.map((e) => e.name).toList(),
      'zodiacSign': zodiacSign?.name,
      'pets': pets.map((e) => e.name).toList(),
      'communicationStyles': communicationStyles.map((e) => e.name).toList(),
      'loveLanguages': loveLanguages.map((e) => e.name).toList(),
      'drinkingHabit': drinkingHabit?.name,
      'smokingHabit': smokingHabit?.name,
      'workoutHabit': workoutHabit?.name,
      'dietaryPreference': dietaryPreference?.name,
      'sleepingHabit': sleepingHabit?.name,
      'familyPlan': familyPlan?.name,
      'usernameChangeHistory':
          usernameChangeHistory.map((e) => e.toIso8601String()).toList(),
      'scheduledForDeletion': scheduledForDeletion,
      'deletionScheduledAt': deletionScheduledAt?.toIso8601String(),
    };
  }

  // Create a UserProfile from a Firestore document
  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final location = map['location'] as GeoPoint?;
    final dateOfBirth = map['dateOfBirth'] != null
        ? DateTime.parse(map['dateOfBirth'] as String)
        : null;
    final lastActive = map['lastActive'] != null
        ? DateTime.parse(map['lastActive'] as String)
        : DateTime.now();
    final deletionScheduledAt = map['deletionScheduledAt'] != null
        ? DateTime.parse(map['deletionScheduledAt'] as String)
        : null;
    final gender = map['gender'] != null
        ? GenderOption.values.firstWhere(
            (e) => e.name == (map['gender'] as String),
            orElse: () => GenderOption.man)
        : null;
    final sexuality = map['sexuality'] != null
        ? SexualityOption.values.firstWhere(
            (e) => e.name == (map['sexuality'] as String),
            orElse: () => SexualityOption.straight)
        : null;
    final lookingFor = ((map['lookingFor'] as List?) ?? [])
        .map((e) => LookingForOption.values.firstWhere((opt) => opt.name == e,
            orElse: () => LookingForOption.notSureYet))
        .toList();

    if (lookingFor.isEmpty) {
      lookingFor.add(LookingForOption.notSureYet);
    }

    // Parse username change history
    final usernameChangeHistory =
        ((map['usernameChangeHistory'] as List?) ?? [])
            .map((e) => DateTime.parse(e as String))
            .toList();

    return UserProfile(
      uid: map['uid'] as String? ?? '',
      displayName: map['displayName'] as String? ?? '',
      username: map['username'] as String? ??
          map['uid'] as String? ??
          '', // Fallback to uid if username not set
      dateOfBirth: dateOfBirth,
      lastActive: lastActive,
      scheduledForDeletion: map['scheduledForDeletion'] as bool? ?? false,
      deletionScheduledAt: deletionScheduledAt,
      gender: gender,
      genderSubOption: map['genderSubOption'] as String?,
      sexuality: sexuality,
      lookingFor: lookingFor,
      jobTitle: map['jobTitle'] as String?,
      company: map['company'] as String?,
      school: map['school'] as String?,
      educationLevels: ((map['educationLevels'] as List?) ?? [])
          .map((e) => EducationLevel.values.firstWhere(
              (level) => level.name == e,
              orElse: () => EducationLevel.highSchool))
          .toList(),
      mainPhotoUrl: map['photoURL'] as String?,
      additionalPhotos: List<String>.from(map['additionalPhotos'] ?? []),
      latitude: location?.latitude,
      longitude: location?.longitude,
      height: map['height'] as int?,
      bio: map['bio'] as String?,
      zodiacSign: map['zodiacSign'] != null
          ? ZodiacSign.values.firstWhere(
              (e) => e.name == (map['zodiacSign'] as String),
              orElse: () => ZodiacSign.aries)
          : null,
      interests: ((map['interests'] as List?) ?? [])
          .map((e) => Interest.values.firstWhere(
              (interest) => interest.name == e,
              orElse: () => Interest.placeholder))
          .toList(),
      pets: ((map['pets'] as List?) ?? [])
          .map((e) => PetOption.values.firstWhere((pet) => pet.name == e,
              orElse: () => PetOption.other))
          .toList(),
      communicationStyles: ((map['communicationStyles'] as List?) ?? [])
          .map((e) => CommunicationStyle.values.firstWhere(
              (style) => style.name == e,
              orElse: () => CommunicationStyle.betterInPerson))
          .toList(),
      loveLanguages: ((map['loveLanguages'] as List?) ?? [])
          .map((e) => LoveLanguage.values.firstWhere((lang) => lang.name == e,
              orElse: () => LoveLanguage.qualityTime))
          .toList(),
      drinkingHabit: map['drinkingHabit'] != null
          ? DrinkingHabit.values.firstWhere(
              (e) => e.name == (map['drinkingHabit'] as String),
              orElse: () => DrinkingHabit.notForMe)
          : null,
      smokingHabit: map['smokingHabit'] != null
          ? SmokingHabit.values.firstWhere(
              (e) => e.name == (map['smokingHabit'] as String),
              orElse: () => SmokingHabit.nonSmoker)
          : null,
      workoutHabit: map['workoutHabit'] != null
          ? WorkoutHabit.values.firstWhere(
              (e) => e.name == (map['workoutHabit'] as String),
              orElse: () => WorkoutHabit.sometimes)
          : null,
      dietaryPreference: map['dietaryPreference'] != null
          ? DietaryPreference.values.firstWhere(
              (e) => e.name == (map['dietaryPreference'] as String),
              orElse: () => DietaryPreference.omnivore)
          : null,
      sleepingHabit: map['sleepingHabit'] != null
          ? SleepingHabit.values.firstWhere(
              (e) => e.name == (map['sleepingHabit'] as String),
              orElse: () => SleepingHabit.inSpectrum)
          : null,
      familyPlan: map['familyPlan'] != null
          ? FamilyPlanOption.values.firstWhere(
              (e) => e.name == (map['familyPlan'] as String),
              orElse: () => FamilyPlanOption.notSureYet)
          : null,
      usernameChangeHistory: usernameChangeHistory,
    );
  }

  // Create a copy of UserProfile with some updated fields
  UserProfile copyWith({
    String? uid,
    String? displayName,
    String? username,
    DateTime? dateOfBirth,
    DateTime? lastActive,
    GenderOption? gender,
    String? genderSubOption,
    SexualityOption? sexuality,
    List<LookingForOption>? lookingFor,
    String? jobTitle,
    String? company,
    List<EducationLevel>? educationLevels,
    String? school,
    String? mainPhotoUrl,
    List<String>? additionalPhotos,
    double? latitude,
    double? longitude,
    int? height,
    String? bio,
    ZodiacSign? zodiacSign,
    List<Interest>? interests,
    List<PetOption>? pets,
    List<CommunicationStyle>? communicationStyles,
    List<LoveLanguage>? loveLanguages,
    DrinkingHabit? drinkingHabit,
    SmokingHabit? smokingHabit,
    WorkoutHabit? workoutHabit,
    DietaryPreference? dietaryPreference,
    SleepingHabit? sleepingHabit,
    FamilyPlanOption? familyPlan,
    List<DateTime>? usernameChangeHistory,
    bool? scheduledForDeletion,
    DateTime? deletionScheduledAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      username: username ?? this.username,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      lastActive: lastActive ?? this.lastActive,
      gender: gender ?? this.gender,
      genderSubOption: genderSubOption ?? this.genderSubOption,
      sexuality: sexuality ?? this.sexuality,
      lookingFor: lookingFor ?? List<LookingForOption>.from(this.lookingFor),
      jobTitle: jobTitle ?? this.jobTitle,
      company: company ?? this.company,
      school: school ?? this.school,
      educationLevels:
          educationLevels ?? List<EducationLevel>.from(this.educationLevels),
      mainPhotoUrl: mainPhotoUrl ?? this.mainPhotoUrl,
      additionalPhotos:
          additionalPhotos ?? List<String>.from(this.additionalPhotos),
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      height: height ?? this.height,
      bio: bio ?? this.bio,
      zodiacSign: zodiacSign ?? this.zodiacSign,
      interests: interests ?? List<Interest>.from(this.interests),
      pets: pets ?? List<PetOption>.from(this.pets),
      communicationStyles: communicationStyles ??
          List<CommunicationStyle>.from(this.communicationStyles),
      loveLanguages:
          loveLanguages ?? List<LoveLanguage>.from(this.loveLanguages),
      drinkingHabit: drinkingHabit ?? this.drinkingHabit,
      smokingHabit: smokingHabit ?? this.smokingHabit,
      workoutHabit: workoutHabit ?? this.workoutHabit,
      dietaryPreference: dietaryPreference ?? this.dietaryPreference,
      sleepingHabit: sleepingHabit ?? this.sleepingHabit,
      familyPlan: familyPlan ?? this.familyPlan,
      usernameChangeHistory: usernameChangeHistory ??
          List<DateTime>.from(this.usernameChangeHistory),
      scheduledForDeletion: scheduledForDeletion ?? this.scheduledForDeletion,
      deletionScheduledAt: deletionScheduledAt ?? this.deletionScheduledAt,
    );
  }

  // Add logic to handle optional sub-choices for gender
  String get displayGender {
    if (genderSubOption != null) return genderSubOption!;
    return gender?.display ?? '';
  }

  double calculateDistanceTo(double otherLat, double otherLng) {
    if (latitude == null || longitude == null) return 0;

    const double earthRadius = 6371; // Earth's radius in kilometers

    // Convert latitude and longitude to radians
    final lat1 = latitude! * (pi / 180);
    final lon1 = longitude! * (pi / 180);
    final lat2 = otherLat * (pi / 180);
    final lon2 = otherLng * (pi / 180);

    // Haversine formula
    final dLat = lat2 - lat1;
    final dLon = lon2 - lon1;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1) * cos(lat2) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    final distance = earthRadius * c;

    return double.parse(
        distance.toStringAsFixed(1)); // Round to 1 decimal place
  }

  static UserProfile createEmpty(String uid) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    return UserProfile(
      uid: uid,
      username:
          "user_" + timestamp.toString(), // Set a temporary unique username
      displayName: "New User", // Set a default display name
      dateOfBirth: null,
      lastActive: DateTime.now(),
      gender: null,
      lookingFor: [], // Empty lookingFor
      additionalPhotos: [],
      interests: [],
      pets: [],
      educationLevels: [],
      communicationStyles: [],
      loveLanguages: [],
      usernameChangeHistory: [],
    );
  }
}
