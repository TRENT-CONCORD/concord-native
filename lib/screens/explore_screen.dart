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
  String? selectedLocation;
  late AnimationController _flyoutAnimationController;

  @override
  void initState() {
    super.initState();
    _flyoutAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _flyoutAnimationController.dispose();
    super.dispose();
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
                                                // TODO: Update min age filter
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
                                                // TODO: Update max age filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged:
                                            (selectedSecondaryGenders) {
                                          setState(() {
                                            // Update secondary gender selection
                                            // TODO: Save secondary gender selection
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update education level filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update communication style filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update love language filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update interests filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update smoking habit filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update drinking habit filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update workout habit filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update dietary preference filter
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
                                        selectedItems: [], // TODO: Bind to state
                                        onSelectionChanged: (selected) {
                                          // TODO: Update sleeping habit filter
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
                                    // TODO: Save selected filters to state or backend
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
        child: FutureBuilder(
          future: _fetchUsers(), // Placeholder for API call
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || (snapshot.data as List).isEmpty) {
              return Center(child: Text('No users found'));
            } else {
              final users = snapshot.data as List;
              return GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: users.length,
                itemBuilder: (context, index) {
                  final user = users[index];
                  return Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    shadowColor: Color(0xFFCC0AE6),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Color(0xFFCC0AE6), width: 2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          user['name'],
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }

  Future<List<Map<String, String>>> _fetchUsers() async {
    try {
      // For Android emulator, use 10.0.2.2 to access host machine
      // For iOS simulator, use localhost
      // For physical devices, use your computer's IP address
      final String baseUrl = 'http://10.0.2.2:3000/api';

      final response = await http.get(
        Uri.parse('$baseUrl/explore'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        try {
          final List<dynamic> data = json.decode(response.body);
          return data
              .map((user) => {
                    'name': user['displayName'].toString(),
                    'distance': user['distance'].toString(),
                  })
              .toList();
        } catch (e) {
          debugPrint('Error parsing JSON: $e');
          return _getMockUsers();
        }
      } else {
        debugPrint('Error: Unexpected response status: ${response.statusCode}');
        debugPrint('Response body: ${response.body}');
        return _getMockUsers();
      }
    } catch (e) {
      debugPrint('Error fetching users: $e');
      return _getMockUsers();
    }
  }

  // Mock data for when the backend is not available
  List<Map<String, String>> _getMockUsers() {
    return [
      {
        'name': 'John Doe',
        'distance': '5 km',
      },
      {
        'name': 'Jane Smith',
        'distance': '3 km',
      },
      {
        'name': 'Alex Johnson',
        'distance': '8 km',
      },
      {
        'name': 'Emily Chen',
        'distance': '6 km',
      },
      {
        'name': 'Michael Brown',
        'distance': '10 km',
      },
    ];
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
