import 'package:flutter/material.dart';
import '../models/video.dart';
import '../models/user.dart';
import '../services/api_service.dart';
import '../services/api_config.dart';
import '../services/auth_service.dart';
import 'video_player_screen.dart';
import 'login_screen.dart';

class VideoDetailScreen extends StatefulWidget {
  final Video video;

  const VideoDetailScreen({super.key, required this.video});

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  Map<String, dynamic>? likesData;
  List<dynamic> comments = [];
  bool isLoadingExtras = true;
  Video? fullVideoDetails;
  User? currentUser;
  final TextEditingController _commentController = TextEditingController();
  bool isSubmittingComment = false;

  @override
  void initState() {
    super.initState();
    _loadFullVideoDetails();
    _loadCurrentUser();
    _loadExtraData();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentUser() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      currentUser = user;
    });
  }

  Future<void> _loadFullVideoDetails() async {
    try {
      // Fetch full video details including video_url
      final videoDetails = await ApiService.getVideoDetails(widget.video.id);
      setState(() {
        fullVideoDetails = videoDetails;
      });
    } catch (e) {
      // If fetch fails, use the passed video object
      setState(() {
        fullVideoDetails = widget.video;
      });
    }
  }

  Future<void> _loadExtraData() async {
    try {
      final likes = await ApiService.getVideoLikes(widget.video.id);
      final videoComments = await ApiService.getVideoComments(widget.video.id);

      setState(() {
        likesData = likes;
        comments = videoComments;
        isLoadingExtras = false;
      });
    } catch (e) {
      setState(() {
        isLoadingExtras = false;
      });
    }
  }

  Video get displayVideo => fullVideoDetails ?? widget.video;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      body: CustomScrollView(
        slivers: [
          // App Bar with backdrop image
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            backgroundColor: const Color(0xFF0F0F0F),
            leading: IconButton(
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.favorite_border, color: Colors.white),
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.share, color: Colors.white),
                ),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.video.backdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[850],
                        child: const Icon(
                          Icons.movie,
                          size: 100,
                          color: Colors.grey,
                        ),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          const Color(0xFF0F0F0F).withOpacity(0.7),
                          const Color(0xFF0F0F0F),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    displayVideo.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Rating, Year, Duration, Views
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      if (displayVideo.displayRating > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE50914),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                displayVideo.displayRating.toStringAsFixed(1),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (displayVideo.releaseYear != null)
                        _buildInfoChip(displayVideo.releaseYear.toString()),
                      if (displayVideo.duration != null)
                        _buildInfoChip(displayVideo.formattedDuration),
                      _buildInfoChip(displayVideo.formattedViews),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Category
                  if (displayVideo.category != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[850],
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.grey[700]!,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        displayVideo.category!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Play Button
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: () {
                        final videoToPlay = displayVideo;
                        if (videoToPlay.videoUrl != null && videoToPlay.videoUrl!.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VideoPlayerScreen(video: videoToPlay),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Loading video... Video URL: ${videoToPlay.videoUrl ?? "null"}'),
                              backgroundColor: Colors.orange,
                              duration: const Duration(seconds: 3),
                            ),
                          );
                          // Retry loading video details
                          _loadFullVideoDetails();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE50914),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 32, color: Colors.white),
                          SizedBox(width: 8),
                          Text(
                            'Watch Now',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Likes and Download Row
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _toggleLike,
                          icon: Icon(
                            (likesData?['user_liked'] ?? false)
                                ? Icons.thumb_up
                                : Icons.thumb_up_outlined,
                            color: (likesData?['user_liked'] ?? false)
                                ? const Color(0xFFE50914)
                                : Colors.white,
                          ),
                          label: Text(
                            likesData != null
                                ? '${likesData!['total_likes']} Likes'
                                : 'Like',
                            style: TextStyle(
                              color: (likesData?['user_liked'] ?? false)
                                  ? const Color(0xFFE50914)
                                  : Colors.white,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(
                              color: (likesData?['user_liked'] ?? false)
                                  ? const Color(0xFFE50914)
                                  : Colors.white,
                              width: 2,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.download, color: Colors.white),
                          label: const Text(
                            'Download',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.white, width: 2),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Description
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    displayVideo.description,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[300],
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Comments Section
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Comments (${comments.length})',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _showAddCommentDialog,
                        icon: const Icon(Icons.add_comment,
                            color: Color(0xFFE50914)),
                        label: const Text(
                          'Add',
                          style: TextStyle(color: Color(0xFFE50914)),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  if (isLoadingExtras)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(
                          color: Color(0xFFE50914),
                        ),
                      ),
                    )
                  else if (comments.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          'No comments yet',
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  else
                    ...comments.map((comment) => _buildCommentItem(comment)),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildCommentItem(Map<String, dynamic> comment) {
    final profileImageUrl = comment['profileImageUrl'] as String?;
    final hasImage = profileImageUrl != null && profileImageUrl.isNotEmpty;
    final fullImageUrl = hasImage ? '${ApiConfig.baseUrl}/$profileImageUrl' : null;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: const Color(0xFFE50914),
                backgroundImage: fullImageUrl != null ? NetworkImage(fullImageUrl) : null,
                child: !hasImage
                    ? Text(
                        (comment['userName'] ?? 'U')[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      comment['userName'] ?? 'Anonymous',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      comment['createdAt'] ?? '',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            comment['commentText'] ?? '',
            style: TextStyle(
              color: Colors.grey[300],
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggleLike() async {
    if (currentUser == null) {
      _showLoginPrompt('like videos');
      return;
    }

    final bool isLiked = likesData?['user_liked'] ?? false;
    
    final result = isLiked
        ? await AuthService.unlikeVideo(widget.video.id)
        : await AuthService.likeVideo(widget.video.id);

    if (result['success']) {
      // Reload likes data
      _loadExtraData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isLiked ? 'Like removed' : 'Video liked!'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to update like'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showAddCommentDialog() {
    if (currentUser == null) {
      _showLoginPrompt('add comments');
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1A1A1A),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFFE50914),
                  child: Text(
                    currentUser!.avatarLetter,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  currentUser!.displayName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _commentController,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Write your comment...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.grey[900],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: isSubmittingComment ? null : _submitComment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: isSubmittingComment
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Post Comment',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => isSubmittingComment = true);

    final result = await AuthService.addComment(
      widget.video.id,
      _commentController.text.trim(),
    );

    setState(() => isSubmittingComment = false);

    if (mounted) {
      Navigator.pop(context);
      
      if (result['success']) {
        _commentController.clear();
        _loadExtraData(); // Reload comments
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comment added successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Failed to add comment'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showLoginPrompt(String action) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A1A),
        title: const Text(
          'Login Required',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'Please login to $action',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginScreen(),
                ),
              );
              if (result == true) {
                _loadCurrentUser();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE50914),
            ),
            child: const Text(
              'Login',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

