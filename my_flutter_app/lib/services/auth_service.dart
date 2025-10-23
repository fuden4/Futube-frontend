import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_config.dart';

class AuthService {
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';

  // Login
  static Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPath}/login.php'),
        body: {
          'username': username,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          // Save user data
          final user = User.fromJson(data['user']);
          await saveUser(user);
          
          return {'success': true, 'user': user};
        } else {
          return {'success': false, 'message': data['message'] ?? 'Login failed'};
        }
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Register
  static Future<Map<String, dynamic>> register(String username, String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPath}/register.php'),
        body: {
          'username': username,
          'email': email,
          'password': password,
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['success'] == true) {
          return {'success': true, 'message': data['message']};
        } else {
          return {'success': false, 'message': data['message'] ?? 'Registration failed'};
        }
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Save user to local storage
  static Future<void> saveUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, json.encode(user.toJson()));
  }

  // Get current user
  static Future<User?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userString = prefs.getString(_userKey);
    
    if (userString != null) {
      return User.fromJson(json.decode(userString));
    }
    return null;
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    final user = await getCurrentUser();
    return user != null;
  }

  // Logout
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
    await prefs.remove(_tokenKey);
  }

  // Add comment
  static Future<Map<String, dynamic>> addComment(int videoId, String commentText, {int? parentCommentId}) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return {'success': false, 'message': 'Please login to comment'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPath}/add_comment.php'),
        body: {
          'video_id': videoId.toString(),
          'user_id': user.id.toString(),
          'comment_text': commentText,
          if (parentCommentId != null) 'parent_comment_id': parentCommentId.toString(),
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Like video
  static Future<Map<String, dynamic>> likeVideo(int videoId) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return {'success': false, 'message': 'Please login to like videos'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPath}/like_action.php'),
        body: {
          'video_id': videoId.toString(),
          'user_id': user.id.toString(),
          'action': 'like',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }

  // Unlike video
  static Future<Map<String, dynamic>> unlikeVideo(int videoId) async {
    try {
      final user = await getCurrentUser();
      if (user == null) {
        return {'success': false, 'message': 'Please login'};
      }

      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.apiPath}/like_action.php'),
        body: {
          'video_id': videoId.toString(),
          'user_id': user.id.toString(),
          'action': 'unlike',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return {'success': false, 'message': 'Server error'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Connection error: $e'};
    }
  }
}

