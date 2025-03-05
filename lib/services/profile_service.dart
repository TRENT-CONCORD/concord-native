import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Collection reference
  CollectionReference get _profiles => _firestore.collection('profiles');

  // Create or update a user profile
  Future<void> updateProfile(UserProfile profile) async {
    await _profiles.doc(profile.uid).set(profile.toMap());
  }

  // Get a user profile by ID
  Future<UserProfile?> getProfile(String uid) async {
    final doc = await _profiles.doc(uid).get();
    if (!doc.exists) return null;
    return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
  }

  // Upload a profile picture and return the URL
  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    final ref = _storage.ref().child('profile_pictures/$uid.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Upload an additional profile picture and return the URL
  Future<String> uploadAdditionalPhoto(String uid, File imageFile, int index) async {
    final ref = _storage.ref().child('profile_pictures/$uid/additional_$index.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Delete a profile picture
  Future<void> deleteProfilePicture(String uid) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$uid.jpg');
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }

  // Delete an additional profile picture
  Future<void> deleteAdditionalPhoto(String uid, int index) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$uid/additional_$index.jpg');
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive(String uid) async {
    await _profiles.doc(uid).update({
      'lastActive': DateTime.now().toIso8601String(),
    });
  }

  // Update profile completion status
  Future<void> updateProfileCompletion(String uid) async {
    final profile = await getProfile(uid);
    if (profile != null) {
      final isComplete = _checkProfileCompletion(profile);
      if (isComplete != profile.isProfileComplete) {
        await updateProfile(profile.copyWith(isProfileComplete: isComplete));
      }
    }
  }

  // Check if a profile is complete
  bool _checkProfileCompletion(UserProfile profile) {
    return profile.displayName.isNotEmpty &&
           profile.photoURL != null &&
           profile.bio != null &&
           profile.bio!.isNotEmpty &&
           profile.dateOfBirth != null &&
           profile.location != null &&
           profile.gender != null &&
           profile.orientation != null &&
           profile.heightCm != null &&
           profile.occupation != null &&
           profile.education != null &&
           profile.interests.isNotEmpty;
  }

  // Stream of profile updates
  Stream<UserProfile?> profileStream(String uid) {
    return _profiles.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  // Update Firestore document with new image URL
  Future<void> updateAdditionalPhotos(String uid, String url) async {
    await _profiles.doc(uid).update({'additionalPhotos': FieldValue.arrayUnion([url])});
  }
} 