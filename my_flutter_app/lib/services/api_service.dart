import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/video.dart';
import 'api_config.dart';

class ApiService {
  // Fetch featured videos
  static Future<List<Video>> getFeaturedVideos() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.featuredVideos));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Video.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load featured videos');
      }
    } catch (e) {
      throw Exception('Error fetching featured videos: $e');
    }
  }

  // Fetch categorized videos
  static Future<Map<String, List<Video>>> getCategorizedVideos() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.categorizedVideos));
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        final Map<String, List<Video>> categorizedVideos = {};
        
        data.forEach((category, videos) {
          categorizedVideos[category] = (videos as List)
              .map((json) => Video.fromJson(json))
              .toList();
        });
        
        return categorizedVideos;
      } else {
        throw Exception('Failed to load categorized videos');
      }
    } catch (e) {
      throw Exception('Error fetching categorized videos: $e');
    }
  }

  // Fetch all videos
  static Future<List<Video>> getAllVideos() async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.allVideos));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Video.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load videos');
      }
    } catch (e) {
      throw Exception('Error fetching videos: $e');
    }
  }

  // Fetch video details
  static Future<Video> getVideoDetails(int id) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.videoDetails(id)));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Video.fromJson(data);
      } else {
        throw Exception('Failed to load video details');
      }
    } catch (e) {
      throw Exception('Error fetching video details: $e');
    }
  }

  // Search videos
  static Future<List<Video>> searchVideos(String query) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.searchVideos(query)));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Video.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search videos');
      }
    } catch (e) {
      throw Exception('Error searching videos: $e');
    }
  }

  // Fetch videos by category
  static Future<List<Video>> getVideosByCategory(String category) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.videosByCategory(category)));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((json) => Video.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load videos by category');
      }
    } catch (e) {
      throw Exception('Error fetching videos by category: $e');
    }
  }

  // Fetch video likes
  static Future<Map<String, dynamic>> getVideoLikes(int videoId) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.videoLikes(videoId)));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load video likes');
      }
    } catch (e) {
      throw Exception('Error fetching video likes: $e');
    }
  }

  // Fetch video comments
  static Future<List<dynamic>> getVideoComments(int videoId) async {
    try {
      final response = await http.get(Uri.parse(ApiConfig.videoComments(videoId)));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Failed to load video comments');
      }
    } catch (e) {
      throw Exception('Error fetching video comments: $e');
    }
  }
}

