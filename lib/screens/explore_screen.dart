import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../models/profile_enums.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/gestures.dart';

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
  late AnimationController _flyoutAnimationController;

  // Pagination and loading state
  bool _isLoading = false;
  bool _hasMoreUsers = true;
  int _currentOffset = 0;
  final int _pageSize = 20;
  List<Map<String, dynamic>> _users = [];
  final ScrollController _scrollController = ScrollController();
  bool _isApiAvailable = true; // Track if API is available

  @override
  void initState() {
    super.initState();
    _flyoutAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );

    // Load initial users
    _loadUsers();

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _flyoutAnimationController.dispose();
    super.dispose();
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
      final users = await _fetchUsers(_currentOffset, _pageSize);
      setState(() {
        _users = users;
        _isLoading = false;
        _hasMoreUsers = users.length >= _pageSize;
        _currentOffset += users.length;
        _isApiAvailable = true; // API is available
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _isApiAvailable = false; // API is not available
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
      final users = await _fetchUsers(_currentOffset, _pageSize);

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

  // Navigate to user profile detail
  void _navigateToUserProfile(Map<String, dynamic> user) {
    // TODO: Implement actual navigation to profile detail page
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

    // For future implementation:
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     builder: (context) => UserProfileDetailScreen(userId: user['id']),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ensure layout adjusts for keyboard
      appBar: AppBar(
        title: Text('Explore'),
        backgroundColor: Color(0xFF4A148C),
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
                                      Color(0xFF4A148C),
                                      Color(0xFF7B1FA2)
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
                                        onSelectionChanged:
                                            (selectedPrimaryGenders) {
                                          setState(() {
                                            // Map the selected strings back to GenderOption values
                                            selectedGenders =
                                                selectedPrimaryGenders
                                                    .map((selected) {
                                              return GenderOption.values
                                                  .firstWhere(
                                                (gender) =>
                                                    gender.display == selected,
                                                orElse: () => GenderOption
                                                    .man, // Default value if not found
                                              );
                                            }).toList();
                                          });
                                        },
                                      ),
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
                                      Row(
                                        children: [
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: 'From',
                                                labelStyle: TextStyle(
                                                    color: Colors.white),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xFFCC0AE6)),
                                                ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (value.isNotEmpty) {
                                                  int? minAge =
                                                      int.tryParse(value);
                                                  if (minAge != null &&
                                                      minAge >= 18 &&
                                                      minAge <= 100) {
                                                    setState(() {
                                                      ageRange = RangeValues(
                                                          minAge.toDouble(),
                                                          ageRange.end);
                                                    });
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: TextField(
                                              decoration: InputDecoration(
                                                labelText: 'To',
                                                labelStyle: TextStyle(
                                                    color: Colors.white),
                                                border: OutlineInputBorder(
                                                  borderSide: BorderSide(
                                                      color: Color(0xFFCC0AE6)),
                                                ),
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              onChanged: (value) {
                                                if (value.isNotEmpty) {
                                                  int? maxAge =
                                                      int.tryParse(value);
                                                  if (maxAge != null &&
                                                      maxAge >= 18 &&
                                                      maxAge <= 100) {
                                                    setState(() {
                                                      ageRange = RangeValues(
                                                          ageRange.start,
                                                          maxAge.toDouble());
                                                    });
                                                  }
                                                }
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Secondary Gender Options',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          fontFamily: 'FuturisticFont',
                                        ),
                                      ),
                                      SizedBox(height: 8),
                                      MultiSelectChip(
                                        items: _getSecondaryGenderOptions(),
                                        selectedItems: selectedSecondaryGenders,
                                        onSelectionChanged:
                                            (selectedSecondaryGenders) {
                                          setState(() {
                                            this.selectedSecondaryGenders =
                                                selectedSecondaryGenders;
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
                                  backgroundColor: Color(0xFF4A148C),
                                  onPressed: () {
                                    Navigator.pop(context);
                                    // Trigger a refresh of the user list with the new filters
                                    setState(() {
                                      // Force rebuild and reload users with new filters
                                      _loadUsers();
                                    });
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
            colors: [Color(0xFF4A148C), Color(0xFF7B1FA2), Color(0xFFAB47BC)],
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
                  color: Colors.orange.withOpacity(0.8),
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
                                });
                                _loadUsers();
                              },
                              icon: Icon(Icons.refresh),
                              label: Text('Reset Filters'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Color(0xFF7B1FA2),
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
                                      Color(0xFF4A148C).withOpacity(0.7),
                                      Color(0xFF7B1FA2).withOpacity(0.7),
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
                                              ? Image.network(
                                                  user['photoUrl'].toString(),
                                                  fit: BoxFit.cover,
                                                  loadingBuilder: (context,
                                                      child, loadingProgress) {
                                                    if (loadingProgress == null)
                                                      return child;
                                                    return Container(
                                                      color: Color(0xFF4A148C),
                                                      child: Center(
                                                        child:
                                                            CircularProgressIndicator(
                                                          value: loadingProgress
                                                                      .expectedTotalBytes !=
                                                                  null
                                                              ? loadingProgress
                                                                      .cumulativeBytesLoaded /
                                                                  loadingProgress
                                                                      .expectedTotalBytes!
                                                              : null,
                                                          valueColor:
                                                              AlwaysStoppedAnimation<
                                                                      Color>(
                                                                  Color(
                                                                      0xFFCC0AE6)),
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    return Container(
                                                      color: Color(0xFF4A148C),
                                                      child: Icon(
                                                        Icons.person,
                                                        size: 80,
                                                        color: Colors.white70,
                                                      ),
                                                    );
                                                  },
                                                )
                                              : Container(
                                                  color: Color(0xFF4A148C),
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
                                                    ?.toList() ??
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

  Future<List<Map<String, dynamic>>> _fetchUsers(
      [int offset = 0, int limit = 20]) async {
    try {
      // Build query parameters based on selected filters
      Map<String, dynamic> queryParams = _buildQueryParams();

      // Add pagination parameters
      queryParams['limit'] = limit;
      queryParams['offset'] = offset;

      // For Android emulator, use 10.0.2.2 to access host machine
      // For iOS simulator, use localhost
      // For physical devices, use your computer's IP address
      final String baseUrl = 'http://10.0.2.2:3000/api';

      // Convert queryParams to URL query string
      final Uri uri = Uri.parse('$baseUrl/explore').replace(
        queryParameters:
            queryParams.map((key, value) => MapEntry(key, value.toString())),
      );

      debugPrint('Fetching users with URI: $uri');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // Add authorization token if you have it
          // 'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(seconds: 10)); // Add timeout to prevent long waiting

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          return data
              .map<Map<String, dynamic>>((user) => {
                    'id': user['id'].toString(),
                    'name': user['displayName'].toString(),
                    'age': user['age'].toString(),
                    'distance': user['distance'].toString(),
                    'photoUrl': user['photoUrl']?.toString() ?? '',
                    'genders': user['genders'] != null
                        ? List<String>.from(user['genders'])
                        : <String>[],
                    // Add other user properties you want to display
                  })
              .toList();
        } catch (e) {
          debugPrint('Error parsing JSON: $e');
          debugPrint('Response body: ${response.body}');
          setState(() {
            _isApiAvailable = false;
          });
          return _getMockUsers(offset, limit);
        }
      } else {
        debugPrint('Error: Unexpected response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        setState(() {
          _isApiAvailable = false;
        });
        return _getMockUsers(offset, limit);
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      setState(() {
        _isApiAvailable = false;
      });
      return _getMockUsers(offset, limit);
    }
  }

  // Mock data for when the backend is not available
  List<Map<String, dynamic>> _getMockUsers([int offset = 0, int limit = 20]) {
    final allMockUsers = [
      {
        'id': '1',
        'name': 'John Doe',
        'age': '28',
        'distance': '5 km',
        'photoUrl': 'https://picsum.photos/id/1/200/300',
        'genders': ['Man'],
      },
      {
        'id': '2',
        'name': 'Jane Smith',
        'age': '26',
        'distance': '3 km',
        'photoUrl': 'https://picsum.photos/id/1025/200/300',
        'genders': ['Woman'],
      },
      {
        'id': '3',
        'name': 'Alex Johnson',
        'age': '31',
        'distance': '8 km',
        'photoUrl': 'https://picsum.photos/id/1027/200/300',
        'genders': ['Beyond Binary'],
      },
      {
        'id': '4',
        'name': 'Emily Chen',
        'age': '24',
        'distance': '6 km',
        'photoUrl': 'https://picsum.photos/id/1062/200/300',
        'genders': ['Woman'],
      },
      {
        'id': '5',
        'name': 'Michael Brown',
        'age': '32',
        'distance': '10 km',
        'photoUrl': 'https://picsum.photos/id/1074/200/300',
        'genders': ['Man'],
      },
      {
        'id': '6',
        'name': 'Sarah Wilson',
        'age': '29',
        'distance': '4 km',
        'photoUrl': 'https://picsum.photos/id/64/200/300',
        'genders': ['Woman'],
      },
      {
        'id': '7',
        'name': 'David Lee',
        'age': '33',
        'distance': '7 km',
        'photoUrl': 'https://picsum.photos/id/91/200/300',
        'genders': ['Man'],
      },
      {
        'id': '8',
        'name': 'Taylor Morgan',
        'age': '27',
        'distance': '2 km',
        'photoUrl': 'https://picsum.photos/id/180/200/300',
        'genders': ['Beyond Binary'],
      },
      {
        'id': '9',
        'name': 'Olivia Parker',
        'age': '25',
        'distance': '9 km',
        'photoUrl': 'https://picsum.photos/id/342/200/300',
        'genders': ['Woman'],
      },
      {
        'id': '10',
        'name': 'Nathan Rodriguez',
        'age': '30',
        'distance': '1 km',
        'photoUrl': 'https://picsum.photos/id/823/200/300',
        'genders': ['Man'],
      },
    ];

    final mockUsers = allMockUsers
        .where((user) {
          // Apply filters to mock data to simulate API behavior
          final gender =
              user['genders'] != null && (user['genders'] as List).isNotEmpty
                  ? (user['genders'] as List)[0]
                  : '';
          final age = int.tryParse(user['age'] as String) ?? 25;

          bool genderMatch = selectedGenders.isEmpty ||
              selectedGenders.any((g) => g.display == gender);

          bool ageMatch = age >= ageRange.start && age <= ageRange.end;

          return genderMatch && ageMatch;
        })
        .skip(offset)
        .take(limit)
        .toList();

    // Simulate pagination by returning limited results
    return mockUsers;
  }

  // Build query parameters based on selected filters
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

    return params;
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
