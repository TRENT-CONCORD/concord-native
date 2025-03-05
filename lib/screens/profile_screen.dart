import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:reorderables/reorderables.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../screens/create_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileService = ProfileService();
  UserProfile? _profile;
  bool _isLoading = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final profile = await _profileService.getProfile(widget.uid);
      if (mounted) {
        setState(() {
          _profile = profile;
          _isLoading = false;
        });
        if (_profile == null) {
          debugPrint('No profile found for uid: ${widget.uid}');
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => CreateProfileScreen(uid: widget.uid),
            ),
          );
        } else {
          debugPrint('Profile loaded: ${_profile!.toMap()}');
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        debugPrint('Error loading profile: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profile?.photoURL = pickedFile.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_profile != null) {
      await _profileService.updateProfile(_profile!);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Profile updated successfully')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopSection(),
            SizedBox(height: 16),
            _buildUserDetails(),
            SizedBox(height: 16),
            _buildBio(),
            SizedBox(height: 16),
            _buildPreferences(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopSection() {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _profile?.photoURL != null
                          ? FileImage(File(_profile!.photoURL!)) as ImageProvider<Object>?
                          : AssetImage('assets/placeholder.png'),
                      child: _profile?.photoURL == null
                          ? Icon(Icons.camera_alt, size: 50)
                          : null,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.add_circle, size: 30),
                    onPressed: () {},
                  ),
                ],
              ),
              SizedBox(height: 8),
              Text(
                _profile?.displayName ?? 'User Name',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              Text(
                'Last Active: ${_formatLastActive(_profile?.lastActive)}',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                'Distance: ${_calculateDistance()} km',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserDetails() {
    if (_profile == null) {
      return Center(
        child: Text('Profile data is not available', style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoTile('Gender', _profile?.displayGender),
        _buildInfoTile('Job', _profile?.occupation),
        _buildInfoTile('Education', _profile?.education),
      ],
    );
  }

  Widget _buildPreferences() {
    if (_profile == null) {
      return Center(
        child: Text('Preferences data is not available', style: TextStyle(color: Colors.grey)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSection('Basics', [
          _buildInfoTile('Zodiac Sign', _profile?.zodiacSign),
          _buildInfoTile('Education Level', _profile?.education),
          _buildInfoTile('Family Plans', _profile?.familyPlans),
        ]),
        _buildSection('Lifestyle', [
          _buildInfoTile('Communication Style', _profile?.communicationStyle),
          _buildInfoTile('Love Language', _profile?.loveLanguage),
          _buildInfoTile('Drinking Habits', _profile?.drinkingHabits),
          _buildInfoTile('Smoking Habits', _profile?.smokingHabit),
          _buildInfoTile('Workout Habits', _profile?.activityLevel),
          _buildInfoTile('Dietary Preference', _profile?.dietaryPreference),
          _buildInfoTile('Sleeping Habits', _profile?.sleepingHabits),
        ]),
        _buildSection('Interests', [
          _buildInfoTile('Pets', _profile?.pets.join(', ')),
          _buildInfoTile('Interests', _profile?.interests.join(', ')),
        ]),
      ],
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoTile(String title, String? value) {
    return ListTile(
      title: Text(
        value ?? 'Add $title',
        style: TextStyle(
          color: value != null ? Colors.white : Colors.grey,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.white),
      onTap: () {
        // Navigate to a new screen or show a dialog to edit user details
      },
    );
  }

  String _formatLastActive(DateTime? lastActive) {
    if (lastActive == null) return 'N/A';
    final now = DateTime.now();
    final difference = now.difference(lastActive);
    if (difference.inDays == 0) {
      return 'Today at ${_formatTime(lastActive)}';
    } else if (difference.inDays == 1) {
      return 'Yesterday at ${_formatTime(lastActive)}';
    } else if (difference.inDays < 365) {
      return '${lastActive.day} ${_monthName(lastActive.month)} at ${_formatTime(lastActive)}';
    } else {
      return '${lastActive.day} ${_monthName(lastActive.month)} ${lastActive.year} at ${_formatTime(lastActive)}';
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  String _monthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }

  Widget _buildBio() {
    final bio = _profile?.bio ?? '';
    final displayBio = bio.length <= 200 ? bio : '${bio.substring(0, 200)}...';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          displayBio,
          style: TextStyle(fontSize: 16),
        ),
        if (bio.length > 200)
          TextButton(
            onPressed: () => setState(() => _isExpanded = !_isExpanded),
            child: Text(_isExpanded ? 'Read less' : 'Read more'),
          ),
      ],
    );
  }

  double _calculateDistance() {
    // Placeholder for actual distance calculation
    return 5.0;
  }
} 