class Video {
  final int id;
  final String title;
  final String description;
  final String? category;
  final String thumbUrl;
  final String? videoUrl;
  final bool isFeatured;
  final bool isVimeo;
  final String? duration;
  final int? releaseYear;
  final double? rating;
  final int views;
  final String? createdAt;

  Video({
    required this.id,
    required this.title,
    required this.description,
    this.category,
    required this.thumbUrl,
    this.videoUrl,
    this.isFeatured = false,
    this.isVimeo = false,
    this.duration,
    this.releaseYear,
    this.rating,
    required this.views,
    this.createdAt,
  });

  factory Video.fromJson(Map<String, dynamic> json) {
    return Video(
      id: int.parse(json['id'].toString()),
      title: json['title'] ?? 'Untitled',
      description: json['description'] ?? '',
      category: json['category'],
      thumbUrl: json['thumb_url'] ?? '',
      videoUrl: json['video_url'],
      isFeatured: json['is_featured'] == true || json['is_featured'] == 1,
      isVimeo: json['is_vimeo'] == true || json['is_vimeo'] == 1,
      duration: json['duration']?.toString(),
      releaseYear: json['release_year'] != null 
          ? int.tryParse(json['release_year'].toString())
          : null,
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      views: int.tryParse(json['views']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category': category,
      'thumb_url': thumbUrl,
      'video_url': videoUrl,
      'is_featured': isFeatured,
      'is_vimeo': isVimeo,
      'duration': duration,
      'release_year': releaseYear,
      'rating': rating,
      'views': views,
      'created_at': createdAt,
    };
  }

  // Helper method to get poster URL
  String get posterUrl => thumbUrl;
  
  // Helper method to get backdrop URL (same as poster for now)
  String get backdropUrl => thumbUrl;
  
  // Helper method to format views
  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M views';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K views';
    }
    return '$views views';
  }
  
  // Helper method to format duration
  String get formattedDuration {
    if (duration == null) return 'N/A';
    return duration!;
  }
  
  // Display rating or default
  double get displayRating => rating ?? 0.0;
}

