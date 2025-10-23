import 'package:flutter/material.dart';
import '../models/video.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';
import '../widgets/video_card.dart';
import 'search_screen.dart';
import 'category_screen.dart';
import 'login_screen.dart';
import 'video_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Video> featuredVideos = [];
  Map<String, List<Video>> categorizedVideos = {};
  bool isLoading = true;
  String? errorMessage;
  User? currentUser;

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _loadCurrentUser();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _loadVideos() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final featured = await ApiService.getFeaturedVideos();
      final categorized = await ApiService.getCategorizedVideos();

      setState(() {
        featuredVideos = featured;
        categorizedVideos = categorized;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to load videos: $e';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _loadVideos,
          color: const Color(0xFFE50914),
          child: CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                backgroundColor: const Color(0xFF0F0F0F),
                floating: true,
                pinned: false,
                snap: true,
                title: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE50914).withOpacity(0.3),
                            blurRadius: 8,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.asset(
                          'assets/images/logo.png',
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFE50914), Color(0xFFB20710)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.movie_filter,
                                color: Colors.white,
                                size: 24,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Futube',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SearchScreen(),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.white),
                    onPressed: _loadVideos,
                  ),
                     // Login/Profile button
                    IconButton(
                      icon: currentUser != null
                          ? CircleAvatar(
                              backgroundColor: const Color(0xFFE50914),
                              radius: 16,
                              backgroundImage: currentUser!.profileImageUrl != null && 
                                              currentUser!.profileImageUrl!.isNotEmpty
                                  ? NetworkImage('${ApiConfig.baseUrl}/${currentUser!.profileImageUrl}')
                                  : null,
                              child: currentUser!.profileImageUrl == null || 
                                     currentUser!.profileImageUrl!.isEmpty
                                  ? Text(
                                      currentUser!.avatarLetter,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    )
                                  : null,
                            )
                          : const Icon(Icons.person_outline, color: Colors.white),
                    onPressed: () async {
                      if (currentUser != null) {
                        // Show profile menu
                        _showProfileMenu();
                      } else {
                        // Navigate to login
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                        if (result == true) {
                          _loadCurrentUser();
                        }
                      }
                    },
                  ),
                ],
              ),

              // Loading or Error State
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFE50914),
                    ),
                  ),
                )
              else if (errorMessage != null)
                SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 80,
                          color: Colors.grey,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _loadVideos,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child: const Text(
                            'Retry',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ..._buildContent(),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildContent() {
    List<Widget> widgets = [];

    // Featured Videos Carousel
    if (featuredVideos.isNotEmpty) {
      widgets.add(
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildFeaturedCarousel(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      );
    }

    // Categorized Videos
    categorizedVideos.forEach((category, videos) {
      if (videos.isNotEmpty) {
        widgets.add(
          SliverToBoxAdapter(
            child: _buildSectionHeader(category, context),
          ),
        );
        widgets.add(
          SliverToBoxAdapter(
            child: SizedBox(
              height: 280,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                scrollDirection: Axis.horizontal,
                itemCount: videos.length,
                itemBuilder: (context, index) {
                  return VideoCard(video: videos[index]);
                },
              ),
            ),
          ),
        );
      }
    });

    // If no categories, show all featured videos
    if (categorizedVideos.isEmpty && featuredVideos.length > 1) {
      widgets.add(
        SliverToBoxAdapter(
          child: _buildSectionHeader('Featured Videos', context),
        ),
      );
      widgets.add(
        SliverToBoxAdapter(
          child: SizedBox(
            height: 280,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: featuredVideos.length,
              itemBuilder: (context, index) {
                return VideoCard(video: featuredVideos[index]);
              },
            ),
          ),
        ),
      );
    }

    widgets.add(
      const SliverToBoxAdapter(
        child: SizedBox(height: 32),
      ),
    );

    return widgets;
  }

  Widget _buildSectionHeader(String title, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          TextButton(
            onPressed: () {
              // Get videos for this category
              final categoryVideos = categorizedVideos[title] ?? [];
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryScreen(
                    categoryName: title,
                    videos: categoryVideos,
                  ),
                ),
              );
            },
            child: const Text(
              'See All',
              style: TextStyle(
                color: Color(0xFFE50914),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedCarousel() {
    return SizedBox(
      height: 280,
      child: PageView.builder(
        itemCount: featuredVideos.length,
        controller: PageController(viewportFraction: 0.9),
        itemBuilder: (context, index) {
          final video = featuredVideos[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => VideoDetailScreen(video: video),
              ),
            );
          },
          child: Container(
            width: MediaQuery.of(context).size.width,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background image
                  Image.network(
                    video.backdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[850],
                        child: const Icon(
                          Icons.movie,
                          size: 80,
                          color: Colors.grey,
                        ),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        color: Colors.grey[850],
                        child: const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFE50914),
                          ),
                        ),
                      );
                    },
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                          Colors.black.withOpacity(0.95),
                        ],
                      ),
                    ),
                  ),
                  // Featured badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE50914),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'FEATURED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Content at bottom
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          video.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (video.displayRating > 0) ...[
                              const Icon(
                                Icons.star,
                                color: Colors.amber,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                video.displayRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(width: 12),
                            ],
                            const Icon(
                              Icons.visibility,
                              color: Colors.white70,
                              size: 14,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              video.formattedViews,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            if (video.category != null) ...[
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  video.category!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoDetailScreen(video: video),
                              ),
                            );
                          },
                          icon: const Icon(Icons.play_arrow, color: Colors.white),
                          label: const Text(
                            'Watch Now',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFE50914),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                          ),
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
    );
  }

  void _showProfileMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
                   CircleAvatar(
                     backgroundColor: const Color(0xFFE50914),
                     radius: 40,
                     backgroundImage: currentUser!.profileImageUrl != null && 
                                     currentUser!.profileImageUrl!.isNotEmpty
                         ? NetworkImage('${ApiConfig.baseUrl}/${currentUser!.profileImageUrl}')
                         : null,
                     child: currentUser!.profileImageUrl == null || 
                            currentUser!.profileImageUrl!.isEmpty
                         ? Text(
                             currentUser!.avatarLetter,
                             style: const TextStyle(
                               color: Colors.white,
                               fontWeight: FontWeight.bold,
                               fontSize: 32,
                             ),
                           )
                         : null,
                   ),
            const SizedBox(height: 16),
            Text(
              currentUser!.displayName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (currentUser!.email != null)
              Text(
                currentUser!.email!,
                style: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
              ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.logout, color: Color(0xFFE50914)),
              title: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
              onTap: () async {
                await AuthService.logout();
                setState(() {
                  currentUser = null;
                });
                if (mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logged out successfully'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
