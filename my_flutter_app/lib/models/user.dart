class User {
  final int id;
  final String username;
  final String? email;
  final String? googleId;
  final String? profileImageUrl;
  final String? createdAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.googleId,
    this.profileImageUrl,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: int.parse(json['id'].toString()),
      username: json['username'],
      email: json['email'],
      googleId: json['google_id'],
      profileImageUrl: json['profile_image_url'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'google_id': googleId,
      'profile_image_url': profileImageUrl,
      'created_at': createdAt,
    };
  }

  String get displayName => username;
  
  String get avatarLetter => username.isNotEmpty ? username[0].toUpperCase() : 'U';
}

