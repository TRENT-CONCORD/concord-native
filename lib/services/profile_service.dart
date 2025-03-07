import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class ProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Collection reference
  CollectionReference get _users => _firestore.collection('users');

  // Create or update a user profile with proper error handling
  Future<void> updateProfile(UserProfile profile) async {
    try {
      debugPrint('Updating profile for UID: ${profile.uid}');

      // Prepare profile data
      Map<String, dynamic> data = profile.toMap();

      // Add lowercase username for case-insensitive queries
      if (profile.username != null && profile.username!.isNotEmpty) {
        data['username_lowercase'] = profile.username!.toLowerCase();
      }

      // Check if the profile is newly created
      bool isNewProfile = false;
      try {
        DocumentSnapshot docSnapshot = await _users.doc(profile.uid).get();
        isNewProfile = !docSnapshot.exists;
      } catch (e) {
        debugPrint('Error checking if profile exists: $e');
      }

      // Add creation timestamp for new profiles
      if (isNewProfile) {
        data['createdAt'] = DateTime.now().toIso8601String();
        debugPrint('Creating new profile');

        // For new profiles, set with merge false to ensure a clean creation
        await _users.doc(profile.uid).set(data);
        debugPrint('New profile created successfully');
      } else {
        // For updates, use update to only modify changed fields
        debugPrint('Updating existing profile');
        await _users.doc(profile.uid).update(data);
        debugPrint('Profile updated successfully');
      }
    } catch (e) {
      debugPrint('Error updating profile: $e');

      // Try a more reliable approach if the update fails
      try {
        if (e.toString().contains('NOT_FOUND')) {
          // If document not found, force create it
          await _users.doc(profile.uid).set(profile.toMap());
          debugPrint('Created profile with fallback method');
        } else {
          rethrow;
        }
      } catch (secondError) {
        debugPrint('Secondary error in updateProfile: $secondError');
        rethrow;
      }
    }
  }

  // Get a user profile by ID with better error handling and retry mechanism for pigeon errors
  Future<UserProfile?> getProfile(String uid) async {
    int retryCount = 0;
    const maxRetries = 2;

    while (retryCount <= maxRetries) {
      try {
        if (retryCount > 0) {
          debugPrint('Getting profile for UID: $uid (Retry #$retryCount)');
        } else {
          debugPrint('Getting profile for UID: $uid');
        }
        final doc = await _users.doc(uid).get();

        if (doc.exists && doc.data() != null) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

          // Ensure UID is included in the map
          userData['uid'] = uid;

          debugPrint('Profile found: ${userData.toString()}');
          return UserProfile.fromMap(userData);
        }

        debugPrint('No profile found for UID: $uid');
        return null;
      } catch (e) {
        debugPrint('Error getting profile: $e');

        // Check if this might be a pigeon error that can be retried
        if (e.toString().contains('pigeon') ||
            e.toString().contains('platform channel') ||
            e.toString().contains('App Check token')) {
          retryCount++;

          if (retryCount <= maxRetries) {
            // Add a delay before retrying
            debugPrint('Retrying profile fetch in 500ms...');
            await Future.delayed(Duration(milliseconds: 500 * retryCount));
            continue;
          }
        }

        // If not a pigeon error or max retries reached, rethrow
        rethrow;
      }
    }

    // This should never happen but return null just in case
    return null;
  }

  // Upload a profile picture
  Future<String> uploadProfilePicture(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_pictures/$uid.jpg');
      await ref.putFile(imageFile);
      final url = await ref.getDownloadURL();
      debugPrint('Profile picture uploaded: $url');
      return url;
    } catch (e) {
      debugPrint('Error uploading profile picture: $e');
      rethrow;
    }
  }

  // Upload an additional profile picture and return the URL
  Future<String> uploadAdditionalPhoto(
      String uid, File imageFile, int index) async {
    final ref =
        _storage.ref().child('profile_pictures/$uid/additional_$index.jpg');
    await ref.putFile(imageFile);
    return await ref.getDownloadURL();
  }

  // Delete a profile picture
  Future<void> deleteProfilePicture(String uid) async {
    try {
      debugPrint('Deleting profile picture for user: $uid');
      final ref = _storage.ref().child('profile_pictures/$uid.jpg');
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
      debugPrint('Error or file not found when deleting profile picture: $e');
    }
  }

  // Delete an additional profile picture
  Future<void> deleteAdditionalPhoto(String uid, int index) async {
    try {
      final ref =
          _storage.ref().child('profile_pictures/$uid/additional_$index.jpg');
      await ref.delete();
    } catch (e) {
      // Ignore if file doesn't exist
    }
  }

  // Update last active timestamp
  Future<void> updateLastActive(String uid) async {
    await _users.doc(uid).update({
      'lastActive': DateTime.now().toIso8601String(),
    });
  }

  // Stream of profile updates
  Stream<UserProfile?> profileStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (!doc.exists) return null;
      return UserProfile.fromMap(doc.data() as Map<String, dynamic>);
    });
  }

  // Update Firestore document with new image URL
  Future<void> updateAdditionalPhotos(String uid, String url) async {
    await _users.doc(uid).update({
      'additionalPhotos': FieldValue.arrayUnion([url])
    });
  }

  // Check if username is available
  Future<bool> isUsernameAvailable(String username) async {
    try {
      // Normalize the username
      final String normalizedUsername = username.trim().toLowerCase();
      debugPrint('Checking availability for username: $normalizedUsername');

      // Query for existing username
      final querySnapshot = await _users
          .where('username_lowercase', isEqualTo: normalizedUsername)
          .get();

      // If no documents found, username is available
      final bool isAvailable = querySnapshot.docs.isEmpty;
      debugPrint('Username available: $isAvailable');
      return isAvailable;
    } catch (e) {
      debugPrint('Error checking username availability: $e');
      return false; // Assume not available in case of error
    }
  }

  // Update username with change limit enforcement
  Future<Map<String, dynamic>> updateUsername(
      String uid, String newUsername) async {
    try {
      // First, check if the username is available
      if (!await isUsernameAvailable(newUsername)) {
        return {
          'success': false,
          'message': 'Username already taken',
        };
      }

      // Get the current profile to check username change history
      final currentProfile = await getProfile(uid);
      if (currentProfile == null) {
        return {
          'success': false,
          'message': 'Profile not found',
        };
      }

      // Check if user has any username changes left in the 30-day period
      if (currentProfile.remainingUsernameChanges <= 0) {
        return {
          'success': false,
          'message':
              'You\'ve reached the limit of 2 username changes in 30 days',
        };
      }

      // Add the current date to the username change history
      List<DateTime> updatedHistory =
          List.from(currentProfile.usernameChangeHistory);
      updatedHistory.add(DateTime.now());

      // Update the profile with new username and updated history
      await _users.doc(uid).update({
        'username': newUsername,
        'username_lowercase': newUsername.toLowerCase(),
        'usernameChangeHistory':
            updatedHistory.map((dt) => dt.toIso8601String()).toList(),
      });

      return {
        'success': true,
        'message': 'Username updated successfully',
        'remainingChanges': currentProfile.remainingUsernameChanges - 1,
      };
    } catch (e) {
      debugPrint('Error updating username: $e');
      return {
        'success': false,
        'message': 'Error updating username: $e',
      };
    }
  }

  // Get the number of remaining username changes for a user
  Future<int> getRemainingUsernameChanges(String uid) async {
    try {
      final profile = await getProfile(uid);
      if (profile == null) return 2; // Default if no profile
      return profile.remainingUsernameChanges;
    } catch (e) {
      debugPrint('Error getting remaining username changes: $e');
      return 0; // Conservative fallback
    }
  }

  // Get the date when username changes will reset
  Future<DateTime?> getNextUsernameChangeResetDate(String uid) async {
    try {
      final profile = await getProfile(uid);
      if (profile == null) return null;

      // If there are no changes in history, return null
      if (profile.usernameChangeHistory.isEmpty) return null;

      // Find the oldest change within the last 30 days
      final changesInLast30Days = profile.usernameChangeHistory
          .where((date) =>
              date.isAfter(DateTime.now().subtract(Duration(days: 30))))
          .toList();

      if (changesInLast30Days.isEmpty) return null;

      // Sort changes to find the earliest one
      changesInLast30Days.sort();
      final oldestChange = changesInLast30Days.first;

      // The reset date is 30 days after the oldest change
      return oldestChange.add(Duration(days: 30));
    } catch (e) {
      debugPrint('Error getting username change reset date: $e');
      return null;
    }
  }

  // Delete a user's profile completely
  Future<void> deleteProfile(String uid) async {
    try {
      debugPrint('Starting deletion of profile with UID: $uid');

      // Instead of immediately deleting, mark the profile for deletion
      await _users.doc(uid).update({
        'scheduledForDeletion': true,
        'deletionScheduledAt': DateTime.now().toIso8601String(),
      });

      debugPrint(
          'Profile marked for deletion. Will be permanently deleted in 90 days.');
      return;
    } catch (e) {
      debugPrint('Error marking profile for deletion: $e');
      throw 'Failed to mark profile for deletion: ${e.toString()}';
    }
  }

  // Cancel scheduled deletion for a user profile
  Future<void> cancelDeletion(String uid) async {
    try {
      debugPrint('Cancelling scheduled deletion for profile with UID: $uid');

      // Verify user is authenticated before attempting operation
      if (_auth.currentUser == null) {
        throw 'Authentication required to cancel deletion. Please sign in first.';
      }

      // There are two possible cases:
      // 1. User is restoring their own account - UID matches current user
      // 2. Admin is restoring someone's account - should use a separate admin flag

      // For now, we'll be lenient and allow the operation regardless of UID mismatch
      // In a production app, you'd want proper role-based authorization

      try {
        // First try the basic update approach
        await _users.doc(uid).update({
          'scheduledForDeletion': false,
          'deletionScheduledAt': null,
        });
        debugPrint('Successfully cancelled deletion with simple update');
        return;
      } catch (updateError) {
        // If simple update fails, try with transaction
        debugPrint('Simple update failed, trying transaction: $updateError');

        await _firestore.runTransaction((transaction) async {
          // Get the current document first
          final docRef = _users.doc(uid);
          final docSnapshot = await transaction.get(docRef);

          if (!docSnapshot.exists) {
            throw 'Profile not found';
          }

          // Update the document
          transaction.update(docRef, {
            'scheduledForDeletion': false,
            'deletionScheduledAt': null,
          });
        });
        debugPrint('Successfully cancelled deletion with transaction');
      }

      debugPrint('Profile deletion cancelled successfully');
      return;
    } catch (e) {
      debugPrint('Error cancelling profile deletion: $e');
      throw 'Failed to cancel profile deletion: ${e.toString()}';
    }
  }

  // Check if a user account is scheduled for deletion
  Future<Map<String, dynamic>> checkDeletionStatus(String uid) async {
    try {
      final doc = await _users.doc(uid).get();

      if (!doc.exists || doc.data() == null) {
        return {'scheduledForDeletion': false, 'daysRemaining': 0};
      }

      final data = doc.data() as Map<String, dynamic>;
      final bool isScheduledForDeletion =
          data['scheduledForDeletion'] as bool? ?? false;

      if (!isScheduledForDeletion) {
        return {'scheduledForDeletion': false, 'daysRemaining': 0};
      }

      // Calculate days remaining
      final deletionScheduledAt = data['deletionScheduledAt'] != null
          ? DateTime.parse(data['deletionScheduledAt'] as String)
          : null;

      if (deletionScheduledAt == null) {
        return {
          'scheduledForDeletion': true,
          'daysRemaining': 90 // Default to 90 days if no date is set
        };
      }

      final DateTime deletionDate = deletionScheduledAt.add(Duration(days: 90));

      // Calculate days remaining with the ceiling function to ensure users get the full 90 days
      // This rounds up any partial day to ensure they get at minimum 90 days
      final Duration difference = deletionDate.difference(DateTime.now());

      // Calculate the hours since deletion was scheduled
      final Duration timeElapsed =
          DateTime.now().difference(deletionScheduledAt);
      final int hoursElapsed = timeElapsed.inHours;

      // If deletion was scheduled less than 24 hours ago, always show 90 days
      final int daysRemaining;
      if (hoursElapsed < 24) {
        daysRemaining = 90;
        debugPrint('Deletion scheduled recently, showing exactly 90 days');
      } else {
        daysRemaining = (difference.inHours / 24).ceil();
      }

      debugPrint('Deletion scheduled at: $deletionScheduledAt');
      debugPrint('Deletion will occur on: $deletionDate');
      debugPrint('Time difference in hours: ${difference.inHours}');
      debugPrint('Hours elapsed since scheduling: $hoursElapsed');
      debugPrint('Showing days remaining: $daysRemaining');

      return {
        'scheduledForDeletion': true,
        'daysRemaining': daysRemaining > 0 ? daysRemaining : 0
      };
    } catch (e) {
      debugPrint('Error checking deletion status: $e');
      return {
        'scheduledForDeletion': false,
        'daysRemaining': 0,
        'error': e.toString()
      };
    }
  }

  // Permanently delete a user profile (called by a scheduled job after 90 days)
  Future<void> permanentlyDeleteProfile(String uid) async {
    try {
      debugPrint('Starting permanent deletion of profile with UID: $uid');

      // Step 1: Delete profile photos from storage
      try {
        // Delete main profile photo
        await deleteProfilePicture(uid);

        // Get profile to find additional photos
        final profile = await getProfile(uid);
        if (profile != null) {
          // Delete any additional photos
          for (int i = 0; i < profile.additionalPhotos.length; i++) {
            await deleteAdditionalPhoto(uid, i);
          }
        }

        debugPrint('Successfully deleted profile photos from storage');
      } catch (e) {
        // Continue even if photo deletion fails
        debugPrint('Error deleting profile photos: $e');
      }

      // Step 2: Delete the profile document from Firestore
      await _users.doc(uid).delete();
      debugPrint('Successfully deleted profile document from Firestore');

      return;
    } catch (e) {
      debugPrint('Error permanently deleting profile: $e');
      throw 'Failed to permanently delete profile: ${e.toString()}';
    }
  }

  // Get profiles that are scheduled for deletion
  Future<List<Map<String, dynamic>>> getProfilesScheduledForDeletion() async {
    try {
      // Calculate cutoff date (90 days ago)
      final cutoffDate = DateTime.now().subtract(Duration(days: 90));
      final cutoffDateString = cutoffDate.toIso8601String();

      debugPrint(
          'Getting profiles scheduled for deletion before: $cutoffDateString');

      // Query profiles scheduled for deletion and past the grace period
      final querySnapshot = await _users
          .where('scheduledForDeletion', isEqualTo: true)
          .where('deletionScheduledAt', isLessThanOrEqualTo: cutoffDateString)
          .get();

      if (querySnapshot.docs.isEmpty) {
        debugPrint('No profiles found that are ready for permanent deletion');
        return [];
      }

      // Convert to a more usable format
      final profiles = querySnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['uid'] = doc.id;

        // Calculate days overdue (past the 90-day period)
        if (data['deletionScheduledAt'] != null) {
          final deletionDate = DateTime.parse(data['deletionScheduledAt']);
          final graceEndDate = deletionDate.add(Duration(days: 90));
          final daysOverdue = DateTime.now().difference(graceEndDate).inDays;
          data['daysOverdue'] = daysOverdue > 0 ? daysOverdue : 0;
        } else {
          data['daysOverdue'] = 0;
        }

        return data;
      }).toList();

      debugPrint(
          'Found ${profiles.length} profiles ready for permanent deletion');
      return profiles;
    } catch (e) {
      debugPrint('Error getting profiles scheduled for deletion: $e');
      return [];
    }
  }

  // A method that can be used by admin tools to trigger the cleanup manually
  // This would typically be called from an admin-only interface
  Future<Map<String, dynamic>> manuallyCleanupExpiredAccounts() async {
    try {
      final expiredProfiles = await getProfilesScheduledForDeletion();

      if (expiredProfiles.isEmpty) {
        return {
          'status': 'success',
          'message': 'No accounts found for cleanup',
          'count': 0
        };
      }

      int successCount = 0;
      List<String> errors = [];

      // Process each expired profile
      for (final profile in expiredProfiles) {
        final uid = profile['uid'];
        try {
          await permanentlyDeleteProfile(uid);
          successCount++;
        } catch (e) {
          errors.add('$uid: $e');
        }
      }

      return {
        'status': 'success',
        'message': 'Cleanup completed',
        'totalProcessed': expiredProfiles.length,
        'successCount': successCount,
        'errorCount': errors.length,
        'errors': errors,
      };
    } catch (e) {
      return {
        'status': 'error',
        'message': 'Failed to execute cleanup: $e',
      };
    }
  }
}
