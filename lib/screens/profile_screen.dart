import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../models/user_profile.dart';
import '../services/profile_service.dart';
import '../services/auth_service.dart';
import '../theme/colors.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:reorderables/reorderables.dart';
import '../models/profile_enums.dart';
import 'package:intl/intl.dart';

// Constants for colors and styling
const Color kBackgroundColor = Color(0xFF0A0A0A);
const Color kSectionBackground = Color(0xFF141414);
const Color kChipBackground = Color(0xFF1A1A1A);
const Color kInputBackground =
    Color(0xFF222222); // New background color for inputs
const Color kPurpleAccent = Color(0xFF8838E1);
const Color kPurpleNeon = Color(0xFF9C27B0);
const Color kPurpleLight = Color(0xFFE1BEE7);
const Color kTextPrimary = Colors.white;
const Color kTextSecondary = Color(0xFF8E8E8E);
const Color kOnlineIndicator = Color(0xFF4CAF50);

// Shadow styles
final List<BoxShadow> kElevatedShadow = [
  BoxShadow(
    color: Color(0xFFCC0AE6),
    offset: Offset(-2, -2),
    blurRadius: 4,
    spreadRadius: -1,
  ),
  BoxShadow(
    color: Color(0xFFCC0AE6),
    offset: Offset(2, 2),
    blurRadius: 4,
    spreadRadius: -1,
  ),
];

