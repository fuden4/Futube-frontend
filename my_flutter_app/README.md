# 🎬 Futube - Video Streaming Mobile App

A professional video streaming mobile application built with Flutter, designed to showcase exclusive cinema content. This is the **frontend client** that connects to a custom PHP backend API.

---

## 📱 About

Futube is a Netflix-style mobile streaming application that provides users with access to exclusive video content. The app features a modern, intuitive interface for browsing, searching, and watching videos from your personal cinema collection.

**This is the mobile frontend** - it communicates with a separate PHP backend that manages all video content, user accounts, and metadata.

---

## ✨ Features

### 🎥 Video Browsing
- **Featured Videos**: Curated selection of highlighted content
- **Categories**: Browse videos by genre (Action, Drama, Comedy, etc.)
- **Search**: Find videos by title, description, or category
- **Video Details**: View ratings, views, duration, release year, and descriptions

### 👤 User Features
- **User Authentication**: Login and register functionality
- **Like Videos**: Save your favorite content
- **Comments**: Engage with the community on videos
- **User Profiles**: Personalized experience with profile management

### 🎬 Video Player
- **Smooth Playback**: Native video player with buffering indicators
- **Playback Controls**: Play, pause, skip forward/backward (10s)
- **Progress Bar**: Seekable progress with buffered indication
- **Fullscreen Mode**: Immersive viewing experience
- **Orientation Support**: Landscape and portrait modes
- **Error Handling**: Retry mechanism for playback issues

### 🎨 User Interface
- **Netflix-Style Design**: Modern, dark-themed interface
- **Smooth Animations**: Polished transitions and interactions
- **Responsive Layout**: Optimized for all screen sizes
- **Video Cards**: Beautiful thumbnails with metadata overlay
- **Category Browsing**: Horizontal scrolling content sections

---

## 🏗️ Architecture

### Frontend (This Repository)
- **Framework**: Flutter 3.5.4+
- **Platform**: Android, iOS (Web & Desktop capable)
- **Language**: Dart
- **UI Theme**: Material Design with custom Netflix-inspired styling

### Backend (Separate Repository)
- **API**: PHP RESTful services
- **Database**: MySQL
- **Storage**: Cloudinary for video hosting
- **Authentication**: Token-based session management

---

## 🔗 API Integration

The app connects to your backend API server for all operations:

### Endpoints Used
```
GET  /api/get_featured_videos.php       - Fetch featured content
GET  /api/get_categorized_videos.php    - Get videos by category
GET  /api/get_video_details.php?id={id} - Video details
GET  /api/videos.php?search={query}     - Search videos
POST /api/register.php                  - User registration
POST /api/login.php                     - User login
GET  /api/get_likes.php?video_id={id}   - Get video likes
POST /api/like_video.php                - Like a video
POST /api/unlike_video.php              - Unlike a video
GET  /api/get_comments.php?video_id={id} - Get comments
POST /api/add_comment.php               - Add comment
```

**API Base URL Configuration**: `lib/services/api_config.dart`

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.5.4 or higher
- Android Studio / VS Code with Flutter extensions
- Android device or emulator for testing
- Your backend API server running and accessible

### Installation

1. **Clone the repository**
```bash
git clone <your-repo-url>
cd my_flutter_app
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Configure API endpoint**
   
   Open `lib/services/api_config.dart` and set your backend URL:
```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:8081';
```

4. **Run the app**
```bash
# For debugging
flutter run

# For release APK
flutter build apk --release
```

### Installation on Android Device
```bash
# Debug version
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk

# Release version
flutter build apk --release
adb install -r build/app/outputs/apk/release/app-release.apk
```

---

## 📂 Project Structure

```
lib/
├── main.dart                      # App entry point
├── models/
│   ├── user.dart                  # User data model
│   └── video.dart                 # Video data model
├── screens/
│   ├── home_screen.dart           # Main feed with featured videos
│   ├── category_screen.dart       # Browse by category
│   ├── search_screen.dart         # Search interface
│   ├── video_detail_screen.dart   # Video details & info
│   ├── video_player_screen.dart   # Video playback
│   ├── login_screen.dart          # User login
│   └── register_screen.dart       # User registration
├── services/
│   ├── api_config.dart            # API configuration
│   ├── api_service.dart           # API calls handler
│   └── auth_service.dart          # Authentication logic
└── widgets/
    └── video_card.dart            # Reusable video thumbnail card

assets/
└── images/
    └── logo.png                   # App logo
```

---

## 🎨 Design & Theme

### Color Scheme
- **Primary Color**: `#E50914` (Netflix Red)
- **Background**: `#0F0F0F` (Dark Black)
- **Surface**: `#1A1A1A` (Dark Gray)
- **Text**: White/Gray variations

