import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../main.dart'; // Import to access enableFirebase flag

class AuthService {
  // Create a Firebase Auth instance only if Firebase is enabled
  final FirebaseAuth? _auth = enableFirebase ? FirebaseAuth.instance : null;
  final FirebaseFirestore? _firestore =
      enableFirebase ? FirebaseFirestore.instance : null;

  // Get current user
  User? get currentUser => _auth?.currentUser;

  // Auth state changes stream
  Stream<User?>? get authStateChanges => _auth?.authStateChanges();

  // Sign in with email and password
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!enableFirebase) {
      // Simulate successful sign-in for development
      debugPrint('DEV MODE: Simulating sign in for $email');
      return null;
    }

    try {
      return await _auth!.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Error signing in: $e');
      rethrow;
    }
  }

  // Register with email and password
  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    if (!enableFirebase) {
      // Simulate successful registration for development
      debugPrint('DEV MODE: Simulating registration for $email');
      return null;
    }

    try {
      // In debug mode, we bypass reCAPTCHA verification
      if (kDebugMode) {
        // Make sure settings are applied
        await _auth!.setSettings(
          appVerificationDisabledForTesting: true,
          phoneNumber: null,
          smsCode: null,
          forceRecaptchaFlow: false,
        );
      }

      // Attempt registration
      final result = await _auth!.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } catch (e) {
      debugPrint('Auth error: $e');
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    if (!enableFirebase) {
      debugPrint('DEV MODE: Simulating sign out');
      return;
    }

    try {
      // Clear any material banners before signing out
      await _auth!.signOut();
      debugPrint('User signed out');
    } catch (e) {
      debugPrint('Error signing out: $e');
      throw e;
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      // Get current user
      final user = _auth?.currentUser;
      if (user != null) {
        debugPrint('Processing account deletion for: ${user.email}');

        // Instead of deleting the account immediately, just sign the user out
        // The actual deletion will happen after the 90-day grace period
        // The profile data is already marked for deletion in ProfileService.deleteProfile
        await _auth!.signOut();
        debugPrint('User signed out as part of account deletion process');

        // Note: We're NOT calling user.delete() here anymore
        // This allows users to log back in during the 90-day period to restore their account
      } else {
        throw Exception('No user is currently signed in');
      }
    } catch (e) {
      debugPrint('Error in deletion process: $e');
      throw _handleAuthException(e);
    }
  }

  // Check if a user is in the deletion period during sign in
  Future<Map<String, dynamic>> checkDeletionStatusDuringSignIn(
      User user) async {
    if (!enableFirebase) {
      // Return a default response for development
      return {
        'scheduledForDeletion': false,
        'daysRemaining': 0,
      };
    }

    try {
      final docSnapshot =
          await _firestore!.collection('deletionRequests').doc(user.uid).get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;
        final deletionTimestamp = data['deletionTimestamp'] as Timestamp;
        final currentTime = Timestamp.now();

        // Calculate days remaining until deletion
        final difference =
            deletionTimestamp.toDate().difference(currentTime.toDate());
        final daysRemaining = difference.inDays;

        return {
          'scheduledForDeletion': true,
          'daysRemaining': daysRemaining,
        };
      }

      return {
        'scheduledForDeletion': false,
        'daysRemaining': 0,
      };
    } catch (e) {
      debugPrint('Error checking deletion status: $e');
      // In case of error, return false to prevent blocking sign-in
      return {
        'scheduledForDeletion': false,
        'daysRemaining': 0,
      };
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      switch (e.code) {
        case 'weak-password':
          return 'The password provided is too weak.';
        case 'email-already-in-use':
          return 'An account already exists for that email.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user has been disabled.';
        case 'user-not-found':
          return 'No user found for that email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'operation-not-allowed':
          return 'Email/password accounts are not enabled.';
        case 'network-request-failed':
          return 'Network error occurred. Please check your internet connection.';
        case 'too-many-requests':
          return 'Too many unsuccessful attempts. Please try again later.';
        case 'internal-error':
          return 'An internal authentication error occurred. Please try again.';
        default:
          if (e.message != null && e.message.toString().contains('recaptcha')) {
            return 'reCAPTCHA verification failed. Please try again.';
          }
          return 'Authentication error: ${e.message}';
      }
    }
    return e.toString();
  }

  // Check if the user needs to be reauthenticated (if their last login was too long ago)
  Future<bool> needsReauthentication() async {
    try {
      final user = _auth?.currentUser;
      if (user == null) return true;

      // Get the user's metadata
      final metadata = user.metadata;
      final lastSignInTime = metadata.lastSignInTime;

      if (lastSignInTime == null) return true;

      // Calculate the time elapsed since last sign-in
      final now = DateTime.now();
      final elapsed = now.difference(lastSignInTime);

      // If the user hasn't signed in within the last hour, require reauthentication
      // This is a conservative approach for security-sensitive operations
      debugPrint(
          'Time since last authentication: ${elapsed.inMinutes} minutes');
      return elapsed.inMinutes > 60;
    } catch (e) {
      debugPrint('Error checking reauthentication need: $e');
      return true; // Default to requiring reauthentication on error
    }
  }

  // Reauthenticate user (needed for security-sensitive operations like account deletion)
  Future<void> reauthenticate(String email, String password) async {
    try {
      // Get current user
      final user = _auth?.currentUser;
      if (user == null) {
        throw Exception('No user is currently signed in');
      }

      debugPrint('Attempting to reauthenticate user: ${user.email}');

      // Check if the email matches the current user's email
      if (user.email != email) {
        debugPrint('Email mismatch: ${user.email} vs $email');
        throw FirebaseAuthException(
            code: 'email-mismatch',
            message: 'The email address doesn\'t match the current user');
      }

      // Create credential
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      // Reauthenticate
      debugPrint('Sending reauthentication request to Firebase');
      await user.reauthenticateWithCredential(credential);
      debugPrint('User reauthenticated successfully');
    } catch (e) {
      debugPrint('Error reauthenticating: ${e.toString()}');

      // Provide more specific error messages for common cases
      if (e is FirebaseAuthException) {
        if (e.code == 'wrong-password') {
          debugPrint('Wrong password provided for reauthentication');
        } else if (e.code == 'user-mismatch') {
          debugPrint('The credential doesn\'t match the current user');
        } else if (e.code == 'user-not-found') {
          debugPrint('User not found for the provided email');
        } else if (e.code == 'invalid-credential') {
          debugPrint('Invalid credential provided');
        } else {
          debugPrint('Firebase Auth error: ${e.code} - ${e.message}');
        }
      }

      throw _handleAuthException(e);
    }
  }

  // Send account deletion email notification
  Future<void> sendAccountDeletionEmail(String email) async {
    try {
      debugPrint('Sending account deletion email to: $email');

      // TODO: Implement Microsoft/Azure SMTP service integration
      // This is a placeholder for now
      // Will be implemented using Microsoft/Azure SMTP services

      /*
      Example implementation using Azure Communication Services Email API:
      
      final azureEmailClient = AzureEmailClient(
        connectionString: 'your-azure-connection-string',
      );
      
      await azureEmailClient.send(
        sender: 'noreply@concord.app',
        recipients: [email],
        subject: 'Your Concord Account Deletion Confirmation',
        htmlContent: '''
          <div>
            <h2>Account Deletion Scheduled</h2>
            <p>Your account has been scheduled for deletion as requested.</p>
            <p>Your profile and data will be permanently deleted in 90 days.</p>
            <p>If you wish to restore your account, simply log back in within the next 90 days.</p>
            <p>Thank you for using Concord.</p>
          </div>
        ''',
      );
      */

      debugPrint('Account deletion email would be sent to: $email');
    } catch (e) {
      debugPrint('Error sending account deletion email: $e');
      // We don't throw here because this is a non-critical operation
      // The account will still be deleted even if the email fails
    }
  }

  // Request account deletion
  Future<void> requestAccountDeletion(String uid) async {
    if (!enableFirebase) {
      debugPrint('DEV MODE: Simulating account deletion request for $uid');
      return;
    }

    try {
      final now = DateTime.now();
      final deletionDate = now.add(const Duration(days: 30));

      await _firestore!.collection('deletionRequests').doc(uid).set({
        'userId': uid,
        'requestTimestamp': Timestamp.now(),
        'deletionTimestamp': Timestamp.fromDate(deletionDate),
      });
    } catch (e) {
      debugPrint('Error requesting account deletion: $e');
      rethrow;
    }
  }

  // Cancel account deletion
  Future<void> cancelAccountDeletion(String uid) async {
    if (!enableFirebase) {
      debugPrint(
          'DEV MODE: Simulating cancellation of account deletion for $uid');
      return;
    }

    try {
      await _firestore!.collection('deletionRequests').doc(uid).delete();
    } catch (e) {
      debugPrint('Error cancelling account deletion: $e');
      rethrow;
    }
  }
}
