class ApiConfig {
  // Update this to your actual server URL
  static const String baseUrl = 'https://olive-okapi-164325.hostingersite.com';
  static const String apiPath = '/api';
  
  // API Endpoints
  static String get featuredVideos => '$baseUrl$apiPath/get_featured_videos.php';
  static String get categorizedVideos => '$baseUrl$apiPath/get_categorized_videos.php';
  static String get allVideos => '$baseUrl$apiPath/videos.php';
  
  static String videoDetails(int id) => '$baseUrl$apiPath/get_video_details.php?id=$id';
  static String videoLikes(int id) => '$baseUrl$apiPath/get_likes.php?video_id=$id';
  static String videoComments(int id) => '$baseUrl$apiPath/get_comments.php?video_id=$id';
  
  // Search
  static String searchVideos(String query) => '$baseUrl$apiPath/videos.php?search=$query';
  static String videosByCategory(String category) => '$baseUrl$apiPath/videos.php?category=$category';
}

