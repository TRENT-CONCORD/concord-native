import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/profile_service.dart';
import '../models/user_profile.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'profile_screen.dart';
import 'explore_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _authService = AuthService();
  final _profileService = ProfileService();
  int _currentIndex = 0;
  UserProfile? _userProfile;
  bool _isLoading = true;
  DateTime? _lastBackPress;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _authService.currentUser;
    if (user != null) {
      try {
        final profile = await _profileService.getProfile(user.uid);
        if (mounted) {
          setState(() {
            _userProfile = profile;
            _isLoading = false;
          });

          // Check if profile is missing required fields
          if (profile == null || !_hasRequiredFields(profile)) {
            // Navigate to the profile screen
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(uid: user.uid),
                ),
              );
            });
          }
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } else {
      // No user is logged in, navigate to landing screen
      if (mounted) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          Navigator.of(context).pushReplacementNamed('/');
        });
      }
    }
  }

  // Helper method to check if profile has all required fields
  bool _hasRequiredFields(UserProfile profile) {
    return profile.displayName.isNotEmpty &&
        profile.username != null &&
        profile.username!.isNotEmpty &&
        profile.gender != null &&
        profile.dateOfBirth != null;
  }

  Future<void> _signOut() async {
    try {
      await _authService.signOut();
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing out: ${e.toString()}')),
      );
    }
  }

  Widget _buildDiscoverScreen() {
    return ExploreScreen();
  }

  Widget _buildChatsScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Chats',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Coming soon: Your conversations will appear here'),
        ],
      ),
    );
  }

  Widget _buildCommunitiesScreen() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Communities',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text('Coming soon: Join and create communities'),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 50,
            backgroundImage: _userProfile?.mainPhotoUrl != null
                ? NetworkImage(_userProfile!.mainPhotoUrl!)
                : null,
            child: _userProfile?.mainPhotoUrl == null
                ? const Icon(Icons.person, size: 50)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            _userProfile?.displayName ?? 'No name',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(_userProfile?.bio ?? 'No bio'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Check if user is still logged in
              if (_authService.currentUser == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('You must be logged in to edit your profile'),
                    backgroundColor: Colors.red,
                  ),
                );
                Navigator.of(context).pushReplacementNamed('/');
                return;
              }

              Navigator.pushNamed(
                context,
                '/profile',
                arguments: _authService.currentUser?.uid,
              );
            },
            child: const Text('Edit Profile'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _signOut,
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_currentIndex != 0) {
      setState(() => _currentIndex = 0);
      return false;
    }

    final now = DateTime.now();
    if (_lastBackPress == null ||
        now.difference(_lastBackPress!) > const Duration(seconds: 2)) {
      _lastBackPress = now;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Press back again to exit'),
          duration: Duration(seconds: 2),
        ),
      );
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> screens = [
      _buildDiscoverScreen(),
      _buildChatsScreen(),
      _buildCommunitiesScreen(),
      _buildProfileTab(),
    ];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Concord'),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications),
              onPressed: () {
                // TODO: Implement notifications
              },
            ),
          ],
        ),
        body: screens[_currentIndex],
        bottomNavigationBar: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF4A148C),
                Color(0xFF7B1FA2),
                Color(0xFFAB47BC),
              ],
              stops: [0.0, 0.5, 1.0],
            ),
            boxShadow: [
              BoxShadow(
                color: Color(0xFFCC0AE6),
                offset: Offset(-4, -4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
              BoxShadow(
                color: Color(0xFFCC0AE6),
                offset: Offset(4, 4),
                blurRadius: 12,
                spreadRadius: 2,
              ),
            ],
          ),
          child: NavigationBar(
            height: 70,
            backgroundColor: Colors.transparent,
            indicatorColor: Colors.transparent,
            selectedIndex: _currentIndex,
            onDestinationSelected: (index) {
              setState(() => _currentIndex = index);
            },
            destinations: [
              NavigationDestination(
                icon: GestureDetector(
                  onLongPressStart: (details) {
                    final overlay = Overlay.of(context);
                    final entry = OverlayEntry(
                      builder: (context) => Positioned(
                        top: details.globalPosition.dy - 80,
                        left: details.globalPosition.dx - 30,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Explore',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    overlay.insert(entry);

                    Future.delayed(const Duration(seconds: 2), () {
                      entry.remove();
                    });
                  },
                  child: Center(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: _currentIndex == 0
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.4),
                                  offset: Offset(-1, -1),
                                  blurRadius: 6,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  offset: Offset(1, 1),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: SvgPicture.network(
                        'https://4355d96bf828a20e921a948d2658b597.cdn.bubble.io/f1739794296650x110416392599961730/Browse%20Profiles%20Navbar.svg',
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: GestureDetector(
                  onLongPressStart: (details) {
                    final overlay = Overlay.of(context);
                    final entry = OverlayEntry(
                      builder: (context) => Positioned(
                        top: details.globalPosition.dy - 80,
                        left: details.globalPosition.dx - 30,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Chats',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    overlay.insert(entry);

                    Future.delayed(const Duration(seconds: 2), () {
                      entry.remove();
                    });
                  },
                  child: Center(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: _currentIndex == 1
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.4),
                                  offset: Offset(-1, -1),
                                  blurRadius: 6,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  offset: Offset(1, 1),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: SvgPicture.network(
                        'https://4355d96bf828a20e921a948d2658b597.cdn.bubble.io/f1739795563045x288695892351106700/User%20Chats.svg',
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: GestureDetector(
                  onLongPressStart: (details) {
                    final overlay = Overlay.of(context);
                    final entry = OverlayEntry(
                      builder: (context) => Positioned(
                        top: details.globalPosition.dy - 80,
                        left: details.globalPosition.dx - 30,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Bubbles',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    overlay.insert(entry);

                    Future.delayed(const Duration(seconds: 2), () {
                      entry.remove();
                    });
                  },
                  child: Center(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: _currentIndex == 2
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.4),
                                  offset: Offset(-1, -1),
                                  blurRadius: 6,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  offset: Offset(1, 1),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: SvgPicture.network(
                        'https://4355d96bf828a20e921a948d2658b597.cdn.bubble.io/f1739795834138x552831874957548740/Bubbles%20Navbar.svg',
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
              NavigationDestination(
                icon: GestureDetector(
                  onLongPressStart: (details) {
                    final overlay = Overlay.of(context);
                    final entry = OverlayEntry(
                      builder: (context) => Positioned(
                        top: details.globalPosition.dy - 80,
                        left: details.globalPosition.dx - 30,
                        child: Material(
                          color: Colors.transparent,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                vertical: 2, horizontal: 6),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.8),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Settings',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontFamily: 'Orbitron',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );

                    overlay.insert(entry);

                    Future.delayed(const Duration(seconds: 2), () {
                      entry.remove();
                    });
                  },
                  child: Center(
                    child: Container(
                      height: 70,
                      width: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: _currentIndex == 3
                            ? [
                                BoxShadow(
                                  color: Colors.white.withOpacity(0.4),
                                  offset: Offset(-1, -1),
                                  blurRadius: 6,
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.15),
                                  offset: Offset(1, 1),
                                  blurRadius: 6,
                                ),
                              ]
                            : null,
                      ),
                      child: SvgPicture.network(
                        'https://4355d96bf828a20e921a948d2658b597.cdn.bubble.io/f1739796011658x473342461644521400/User%20Settings%20Navbar.svg',
                        width: 70,
                        height: 70,
                      ),
                    ),
                  ),
                ),
                label: '',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
