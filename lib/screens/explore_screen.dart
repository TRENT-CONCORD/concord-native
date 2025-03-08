import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart'; // Import WebSocket channel
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/user_profile.dart';
import '../models/profile_enums.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:geolocator/geolocator.dart'; // Import geolocator package
import 'package:shared_preferences/shared_preferences.dart'; // Import shared_preferences for local storage
import 'package:flutter_svg/flutter_svg.dart'; // Import flutter_svg for SVG support
import 'dart:async'; // Import dart:async for Timer
import 'dart:math';
import '../services/api_service.dart'; // Import the API service

class ExploreScreen extends StatefulWidget {
  @override
  _ExploreScreenState createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  // Placeholder for filters
  List<GenderOption> selectedGenders = [];
  List<String> selectedSecondaryGenders = [];
  RangeValues ageRange = RangeValues(18, 40);
  List<EducationLevel> selectedEducationLevels = [];
  List<CommunicationStyle> selectedCommunicationStyles = [];
  List<LoveLanguage> selectedLoveLanguages = [];
  List<Interest> selectedInterests = [];
  SmokingHabit? selectedSmokingHabit;
  DrinkingHabit? selectedDrinkingHabit;
  WorkoutHabit? selectedWorkoutHabit;
  DietaryPreference? selectedDietaryPreference;
  SleepingHabit? selectedSleepingHabit;
  String? selectedLocation;
  double maxDistance = 50; // Default max distance in kilometers
  double? userLatitude;
  double? userLongitude;
  late AnimationController _flyoutAnimationController;

  // Pagination and loading state
  bool _isLoading = false;
  bool _hasMoreUsers = true;
  int _currentOffset = 0;
  final int _pageSize = 20;
  List<Map<String, dynamic>> _users = [];
  final ScrollController _scrollController = ScrollController();
  bool _isApiAvailable = true; // Track if API is available

  // API Service
  final ApiService _apiService = ApiService();

  // WebSocket channel for real-time updates
  WebSocketChannel? _webSocketChannel;