### Key Components
- **Video Cards**: Thumbnail images with gradient overlays
- **AppBar**: Minimal, dark with logo
- **Buttons**: Netflix-style red primary buttons
- **Cards**: Rounded corners with subtle elevation

---

## 🔧 Configuration

### Update API Server
Edit `lib/services/api_config.dart`:
```dart
class ApiConfig {
  static const String baseUrl = 'http://192.168.0.249:8081';
  // Change to your server IP or domain
}
```

### Network Permissions
Already configured in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
<application android:usesCleartextTraffic="true">
```

---

## 📦 Dependencies

### Main Packages
```yaml
dependencies:
  flutter: sdk: flutter
  http: ^1.1.0                    # API requests
  video_player: ^2.8.0            # Video playback
  shared_preferences: ^2.2.0      # Local storage
  cupertino_icons: ^1.0.8         # iOS icons
```

### Dev Dependencies
```yaml
dev_dependencies:
  flutter_test: sdk: flutter
  flutter_lints: ^4.0.0           # Code quality
```

---

## 🎯 Key Features Explained

### 1. Featured Videos Section
- Displays curated content on home screen
- Horizontal scrollable cards with thumbnails
- Shows rating, views, and duration

### 2. Category Browsing
- Multiple content categories (Action, Drama, Comedy, etc.)
- Each category has its own section
- Horizontal scrolling within categories

### 3. Video Player
- Custom controls overlay
- Skip forward/backward 10 seconds
- Fullscreen support
- Buffering indicators
- Error recovery with retry

### 4. User Authentication
- Persistent login sessions
- Secure token storage
- Profile information display
- Guest browsing available

### 5. Social Features
- Like/unlike videos
- View like counts
- Add comments
- See other users' comments
- User profile pictures

---

## 🌐 Deployment

### Development
```bash
flutter run --debug
```

### Production APK
```bash
flutter build apk --release
# Output: build/app/outputs/apk/release/app-release.apk
```

### App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

---

## 🐛 Troubleshooting

### Common Issues

**Problem**: "Failed to load videos"
- **Solution**: Check API server is running and accessible from device
- Verify API URL in `api_config.dart`
- Test API endpoint in browser: `http://YOUR_IP:8081/api/get_featured_videos.php`

**Problem**: "Connection refused"
- **Solution**: Ensure device and server are on same network
- Check firewall allows port 8081
- Use device's IP, not `localhost`

**Problem**: Video won't play
- **Solution**: Verify video URL is accessible
- Check Cloudinary URLs are valid
- Ensure video format is supported (MP4, WebM)

**Problem**: Images not loading
- **Solution**: Check thumbnail URLs in database
- Verify Cloudinary credentials
- Enable cleartext traffic in AndroidManifest.xml

---

## 📱 Platform Support

| Platform | Status | Notes |
|----------|--------|-------|
| Android  | ✅ Full Support | Primary platform |
| iOS      | ✅ Supported | Requires Xcode for build |
| Web      | ⚠️ Limited | Video player has limitations |
| Windows  | ⚠️ Limited | Desktop build available |
| macOS    | ⚠️ Limited | Requires Mac for build |
| Linux    | ⚠️ Limited | Desktop build available |

---

## 🔐 Security Notes

- API communications should use HTTPS in production
- User tokens stored securely with SharedPreferences
- No sensitive data hardcoded in app
- Backend handles all authentication validation

---

## 📄 License

This project is proprietary software containing exclusive content.  
**All rights reserved** - Unauthorized copying or distribution is prohibited.

---

## 👨‍💻 About the Backend

This frontend connects to a custom PHP backend that:
- Manages all video content and metadata
- Handles user authentication and sessions
- Stores video files on Cloudinary
- Manages MySQL database operations
- Provides RESTful API endpoints
- Contains **exclusive content created by the owner**

**Backend Repository**: (Private/Separate)

---

## 📞 Support

For issues related to:
- **Frontend/App**: Check this repository's issues
- **Backend/API**: Contact backend administrator
- **Video Content**: Contact content administrator

---

## 🎬 Screenshots

> Add screenshots of your app here:
> - Home screen
> - Video player
> - Category browsing
> - User profile
> - Search interface

---

## 🚧 Future Enhancements

Potential features for future versions:
- [ ] Offline download functionality
- [ ] Picture-in-Picture mode
- [ ] Chromecast support
- [ ] Multiple quality selection
- [ ] Subtitle support
- [ ] Continue watching feature
- [ ] Watch history
- [ ] Playlist creation
- [ ] Video recommendations

---

**Built with Flutter** ❤️ | **Powered by Custom PHP Backend** 🚀

*A professional streaming solution for exclusive cinema content*
