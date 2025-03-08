import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'firebase_options.dart';
import 'screens/landing_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/account_restoration_screen.dart';
import 'services/auth_service.dart';
import 'services/profile_service.dart';
import 'models/user_profile.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart' show kIsWeb, kDebugMode;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_app_check/firebase_app_check.dart';

Future<void> initializeFirebase() async {
  try {
    // Initialize Firebase first
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // Set up debug configurations in debug mode
    if (kDebugMode) {
      debugPrint("Running in debug mode - enabling debug settings");
      // Skip using emulator since we're having connectivity issues
      // Just disable verification instead
      await FirebaseAuth.instance.setSettings(
        appVerificationDisabledForTesting: true,
        phoneNumber: null,
        smsCode: null,
        forceRecaptchaFlow: false,
      );

      // NOTE: Disabling the emulator connections because they're causing issues
      // If you need to use emulators, uncomment these lines
      /*
      try {
        FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
        FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
        debugPrint("Firebase emulators connected");
      } catch (e) {
        debugPrint('Error setting up emulators: $e');
      }
      */
    }

    // Initialize App Check with appropriate provider
    try {
      if (kDebugMode) {
        // Use debug provider for development
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
          appleProvider: AppleProvider.debug,
        );

        // Explicitly set App Verification disabled for testing
        await FirebaseAuth.instance.setSettings(
          appVerificationDisabledForTesting: true,
          phoneNumber: null,
          smsCode: null,
          forceRecaptchaFlow: false,
        );

        debugPrint('Activated Firebase App Check with Debug Provider');
        debugPrint('Disabled app verification for testing mode');
      } else {
        // Use Play Integrity for production
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.playIntegrity,
        );
        debugPrint('Activated Firebase App Check with Play Integrity');
      }

      // Enable token auto-refresh for App Check
      await FirebaseAppCheck.instance.setTokenAutoRefreshEnabled(true);
      debugPrint('App Check token auto-refresh enabled');
    } catch (appCheckError) {
      debugPrint('Error activating App Check: $appCheckError');
      // Try again with debug provider as fallback
      try {
        await FirebaseAppCheck.instance.activate(
          androidProvider: AndroidProvider.debug,
        );
        debugPrint(
            'Activated Firebase App Check with Debug Provider (fallback)');
      } catch (fallbackError) {
        debugPrint('Fatal App Check error: $fallbackError');
      }
    }
  } catch (e) {
    debugPrint('Fatal error initializing Firebase: $e');
    throw e; // Rethrow to handle in the app
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Concord',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6A1B9A),
          brightness: Brightness.dark,
        ),
        textTheme: GoogleFonts.interTextTheme(
          Theme.of(context).textTheme,
        ),
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        if (settings.name == '/profile') {
          // First check if a user is logged in
          final authService = AuthService();
          if (authService.currentUser == null) {
            // If no user is logged in, redirect to the landing screen
            return MaterialPageRoute(
              builder: (context) => const LandingScreen(),
            );
          }

          final String uid = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => ProfileScreen(uid: uid),
          );
        }
        return null;
      },
      routes: {
        '/': (context) => const AuthWrapper(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
      },
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          // User is logged in, but let's check if their profile is complete
          final user = snapshot.data;

          // First check if the account is scheduled for deletion
          return FutureBuilder<Map<String, dynamic>>(
            future: AuthService().checkDeletionStatusDuringSignIn(user!),
            builder: (context, deletionSnapshot) {
              // Show loading while checking deletion status
              if (deletionSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }

              // If the account is scheduled for deletion, show the restoration screen
              if (deletionSnapshot.hasData &&
                  deletionSnapshot.data != null &&
                  deletionSnapshot.data!['scheduledForDeletion'] == true) {
                debugPrint(
                    'Account is scheduled for deletion, showing restoration screen');

                // Get email from Firebase Auth before redirecting
                final email = user.email ?? '';

                // Show the restoration screen while keeping the user signed in for permissions
                return AccountRestorationScreen(
                  uid: user.uid,
                  daysRemaining: deletionSnapshot.data!['daysRemaining'],
                  email: email,
                  password: '',
                  keepUserSignedIn: true,
                );
              }

              // Return a FutureBuilder to check if the profile is complete
              return FutureBuilder<UserProfile?>(
                future: ProfileService().getProfile(user!.uid),
                builder: (context, profileSnapshot) {
                  // Show loading while fetching profile
                  if (profileSnapshot.connectionState ==
                      ConnectionState.waiting) {
                    return const Scaffold(
                      body: Center(
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  // Handle errors that might be related to pigeon issues
                  if (profileSnapshot.hasError) {
                    // Log the error
                    debugPrint('Profile fetch error: ${profileSnapshot.error}');

                    // Check if it might be a pigeon error
                    final errorString = profileSnapshot.error.toString();
                    if (errorString.contains('pigeon') ||
                        errorString.contains('platform channel') ||
                        errorString.contains('App Check token')) {
                      // Force a reload after a short delay
                      Future.delayed(const Duration(seconds: 1), () {
                        Navigator.pushNamedAndRemoveUntil(
                            context, '/', (route) => false);
                      });

                      // Show an intermediate loading screen
                      return Scaffold(
                        body: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const CircularProgressIndicator(),
                              const SizedBox(height: 16),
                              const Text('Resolving connection issue...'),
                            ],
                          ),
                        ),
                      );
                    }
                  }

                  // If profile is missing or doesn't have required fields, go to profile screen
                  if (!profileSnapshot.hasData ||
                      profileSnapshot.data == null ||
                      !_hasRequiredFields(profileSnapshot.data!)) {
                    // Only show profile screen if we have a valid user
                    if (user != null) {
                      return ProfileScreen(uid: user.uid);
                    } else {
                      // This should not happen, but just in case
                      return const LandingScreen();
                    }
                  }

                  // Profile is complete, go to home screen
                  return const HomeScreen();
                },
              );
            },
          );
        }

        return const LandingScreen();
      },
    );
  }

  // Helper method to check if profile has all required fields
  bool _hasRequiredFields(UserProfile profile) {
    return profile.displayName.isNotEmpty &&
        profile.username != null &&
        profile.username!.isNotEmpty &&
        profile.gender != null &&
        profile.dateOfBirth != null;
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = AuthService();

    return Scaffold(
      appBar: null,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome ${authService.currentUser?.email ?? ""}!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            const Text('You are now logged in.'),
          ],
        ),
      ),
    );
  }
}
