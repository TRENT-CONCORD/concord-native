import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:math';
import 'dart:io'; // Import for SocketException
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Singleton pattern
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  // API URL based on environment
  String get baseUrl {
    const branch = String.fromEnvironment('BRANCH', defaultValue: 'sandbox');
    if (branch == 'main') {
      return 'https://api.concord.digital';
    } else {
      return 'https://api-dev.concord.digital';
    }
  }

  // WebSocket URL based on API URL
  String get wsBaseUrl {
    return baseUrl
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
  }

  // Track API availability
  bool _isApiAvailable = true;
  bool get isApiAvailable => _isApiAvailable;

  // WebSocket connection for real-time updates
  WebSocketChannel? _exploreWebSocket;
  bool _wsConnected = false;
  StreamController<Map<String, dynamic>> _wsEventsController =
      StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get wsEvents => _wsEventsController.stream;

  // Test API connectivity
  Future<bool> testConnectivity() async {
    try {
      debugPrint('🔍 Testing API connectivity to: $baseUrl');

      // Try health endpoint first
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/health'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: 5));

        debugPrint('🔍 API health check result: ${response.statusCode}');
        if (response.statusCode == 200) {
          _isApiAvailable = true;
          return true;
        }
      } on SocketException catch (e) {
        debugPrint('Socket exception during API connectivity test: $e');
        _isApiAvailable = false;
        return false;
      } catch (e) {
        debugPrint('Health endpoint not available: $e');
      }

      // Try users endpoint as fallback
      try {
        final response = await http.get(
          Uri.parse('$baseUrl/api/users?limit=1'),
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: 5));

        debugPrint('🔍 Users endpoint test: ${response.statusCode}');
        if (response.statusCode == 200) {
          _isApiAvailable = true;
          return true;
        }
      } on SocketException catch (e) {
        debugPrint('Socket exception during API connectivity test: $e');
        _isApiAvailable = false;
        return false;
      } catch (e) {
        debugPrint('Users endpoint not available: $e');
      }

      // Both tests failed
      _isApiAvailable = false;
      return false;
    } catch (e) {
      debugPrint('❌ API connectivity test failed: $e');
      _isApiAvailable = false;
      return false;
    }
  }

  // Connect to WebSocket for real-time updates
  Future<bool> connectToExploreWebSocket(String userId) async {
    if (!_isApiAvailable) {
      debugPrint('API not available, skipping WebSocket connection');
      return false;
    }

    try {
      // Close existing connection if any
      await disconnectFromExploreWebSocket();

      // Construct WebSocket URL
      final wsUrl = '$wsBaseUrl/ws/explore?userId=$userId';
      debugPrint('Connecting to WebSocket: $wsUrl');

      // Create WebSocket connection
      _exploreWebSocket = IOWebSocketChannel.connect(
        wsUrl,
        pingInterval: Duration(seconds: 30),
      );

      // Listen for WebSocket messages
      _exploreWebSocket!.stream.listen(
        (message) {
          debugPrint('Received WebSocket message: $message');
          try {
            final data = json.decode(message);
            _wsEventsController.add(data);
          } catch (e) {
            debugPrint('Error processing WebSocket message: $e');
          }
        },
        onError: (error) {
          debugPrint('WebSocket error: $error');
          _wsConnected = false;
          _retryWebSocketConnection(userId);
        },
        onDone: () {
          debugPrint('WebSocket connection closed');
          _wsConnected = false;
          _retryWebSocketConnection(userId);
        },
      );

      _wsConnected = true;
      return true;
    } catch (e) {
      debugPrint('Error connecting to WebSocket: $e');
      _wsConnected = false;
      return false;
    }
  }

  // Disconnect from WebSocket
  Future<void> disconnectFromExploreWebSocket() async {
    try {
      if (_exploreWebSocket != null) {
        _exploreWebSocket!.sink.close();
        _exploreWebSocket = null;
      }
      _wsConnected = false;
    } catch (e) {
      debugPrint('Error disconnecting from WebSocket: $e');
    }
  }

  // Retry WebSocket connection with exponential backoff
  int _wsRetryCount = 0;
  Timer? _wsRetryTimer;

  void _retryWebSocketConnection(String userId) {
    // Cancel existing timer if any
    _wsRetryTimer?.cancel();

    // Limit retries to prevent infinite loop
    if (_wsRetryCount >= 5) {
      debugPrint('Maximum WebSocket retry attempts reached');
      _wsRetryCount = 0;
      return;
    }

    // Exponential backoff
    final delay = Duration(seconds: pow(2, _wsRetryCount).toInt());
    _wsRetryCount++;

    debugPrint(
        'Retrying WebSocket connection in ${delay.inSeconds} seconds (attempt $_wsRetryCount)');
    _wsRetryTimer = Timer(delay, () {
      if (_isApiAvailable && !_wsConnected) {
        connectToExploreWebSocket(userId);
      }
    });
  }

  // Get users for explore page with proximity-based filtering
  Future<List<Map<String, dynamic>>> getExploreUsers({
    int offset = 0,
    int limit = 20,
    Map<String, dynamic>? filters,
    double? latitude,
    double? longitude,
    double? maxDistance,
  }) async {
    if (!_isApiAvailable) {
      return _getMockUsers(offset, limit);
    }

    try {
      // Build query parameters
      Map<String, dynamic> queryParams = {
        'offset': offset,
        'limit': limit,
      };

      // Add location parameters if available
      if (latitude != null && longitude != null) {
        queryParams['latitude'] = latitude;
        queryParams['longitude'] = longitude;

        if (maxDistance != null) {
          queryParams['maxDistance'] = maxDistance;
        }
      }

      // Add filters if available
      if (filters != null) {
        queryParams.addAll(filters);
      }

      // Make API request
      final data = await get('api/users', queryParams: queryParams);

      if (data != null && data is List) {
        return data
            .map<Map<String, dynamic>>((user) => {
                  'id': user['id']?.toString() ?? '',
                  'name': user['displayName']?.toString() ?? 'User',
                  'age': user['age']?.toString() ?? '?',
                  'distance': user['distance']?.toString() ?? 'Unknown',
                  'photoUrl': user['photoUrl']?.toString() ?? '',
                  'genders': user['genders'] != null
                      ? List<String>.from(user['genders'])
                      : <String>[],
                })
            .toList();
      } else {
        debugPrint('Unexpected data format from API');
        return _getMockUsers(offset, limit);
      }
    } catch (e) {
      debugPrint('Error fetching explore users: $e');
      return _getMockUsers(offset, limit);
    }
  }

  // Save user filters to API
  Future<bool> saveUserFilters(
      String userId, Map<String, dynamic> filters) async {
    if (!_isApiAvailable) {
      // Save locally if API is not available
      await _saveFiltersLocally(filters);
      return true;
    }

    try {
      await post('api/users/$userId/filters', body: filters);

      // Also save locally as backup
      await _saveFiltersLocally(filters);
      return true;
    } catch (e) {
      debugPrint('Error saving filters to API: $e');

      // Save locally as fallback
      await _saveFiltersLocally(filters);
      return false;
    }
  }

  // Get user filters from API
  Future<Map<String, dynamic>> getUserFilters(String userId) async {
    if (!_isApiAvailable) {
      return await _getLocalFilters();
    }

    try {
      final data = await get('api/users/$userId/filters');

      if (data != null && data is Map<String, dynamic>) {
        // Save to local storage as backup
        await _saveFiltersLocally(data);
        return data;
      } else {
        // Fallback to local filters
        return await _getLocalFilters();
      }
    } catch (e) {
      debugPrint('Error getting filters from API: $e');
      return await _getLocalFilters();
    }
  }

  // Save filters locally
  Future<void> _saveFiltersLocally(Map<String, dynamic> filters) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedFilter', json.encode(filters));
    } catch (e) {
      debugPrint('Error saving filters locally: $e');
    }
  }

  // Get filters from local storage
  Future<Map<String, dynamic>> _getLocalFilters() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedFilter = prefs.getString('savedFilter');

      if (savedFilter != null) {
        return json.decode(savedFilter);
      }
    } catch (e) {
      debugPrint('Error getting local filters: $e');
    }

    return {}; // Return empty map if no filters found
  }

  // Mock data for when the backend is not available
  List<Map<String, dynamic>> _getMockUsers(int offset, int limit) {
    final random = Random();
    final List<Map<String, dynamic>> mockUsers = [];

    // Generate random users
    for (int i = 0; i < limit; i++) {
      final id = offset + i + 1;
      final isMale = random.nextBool();
      final age = 18 + random.nextInt(40);
      final distance = random.nextInt(50);

      mockUsers.add({
        'id': id.toString(),
        'name': isMale ? 'John Doe ${id}' : 'Jane Doe ${id}',
        'age': age.toString(),
        'distance': '$distance km',
        'photoUrl': isMale
            ? 'https://randomuser.me/api/portraits/men/${id % 100}.jpg'
            : 'https://randomuser.me/api/portraits/women/${id % 100}.jpg',
        'genders': [isMale ? 'Man' : 'Woman'],
      });
    }

    return mockUsers;
  }

  // Generic GET request with retries
  Future<dynamic> get(String endpoint,
      {Map<String, dynamic>? queryParams,
      int maxRetries = 3,
      int timeoutSeconds = 10}) async {
    if (!_isApiAvailable && !endpoint.contains('health')) {
      throw Exception('API is not available');
    }

    String url = '$baseUrl/$endpoint';
    if (url.contains('//')) {
      url = url.replaceAll('//', '/');
      url = url.replaceFirst('://', '://'); // Fix protocol
    }

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final Uri uri = queryParams != null
            ? Uri.parse(url).replace(
                queryParameters: queryParams
                    .map((key, value) => MapEntry(key, value.toString())),
              )
            : Uri.parse(url);

        debugPrint('🔍 GET Request: $uri (Attempt ${retryCount + 1})');

        final response = await http.get(
          uri,
          headers: {'Content-Type': 'application/json'},
        ).timeout(Duration(seconds: timeoutSeconds));

        if (response.statusCode == 200) {
          debugPrint('✅ GET Success: $uri (${response.statusCode})');
          if (response.body.isNotEmpty) {
            try {
              return json.decode(response.body);
            } catch (e) {
              debugPrint('⚠️ JSON parse error: $e');
              return response.body;
            }
          }
          return null;
        } else {
          debugPrint('❌ GET Error: $uri (${response.statusCode})');
          debugPrint('Response: ${response.body}');

          if (response.statusCode == 404) {
            // Don't retry 404 errors
            _isApiAvailable =
                endpoint.contains('health') || endpoint.contains('users')
                    ? false
                    : _isApiAvailable;
            throw Exception('Endpoint not found: $url');
          }

          retryCount++;
          if (retryCount >= maxRetries) {
            _isApiAvailable = false;
            throw Exception(
                'Max retries reached. Status: ${response.statusCode}');
          }
          await Future.delayed(
              Duration(seconds: 2 * retryCount)); // Exponential backoff
        }
      } on SocketException catch (e) {
        debugPrint('❌ Socket error (network connectivity issue): $e');
        _isApiAvailable = false;
        throw Exception('Network connectivity issue: $e');
      } catch (e) {
        debugPrint('❌ Network error: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          _isApiAvailable = false;
          throw Exception('Network error after $maxRetries attempts: $e');
        }
        await Future.delayed(
            Duration(seconds: 2 * retryCount)); // Exponential backoff
      }
    }

    throw Exception('Request failed after $maxRetries attempts');
  }

  // Generic POST request with retries
  Future<dynamic> post(String endpoint,
      {Map<String, dynamic>? body,
      int maxRetries = 3,
      int timeoutSeconds = 10}) async {
    if (!_isApiAvailable && !endpoint.contains('health')) {
      throw Exception('API is not available');
    }

    String url = '$baseUrl/$endpoint';
    if (url.contains('//')) {
      url = url.replaceAll('//', '/');
      url = url.replaceFirst('://', '://'); // Fix protocol
    }

    int retryCount = 0;
    while (retryCount < maxRetries) {
      try {
        final Uri uri = Uri.parse(url);

        debugPrint('🔍 POST Request: $uri (Attempt ${retryCount + 1})');

        final response = await http
            .post(
              uri,
              headers: {'Content-Type': 'application/json'},
              body: body != null ? json.encode(body) : null,
            )
            .timeout(Duration(seconds: timeoutSeconds));

        if (response.statusCode >= 200 && response.statusCode < 300) {
          debugPrint('✅ POST Success: $uri (${response.statusCode})');
          if (response.body.isNotEmpty) {
            try {
              return json.decode(response.body);
            } catch (e) {
              debugPrint('⚠️ JSON parse error: $e');
              return response.body;
            }
          }
          return null;
        } else {
          debugPrint('❌ POST Error: $uri (${response.statusCode})');
          debugPrint('Response: ${response.body}');

          if (response.statusCode == 404) {
            // Don't retry 404 errors
            throw Exception('Endpoint not found: $url');
          }

          retryCount++;
          if (retryCount >= maxRetries) {
            throw Exception(
                'Max retries reached. Status: ${response.statusCode}');
          }
          await Future.delayed(
              Duration(seconds: 2 * retryCount)); // Exponential backoff
        }
      } on SocketException catch (e) {
        debugPrint('❌ Socket error (network connectivity issue): $e');
        _isApiAvailable = false;
        throw Exception('Network connectivity issue: $e');
      } catch (e) {
        debugPrint('❌ Network error: $e');
        retryCount++;
        if (retryCount >= maxRetries) {
          throw Exception('Network error after $maxRetries attempts: $e');
        }
        await Future.delayed(
            Duration(seconds: 2 * retryCount)); // Exponential backoff
      }
    }

    throw Exception('Request failed after $maxRetries attempts');
  }
}