  // Dummy channel getter to prevent null issues
  WebSocketChannel get _channel {
    // Return a dummy channel if the real one isn't initialized
    _webSocketChannel ??= IOWebSocketChannel.connect(
        'ws://${_apiService.baseUrl.replaceFirst('https://', '')}/ws/explore');
    return _webSocketChannel!;
  }

  @override
  void initState() {
    super.initState();
    _flyoutAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Test API connectivity first
    _testApiConnectivity();

    // Load saved filters
    _loadSavedFilter();

    // Get user's current location
    _getUserLocation();

    // Initialize real-time updates system
    _initializeRealTimeUpdates();

    // Load initial users
    _loadUsers();

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _flyoutAnimationController.dispose();

    // Disconnect from WebSocket
    _apiService.disconnectFromExploreWebSocket();

    super.dispose();
  }

  // Add a mounted check before calling setState
  void _safeSetState(VoidCallback fn) {
    if (mounted) {
      setState(fn);
    }
  }

  // Update WebSocket handlers to use _safeSetState
  void _handleUserUpdated(Map<String, dynamic> updatedUser) {
    _safeSetState(() {
      final index =
          _users.indexWhere((user) => user['id'] == updatedUser['id']);
      if (index != -1) {
        _users[index] = updatedUser;
      }
    });
  }

  void _handleNewUser(Map<String, dynamic> newUser) {
    _safeSetState(() {
      _users.insert(0, newUser);
    });
  }

  // Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      if (!_isLoading && _hasMoreUsers) {
        _loadMoreUsers();
      }
    }
  }

  // Load initial users
  Future<void> _loadUsers() async {
    setState(() {
      _isLoading = true;
      _currentOffset = 0;
      _hasMoreUsers = true;
    });

    try {
      // Build filters from selected options
      final filters = _buildQueryParams();

      // Get users from API service
      final users = await _apiService.getExploreUsers(
        offset: _currentOffset,
        limit: _pageSize,
        filters: filters,
        latitude: userLatitude,
        longitude: userLongitude,
        maxDistance: maxDistance,
      );

      setState(() {
        _users = users;
        _isLoading = false;
        _hasMoreUsers = users.length >= _pageSize;
        _currentOffset += users.length;
        _isApiAvailable = _apiService.isApiAvailable;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isApiAvailable = false;
      });
      debugPrint('Error loading users: $e');
    }
  }

  // Load more users for pagination
  Future<void> _loadMoreUsers() async {
    if (_isLoading || !_hasMoreUsers) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Build filters from selected options
      final filters = _buildQueryParams();

      // Get more users from API service
      final users = await _apiService.getExploreUsers(
        offset: _currentOffset,
        limit: _pageSize,
        filters: filters,
        latitude: userLatitude,
        longitude: userLongitude,
        maxDistance: maxDistance,
      );

      setState(() {
        if (users.isEmpty) {
          _hasMoreUsers = false;
        } else {
          _users.addAll(users);
          _currentOffset += users.length;
          _hasMoreUsers = users.length >= _pageSize;
        }
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      debugPrint('Error loading more users: $e');
    }
  }

  // Prevent multiple navigation actions
  void _navigateToUserProfile(Map<String, dynamic> user) {
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Viewing ${user['name']}\'s profile'),
        backgroundColor: Color(0xFF4A148C),
        duration: Duration(seconds: 1),
        action: SnackBarAction(
          label: 'Details',
          textColor: Color(0xFFCC0AE6),
          onPressed: () {
            // TODO: Navigate to detailed profile view
          },
        ),
      ),
    );
  }

  Future<void> _getUserLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied.');
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        userLatitude = position.latitude;
        userLongitude = position.longitude;
      });
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  // Save filter preferences
  Future<void> _saveFilter() async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();

      // Build filter data
      final filterData = {
        'selectedGenders': selectedGenders.map((g) => g.name).toList(),
        'selectedSecondaryGenders': selectedSecondaryGenders,
        'ageRange': [ageRange.start.toInt(), ageRange.end.toInt()],
        'selectedEducationLevels':
            selectedEducationLevels.map((e) => e.name).toList(),
        'selectedCommunicationStyles':
            selectedCommunicationStyles.map((s) => s.name).toList(),
        'selectedLoveLanguages':
            selectedLoveLanguages.map((l) => l.name).toList(),
        'selectedInterests': selectedInterests.map((i) => i.name).toList(),
        'selectedSmokingHabit': selectedSmokingHabit?.name,
        'selectedDrinkingHabit': selectedDrinkingHabit?.name,
        'selectedWorkoutHabit': selectedWorkoutHabit?.name,
        'selectedDietaryPreference': selectedDietaryPreference?.name,
        'selectedSleepingHabit': selectedSleepingHabit?.name,
        'maxDistance': maxDistance,
      };

      // Save filters using API service
      final success = await _apiService.saveUserFilters(userId, filterData);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Filters saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error saving filters: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save filters. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Load saved filter preferences
  Future<void> _loadSavedFilter() async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();

      // Get filters from API service
      final filterData = await _apiService.getUserFilters(userId);

      if (filterData.isNotEmpty) {
        setState(() {
          // Parse gender filters
          if (filterData['selectedGenders'] != null) {
            selectedGenders = (filterData['selectedGenders'] as List)
                .map((g) => GenderOption.values.firstWhere((e) => e.name == g))
                .toList();
          }

          // Parse age range
          if (filterData['ageRange'] != null) {
            ageRange = RangeValues(
              (filterData['ageRange'][0] as int).toDouble(),
              (filterData['ageRange'][1] as int).toDouble(),
            );
          }

          // Parse education levels
          if (filterData['selectedEducationLevels'] != null) {
            selectedEducationLevels =
                (filterData['selectedEducationLevels'] as List)
                    .map((e) =>
                        EducationLevel.values.firstWhere((el) => el.name == e))
                    .toList();
          }

          // Parse communication styles
          if (filterData['selectedCommunicationStyles'] != null) {
            selectedCommunicationStyles =
                (filterData['selectedCommunicationStyles'] as List)
                    .map((s) => CommunicationStyle.values
                        .firstWhere((cs) => cs.name == s))
                    .toList();
          }

          // Parse love languages
          if (filterData['selectedLoveLanguages'] != null) {
            selectedLoveLanguages = (filterData['selectedLoveLanguages']
                    as List)
                .map(
                    (l) => LoveLanguage.values.firstWhere((ll) => ll.name == l))
                .toList();
          }

          // Parse interests
          if (filterData['selectedInterests'] != null) {
            selectedInterests = (filterData['selectedInterests'] as List)
                .map((i) => Interest.values.firstWhere((iv) => iv.name == i))
                .toList();
          }

          // Parse habits
          if (filterData['selectedSmokingHabit'] != null) {
            selectedSmokingHabit = SmokingHabit.values.firstWhere(
                (sh) => sh.name == filterData['selectedSmokingHabit']);
          }

          if (filterData['selectedDrinkingHabit'] != null) {
            selectedDrinkingHabit = DrinkingHabit.values.firstWhere(
                (dh) => dh.name == filterData['selectedDrinkingHabit']);
          }

          if (filterData['selectedWorkoutHabit'] != null) {
            selectedWorkoutHabit = WorkoutHabit.values.firstWhere(
                (wh) => wh.name == filterData['selectedWorkoutHabit']);
          }

          if (filterData['selectedDietaryPreference'] != null) {
            selectedDietaryPreference = DietaryPreference.values.firstWhere(
                (dp) => dp.name == filterData['selectedDietaryPreference']);
          }

          if (filterData['selectedSleepingHabit'] != null) {
            selectedSleepingHabit = SleepingHabit.values.firstWhere(
                (sh) => sh.name == filterData['selectedSleepingHabit']);
          }

          // Parse max distance
          if (filterData['maxDistance'] != null) {
            maxDistance = (filterData['maxDistance'] as num).toDouble();
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading saved filters: $e');
    }
  }

  // Test API connectivity
  Future<void> _testApiConnectivity() async {
    final isAvailable = await _apiService.testConnectivity();
    setState(() {
      _isApiAvailable = isAvailable;
    });
  }

  // Initialize real-time updates
  Future<void> _initializeRealTimeUpdates() async {
    try {
      // Get current user ID
      final userId = await _getCurrentUserId();

      // Connect to WebSocket for real-time updates
      final connected = await _apiService.connectToExploreWebSocket(userId);

      if (connected) {
        debugPrint('Successfully connected to real-time updates');

        // Listen for WebSocket events
        _apiService.wsEvents.listen((data) {
          if (data['event'] == 'userUpdated') {
            _handleUserUpdated(data['user']);
          } else if (data['event'] == 'newUser') {
            _handleNewUser(data['user']);
          }
        });
      } else {
        debugPrint(
            'Failed to connect to real-time updates, using polling fallback');
        _startPollingFallback();
      }
    } catch (e) {
      debugPrint('Error initializing real-time updates: $e');
      _startPollingFallback();
    }
  }

  // Fallback to polling if WebSocket is not available
  Timer? _pollingTimer;

  void _startPollingFallback() {
    // Cancel existing timer if any
    _pollingTimer?.cancel();

    // Poll for updates every 30 seconds
    _pollingTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (mounted) {
        _loadUsers();
      } else {
        timer.cancel();
      }
    });
  }

  Future<String> _getCurrentUserId() async {
    // Try to get user ID from SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      String? userId = prefs.getString('userId');
      if (userId != null && userId.isNotEmpty) {
        return userId;
      }
    } catch (e) {
      debugPrint('Error getting user ID from SharedPreferences: $e');
    }

    // Default placeholder value
    return 'user-${DateTime.now().millisecondsSinceEpoch}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure layout adjusts for keyboard
      appBar: AppBar(
        title: Text('Explore'),
        backgroundColor:
            Color(0xFF1A0033), // Match the darkest background color
        actions: [
          IconButton(
            icon: Icon(Icons.filter_list),
            onPressed: () {
              showModalBottomSheet(
                isScrollControlled: true,
                transitionAnimationController: _flyoutAnimationController,
                context: context,
                builder: (context) {
                  return DraggableScrollableSheet(
                    initialChildSize: 0.75,
                    minChildSize: 0.5,
                    maxChildSize: 0.9,
                    expand: false,
                    builder: (context, scrollController) {
                      return FractionallySizedBox(
                        heightFactor: 1.0,
                        child: Padding(
                          padding: EdgeInsets.only(
                            bottom: MediaQuery.of(context).viewInsets.bottom,
                          ),
                          child: Stack(
                            children: [
                              AnimatedContainer(
                                duration: Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1A0033),
                                      Color(0xFF2D0A4F)
                                    ],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ),
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(20),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFF7B1FA2).withOpacity(0.5),
                                      blurRadius: 20,
                                      spreadRadius: -5,
                                      offset: Offset(0, -10),
                                    ),
                                  ],
                                ),
                                child: SingleChildScrollView(
                                  controller: scrollController,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'Distance (km)',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'FuturisticFont',
                                        ),
                                      ),
                                      Slider(
                                        value: maxDistance,
                                        min: 1,
                                        max: 100,
                                        divisions: 99,
                                        label: '${maxDistance.toInt()} km',
                                        onChanged: (value) {
                                          setState(() {
                                            maxDistance = value;
                                          });
                                        },
                                      ),
                                      Text(
                                        'Gender',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'FuturisticFont',
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: GenderOption.values
                                            .map((gender) => gender.display)
                                            .toList(),
                                        selectedItems: selectedGenders
                                            .map((gender) => gender.display)
                                            .toList(),
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedGenders = selected
                                                .map((s) => GenderOption.values
                                                    .firstWhere(
                                                        (g) => g.display == s))
                                                .toList();
                                          });
                                        },
                                      ),
                                      if (selectedGenders.isNotEmpty) ...[
                                        SizedBox(height: 16),
                                        Text(
                                          'Secondary Genders',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                            fontFamily: 'FuturisticFont',
                                          ),
                                        ),
                                        SizedBox(height: 8),
                                        MultiSelectChip(
                                          items: _getSecondaryGenderOptions(),
                                          selectedItems:
                                              selectedSecondaryGenders,
                                          onSelectionChanged: (selected) {
                                            setState(() {
                                              selectedSecondaryGenders =
                                                  selected;
                                            });
                                          },
                                        ),
                                      ],
                                      SizedBox(height: 16),
                                      Text(
                                        'Age Range',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'FuturisticFont',
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      RangeSlider(
                                        values: ageRange,
                                        min: 18,
                                        max: 100,
                                        divisions: 82,
                                        labels: RangeLabels(
                                          ageRange.start.round().toString(),
                                          ageRange.end.round().toString(),
                                        ),
                                        onChanged: (RangeValues values) {
                                          setState(() {
                                            ageRange = values;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Education Level',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: EducationLevel.values
                                            .map((level) => level.display)
                                            .toList(),
                                        selectedItems: selectedEducationLevels
                                            .map((level) => level.display)
                                            .toList(),
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedEducationLevels = selected
                                                .map((s) => EducationLevel
                                                    .values
                                                    .firstWhere(
                                                        (e) => e.display == s))
                                                .toList();
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Communication Style',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: CommunicationStyle.values
                                            .map((style) => style.display)
                                            .toList(),
                                        selectedItems:
                                            selectedCommunicationStyles
                                                .map((style) => style.display)
                                                .toList(),
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedCommunicationStyles =
                                                selected
                                                    .map((s) =>
                                                        CommunicationStyle
                                                            .values
                                                            .firstWhere((e) =>
                                                                e.display == s))
                                                    .toList();
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Love Languages',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: LoveLanguage.values
                                            .map((language) => language.display)
                                            .toList(),
                                        selectedItems: selectedLoveLanguages
                                            .map((language) => language.display)
                                            .toList(),
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedLoveLanguages = selected
                                                .map((s) => LoveLanguage.values
                                                    .firstWhere(
                                                        (e) => e.display == s))
                                                .toList();
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Interests',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: Interest.values
                                            .map((interest) => interest.display)
                                            .toList(),
                                        selectedItems: selectedInterests
                                            .map((interest) => interest.display)
                                            .toList(),
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedInterests = selected
                                                .map((s) => Interest.values
                                                    .firstWhere(
                                                        (e) => e.display == s))
                                                .toList();
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Smoking',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: SmokingHabit.values
                                            .map((habit) => habit.display)
                                            .toList(),
                                        selectedItems: selectedSmokingHabit !=
                                                null
                                            ? [selectedSmokingHabit!.display]
                                            : [],
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedSmokingHabit =
                                                selected.isNotEmpty
                                                    ? SmokingHabit.values
                                                        .firstWhere((e) =>
                                                            e.display ==
                                                            selected.first)
                                                    : null;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Drinking',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: DrinkingHabit.values
                                            .map((habit) => habit.display)
                                            .toList(),
                                        selectedItems: selectedDrinkingHabit !=
                                                null
                                            ? [selectedDrinkingHabit!.display]
                                            : [],
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedDrinkingHabit = selected
                                                    .isNotEmpty
                                                ? DrinkingHabit.values
                                                    .firstWhere((e) =>
                                                        e.display ==
                                                        selected.first)
                                                : null;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Workout',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: WorkoutHabit.values
                                            .map((habit) => habit.display)
                                            .toList(),
                                        selectedItems: selectedWorkoutHabit !=
                                                null
                                            ? [selectedWorkoutHabit!.display]
                                            : [],
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedWorkoutHabit =
                                                selected.isNotEmpty
                                                    ? WorkoutHabit.values
                                                        .firstWhere((e) =>
                                                            e.display ==
                                                            selected.first)
                                                    : null;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Dietary Preferences',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: DietaryPreference.values
                                            .map((preference) =>
                                                preference.display)
                                            .toList(),
                                        selectedItems:
                                            selectedDietaryPreference != null
                                                ? [
                                                    selectedDietaryPreference!
                                                        .display
                                                  ]
                                                : [],
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedDietaryPreference =
                                                selected.isNotEmpty
                                                    ? DietaryPreference.values
                                                        .firstWhere((e) =>
                                                            e.display ==
                                                            selected.first)
                                                    : null;
                                          });
                                        },
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Sleeping',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily:
                                              'FuturisticFont', // Replace with actual font
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: SleepingHabit.values
                                            .map((habit) => habit.display)
                                            .toList(),
                                        selectedItems: selectedSleepingHabit !=
                                                null
                                            ? [selectedSleepingHabit!.display]
                                            : [],
                                        onSelectionChanged: (selected) {
                                          setState(() {
                                            selectedSleepingHabit = selected
                                                    .isNotEmpty
                                                ? SleepingHabit.values
                                                    .firstWhere((e) =>
                                                        e.display ==
                                                        selected.first)
                                                : null;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                right: 16,
                                child: FloatingActionButton(
                                  backgroundColor: Color(
                                      0xFF6A0DAD), // Brighter purple button
                                  onPressed: () async {
                                    if (Navigator.of(context).canPop()) {
                                      Navigator.of(context)
                                          .pop(); // Minimise the flyout
                                    }
                                    await _saveFilter(); // Save the filter
                                    _loadUsers(); // Refresh the user list after the flyout is closed
                                  },
                                  child: Icon(
                                    Icons.save,
                                    color: Colors.white,
                                    shadows: [
                                      BoxShadow(
                                        color: Color(0xFFCC0AE6),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFF1A0033), // Darker deep purple
              Color(0xFF2D0A4F), // Darker mid purple
              Color(0xFF3B1064), // Darker light purple
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadUsers,
          color: Color(0xFFCC0AE6),
          backgroundColor: Color(0xFF4A148C),
          child: Column(
            children: [
              // API Status Banner
              if (!_isApiAvailable)
                Container(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                  color: Colors.deepOrange.withOpacity(
                      0.7), // Darker orange that stands out on dark background
                  child: Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'API not available. Showing mock data.',
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ),
                      TextButton(
                        onPressed: _loadUsers,
                        child: Text(
                          'Retry',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              // User Grid or Empty State
              Expanded(
                child: _users.isEmpty && !_isLoading
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 64,
                              color: Colors.white70,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Try adjusting your filters',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Reset filters and reload
                                setState(() {
                                  selectedGenders = [];
                                  selectedSecondaryGenders = [];
                                  ageRange = RangeValues(18, 40);
                                  selectedEducationLevels = [];
                                  selectedCommunicationStyles = [];
                                  selectedLoveLanguages = [];
                                  selectedInterests = [];
                                  selectedSmokingHabit = null;
                                  selectedDrinkingHabit = null;
                                  selectedWorkoutHabit = null;
                                  selectedDietaryPreference = null;
                                  selectedSleepingHabit = null;
                                  maxDistance = 50;
                                });
                                _loadUsers();
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Reset Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(
                                    0xFF6A0DAD), // Brighter purple for better visibility
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 12),
                                elevation: 4,
                              ),
                            ),
                          ],
                        ),
                      )
                    : GridView.builder(
                        controller: _scrollController,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75, // Make cards taller
                        ),
                        padding: EdgeInsets.all(10),
                        itemCount: _users.length + (_hasMoreUsers ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index >= _users.length) {
                            // Build loading indicator at the end
                            return Center(
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Color(0xFFCC0AE6)),
                                ),
                              ),
                            );
                          }

                          final user = _users[index];
                          return GestureDetector(
                            onTap: () {
                              _navigateToUserProfile(user);
                            },
                            onLongPress: () {
                              // Show additional info in a tooltip
                              final tooltip = user['genders'] != null
                                  ? '${user['age']}, ${(user['genders'] as List).join(', ')}'
                                  : '${user['age']}';

                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(tooltip),
                                  backgroundColor: Color(0xFF4A148C),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 8,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              shadowColor: Color(0xFFCC0AE6),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  gradient: LinearGradient(
                                    colors: [
                                      Color(0xFF1A0033).withOpacity(0.9),
                                      Color(0xFF2D0A4F).withOpacity(0.9),
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Color(0xFFCC0AE6).withOpacity(0.3),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                      offset: Offset(3, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: Color(0xFFCC0AE6),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Hero(
                                      tag: 'user-${user['id']}',
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10),
                                        ),
                                        child: Container(
                                          height: 150,
                                          width: double.infinity,
                                          child: user['photoUrl'] != null &&
                                                  user['photoUrl']
                                                      .toString()
                                                      .isNotEmpty
                                              ? _buildSvgImage(
                                                  user['photoUrl'].toString())
                                              : Container(
                                                  color: Color(0xFF1A0033),
                                                  child: Icon(
                                                    Icons.person,
                                                    size: 80,
                                                    color: Colors.white70,
                                                  ),
                                                ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Flexible(
                                                child: Text(
                                                  user['name'] ?? '',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 16,
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                              Text(
                                                user['age'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 14,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.location_on,
                                                color: Color(0xFFCC0AE6),
                                                size: 14,
                                              ),
                                              SizedBox(width: 2),
                                              Text(
                                                user['distance'] ?? '',
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 4),
                                          Wrap(
                                            spacing: 4,
                                            children: (user['genders']
                                                        as List<dynamic>?)
                                                    ?.map((gender) => Container(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal: 6,
                                                                  vertical: 2),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: Color(
                                                                    0xFFCC0AE6)
                                                                .withOpacity(
                                                                    0.3),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            border: Border.all(
                                                              color: Color(
                                                                  0xFFCC0AE6),
                                                              width: 1,
                                                            ),
                                                          ),
                                                          child: Text(
                                                            gender.toString(),
                                                            style: TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontSize: 10,
                                                            ),
                                                          ),
                                                        ))
                                                    .toList() ??
                                                [],
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
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSvgImage(String imageUrl) {
    // Check if URL is valid
    if (imageUrl.isEmpty) {
      return Container(
        color: Color(0xFF1A0033),
        child: Icon(
          Icons.person,
          size: 80,
          color: Colors.white70,
        ),
      );
    }

    // Check if it's a local file path (usually SVG)
    if (imageUrl.startsWith('/') || imageUrl.startsWith('assets/')) {
      try {
        return SvgPicture.asset(
          imageUrl,
          placeholderBuilder: (BuildContext context) => Container(
            color: Colors.grey[900],
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC0AE6)),
              ),
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error loading local SVG: $e');
        // Fall back to network image if SVG loading fails
      }
    }

    // Handle remote images
    if (imageUrl.toLowerCase().endsWith('.svg')) {
      // Handle SVG network images
      try {
        return SvgPicture.network(
          imageUrl,
          placeholderBuilder: (BuildContext context) => Container(
            color: Colors.grey[900],
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC0AE6)),
              ),
            ),
          ),
        );
      } catch (e) {
        debugPrint('Error loading SVG from network: $e');
        // Fall back to regular image if SVG loading fails
      }
    }

    // For normal image URLs, use Image.network
    try {
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[900],
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFCC0AE6)),
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                        loadingProgress.expectedTotalBytes!
                    : null,
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          debugPrint('Error loading image: $error');
          return Container(
            color: Colors.grey[900],
            child: Icon(
              Icons.broken_image,
              color: Colors.white70,
              size: 80,
            ),
          );
        },
      );
    } catch (e) {
      debugPrint('Error constructing image widget: $e');
      return Container(
        color: Colors.grey[900],
        child: Icon(
          Icons.broken_image,
          color: Colors.white70,
          size: 80,
        ),
      );
    }
  }

  List<String> _getSecondaryGenderOptions() {
    List<String> options = [];
    if (selectedGenders.contains(GenderOption.man)) {
      options.addAll(GenderSubOptionMan.values.map((e) => e.display));
    }
    if (selectedGenders.contains(GenderOption.woman)) {
      options.addAll(GenderSubOptionWoman.values.map((e) => e.display));
    }
    if (selectedGenders.contains(GenderOption.beyondBinary)) {
      options.addAll(GenderSubOptionBeyondBinary.values.map((e) => e.display));
    }
    return options;
  }

  List<String> _getSecondaryGenderOptionsForPrimary(GenderOption primary) {
    List<String> options = [];
    if (primary == GenderOption.man) {
      options.addAll(GenderSubOptionMan.values.map((e) => e.display));
    } else if (primary == GenderOption.woman) {
      options.addAll(GenderSubOptionWoman.values.map((e) => e.display));
    } else if (primary == GenderOption.beyondBinary) {
      options.addAll(GenderSubOptionBeyondBinary.values.map((e) => e.display));
    }
    return options;
  }

  Map<String, dynamic> _buildQueryParams() {
    Map<String, dynamic> params = {};

    // Add gender filter
    if (selectedGenders.isNotEmpty) {
      params['genders'] = selectedGenders.map((g) => g.name).toList();
    }

    // Add age range
    if (ageRange.start > 18) {
      params['minAge'] = ageRange.start.toInt();
    }
    if (ageRange.end < 100) {
      params['maxAge'] = ageRange.end.toInt();
    }

    // Add education levels
    if (selectedEducationLevels.isNotEmpty) {
      params['educationLevels'] =
          selectedEducationLevels.map((e) => e.name).toList();
    }

    // Add communication styles
    if (selectedCommunicationStyles.isNotEmpty) {
      params['communicationStyles'] =
          selectedCommunicationStyles.map((s) => s.name).toList();
    }

    // Add love languages
    if (selectedLoveLanguages.isNotEmpty) {
      params['loveLanguages'] =
          selectedLoveLanguages.map((l) => l.name).toList();
    }

    // Add interests
    if (selectedInterests.isNotEmpty) {
      params['interests'] = selectedInterests.map((i) => i.name).toList();
    }

    // Add habits
    if (selectedSmokingHabit != null) {
      params['smokingHabit'] = selectedSmokingHabit!.name;
    }
    if (selectedDrinkingHabit != null) {
      params['drinkingHabit'] = selectedDrinkingHabit!.name;
    }
    if (selectedWorkoutHabit != null) {
      params['workoutHabit'] = selectedWorkoutHabit!.name;
    }
    if (selectedDietaryPreference != null) {
      params['dietaryPreference'] = selectedDietaryPreference!.name;
    }
    if (selectedSleepingHabit != null) {
      params['sleepingHabit'] = selectedSleepingHabit!.name;
    }

    // Add proximity-based filtering parameters
    if (userLatitude != null && userLongitude != null) {
      params['latitude'] = userLatitude;
      params['longitude'] = userLongitude;
      params['maxDistance'] = maxDistance.toInt();
    }

    return params;
  }
}

class MultiSelectChip extends StatefulWidget {
  final List<String> items;
  final List<String> selectedItems;
  final Function(List<String>) onSelectionChanged;

  MultiSelectChip({
    required this.items,
    required this.selectedItems,
    required this.onSelectionChanged,
  });

  @override
  _MultiSelectChipState createState() => _MultiSelectChipState();
}

class _MultiSelectChipState extends State<MultiSelectChip> {
  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8.0,
      children: widget.items.map((item) {
        final isSelected = widget.selectedItems.contains(item);
        return ChoiceChip(
          label: Text(item,
              style:
                  TextStyle(color: isSelected ? Colors.black : Colors.white)),
          selected: isSelected,
          selectedColor: Color(0xFFCC0AE6),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                widget.selectedItems.add(item);
              } else {
                widget.selectedItems.remove(item);
              }
              widget.onSelectionChanged(widget.selectedItems);
            });
          },
        );
      }).toList(),
    );
  }
}