final BoxDecoration kNeonBorderDecoration = BoxDecoration(
  color: kSectionBackground,
  borderRadius: BorderRadius.circular(16),
  boxShadow: [
    BoxShadow(
      color: Color(0xFFCC0AE6),
      offset: Offset(-2, -2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
    BoxShadow(
      color: Color(0xFFCC0AE6),
      offset: Offset(2, 2),
      blurRadius: 4,
      spreadRadius: -1,
    ),
  ],
);

class ProfileScreen extends StatefulWidget {
  final String uid;

  const ProfileScreen({Key? key, required this.uid}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileService _profileService = ProfileService();
  final AuthService _authService = AuthService();
  final _scrollController = ScrollController();
  late PageController _pageController;
  final _bioController = TextEditingController();
  final _displayNameController = TextEditingController();
  final _jobTitleController = TextEditingController();
  final _companyController = TextEditingController();
  UserProfile? _profile;
  UserProfile? _originalProfile; // Store original profile for change tracking
  bool _isLoading = true;
  bool _isExpanded = false;
  DateTime? _selectedDate;
  bool _hasUnsavedChanges = false;
  int _currentPhotoPage = 0;

  // Define section tags for navigation
  final List<String> _sectionTags = [
    'Photos',
    'Info',
    'Bio',
    'Work',
    'Lifestyle',
    'Habits',
    'Interests'
  ];
  int _activeTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _pageController.addListener(_onPhotoPageChanged);
    _loadProfile();

    // Add listener to the scroll controller to update the active tab
    _scrollController.addListener(_updateActiveTabFromScroll);
  }

  void _onPhotoPageChanged() {
    if (_pageController.hasClients && _pageController.page != null) {
      setState(() {
        _currentPhotoPage = _pageController.page!.round();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateActiveTabFromScroll);
    _pageController.removeListener(_onPhotoPageChanged);
    _scrollController.dispose();
    _pageController.dispose();
    _bioController.dispose();
    _displayNameController.dispose();
    _jobTitleController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  void _updateActiveTabFromScroll() {
    // Skip updating during a programmatic scroll
    if (_scrollController.position.isScrollingNotifier.value) return;

    // Get current scroll position
    final double offset = _scrollController.offset;
    final double maxScrollExtent = _scrollController.position.maxScrollExtent;

    // Calculate approximate position based on scroll offset relative to max scroll
    if (offset < 350) {
      _setActiveTab(0); // Photos
    } else if (offset < 550) {
      _setActiveTab(1); // Info
    } else if (offset < 750) {
      _setActiveTab(2); // Bio
    } else if (offset < 950) {
      _setActiveTab(3); // Work
    } else if (offset < 1150) {
      _setActiveTab(4); // Lifestyle
    } else if (offset < 1350) {
      _setActiveTab(5); // Habits
    } else {
      _setActiveTab(6); // Interests
    }
  }

  void _setActiveTab(int index) {
    if (_activeTabIndex != index) {
      setState(() {
        _activeTabIndex = index;
      });
    }
  }

  void _scrollToSection(int index) {
    double offset = 0;

    switch (index) {
      case 0: // Photos
        offset = 0;
        break;
      case 1: // Info
        offset = 350;
        break;
      case 2: // Bio
        offset = 550;
        break;
      case 3: // Work
        offset = 750;
        break;
      case 4: // Lifestyle
        offset = 950;
        break;
      case 5: // Habits
        offset = 1150;
        break;
      case 6: // Interests
        offset = 1350;
        break;
    }

    _scrollController.animateTo(
      offset,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  Widget _buildTabBar() {
    return Container(
      height: 50,
      margin: EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _sectionTags.length,
        itemBuilder: (context, index) {
          final isActive = _activeTabIndex == index;
          return GestureDetector(
            onTap: () => _scrollToSection(index),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              margin: EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: isActive ? kPurpleAccent : kSectionBackground,
                borderRadius: BorderRadius.circular(20),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: kPurpleAccent.withOpacity(0.3),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Text(
                _sectionTags[index],
                style: TextStyle(
                  color: isActive ? kTextPrimary : kTextSecondary,
                  fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showBottomSheet({
    required String title,
    required Widget content,
    required VoidCallback onSave,
    bool showActions = true,
  }) {
    // Use a try-catch block to handle potential rendering issues
    try {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: kBackgroundColor,
        useRootNavigator: true, // Add this to ensure proper context
        isDismissible: true,
        enableDrag: true,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (BuildContext context) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Handle bar at the top
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: kTextSecondary,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),

                    // Title
                    Text(
                      title,
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: kTextPrimary),
                    ),
                    SizedBox(height: 16),

                    // Content - no longer in a Flexible widget
                    content,

                    // Action buttons
                    if (showActions)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: TextStyle(
                                  color: kTextSecondary,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: onSave,
                              style: ElevatedButton.styleFrom(
                                foregroundColor: kTextPrimary,
                                backgroundColor: kPurpleAccent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: Text(
                                'Save',
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ).then((_) {
        // Debug log for successful open
        debugPrint('Bottom sheet closed properly');
      });
    } catch (e) {
      // If there's an error showing the bottom sheet, fallback to a simple dialog
      debugPrint('Error showing bottom sheet: $e');

      // Show error message if bottom sheet fails
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the dialog. Please try again.')),
      );
    }
  }

  Future<void> _loadProfile() async {
    try {
      setState(() => _isLoading = true);

      // First check if the user is logged in
      if (_authService.currentUser == null) {
        debugPrint('No user is logged in, navigating to landing page');
        if (mounted) {
          // Navigate to the landing page
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          return;
        }
      }

      // Ensure the current user's UID matches the profile being viewed
      if (_authService.currentUser?.uid != widget.uid) {
        debugPrint(
            'Profile UID does not match current user, navigating to landing page');
        if (mounted) {
          // Navigate to the landing page
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          return;
        }
      }

      debugPrint('Loading profile for UID: ${widget.uid}');
      var profile = await _profileService.getProfile(widget.uid);

      if (mounted) {
        if (profile == null) {
          debugPrint(
              'Profile not found, creating new profile for UID: ${widget.uid}');

          // Verify there's a logged-in user before creating a profile
          if (_authService.currentUser == null) {
            debugPrint('Cannot create profile: no user is logged in');
            Navigator.of(context)
                .pushNamedAndRemoveUntil('/', (route) => false);
            return;
          }

          // Create a new profile with minimum required fields
          profile = UserProfile.createEmpty(widget.uid);

          // Add default display name to meet validation
          profile = profile.copyWith(
            displayName: "New User",
            username:
                "user_${DateTime.now().millisecondsSinceEpoch}", // Add a default unique username
          );

          try {
            debugPrint('Attempting to save new profile: ${profile.toMap()}');
            await _profileService.updateProfile(profile);
            debugPrint('New profile saved successfully');
          } catch (e) {
            // Handle validation error when creating profile
            debugPrint('Error creating initial profile: $e');
            // We'll still use the profile for UI rendering even if saving failed
          }

          // Verify the profile was created by fetching it again
          try {
            debugPrint('Verifying profile creation...');
            var verifiedProfile = await _profileService.getProfile(widget.uid);
            if (verifiedProfile != null) {
              debugPrint('Profile verified: ${verifiedProfile.toMap()}');
              profile = verifiedProfile;
            } else {
              debugPrint(
                  'WARNING: Profile verification failed, using local instance');
              // Continue with local instance
            }
          } catch (e) {
            debugPrint('Error verifying profile: $e');
          }
        }

        debugPrint('Setting profile in state: ${profile?.toMap()}');

        // Validate gender sub-option when loading profile
        if (profile?.genderSubOption != null) {
          debugPrint(
              'Validating gender sub-option: ${profile?.genderSubOption}');
          bool isValidSubOption = false;
          if (profile?.gender != null) {
            switch (profile!.gender) {
              case GenderOption.man:
                final validOptions =
                    GenderSubOptionMan.values.map((e) => e.display).toList();
                debugPrint('Valid man sub-options: $validOptions');
                isValidSubOption =
                    validOptions.contains(profile.genderSubOption);
                break;
              case GenderOption.woman:
                final validOptions =
                    GenderSubOptionWoman.values.map((e) => e.display).toList();
                debugPrint('Valid woman sub-options: $validOptions');
                isValidSubOption =
                    validOptions.contains(profile.genderSubOption);
                break;
              case GenderOption.beyondBinary:
                final validOptions = GenderSubOptionBeyondBinary.values
                    .map((e) => e.display)
                    .toList();
                debugPrint('Valid beyond binary sub-options: $validOptions');
                isValidSubOption =
                    validOptions.contains(profile.genderSubOption);
                break;
              default:
                isValidSubOption = false;
            }
            debugPrint('Is valid sub-option: $isValidSubOption');
            if (!isValidSubOption) {
              debugPrint('Invalid gender sub-option, setting to null');
              profile = profile.copyWith(genderSubOption: null);
            }
          }
        }

        setState(() {
          _profile = profile;
          _originalProfile =
              profile?.copyWith(); // Make a copy for change detection
          _isLoading = false;
          _hasUnsavedChanges = false; // Reset unsaved changes flag

          // Set text controllers with profile data
          if (profile != null) {
            _bioController.text = profile.bio ?? '';
            _displayNameController.text = profile.displayName ?? '';
            _jobTitleController.text = profile.jobTitle ?? '';
            _companyController.text = profile.company ?? '';
            _selectedDate = profile.dateOfBirth;
          }

          // Debug output to verify profile is set
          debugPrint(
              'Profile loaded into state: ${_profile != null ? 'SUCCESS' : 'FAILED'}');
        });

        // If the profile is missing required photos, show a suggestion message
        if (profile != null &&
            _profile?.mainPhotoUrl == null &&
            _authService.currentUser != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPhotoCompletionBanner();
          });
        }

        // Only show the photo completion banner if:
        // 1. The user is logged in
        // 2. We have a profile
        // 3. The profile belongs to the current user
        // 4. The main photo is missing
        if (_authService.currentUser != null &&
            profile != null &&
            _profile?.mainPhotoUrl == null &&
            _profile?.uid == _authService.currentUser?.uid) {
          debugPrint(
              'Showing photo completion banner for logged in user: ${_authService.currentUser?.uid}');
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showPhotoCompletionBanner();
          });
        }
      }
    } catch (e) {
      debugPrint('Error loading profile for UID: ${widget.uid}, Error: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        // Check if the error is because there's no authenticated user
        if (_authService.currentUser == null) {
          debugPrint(
              'Error due to no authenticated user, navigating to landing page');
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading profile: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _saveProfile() async {
    if (_profile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Cannot save: profile data is missing')),
      );
      return;
    }

    try {
      // Check for required fields before saving
      if (_profile!.displayName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Display name is required')),
        );
        return;
      }

      // Check if username is set
      if (_profile!.username == null || _profile!.username!.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Username is required')),
        );
        return;
      }

      // Show loading indicator
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Saving profile...'),
          duration: Duration(seconds: 1),
        ),
      );

      debugPrint('Saving profile data: ${_profile!.toMap()}');

      // Attempt to save the profile
      await _profileService.updateProfile(_profile!);

      if (mounted) {
        // Update original profile after successful save
        setState(() {
          _originalProfile = _profile!.copyWith();
          _hasUnsavedChanges = false;
        });

        // Check photo requirements for notification
        bool hasMainPhoto = _profile!.mainPhotoUrl != null;

        // Show appropriate message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(hasMainPhoto
                ? 'Profile saved successfully'
                : 'Profile saved, but you still need to add a main photo'),
            action: !hasMainPhoto
                ? SnackBarAction(
                    label: 'Add Photo',
                    onPressed: () {
                      _showPhotoManagement();
                    },
                  )
                : null,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving profile: $e');
      if (mounted) {
        // Provide a more detailed error message
        String errorMessage = 'Error saving profile: ${e.toString()}';

        // Simplify common error messages
        if (e.toString().contains("Display name is required")) {
          errorMessage = "Display name is required";
        } else if (e.toString().contains("photos are required")) {
          errorMessage = "You need at least 3 photos (1 main + 2 additional)";
        } else if (e.toString().contains("Username already exists")) {
          errorMessage =
              "Username already exists. Please choose a different username.";
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            action: errorMessage.contains("photos")
                ? SnackBarAction(
                    label: 'Add Photos',
                    onPressed: () {
                      _showPhotoManagement();
                    },
                  )
                : null,
          ),
        );
      }
    }
  }

  // Improved update profile method to ensure state is properly updated
  void _updateProfile(UserProfile updatedProfile) {
    if (updatedProfile == null) {
      debugPrint('Cannot update profile: updatedProfile is null');
      return;
    }

    setState(() {
      _profile = updatedProfile;
      _hasUnsavedChanges = true;

      // Debug information
      debugPrint('Profile updated: hasUnsavedChanges=$_hasUnsavedChanges');
    });
  }

  // Check if there are unsaved changes
  void _checkForUnsavedChanges() {
    if (_profile == null || _originalProfile == null) return;

    // Simple comparison - in a real app you might want a more sophisticated comparison
    final bool hasChanges = _profile.toString() != _originalProfile.toString();

    if (_hasUnsavedChanges != hasChanges) {
      setState(() {
        _hasUnsavedChanges = hasChanges;
      });
    }
  }

  Future<void> _editPhoto(int index) async {
    final picker = ImagePicker();

    _showBottomSheet(
      title: 'Choose Photo Source',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: Icon(Icons.camera_alt, color: kPurpleAccent),
            title: Text('Take a photo', style: TextStyle(color: kTextPrimary)),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile =
                  await picker.pickImage(source: ImageSource.camera);
              if (pickedFile != null && _profile != null) {
                if (index == 0) {
                  _updateProfile(
                      _profile!.copyWith(mainPhotoUrl: pickedFile.path));
                } else {
                  final photoIndex = index - 1;
                  List<String> updatedPhotos =
                      List.from(_profile!.additionalPhotos ?? []);
                  if (photoIndex < updatedPhotos.length) {
                    updatedPhotos[photoIndex] = pickedFile.path;
                  } else {
                    updatedPhotos.add(pickedFile.path);
                  }
                  _updateProfile(
                      _profile!.copyWith(additionalPhotos: updatedPhotos));
                }
              }
            },
          ),
          ListTile(
            leading: Icon(Icons.photo_library, color: kPurpleAccent),
            title: Text('Choose from gallery',
                style: TextStyle(color: kTextPrimary)),
            onTap: () async {
              Navigator.pop(context);
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);
              if (pickedFile != null && _profile != null) {
                if (index == 0) {
                  _updateProfile(
                      _profile!.copyWith(mainPhotoUrl: pickedFile.path));
                } else {
                  final photoIndex = index - 1;
                  List<String> updatedPhotos =
                      List.from(_profile!.additionalPhotos ?? []);
                  if (photoIndex < updatedPhotos.length) {
                    updatedPhotos[photoIndex] = pickedFile.path;
                  } else {
                    updatedPhotos.add(pickedFile.path);
                  }
                  _updateProfile(
                      _profile!.copyWith(additionalPhotos: updatedPhotos));
                }
              }
            },
          ),
          if (index == 0 && _profile?.mainPhotoUrl != null)
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title:
                  Text('Remove photo', style: TextStyle(color: kTextPrimary)),
              onTap: () {
                Navigator.pop(context);
                if (_profile != null) {
                  _updateProfile(_profile!.copyWith(mainPhotoUrl: null));
                }
              },
            ),
          if (index > 0 && index <= (_profile?.additionalPhotos.length ?? 0))
            ListTile(
              leading: Icon(Icons.delete, color: Colors.red),
              title:
                  Text('Remove photo', style: TextStyle(color: kTextPrimary)),
              onTap: () {
                Navigator.pop(context);
                if (_profile != null) {
                  List<String> updatedPhotos =
                      List.from(_profile!.additionalPhotos);
                  updatedPhotos.removeAt(index - 1);
                  _updateProfile(
                      _profile!.copyWith(additionalPhotos: updatedPhotos));
                }
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  // Fix the edit display name method to ensure it works properly
  void _editDisplayName() {
    if (_profile == null) {
      debugPrint('Cannot edit display name: profile is null');
      return;
    }

    _displayNameController.text = _profile?.displayName ?? '';

    _showBottomSheet(
      title: 'Edit Display Name',
      content: TextField(
        controller: _displayNameController,
        style: TextStyle(color: kTextPrimary),
        decoration: InputDecoration(
          hintText: 'Enter your display name',
          hintStyle: TextStyle(color: kTextSecondary),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kPurpleAccent),
          ),
        ),
      ),
      onSave: () {
        if (_profile != null) {
          final String newName = _displayNameController.text.trim();
          if (newName.isNotEmpty) {
            _updateProfile(_profile!.copyWith(
              displayName: newName,
            ));
            Navigator.pop(context);

            // Show confirmation
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(
                      'Display name updated. Don\'t forget to save your profile.')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Display name cannot be empty')),
            );
          }
        }
      },
    );
  }

  // Add this method to check if profile has required fields set
  bool _hasRequiredProfileFields() {
    if (_profile == null) return false;

    return _profile!.displayName.isNotEmpty &&
        _profile!.username != null &&
        _profile!.username!.isNotEmpty &&
        _profile!.gender != null &&
        _profile!.dateOfBirth != null;
  }

  // Add this method to show a required fields dialog
  void _showRequiredFieldsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User must tap button to close dialog
      builder: (context) => AlertDialog(
        backgroundColor: kSectionBackground,
        title: Text(
          'Complete Your Profile',
          style: TextStyle(color: kTextPrimary),
        ),
        content: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.5,
          ),
          width: double.maxFinite,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'You must fill in these required fields before continuing:',
                  style: TextStyle(color: kTextPrimary),
                ),
                SizedBox(height: 16),
                // Display name requirement
                Row(
                  children: [
                    Icon(
                      _profile?.displayName?.isNotEmpty == true
                          ? Icons.check_circle
                          : Icons.error,
                      color: _profile?.displayName?.isNotEmpty == true
                          ? Colors.green
                          : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Display name',
                      style: TextStyle(color: kTextPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Username requirement
                Row(
                  children: [
                    Icon(
                      (_profile?.username?.isNotEmpty ?? false)
                          ? Icons.check_circle
                          : Icons.error,
                      color: (_profile?.username?.isNotEmpty ?? false)
                          ? Colors.green
                          : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Username',
                      style: TextStyle(color: kTextPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Gender requirement
                Row(
                  children: [
                    Icon(
                      _profile?.gender != null
                          ? Icons.check_circle
                          : Icons.error,
                      color:
                          _profile?.gender != null ? Colors.green : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Gender',
                      style: TextStyle(color: kTextPrimary),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                // Date of birth requirement
                Row(
                  children: [
                    Icon(
                      _profile?.dateOfBirth != null
                          ? Icons.check_circle
                          : Icons.error,
                      color: _profile?.dateOfBirth != null
                          ? Colors.green
                          : Colors.red,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Date of birth',
                      style: TextStyle(color: kTextPrimary),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'OK',
              style: TextStyle(color: kPurpleAccent),
            ),
          ),
        ],
      ),
    );
  }

  void _editUsername() async {
    // Check for null profile
    if (_profile == null) return;

    final TextEditingController usernameController =
        TextEditingController(text: _profile?.username);
    bool isUsernameValid = true;
    String errorMessage = '';
    int remainingChanges = 0;

    try {
      // Get remaining changes
      remainingChanges =
          await _profileService.getRemainingUsernameChanges(widget.uid);
    } catch (e) {
      debugPrint('Error getting remaining username changes: $e');
    }

    _showBottomSheet(
      title: 'Edit Username',
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Username must be unique and cannot be changed frequently.',
              style: TextStyle(color: kTextSecondary, fontSize: 12),
            ),
            SizedBox(height: 8),
            // Show remaining changes with updated message
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: remainingChanges > 0
                    ? Colors.green.withOpacity(0.2)
                    : Colors.red.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'You can change your username twice every 30 days.',
                    style: TextStyle(
                      color: remainingChanges > 0 ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  FutureBuilder<DateTime?>(
                      future: _profileService
                          .getNextUsernameChangeResetDate(widget.uid),
                      builder: (context, snapshot) {
                        // Calculate the reset date
                        String resetDateText = "calculating...";
                        if (snapshot.hasData && snapshot.data != null) {
                          final resetDate = snapshot.data!;
                          final formatter = DateFormat('MMM d, yyyy');
                          resetDateText = formatter.format(resetDate);
                        }

                        return Text(
                          'You have $remainingChanges/2 changes remaining and will reset on $resetDateText',
                          style: TextStyle(
                            color: remainingChanges > 0
                                ? Colors.green
                                : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        );
                      }),
                ],
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: usernameController,
              style: TextStyle(color: kTextPrimary),
              decoration: InputDecoration(
                hintText: 'Enter your username',
                hintStyle: TextStyle(color: kTextSecondary),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: kPurpleAccent),
                ),
                errorText: isUsernameValid ? null : errorMessage,
              ),
              onChanged: (value) {
                // Reset validation on change
                if (!isUsernameValid) {
                  setState(() {
                    isUsernameValid = true;
                  });
                }
              },
            ),
          ],
        );
      }),
      onSave: () async {
        if (_profile != null) {
          final String username = usernameController.text.trim();

          // Validate username
          if (username.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Username cannot be empty')),
            );
            return;
          }

          // Check if username is different from current
          if (username == _profile!.username) {
            Navigator.pop(context);
            return;
          }

          // Show loading indicator
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Checking username availability...'),
                duration: Duration(seconds: 1)),
          );

          // Update username with new service method that checks limits
          final result =
              await _profileService.updateUsername(widget.uid, username);
          Navigator.pop(context);

          if (result['success']) {
            // Username updated successfully
            _updateProfile(_profile!.copyWith(
              username: username,
              usernameChangeHistory: [
                ..._profile!.usernameChangeHistory,
                DateTime.now()
              ],
            ));

            // Show success message
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                    '${result['message']}. You have ${result['remainingChanges']} changes remaining.'),
              ),
            );
          } else {
            // Handle error case
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(result['message'])),
            );
          }
        }
      },
    );
  }

  // Helper method to debug gender selection
  void _debugGenderSelection(UserProfile profile) {
    debugPrint('DEBUG GENDER: Primary Gender: ${profile.gender?.display}');
    debugPrint('DEBUG GENDER: Sub-option: ${profile.genderSubOption}');

    if (profile.gender != null && profile.genderSubOption != null) {
      bool isValid = false;
      List<String> validOptions = [];

      switch (profile.gender) {
        case GenderOption.man:
          validOptions =
              GenderSubOptionMan.values.map((e) => e.display).toList();
          isValid = validOptions.contains(profile.genderSubOption);
          break;
        case GenderOption.woman:
          validOptions =
              GenderSubOptionWoman.values.map((e) => e.display).toList();
          isValid = validOptions.contains(profile.genderSubOption);
          break;
        case GenderOption.beyondBinary:
          validOptions =
              GenderSubOptionBeyondBinary.values.map((e) => e.display).toList();
          isValid = validOptions.contains(profile.genderSubOption);
          break;
        default:
          // Handle null or any future gender options
          debugPrint('DEBUG GENDER: Unknown gender option');
          break;
      }

      debugPrint('DEBUG GENDER: Valid options: $validOptions');
      debugPrint('DEBUG GENDER: Is sub-option valid: $isValid');
    }
  }

  void _editGender() {
    // Make sure we have a profile to edit
    if (_profile == null) return;

    UserProfile tempProfile = _profile!.copyWith();

    // Debug current gender
    _debugGenderSelection(tempProfile);

    _showBottomSheet(
      title: 'Edit Gender',
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Primary gender options
              for (var gender in GenderOption.values)
                RadioListTile<GenderOption>(
                  title: Text(
                    gender.display,
                    style: TextStyle(color: kTextPrimary),
                  ),
                  value: gender,
                  groupValue: tempProfile.gender,
                  onChanged: (GenderOption? value) {
                    if (value != null) {
                      setState(() {
                        tempProfile = tempProfile.copyWith(
                          gender: value,
                          genderSubOption: null,
                        );
                        _debugGenderSelection(tempProfile);
                      });
                    }
                  },
                ),

              // Divider if gender is selected
              if (tempProfile.gender != null)
                Column(
                  children: [
                    Divider(color: kSectionBackground, thickness: 1),
                    SizedBox(height: 8),
                    Text(
                      'More Specifically...',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                  ],
                ),

              // Sub-options based on selected gender
              if (tempProfile.gender == GenderOption.man)
                _buildGenderSubOptionsLocal<GenderSubOptionMan>(
                  GenderSubOptionMan.values,
                  tempProfile,
                  setState,
                )
              else if (tempProfile.gender == GenderOption.woman)
                _buildGenderSubOptionsLocal<GenderSubOptionWoman>(
                  GenderSubOptionWoman.values,
                  tempProfile,
                  setState,
                )
              else if (tempProfile.gender == GenderOption.beyondBinary)
                _buildGenderSubOptionsLocal<GenderSubOptionBeyondBinary>(
                  GenderSubOptionBeyondBinary.values,
                  tempProfile,
                  setState,
                ),
            ],
          );
        },
      ),
      onSave: () {
        if (_profile != null) {
          _updateProfile(tempProfile);
          Navigator.pop(context);
        }
      },
    );
  }

  void _editHeight() {
    _showBottomSheet(
      title: 'Edit Height',
      content: TextField(
        controller:
            TextEditingController(text: _profile?.height?.toString() ?? ''),
        style: TextStyle(color: kTextPrimary),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: 'Enter your height in cm',
          hintStyle: TextStyle(color: kTextSecondary),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kPurpleAccent),
          ),
        ),
      ),
      onSave: () {
        if (_profile != null) {
          String heightText =
              TextEditingController(text: _profile?.height?.toString() ?? '')
                  .text;
          int? height = int.tryParse(heightText);
          _updateProfile(_profile!.copyWith(height: height));
          Navigator.pop(context);
        }
      },
    );
  }

  void _editLookingFor() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'What are you looking for?',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var option in LookingForOption.values)
            ListTile(
              title: Text(option.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(lookingFor: [option]));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editOccupation() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Occupation',
      content: TextField(
        controller: TextEditingController(text: _profile?.jobTitle),
        style: TextStyle(color: kTextPrimary),
        decoration: InputDecoration(
          hintText: 'Enter your job title',
          hintStyle: TextStyle(color: kTextSecondary),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kPurpleAccent),
          ),
        ),
      ),
      onSave: () {
        if (_profile != null) {
          _updateProfile(_profile!.copyWith(
              jobTitle: TextEditingController(text: _profile?.jobTitle).text));
          Navigator.pop(context);
        }
      },
    );
  }

  void _editSchool() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit School',
      content: TextField(
        controller: TextEditingController(text: _profile?.school),
        style: TextStyle(color: kTextPrimary),
        decoration: InputDecoration(
          hintText: 'Enter your school',
          hintStyle: TextStyle(color: kTextSecondary),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kPurpleAccent),
          ),
        ),
      ),
      onSave: () {
        if (_profile != null) {
          _updateProfile(_profile!.copyWith(
              school: TextEditingController(text: _profile?.school).text));
          Navigator.pop(context);
        }
      },
    );
  }

  void _editBio() {
    // Check for null profile
    if (_profile == null) {
      debugPrint('Cannot edit bio: profile is null');
      return;
    }

    // Set controller text from current profile
    _bioController.text = _profile?.bio ?? '';

    _showBottomSheet(
      title: 'Edit Bio',
      content: TextField(
        controller: _bioController,
        style: TextStyle(color: kTextPrimary),
        maxLines: 5,
        decoration: InputDecoration(
          hintText: 'Tell us about yourself',
          hintStyle: TextStyle(color: kTextSecondary),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: kPurpleAccent),
          ),
        ),
      ),
      onSave: () {
        if (_profile != null) {
          final String newBio = _bioController.text.trim();
          _updateProfile(_profile!.copyWith(bio: newBio));
          Navigator.pop(context);

          // Show confirmation
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text('Bio updated. Don\'t forget to save your profile.')),
          );
        }
      },
    );
  }

  void _editZodiacSign() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Zodiac Sign',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var sign in ZodiacSign.values)
            ListTile(
              title: Text(sign.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(zodiacSign: sign));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editEducation() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Education',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var education in EducationLevel.values)
            ListTile(
              title: Text(education.display),
              onTap: () {
                _updateProfile(
                    _profile!.copyWith(educationLevels: [education]));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editCommunicationStyles() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Communication Styles',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var style in CommunicationStyle.values)
            ListTile(
              title: Text(style.display),
              onTap: () {
                _updateProfile(
                    _profile!.copyWith(communicationStyles: [style]));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editLoveLanguages() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Love Languages',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var language in LoveLanguage.values)
            ListTile(
              title: Text(language.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(loveLanguages: [language]));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editDrinking() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Drinking Preference',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var option in DrinkingHabit.values)
            ListTile(
              title: Text(option.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(drinkingHabit: option));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editSmoking() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Smoking Preference',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var option in SmokingHabit.values)
            ListTile(
              title: Text(option.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(smokingHabit: option));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editWorkout() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Workout Preference',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var option in WorkoutHabit.values)
            ListTile(
              title: Text(option.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(workoutHabit: option));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editDiet() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Diet Preference',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var option in DietaryPreference.values)
            ListTile(
              title: Text(option.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(dietaryPreference: option));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editSleep() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Sleep Preference',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var option in SleepingHabit.values)
            ListTile(
              title: Text(option.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(sleepingHabit: option));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editPets() {
    // Check for null profile
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Edit Pet Preference',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var option in PetOption.values)
            ListTile(
              title: Text(option.display),
              onTap: () {
                _updateProfile(_profile!.copyWith(pets: [option]));
                Navigator.pop(context);
              },
            ),
        ],
      ),
      onSave: () {},
    );
  }

  void _editInterests() {
    // Safely handle null profile
    if (_profile == null) return;

    List<Interest> selectedInterests = List.from(_profile?.interests ?? []);

    _showBottomSheet(
      title: 'Edit Interests',
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Select your interests (${selectedInterests.length}/${Interest.values.length})',
                style: TextStyle(color: kTextSecondary, fontSize: 14),
              ),
              SizedBox(height: 8),

              // Selected interests chips - make it safer with fixed height
              if (selectedInterests.isNotEmpty)
                Container(
                  height: 56,
                  margin: EdgeInsets.only(bottom: 8),
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: selectedInterests.map((interest) {
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: Chip(
                          backgroundColor: kChipBackground,
                          label: Text(
                            interest.display,
                            style: TextStyle(color: kTextPrimary),
                          ),
                          deleteIcon: Icon(Icons.close,
                              size: 16, color: kTextSecondary),
                          onDeleted: () {
                            setState(() {
                              selectedInterests.remove(interest);
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
                ),

              Divider(color: kSectionBackground),
              SizedBox(height: 8),

              // All available interests - limit height and make it scrollable
              Container(
                height: 300, // Fixed height
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: Interest.values.length,
                  itemBuilder: (context, index) {
                    final interest = Interest.values[index];
                    return CheckboxListTile(
                      title: Text(
                        interest.display,
                        style: TextStyle(color: kTextPrimary),
                      ),
                      activeColor: kPurpleAccent,
                      checkColor: kTextPrimary,
                      value: selectedInterests.contains(interest),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            if (!selectedInterests.contains(interest)) {
                              selectedInterests.add(interest);
                            }
                          } else {
                            selectedInterests.removeWhere(
                                (item) => item.display == interest.display);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
      onSave: () {
        if (_profile != null) {
          _updateProfile(_profile!.copyWith(interests: selectedInterests));
          Navigator.pop(context);
        }
      },
    );
  }

  void _showPhotoOptions(int index) {
    _showBottomSheet(
      title: index == 0 ? 'Main Photo' : 'Photo ${index + 1}',
      content: Column(
        children: [
          if (index > 0)
            ListTile(
              leading: Icon(Icons.photo, color: kPurpleAccent),
              title: Text('Set as Main Photo'),
              onTap: () {
                final mainPhoto = _profile!.mainPhotoUrl;
                final selectedPhoto = _profile!.additionalPhotos[index - 1];

                List<String> updatedPhotos =
                    List.from(_profile!.additionalPhotos);
                if (mainPhoto != null) {
                  updatedPhotos[index - 1] = mainPhoto;
                } else {
                  updatedPhotos.removeAt(index - 1);
                }

                _updateProfile(_profile!.copyWith(
                    mainPhotoUrl: selectedPhoto,
                    additionalPhotos: updatedPhotos));
                Navigator.pop(context);
              },
            ),
          ListTile(
            leading: Icon(Icons.edit, color: kPurpleAccent),
            title: Text('Change Photo'),
            onTap: () {
              Navigator.pop(context);
              _editPhoto(index);
            },
          ),
          ListTile(
            leading: Icon(Icons.delete, color: Colors.red),
            title: Text('Delete Photo'),
            onTap: () async {
              if (index == 0) {
                _updateProfile(_profile!.copyWith(mainPhotoUrl: null));
              } else {
                List<String> updatedPhotos =
                    List.from(_profile!.additionalPhotos);
                updatedPhotos.removeAt(index - 1);
                _updateProfile(
                    _profile!.copyWith(additionalPhotos: updatedPhotos));
              }
              await _profileService.deleteProfilePicture(_profile!.uid);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      onSave: () {},
    );
  }

  void _showPhotoManagement() {
    // Handle null profile safely
    if (_profile == null) return;

    _showBottomSheet(
      title: 'Manage Photos',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Main Photo',
            style: TextStyle(
              color: kTextPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),

          // Main photo row
          if (_profile?.mainPhotoUrl != null)
            ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: kElevatedShadow,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: _buildPhotoWidget(_profile!.mainPhotoUrl!),
                ),
              ),
              title: Text(
                'Profile Photo',
                style: TextStyle(color: kTextPrimary),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.edit, color: kPurpleAccent),
                    onPressed: () {
                      Navigator.pop(context);
                      _editPhoto(0);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () async {
                      Navigator.pop(context);
                      _updateProfile(_profile!.copyWith(mainPhotoUrl: null));
                      await _profileService.deleteProfilePicture(_profile!.uid);
                    },
                  ),
                ],
              ),
            )
          else
            ListTile(
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: kSectionBackground,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.person, color: kTextSecondary),
              ),
              title: Text(
                'No Profile Photo',
                style: TextStyle(color: kTextPrimary),
              ),
              trailing: IconButton(
                icon: Icon(Icons.add_photo_alternate, color: kPurpleAccent),
                onPressed: () {
                  Navigator.pop(context);
                  _editPhoto(0);
                },
              ),
            ),

          SizedBox(height: 16),
          Divider(color: kSectionBackground),
          SizedBox(height: 8),

          // Additional photos header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Additional Photos',
                style: TextStyle(
                  color: kTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add_photo_alternate, color: kPurpleAccent),
                onPressed: () {
                  Navigator.pop(context);
                  _editPhoto((_profile?.additionalPhotos.length ?? 0) + 1);
                },
              ),
            ],
          ),
          SizedBox(height: 8),

          // Additional photos list - with limited height
          Container(
            height: 200, // Fixed height for the list view
            child: _profile?.additionalPhotos.isEmpty ?? true
                ? Center(
                    child: Text(
                      'No additional photos',
                      style: TextStyle(color: kTextSecondary),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    itemCount: _profile?.additionalPhotos.length ?? 0,
                    itemBuilder: (context, index) {
                      final photo = _profile!.additionalPhotos[index];
                      return ListTile(
                        key: ValueKey(photo),
                        leading: Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: _buildPhotoWidget(photo),
                          ),
                        ),
                        title: Text(
                          'Photo ${index + 1}',
                          style: TextStyle(color: kTextPrimary),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon:
                                  Icon(Icons.star_border, color: Colors.amber),
                              onPressed: () {
                                Navigator.pop(context);
                                final mainPhoto = _profile!.mainPhotoUrl;
                                final selectedPhoto =
                                    _profile!.additionalPhotos[index];

                                List<String> updatedPhotos =
                                    List.from(_profile!.additionalPhotos);
                                if (mainPhoto != null) {
                                  updatedPhotos[index] = mainPhoto;
                                } else {
                                  updatedPhotos.removeAt(index);
                                }

                                _updateProfile(_profile!.copyWith(
                                    mainPhotoUrl: selectedPhoto,
                                    additionalPhotos: updatedPhotos));
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                Navigator.pop(context);
                                List<String> updatedPhotos =
                                    List.from(_profile!.additionalPhotos);
                                updatedPhotos.removeAt(index);
                                _updateProfile(_profile!
                                    .copyWith(additionalPhotos: updatedPhotos));
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      onSave: () {},
      showActions: false,
    );
  }

  Widget _buildPhotoWidget(String photoPath) {
    if (photoPath.startsWith('http')) {
      // Handle network images
      return Image.network(
        photoPath,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.red,
              size: 32,
            ),
          );
        },
      );
    } else {
      // Handle local files
      return Image.file(
        File(photoPath),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Center(
            child: Icon(
              Icons.broken_image,
              color: Colors.red,
              size: 32,
            ),
          );
        },
      );
    }
  }

  Widget _buildInterestChip(Interest interest) {
    return Chip(
      backgroundColor: kChipBackground,
      label: Text(
        interest.display,
        style: TextStyle(color: kTextPrimary),
      ),
      deleteIcon: Icon(Icons.close, size: 16, color: kTextSecondary),
      onDeleted: () {
        if (_profile != null) {
          List<Interest> updatedInterests = List.from(_profile!.interests ?? [])
            ..removeWhere((item) => item.display == interest.display);
          _updateProfile(_profile!.copyWith(interests: updatedInterests));
        }
      },
    );
  }

  Widget _buildGenderSubOptionsLocal<T extends Enum>(
    List<T> options,
    UserProfile tempProfile,
    StateSetter setState,
  ) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: Column(
        children: options.map((option) {
          final display = (option as dynamic).display as String;
          return RadioListTile<String>(
            title: Text(display, style: TextStyle(color: kTextPrimary)),
            value: display,
            groupValue: tempProfile.genderSubOption,
            onChanged: (String? value) {
              if (value != null) {
                setState(() {
                  tempProfile = tempProfile.copyWith(genderSubOption: value);
                  debugPrint('Selected gender sub-option: $value');
                });
              }
            },
          );
        }).toList(),
      ),
    );
  }

  void _editDateOfBirth() async {
    // Handle null profile
    if (_profile == null) return;

    // If date of birth is already set, don't allow changes
    if (_profile!.dateOfBirth != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Date of birth cannot be changed once set')),
      );
      return;
    }

    final DateTime now = DateTime.now();
    final DateTime minAllowedDate =
        DateTime(now.year - 100, now.month, now.day);
    final DateTime maxAllowedDate = DateTime(now.year - 18, now.month, now.day);

    // Default to max allowed date if current date is null
    DateTime initialDate = maxAllowedDate;

    // Store selected date
    _selectedDate = initialDate;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle bar at the top
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: kTextSecondary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 16),

              // Title
              Text(
                'Select Birth Date',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: kTextPrimary),
              ),
              SizedBox(height: 8),

              Text(
                'This cannot be changed later, so please select carefully.',
                style: TextStyle(color: Colors.orange, fontSize: 14),
              ),
              SizedBox(height: 16),

              // Date picker
              Expanded(
                child: Theme(
                  data: ThemeData.dark().copyWith(
                    colorScheme: ColorScheme.dark(
                      primary: kPurpleAccent,
                      onPrimary: kTextPrimary,
                      surface: kSectionBackground,
                      onSurface: kTextPrimary,
                    ),
                    dialogBackgroundColor: kSectionBackground,
                  ),
                  child: CalendarDatePicker(
                    initialDate: initialDate,
                    firstDate: minAllowedDate,
                    lastDate: maxAllowedDate,
                    onDateChanged: (DateTime date) {
                      _selectedDate = date;
                    },
                  ),
                ),
              ),

              // Action buttons
              Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          color: kTextSecondary,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        if (_profile != null && _selectedDate != null) {
                          _updateProfile(
                              _profile!.copyWith(dateOfBirth: _selectedDate));
                          Navigator.pop(context);

                          // Show confirmation message
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                  'Date of birth set. This cannot be changed.'),
                              duration: Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: kTextPrimary,
                        backgroundColor: kPurpleAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding:
                            EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        'Confirm',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showPhotoCompletionBanner() {
    // Don't show the banner if user is not logged in
    if (_authService.currentUser == null) return;

    ScaffoldMessenger.of(context).showMaterialBanner(
      MaterialBanner(
        backgroundColor: kSectionBackground,
        content: Text(
          'Your profile needs a main photo. Add one now to complete your profile.',
          style: TextStyle(color: kTextPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
              _showPhotoManagement();
            },
            child: Text(
              'Add Photos',
              style: TextStyle(color: kPurpleAccent),
            ),
          ),
          TextButton(
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentMaterialBanner();
            },
            child: Text(
              'Later',
              style: TextStyle(color: kTextSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _showProfileCompletionGuide() {
    // Check if profile is available
    if (_profile == null) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: kSectionBackground,
        title: Text(
          'Complete Your Profile',
          style: TextStyle(color: kTextPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your profile requires the following:',
              style: TextStyle(color: kTextPrimary),
            ),
            SizedBox(height: 16),
            // Display name requirement
            Row(
              children: [
                Icon(
                  _profile?.displayName?.isNotEmpty == true
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: _profile?.displayName?.isNotEmpty == true
                      ? Colors.green
                      : kTextSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Display name',
                  style: TextStyle(color: kTextPrimary),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Main photo requirement
            Row(
              children: [
                Icon(
                  _profile?.mainPhotoUrl != null
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: _profile?.mainPhotoUrl != null
                      ? Colors.green
                      : kTextSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Main profile photo',
                  style: TextStyle(color: kTextPrimary),
                ),
              ],
            ),
            SizedBox(height: 8),
            // Additional photos requirement
            Row(
              children: [
                Icon(
                  (_profile?.additionalPhotos.length ?? 0) > 0
                      ? Icons.check_circle
                      : Icons.circle_outlined,
                  color: (_profile?.additionalPhotos.length ?? 0) > 0
                      ? Colors.green
                      : kTextSecondary,
                ),
                SizedBox(width: 8),
                Text(
                  'Additional photos (optional)',
                  style: TextStyle(color: kTextPrimary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text(
              'Later',
              style: TextStyle(color: kTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (_profile?.displayName?.isEmpty ?? true) {
                _editDisplayName();
              } else if (_profile?.mainPhotoUrl == null) {
                _editPhoto(0);
              } else {
                _showPhotoManagement();
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: kTextPrimary,
              backgroundColor: kPurpleAccent,
            ),
            child: Text('Complete Now'),
          ),
        ],
      ),
    );
  }

  // Add method to handle account deletion
  Future<void> _deleteAccount() async {
    // Get current user's email to use for re-authentication
    final currentUser = _authService.currentUser;
    if (currentUser == null || currentUser.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You must be logged in to delete your account.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    debugPrint('Starting account deletion process for: ${currentUser.email}');

    // Check if the user needs reauthentication
    bool needsReauth = await _authService.needsReauthentication();
    debugPrint('User needs reauthentication: $needsReauth');

    // Password controller for authentication
    final TextEditingController passwordController = TextEditingController();
    bool passwordError = false;
    String passwordErrorText = 'Password is required';

    // Show confirmation dialog with password verification
    final confirmDelete = await showDialog<bool>(
          context: context,
          builder: (context) => StatefulBuilder(
            builder: (context, setState) => AlertDialog(
              backgroundColor: kSectionBackground,
              title: Text(
                'Delete Account',
                style:
                    TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
              content: Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.6,
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Please confirm your decision to delete your account:',
                        style: TextStyle(color: kTextPrimary),
                      ),
                      SizedBox(height: 16),
                      Text(
                        '• You\'ll have 90 days to restore your account before your data is permanently deleted',
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        '• During this period, your profile won\'t be visible to others',
                        style: TextStyle(color: kTextPrimary),
                      ),
                      Text(
                        '• To restore your account, simply log in again',
                        style: TextStyle(color: kTextPrimary),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Please enter your password to confirm deletion:',
                        style: TextStyle(color: kTextPrimary),
                      ),
                      SizedBox(height: 8),
                      TextField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          fillColor: kInputBackground,
                          filled: true,
                          hintText: 'Password',
                          hintStyle: TextStyle(color: kTextSecondary),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          errorText: passwordError ? passwordErrorText : null,
                        ),
                        style: TextStyle(color: kTextPrimary),
                        onChanged: (_) {
                          // Clear error when user types
                          if (passwordError) {
                            setState(() => passwordError = false);
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: kTextSecondary),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    final password = passwordController.text.trim();
                    if (password.isEmpty) {
                      setState(() {
                        passwordError = true;
                        passwordErrorText = 'Password is required';
                      });
                    } else if (password.length < 6) {
                      setState(() {
                        passwordError = true;
                        passwordErrorText =
                            'Password must be at least 6 characters';
                      });
                    } else {
                      Navigator.of(context).pop(true);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.red,
                  ),
                  child: Text('Delete Account'),
                ),
              ],
            ),
          ),
        ) ??
        false;

    if (!confirmDelete) {
      debugPrint('User cancelled account deletion');
      return;
    }

    debugPrint(
        'User confirmed account deletion, proceeding with authentication');

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: kSectionBackground,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: kPurpleAccent),
                    SizedBox(width: 20),
                    Flexible(
                      child: Text(
                        'Scheduling account for deletion...',
                        style: TextStyle(color: kTextPrimary),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      );

      // Reauthenticate with the provided password
      if (needsReauth) {
        try {
          debugPrint(
              'Attempting to reauthenticate with email: ${currentUser.email}');

          // Handle the PigeonUserDetails error that occurs in newer Firebase versions
          try {
            await _authService.reauthenticate(
                currentUser.email!, passwordController.text);
            debugPrint('Reauthentication successful');
          } catch (e) {
            // If the error is the specific PigeonUserDetails type error
            if (e.toString().contains(
                "type 'List<Object?>' is not a subtype of type 'PigeonUserDetails?'")) {
              debugPrint(
                  'Caught PigeonUserDetails error, using alternative method');

              // Use a workaround by signing in again instead of reauthenticating
              await _authService.signInWithEmailAndPassword(
                email: currentUser.email!,
                password: passwordController.text,
              );
              debugPrint('Signed in successfully instead of reauthenticating');
            } else {
              // Rethrow if it's a different error
              rethrow;
            }
          }
        } catch (authError) {
          // Close the loading dialog
          if (mounted) Navigator.of(context, rootNavigator: true).pop();

          // Show specific error for wrong password
          if (mounted) {
            String errorMessage = 'Authentication failed. Please try again.';

            // Format user-friendly error message
            if (authError.toString().contains('wrong-password')) {
              errorMessage = 'Incorrect password. Please try again.';
            } else if (authError.toString().contains('too-many-requests')) {
              errorMessage =
                  'Too many unsuccessful attempts. Please try again later.';
            } else if (authError.toString().contains('email-mismatch')) {
              errorMessage =
                  'Email address doesn\'t match your current account.';
            } else if (authError.toString().contains('user-mismatch')) {
              errorMessage =
                  'The provided credentials don\'t match your account.';
            } else if (authError.toString().contains('invalid-credential')) {
              errorMessage = 'Invalid login credentials. Please try again.';
            } else if (authError
                .toString()
                .contains('network-request-failed')) {
              errorMessage =
                  'Network error. Please check your internet connection and try again.';
            }

            debugPrint('Authentication error: $authError');
            debugPrint('Showing error message: $errorMessage');

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }
      } else {
        debugPrint('Reauthentication not needed, proceeding with deletion');
      }

      // Delete profile first (this ensures we clean up all data even if auth deletion fails)
      debugPrint('Deleting profile data');
      await _profileService.deleteProfile(widget.uid);
      debugPrint('Profile data deleted successfully');

      // Send account deletion notification email
      debugPrint('Sending deletion notification email');
      try {
        await _authService.sendAccountDeletionEmail(currentUser.email!);
        debugPrint('Deletion notification email sent');
      } catch (emailError) {
        debugPrint('Error sending deletion email: $emailError');
        // Continue with deletion even if email fails
      }

      // Delete the authentication account
      debugPrint('Deleting Firebase auth account');
      try {
        await _authService.deleteAccount();
        debugPrint('Auth account deletion initiated');
      } catch (deleteError) {
        debugPrint('Error during auth account deletion: $deleteError');
        // If auth deletion fails, at least we've marked the profile for deletion
        // and signed the user out
      }

      // Close the dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      // Navigate to landing page
      if (mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Your account has been scheduled for deletion and you\'ve been signed out. You can restore your account within 90 days by logging back in.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      // Close the loading dialog
      if (mounted) Navigator.of(context, rootNavigator: true).pop();

      // Show error message
      if (mounted) {
        debugPrint('Unexpected error during account deletion: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting account: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: kBackgroundColor,
        body: Center(child: CircularProgressIndicator(color: kPurpleAccent)),
      );
    }

    // Check if profile is complete
    bool isProfileComplete = _profile?.displayName?.isNotEmpty == true &&
        _profile?.mainPhotoUrl != null;

    // Check if required fields are filled
    bool hasRequiredFields = _hasRequiredProfileFields();

    return WillPopScope(
      // Prevent back navigation if required fields aren't set
      onWillPop: () async {
        if (!hasRequiredFields) {
          _showRequiredFieldsDialog();
          return false;
        }

        // If there are unsaved changes, show confirmation dialog
        if (_hasUnsavedChanges) {
          bool shouldPop = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: kSectionBackground,
                  title: Text(
                    'Unsaved Changes',
                    style: TextStyle(color: kTextPrimary),
                  ),
                  content: Container(
                    width: double.maxFinite,
                    child: Text(
                      'You have unsaved changes. Do you want to save them before leaving?',
                      style: TextStyle(color: kTextSecondary),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context)
                            .pop(true); // Allow pop and discard changes
                      },
                      child: Text(
                        'Discard',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(false); // Don't allow pop
                      },
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: kTextSecondary),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        await _saveProfile();
                        if (mounted) {
                          Navigator.of(context)
                              .pop(true); // Allow pop after saving
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        foregroundColor: kTextPrimary,
                        backgroundColor: kPurpleAccent,
                      ),
                      child: Text('Save'),
                    ),
                  ],
                ),
              ) ??
              false;
          return shouldPop;
        }
        return hasRequiredFields; // Only allow pop if required fields are set
      },
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: kBackgroundColor,
          title: Text(
            _profile?.displayName?.isNotEmpty == true
                ? _profile!.displayName
                : 'Complete Your Profile',
            style: TextStyle(color: kTextPrimary, fontWeight: FontWeight.bold),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: kTextPrimary),
            onPressed: () {
              if (!hasRequiredFields) {
                _showRequiredFieldsDialog();
                return;
              }

              if (_hasUnsavedChanges) {
                // Show confirmation dialog before leaving
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    backgroundColor: kSectionBackground,
                    title: Text(
                      'Unsaved Changes',
                      style: TextStyle(color: kTextPrimary),
                    ),
                    content: Container(
                      width: double.maxFinite,
                      child: Text(
                        'You have unsaved changes. Do you want to save them before leaving?',
                        style: TextStyle(color: kTextSecondary),
                      ),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context)
                              .pop(true); // Allow pop and discard changes
                        },
                        child: Text(
                          'Discard',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(false); // Don't allow pop
                        },
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: kTextSecondary),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          await _saveProfile();
                          if (mounted) {
                            Navigator.of(context)
                                .pop(true); // Allow pop after saving
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: kTextPrimary,
                          backgroundColor: kPurpleAccent,
                        ),
                        child: Text('Save'),
                      ),
                    ],
                  ),
                );
              } else {
                Navigator.of(context).pop();
              }
            },
          ),
          actions: [
            // Show required fields indicator if profile is incomplete
            if (!hasRequiredFields)
              TextButton.icon(
                icon: Icon(Icons.warning_amber_rounded, color: Colors.red),
                label: Text(
                  'Required',
                  style: TextStyle(color: Colors.red),
                ),
                onPressed: _showRequiredFieldsDialog,
              )
            // Show complete profile action if photos are incomplete
            else if (!isProfileComplete)
              TextButton.icon(
                icon: Icon(Icons.warning_amber_rounded, color: Colors.amber),
                label: Text(
                  'Complete',
                  style: TextStyle(color: Colors.amber),
                ),
                onPressed: _showProfileCompletionGuide,
              ),
            IconButton(
              icon: Icon(Icons.settings, color: kTextPrimary),
              onPressed: () {
                // Navigate to settings or show settings bottom sheet
                _showBottomSheet(
                  title: 'Profile Settings',
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: Icon(Icons.edit, color: kPurpleAccent),
                        title: Text('Edit Profile',
                            style: TextStyle(color: kTextPrimary)),
                        onTap: () {
                          Navigator.pop(context);
                          // Scroll to profile section
                          _scrollController.animateTo(
                            0,
                            duration: Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        },
                      ),
                      ListTile(
                        leading:
                            Icon(Icons.photo_library, color: kPurpleAccent),
                        title: Text('Manage Photos',
                            style: TextStyle(color: kTextPrimary)),
                        onTap: () {
                          Navigator.pop(context);
                          _showPhotoManagement();
                        },
                      ),
                      Divider(color: kSectionBackground),
                      ListTile(
                        leading: Icon(Icons.delete_forever, color: Colors.red),
                        title: Text('Delete Account',
                            style: TextStyle(color: Colors.red)),
                        onTap: () {
                          Navigator.pop(context);
                          _deleteAccount();
                        },
                      ),
                    ],
                  ),
                  onSave: () {},
                  showActions: false,
                );
              },
            ),
          ],
        ),
        // Add Floating Action Button for saving changes
        floatingActionButton: _hasUnsavedChanges
            ? FloatingActionButton(
                onPressed: _saveProfile,
                backgroundColor: kPurpleAccent,
                child: Icon(Icons.save, color: kTextPrimary),
              )
            : null,
        // Add banner for required fields
        bottomNavigationBar: !hasRequiredFields
            ? Container(
                color: Colors.red.withOpacity(0.8),
                padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Please complete the required fields to continue',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: _showRequiredFieldsDialog,
                      child: Text(
                        'VIEW',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              )
            : null,
        body: RefreshIndicator(
          color: kPurpleAccent,
          onRefresh: _loadProfile,
          child: SingleChildScrollView(
            controller: _scrollController,
            physics: AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Profile Photos Section
                  _buildPhotoSection(),

                  // Tab Bar Navigation
                  _buildTabBar(),

                  // Basic Info Section
                  _buildInfoSection(
                    "Basic Info",
                    [
                      _buildInfoItem(
                        "Display Name",
                        _profile?.displayName ?? "Add display name",
                        _editDisplayName,
                      ),
                      _buildInfoItem(
                        "Username",
                        _profile?.username ?? "Add username",
                        _editUsername,
                      ),
                      _buildInfoItem(
                        "Gender",
                        _profile?.genderSubOption != null
                            ? "${_profile?.gender?.display} (${_profile?.genderSubOption})"
                            : _profile?.gender?.display ?? "Add gender",
                        _editGender,
                      ),
                      _buildInfoItem(
                        "Date of Birth",
                        _profile?.dateOfBirth != null
                            ? "${_profile!.dateOfBirth!.day}/${_profile!.dateOfBirth!.month}/${_profile!.dateOfBirth!.year}"
                            : "Add date of birth",
                        _editDateOfBirth,
                      ),
                      _buildInfoItem(
                        "Height",
                        _profile?.height != null
                            ? "${_profile!.height} cm"
                            : "Add height",
                        _editHeight,
                      ),
                      _buildInfoItem(
                        "Looking For",
                        _profile?.lookingFor.isNotEmpty == true
                            ? _profile!.lookingFor
                                .map((e) => e.display)
                                .join(", ")
                            : "Add what you're looking for",
                        _editLookingFor,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Bio Section
                  _buildInfoSection(
                    "About Me",
                    [
                      _buildInfoItem(
                        "Bio",
                        _profile?.bio?.isNotEmpty == true
                            ? _profile!.bio!
                            : "Add a bio",
                        _editBio,
                        isMultiLine: true,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Work & Education
                  _buildInfoSection(
                    "Work & Education",
                    [
                      _buildInfoItem(
                        "Occupation",
                        _profile?.jobTitle ?? "Add occupation",
                        _editOccupation,
                      ),
                      _buildInfoItem(
                        "School",
                        _profile?.school ?? "Add school",
                        _editSchool,
                      ),
                      _buildInfoItem(
                        "Education Level",
                        _profile?.educationLevels.isNotEmpty == true
                            ? _profile!.educationLevels
                                .map((e) => e.display)
                                .join(", ")
                            : "Add education level",
                        _editEducation,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Lifestyle
                  _buildInfoSection(
                    "Lifestyle",
                    [
                      _buildInfoItem(
                        "Zodiac Sign",
                        _profile?.zodiacSign?.display ?? "Add zodiac sign",
                        _editZodiacSign,
                      ),
                      _buildInfoItem(
                        "Communication Style",
                        _profile?.communicationStyles.isNotEmpty == true
                            ? _profile!.communicationStyles
                                .map((e) => e.display)
                                .join(", ")
                            : "Add communication style",
                        _editCommunicationStyles,
                      ),
                      _buildInfoItem(
                        "Love Languages",
                        _profile?.loveLanguages.isNotEmpty == true
                            ? _profile!.loveLanguages
                                .map((e) => e.display)
                                .join(", ")
                            : "Add love languages",
                        _editLoveLanguages,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Habits
                  _buildInfoSection(
                    "Habits",
                    [
                      _buildInfoItem(
                        "Drinking",
                        _profile?.drinkingHabit?.display ??
                            "Add drinking habits",
                        _editDrinking,
                      ),
                      _buildInfoItem(
                        "Smoking",
                        _profile?.smokingHabit?.display ?? "Add smoking habits",
                        _editSmoking,
                      ),
                      _buildInfoItem(
                        "Workout",
                        _profile?.workoutHabit?.display ?? "Add workout habits",
                        _editWorkout,
                      ),
                      _buildInfoItem(
                        "Diet",
                        _profile?.dietaryPreference?.display ??
                            "Add dietary preferences",
                        _editDiet,
                      ),
                      _buildInfoItem(
                        "Sleep",
                        _profile?.sleepingHabit?.display ??
                            "Add sleeping habits",
                        _editSleep,
                      ),
                      _buildInfoItem(
                        "Pets",
                        _profile?.pets.isNotEmpty == true
                            ? _profile!.pets.map((e) => e.display).join(", ")
                            : "Add pet preferences",
                        _editPets,
                      ),
                    ],
                  ),

                  SizedBox(height: 20),

                  // Interests
                  _buildInterestsSection(),

                  SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    // Handle null profile
    if (_profile == null) {
      return Container(
        height: 320,
        child: Center(
          child: Text(
            'Profile data not available',
            style: TextStyle(color: kTextSecondary),
          ),
        ),
      );
    }

    final int totalPhotos = (_profile!.additionalPhotos.length) +
        1 +
        1; // +1 for main photo, +1 for add photo

    return Column(
      children: [
        Container(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            itemCount: totalPhotos,
            itemBuilder: (context, index) {
              if (index == 0) {
                // Main photo
                return _buildPhotoCard(
                  _profile?.mainPhotoUrl,
                  index,
                  isMain: true,
                );
              } else if (index <= (_profile?.additionalPhotos.length ?? 0)) {
                // Additional photos
                return _buildPhotoCard(
                  _profile?.additionalPhotos[index - 1],
                  index,
                );
              } else {
                // Add photo button
                return GestureDetector(
                  onTap: () =>
                      _editPhoto((_profile?.additionalPhotos.length ?? 0) + 1),
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: kSectionBackground,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: kPurpleAccent,
                          width: 1,
                          style: BorderStyle.solid),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate,
                              size: 64, color: kPurpleAccent),
                          SizedBox(height: 16),
                          Text(
                            'Add Photo',
                            style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }
            },
          ),
        ),

        // Photo indicators
        SizedBox(height: 16),
        if (totalPhotos > 1)
          Builder(builder: (context) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(totalPhotos, (index) {
                return AnimatedContainer(
                  duration: Duration(milliseconds: 300),
                  margin: EdgeInsets.symmetric(horizontal: 4),
                  height: 8,
                  width: _currentPhotoPage == index ? 24 : 8,
                  decoration: BoxDecoration(
                    color: _currentPhotoPage == index
                        ? kPurpleAccent
                        : kSectionBackground,
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              }),
            );
          }),

        // Manage photos button
        SizedBox(height: 16),
        if ((_profile?.additionalPhotos.length ?? 0) > 0)
          TextButton.icon(
            onPressed: _showPhotoManagement,
            icon: Icon(Icons.photo_library, color: kPurpleAccent),
            label: Text(
              'Manage Photos',
              style: TextStyle(color: kPurpleAccent),
            ),
          ),
      ],
    );
  }

  Widget _buildPhotoCard(String? photoUrl, int index, {bool isMain = false}) {
    return GestureDetector(
      onTap: () => _showPhotoOptions(index),
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: kSectionBackground,
              borderRadius: BorderRadius.circular(16),
              boxShadow: isMain ? kElevatedShadow : null,
              border: isMain
                  ? Border.all(
                      color: kPurpleAccent,
                      width: 2,
                      style: BorderStyle.solid,
                    )
                  : null,
            ),
            child: photoUrl == null
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.person,
                          size: 64,
                          color: kTextSecondary,
                        ),
                        SizedBox(height: 16),
                        Text(
                          isMain ? 'Add Profile Photo' : 'Add Photo',
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : ClipRRect(
                    borderRadius: BorderRadius.circular(
                        14), // Adjusted to account for the border
                    child: _buildPhotoWidget(photoUrl),
                  ),
          ),
          if (isMain && photoUrl != null)
            Positioned(
              bottom: 16,
              left: 16,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: kBackgroundColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.amber,
                      size: 18,
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Main Photo',
                      style: TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> items) {
    return Container(
      decoration: kNeonBorderDecoration,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: kTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 16),
          ...items,
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, VoidCallback onTap,
      {bool isMultiLine = false}) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: value.contains("Add") ? kPurpleAccent : kTextPrimary,
                fontSize: 16,
                fontStyle:
                    value.contains("Add") ? FontStyle.italic : FontStyle.normal,
              ),
              maxLines: isMultiLine ? 5 : 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 4),
            Divider(color: kSectionBackground),
          ],
        ),
      ),
    );
  }

  Widget _buildInterestsSection() {
    return Container(
      decoration: kNeonBorderDecoration,
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Interests",
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                icon: Icon(Icons.add, color: kPurpleAccent),
                onPressed: _editInterests,
              ),
            ],
          ),
          SizedBox(height: 16),
          if (_profile?.interests.isEmpty ?? true)
            Text(
              "Add your interests",
              style: TextStyle(
                color: kPurpleAccent,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _profile!.interests
                  .map((interest) => _buildInterestChip(interest))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
