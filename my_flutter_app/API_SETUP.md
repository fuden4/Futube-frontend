
# CineMax - API Setup Guide

## 📡 Connecting to Your Futube Backend

The app is now connected to your Futube API and ready to display your videos!

### Current Configuration

**API Base URL:** `http://192.168.0.249:8081`

This is the IP address from your PHP backend config. The app will fetch data from:
- Featured Videos: `/api/get_featured_videos.php`
- Categorized Videos: `/api/get_categorized_videos.php`
- Video Details: `/api/get_video_details.php?id={id}`
- Search: `/api/videos.php?search={query}`
- Likes & Comments: `/api/get_likes.php` and `/api/get_comments.php`

### 🔧 How to Change the API URL

1. Open `lib/services/api_config.dart`
2. Update the `baseUrl` constant:

```dart
static const String baseUrl = 'http://YOUR_SERVER_IP:PORT';
```

**Examples:**
- Local network: `http://192.168.1.100:8081`
- Production domain: `https://yourdomain.com`
- Localhost (for emulator): `http://10.0.2.2:8081`

3. Rebuild the app:
```bash
flutter build apk --debug
adb install -r build\app\outputs\flutter-apk\app-debug.apk
```

### 📱 Testing on Your Android Device

**Make sure your Android device can reach your server:**

1. **Same Network**: Your phone and server must be on the same WiFi/network
2. **Firewall**: Ensure port 8081 is open on your server
3. **Test Connection**: Open a browser on your phone and visit:
   ```
   http://192.168.0.249:8081/api/get_featured_videos.php
   ```
   You should see JSON data.

### 🌐 Internet Permission (Already Added)

The app already has internet permission in `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

### 🐛 Troubleshooting

#### "Failed to load videos" Error

1. **Check your server is running:**
   ```bash
   # Test API from your computer
   curl http://192.168.0.249:8081/api/get_featured_videos.php
   ```

2. **Check Android can reach server:**
   - Open browser on phone
   - Visit the API URL
   - If it doesn't load, there's a network issue

3. **Check API returns valid JSON:**
   - API should return JSON array/object
   - Check for PHP errors in response

4. **Update cleartext traffic (if needed):**
   If using HTTP (not HTTPS), ensure `android/app/src/main/AndroidManifest.xml` has:
   ```xml
   <application
       android:usesCleartextTraffic="true"
       ...>
   ```

#### "Connection refused" Error

- Server is not running
- Wrong IP address or port
- Firewall blocking connection

#### "No data showing" Error

- API returns empty array
- Database has no videos with `is_featured = 1`
- Check your MySQL database has data

### 🚀 Deploy to Production

When you deploy your backend to a public server:

1. Update `api_config.dart` with your domain:
   ```dart
   static const String baseUrl = 'https://yourdomain.com';
   ```

2. Enable HTTPS (recommended):
   - Get SSL certificate
   - Configure your server for HTTPS
   - Update all API endpoints to use HTTPS

3. Rebuild and release:
   ```bash
   flutter build apk --release
   ```

### 📊 API Response Examples

**Featured Videos:**
```json
[
  {
    "id": "1",
    "title": "Movie Title",
    "description": "Description...",
    "thumb_url": "http://192.168.0.249:8081/uploads/thumb.jpg",
    "rating": "8.5",
    "views": "1250",
    "category": "Action",
    "duration": "2:15:00",
    "release_year": "2024",
    "is_featured": true,
    "is_vimeo": false
  }
]
```

**Video Likes:**
```json
{
  "success": true,
  "total_likes": 42,
  "user_liked": false
}
```

### 🎯 Next Steps

1. ✅ Verify your server is accessible from your phone
2. ✅ Add more videos to your database
3. ✅ Test all features (search, categories, details)
4. 🔄 Consider adding user authentication
5. 🔄 Implement video player for playback

### 💡 Tips

- **Development**: Use local IP for testing
- **Production**: Use domain name with HTTPS
- **Offline Mode**: Consider caching API responses
- **Performance**: Implement pagination for large datasets

---

Need help? Check your server logs and use Chrome DevTools to inspect API responses!

