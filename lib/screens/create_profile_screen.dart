import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';
import 'package:concord/screens/profile_screen.dart';
import 'dart:io';

class CreateProfileScreen extends StatefulWidget {
  final String uid;

  const CreateProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _profileService = ProfileService();

  String? _displayName;
  String? _bio;
  DateTime? _dateOfBirth;
  String? _gender;
  String? _zodiacSign;
  String? _education;
  String? _familyPlans;
  String? _communicationStyle;
  String? _loveLanguage;
  String? _drinkingHabits;
  String? _smokingHabits;
  String? _workoutHabits;
  String? _dietaryPreference;
  String? _sleepingHabits;
  List<String> _pets = [];
  List<String> _interests = [];
  String? _profileImage;
  List<String> _additionalPhotos = [];

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      final newProfile = UserProfile(
        uid: widget.uid,
        displayName: _displayName!,
        bio: _bio,
        dateOfBirth: _dateOfBirth,
        gender: _gender,
        zodiacSign: _zodiacSign,
        education: _education,
        familyPlans: _familyPlans,
        communicationStyle: _communicationStyle,
        loveLanguage: _loveLanguage,
        drinkingHabits: _drinkingHabits,
        smokingHabit: _smokingHabits,
        activityLevel: _workoutHabits,
        dietaryPreference: _dietaryPreference,
        sleepingHabits: _sleepingHabits,
        pets: _pets,
        interests: _interests,
        createdAt: DateTime.now(),
        lastUpdated: DateTime.now(),
        lastActive: DateTime.now(),
        additionalPhotos: _additionalPhotos,
      );
      await _profileService.updateProfile(newProfile);
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ProfileScreen(uid: widget.uid),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: _profileImage != null
                      ? FileImage(File(_profileImage!))
                      : null,
                  child: _profileImage == null
                      ? Icon(Icons.camera_alt, size: 50)
                      : null,
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(labelText: 'Display Name'),
                validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                onSaved: (value) => _displayName = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Bio'),
                onSaved: (value) => _bio = value,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Date of Birth'),
                onTap: () async {
                  FocusScope.of(context).requestFocus(FocusNode());
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime(2000),
                    firstDate: DateTime(1900),
                    lastDate: DateTime.now(),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dateOfBirth = pickedDate;
                    });
                  }
                },
                readOnly: true,
                controller: TextEditingController(
                  text: _dateOfBirth != null
                      ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                      : '',
                ),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                items: ['Man', 'Woman', 'Beyond Binary']
                    .map((gender) => DropdownMenuItem(
                          value: gender,
                          child: Text(gender),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _gender = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Zodiac Sign'),
                items: [
                  'Aries', 'Taurus', 'Gemini', 'Cancer', 'Leo', 'Virgo',
                  'Libra', 'Scorpio', 'Sagittarius', 'Capricorn', 'Aquarius', 'Pisces'
                ].map((sign) => DropdownMenuItem(
                      value: sign,
                      child: Text(sign),
                    ))
                    .toList(),
                onChanged: (value) => setState(() => _zodiacSign = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Education'),
                items: [
                  'High School', 'In College/Uni', 'In Grad School', 'Trade School',
                  'Higher Certificate', 'Bachelors', 'Honours', 'Masters', 'PhD'
                ].map((level) => DropdownMenuItem(
                      value: level,
                      child: Text(level),
                    ))
                    .toList(),
                onChanged: (value) => setState(() => _education = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Family Plans'),
                items: [
                  'Not sure yet', 'I want children', "I don't want children",
                  'I have children and want more', "I have children and don't want more"
                ].map((plan) => DropdownMenuItem(
                      value: plan,
                      child: Text(plan),
                    ))
                    .toList(),
                onChanged: (value) => setState(() => _familyPlans = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Drinking Habits'),
                items: [
                  'Not for me', 'Sober', 'Sober curious', 'On special occasions',
                  'Socially on some weekends', 'Socially on most weekends', 'Most nights'
                ].map((habit) => DropdownMenuItem(
                      value: habit,
                      child: Text(habit),
                    ))
                    .toList(),
                onChanged: (value) => setState(() => _drinkingHabits = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Smoking Habits'),
                items: [
                  'Social smoker', 'Smoker when drinking', 'Non-smoker',
                  'Smoker', 'Trying to quit'
                ].map((habit) => DropdownMenuItem(
                      value: habit,
                      child: Text(habit),
                    ))
                    .toList(),
                onChanged: (value) => setState(() => _smokingHabits = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Workout Habits'),
                items: ['Everyday', 'Often', 'Sometimes', 'Never']
                    .map((habit) => DropdownMenuItem(
                          value: habit,
                          child: Text(habit),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _workoutHabits = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Dietary Preference'),
                items: [
                  'Vegan', 'Vegetarian', 'Pescatarian', 'Kosher', 'Halal',
                  'Carnivore', 'Omnivore', 'Other'
                ].map((preference) => DropdownMenuItem(
                      value: preference,
                      child: Text(preference),
                    ))
                    .toList(),
                onChanged: (value) => setState(() => _dietaryPreference = value),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Sleeping Habits'),
                items: ['Early bird', 'Night owl', 'In a spectrum']
                    .map((habit) => DropdownMenuItem(
                          value: habit,
                          child: Text(habit),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _sleepingHabits = value),
              ),
              Column(
                children: [
                  Text('Communication Style'),
                  ...['Big time texter', 'Phone caller', 'Video chatter', 'Bad texter', 'Better in person']
                      .map((style) => CheckboxListTile(
                            title: Text(style),
                            value: _communicationStyle?.contains(style) ?? false,
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _communicationStyle = (_communicationStyle ?? '') + ', ' + style;
                                } else {
                                  _communicationStyle = _communicationStyle?.replaceAll(', ' + style, '');
                                }
                              });
                            },
                          ))
                      .toList(),
                ],
              ),
              Column(
                children: [
                  Text('Love Language'),
                  ...['Thoughtful gestures', 'Gifts', 'Touch', 'Compliments', 'Quality time']
                      .map((language) => CheckboxListTile(
                            title: Text(language),
                            value: _loveLanguage?.contains(language) ?? false,
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _loveLanguage = (_loveLanguage ?? '') + ', ' + language;
                                } else {
                                  _loveLanguage = _loveLanguage?.replaceAll(', ' + language, '');
                                }
                              });
                            },
                          ))
                      .toList(),
                ],
              ),
              Column(
                children: [
                  Text('Pets'),
                  ...['Dog', 'Cat', 'Reptile', 'Amphibian', 'Bird', 'Fish', "Don't have but love", 'Turtle', 'Hamster', 'Rabbit', 'Other', 'Pet-free', 'All the pets', 'Want a pet', 'Allergic to pets']
                      .map((pet) => CheckboxListTile(
                            title: Text(pet),
                            value: _pets.contains(pet),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _pets.add(pet);
                                } else {
                                  _pets.remove(pet);
                                }
                              });
                            },
                          ))
                      .toList(),
                ],
              ),
              Column(
                children: [
                  Text('Interests'),
                  ...['Hiking', 'Reading', 'Traveling', 'Cooking', 'Music', 'Movies', 'Sports', 'Gaming', 'Art', 'Technology']
                      .map((interest) => CheckboxListTile(
                            title: Text(interest),
                            value: _interests.contains(interest),
                            onChanged: (bool? selected) {
                              setState(() {
                                if (selected == true) {
                                  _interests.add(interest);
                                } else {
                                  _interests.remove(interest);
                                }
                              });
                            },
                          ))
                      .toList(),
                ],
              ),
              ElevatedButton(
                onPressed: _saveProfile,
                child: Text('Save Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 