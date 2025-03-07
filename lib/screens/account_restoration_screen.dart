import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';

class AccountRestorationScreen extends StatefulWidget {
  final String uid;
  final int daysRemaining;
  final String email;
  final String password;
  final bool keepUserSignedIn;

  const AccountRestorationScreen({
    Key? key,
    required this.uid,
    required this.daysRemaining,
    required this.email,
    required this.password,
    this.keepUserSignedIn =
        false, // Default to false for backward compatibility
  }) : super(key: key);

  @override
  State<AccountRestorationScreen> createState() =>
      _AccountRestorationScreenState();
}

class _AccountRestorationScreenState extends State<AccountRestorationScreen> {
  final _authService = AuthService();
  final _profileService = ProfileService();
  bool _isLoading = false;

  Future<void> _restoreAccount() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // First check if we are still authenticated
      if (_authService.currentUser == null) {
        debugPrint(
            'Not authenticated, need to sign in first before restoration');

        // Try to sign in with the provided credentials if available
        if (widget.email.isNotEmpty && widget.password.isNotEmpty) {
          try {
            debugPrint('Attempting to sign in with provided credentials');
            await _authService.signInWithEmailAndPassword(
              email: widget.email,
              password: widget.password,
            );
          } catch (signInError) {
            debugPrint('Sign in error: $signInError');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Authentication error: ${signInError.toString().split(']').last.trim()}'),
                  backgroundColor: Colors.orange,
                ),
              );

              // Navigate to login screen instead
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );

              setState(() {
                _isLoading = false;
              });
              return;
            }
          }
        } else {
          // No credentials available, show sign in screen
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content:
                    Text('You need to sign in first to restore your account'),
                backgroundColor: Colors.orange,
              ),
            );

            // Show dialog to go to login screen
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => AlertDialog(
                title: const Text('Authentication Required'),
                content: const Text(
                  'You need to sign in to restore your account.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close dialog
                      // Navigate to login screen
                      Navigator.pushNamedAndRemoveUntil(
                        context,
                        '/login',
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );

            setState(() {
              _isLoading = false;
            });
            return;
          }
        }
      }

      // Now that we're authenticated, proceed with account restoration
      debugPrint('Starting account restoration for UID: ${widget.uid}');

      try {
        await _profileService.cancelDeletion(widget.uid);
        debugPrint('Successfully cancelled scheduled deletion');
      } catch (deletionError) {
        debugPrint('Error cancelling deletion: $deletionError');

        // If we get a permission error, try to re-authenticate
        if (deletionError.toString().contains('permission') ||
            deletionError.toString().contains('Authentication required')) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Authentication error. Please log in again.'),
                backgroundColor: Colors.orange,
              ),
            );

            // Navigate to login
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );

            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else {
          // Show warning for other types of errors but continue
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Warning: ${deletionError.toString()}'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }

      // Even if there was an error cancelling the deletion, we'll still try to handle the sign in
      // and redirect the user to the appropriate screen to ensure a good user experience

      if (widget.keepUserSignedIn) {
        // We were already signed in (came from AuthWrapper)
        debugPrint('User is already signed in, keeping session');

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Successfully returned to your account.'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home screen
          Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
        }
      } else if (widget.password.isNotEmpty) {
        // We came from login screen with password
        debugPrint('Signing in with provided credentials');

        try {
          // Complete the sign in process
          await _authService.signInWithEmailAndPassword(
            email: widget.email,
            password: widget.password,
          );

          if (mounted) {
            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Successfully restored your account.'),
                backgroundColor: Colors.green,
              ),
            );

            // Navigate to home screen
            Navigator.pushNamedAndRemoveUntil(
                context, '/home', (route) => false);
          }
        } catch (signInError) {
          debugPrint('Sign in error during restoration: $signInError');
          if (mounted) {
            // Show error and redirect to login
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    'Authentication error: ${signInError.toString().split(']').last.trim()}'),
                backgroundColor: Colors.orange,
              ),
            );

            // Navigate to login screen
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/login',
              (route) => false,
            );
          }
        }
      } else {
        // We don't have the password, show login dialog
        debugPrint('No password provided, redirecting to login');

        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => AlertDialog(
              title: const Text('Account Restored'),
              content: const Text(
                'Your account has been successfully restored. You will need to log in again to access your account.',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Navigate to login screen
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/login',
                      (route) => false,
                    );
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error in account restoration process: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error restoring account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _continueWithDeletion() async {
    // If we kept the user signed in, sign them out now
    if (widget.keepUserSignedIn) {
      try {
        await _authService.signOut();
        debugPrint('User signed out after continuing with deletion');
      } catch (e) {
        debugPrint('Error signing out: $e');
      }
    }

    // Navigate back to landing screen
    Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A1B9A), // Deep Purple
              Color(0xFF8E24AA), // Purple
              Color(0xFFAB47BC), // Light Purple
              Color(0xFF9C27B0), // Medium Purple
              Color(0xFF7B1FA2), // Rich Purple
            ],
            stops: [0.0, 0.3, 0.5, 0.7, 1.0],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          const SizedBox(height: 40),
                          Icon(
                            Icons.warning_amber_rounded,
                            size: 80,
                            color: Colors.amber,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Account Scheduled for Deletion',
                            style: GoogleFonts.orbitron(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Your account is currently scheduled for deletion.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'It will be permanently deleted in ${widget.daysRemaining} days.',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Our policy provides a 90-day window for account restoration. Your account and any data associated with it will not be shown during this period.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'Would you like to restore your account?',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 48),
                          ElevatedButton(
                            onPressed: _isLoading ? null : _restoreAccount,
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Text(
                                    'Yes, Restore My Account',
                                    style: GoogleFonts.orbitron(fontSize: 16),
                                  ),
                          ),
                          const SizedBox(height: 16),
                          TextButton(
                            onPressed:
                                _isLoading ? null : _continueWithDeletion,
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white70,
                            ),
                            child: Text(
                              'No, Continue with Deletion',
                              style: GoogleFonts.orbitron(fontSize: 14),
                            ),
                          ),
                          const SizedBox(
                              height:
                                  40), // Add bottom spacing to balance the layout
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
