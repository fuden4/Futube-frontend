import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import '../models/video.dart';

class VideoPlayerScreen extends StatefulWidget {
  final Video video;

  const VideoPlayerScreen({super.key, required this.video});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with TickerProviderStateMixin {
  VideoPlayerController? _controller;
  bool _isLoading = true;
  String? _errorMessage;
  bool _isPlaying = false;
  bool _showControls = true;
  bool _isFullScreen = false;
  Timer? _hideControlsTimer;
  double _currentSpeed = 1.0;
  
  // Animation controllers
  late AnimationController _controlsAnimationController;
  late Animation<double> _controlsAnimation;
  late AnimationController _seekAnimationController;
  
  // Double tap to seek
  String? _seekFeedback; // "10" or "-10"
  Alignment? _seekFeedbackAlignment;
  
  // Dragging for seeking
  bool _isDragging = false;
  Duration? _dragPosition;
  
  // Gesture controls for brightness/volume
  double _brightness = 0.5;
  double _volume = 0.5;
  String? _gestureIndicator;
  Timer? _gestureIndicatorTimer;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
    
    // Setup animations
    _controlsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _controlsAnimation = CurvedAnimation(
      parent: _controlsAnimationController,
      curve: Curves.easeInOut,
    );
    _controlsAnimationController.forward();
    
    _seekAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    
    // Keep screen awake and set landscape
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    
    _startHideControlsTimer();
  }

  void _startHideControlsTimer() {
    _hideControlsTimer?.cancel();
    _hideControlsTimer = Timer(const Duration(seconds: 3), () {
      if (_showControls && _isPlaying && !_isDragging) {
        _hideControls();
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _controlsAnimationController.forward();
    _startHideControlsTimer();
  }

  void _hideControls() {
    _controlsAnimationController.reverse().then((_) {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleControls() {
    if (_showControls) {
      _hideControls();
      _hideControlsTimer?.cancel();
    } else {
      _showControlsTemporarily();
    }
  }

  Future<void> _initializePlayer() async {
    try {
      if (widget.video.videoUrl == null || widget.video.videoUrl!.isEmpty) {
        setState(() {
          _errorMessage = 'Video URL not available';
          _isLoading = false;
        });
        return;
      }

      String videoUrl = widget.video.videoUrl!.trim();
      
      if (videoUrl.startsWith('http://res.cloudinary.com')) {
        videoUrl = videoUrl.replaceFirst('http://', 'https://');
      }

      _controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        videoPlayerOptions: VideoPlayerOptions(
          mixWithOthers: false,
          allowBackgroundPlayback: false,
        ),
      );

      _controller!.addListener(() {
        if (mounted) {
          if (_controller!.value.hasError) {
            setState(() {
              _errorMessage = 'Video playback error. Please check your connection.';
              _isLoading = false;
            });
          } else {
            setState(() {
              _isPlaying = _controller!.value.isPlaying;
            });
          }
        }
      });

      await _controller!.initialize();
      await _controller!.setPlaybackSpeed(_currentSpeed);
      await _controller!.play();

      setState(() {
        _isLoading = false;
        _isPlaying = true;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to load video. Please check your internet connection.\n\nError: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _retryVideo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    _controller?.dispose();
    await _initializePlayer();
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
      } else {
        _controller!.play();
      }
    });
    _showControlsTemporarily();
  }

  void _handleDoubleTap(TapDownDetails details) {
    if (_controller == null || !_controller!.value.isInitialized) return;
    
    final screenWidth = MediaQuery.of(context).size.width;
    final tapPosition = details.globalPosition.dx;
    final currentPosition = _controller!.value.position;
    final duration = _controller!.value.duration;
    
    if (tapPosition < screenWidth / 3) {
      // Left side - seek backward 10 seconds
      final newPosition = currentPosition - const Duration(seconds: 10);
      _controller!.seekTo(newPosition > Duration.zero ? newPosition : Duration.zero);
      _showSeekFeedback('-10', Alignment.centerLeft);
    } else if (tapPosition > screenWidth * 2 / 3) {
      // Right side - seek forward 10 seconds
      final newPosition = currentPosition + const Duration(seconds: 10);
      _controller!.seekTo(newPosition < duration ? newPosition : duration);
      _showSeekFeedback('+10', Alignment.centerRight);
    }
  }

  void _showSeekFeedback(String text, Alignment alignment) {
    setState(() {
      _seekFeedback = text;
      _seekFeedbackAlignment = alignment;
    });
    _seekAnimationController.forward(from: 0.0);
    
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _seekFeedback = null;
        });
      }
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    
    if (duration.inHours > 0) {
      return "$hours:$minutes:$seconds";
    }
    return "$minutes:$seconds";
  }

  void _handleVerticalDrag(DragUpdateDetails details, bool isLeftSide) {
    final delta = details.delta.dy;
    
    if (isLeftSide) {
      // Brightness control
      setState(() {
        _brightness = (_brightness - (delta / 200)).clamp(0.0, 1.0);
        _gestureIndicator = 'brightness';
      });
    } else {
      // Volume control
      setState(() {
        _volume = (_volume - (delta / 200)).clamp(0.0, 1.0);
        _gestureIndicator = 'volume';
      });
    }
    
    _gestureIndicatorTimer?.cancel();
    _gestureIndicatorTimer = Timer(const Duration(milliseconds: 1000), () {
      if (mounted) {
        setState(() {
          _gestureIndicator = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    _gestureIndicatorTimer?.cancel();
    _controller?.dispose();
    _controlsAnimationController.dispose();
    _seekAnimationController.dispose();
    
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    super.dispose();
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
      if (_isFullScreen) {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      } else {
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      }
    });
    _showControlsTemporarily();
  }

  void _showSettingsMenu() {
    _hideControlsTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Video Settings',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.speed, color: Colors.white),
              title: const Text(
                'Playback Speed',
                style: TextStyle(color: Colors.white),
              ),
              trailing: Text(
                _currentSpeed == 1.0 ? 'Normal' : '${_currentSpeed}x',
                style: const TextStyle(
                  color: Color(0xFFE50914),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showSpeedMenu();
              },
            ),
            ListTile(
              leading: const Icon(Icons.high_quality, color: Colors.white),
              title: const Text(
                'Quality',
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                'Auto',
                style: TextStyle(
                  color: Color(0xFFE50914),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _showQualityMenu();
              },
            ),
            ListTile(
              leading: const Icon(Icons.subtitles, color: Colors.white),
              title: const Text(
                'Subtitles',
                style: TextStyle(color: Colors.white),
              ),
              trailing: const Text(
                'Off',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Subtitles feature coming soon!'),
                    duration: Duration(seconds: 1),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) => _showControlsTemporarily());
  }

  void _showSpeedMenu() {
    _hideControlsTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Playback Speed',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...[ 0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0].map((speed) {
              final isSelected = _currentSpeed == speed;
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? const Color(0xFFE50914) : Colors.grey,
                ),
                title: Text(
                  speed == 1.0 ? 'Normal' : '${speed}x',
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE50914) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  setState(() {
                    _currentSpeed = speed;
                    _controller?.setPlaybackSpeed(speed);
                  });
                  Navigator.pop(context);
                  _showControlsTemporarily();
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) => _showControlsTemporarily());
  }

  void _showQualityMenu() {
    _hideControlsTimer?.cancel();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[600],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Video Quality',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ...['Auto', '1080p', '720p', '480p', '360p'].map((quality) {
              final isSelected = quality == 'Auto';
              return ListTile(
                leading: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected ? const Color(0xFFE50914) : Colors.grey,
                ),
                title: Text(
                  quality,
                  style: TextStyle(
                    color: isSelected ? const Color(0xFFE50914) : Colors.white,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Quality set to $quality'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                  _showControlsTemporarily();
                },
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    ).then((_) => _showControlsTemporarily());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFE50914),
              ),
            )
          : _errorMessage != null
              ? _buildErrorWidget()
              : _buildVideoPlayer(),
    );
  }

  Widget _buildErrorWidget() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 80,
          ),
          const SizedBox(height: 16),
          Text(
            _errorMessage!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: _retryVideo,
                icon: const Icon(Icons.refresh, color: Colors.white),
                label: const Text(
                  'Retry',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE50914),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.white, width: 2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Go Back',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Gesture detector for brightness/volume
        Row(
          children: [
            // Left side - brightness control
            Expanded(
              child: GestureDetector(
                onTap: _toggleControls,
                onDoubleTapDown: _handleDoubleTap,
                onVerticalDragUpdate: (details) {
                  _handleVerticalDrag(details, true);
                },
                child: Container(color: Colors.transparent),
              ),
            ),
            // Right side - volume control
            Expanded(
              child: GestureDetector(
                onTap: _toggleControls,
                onDoubleTapDown: _handleDoubleTap,
                onVerticalDragUpdate: (details) {
                  _handleVerticalDrag(details, false);
                },
                child: Container(color: Colors.transparent),
              ),
            ),
          ],
        ),
        
        // Video and other UI elements
        IgnorePointer(
          child: Stack(
            fit: StackFit.expand,
            children: [
          // Video player
          Center(
            child: AspectRatio(
              aspectRatio: _controller!.value.aspectRatio,
              child: VideoPlayer(_controller!),
            ),
          ),
          
          // Buffering indicator
          if (_controller!.value.isBuffering)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFFE50914),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Buffering...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          
          // Seek feedback (double tap animation)
          if (_seekFeedback != null)
            AnimatedBuilder(
              animation: _seekAnimationController,
              builder: (context, child) {
                return Align(
                  alignment: _seekFeedbackAlignment!,
                  child: Opacity(
                    opacity: 1.0 - _seekAnimationController.value,
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 60),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.7),
                        shape: BoxShape.circle,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _seekFeedback!.startsWith('+')
                                ? Icons.forward_10
                                : Icons.replay_10,
                            color: Colors.white,
                            size: 40,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$_seekFeedback seconds',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          
              // Controls overlay
              if (_showControls)
                FadeTransition(
                  opacity: _controlsAnimation,
                  child: _buildControls(),
                ),
            ],
          ),
        ),
        
        // Gesture indicator (brightness/volume)
        if (_gestureIndicator != null)
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _gestureIndicator == 'brightness'
                        ? Icons.brightness_6
                        : Icons.volume_up,
                    color: Colors.white,
                    size: 40,
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: 200,
                    child: LinearProgressIndicator(
                      value: _gestureIndicator == 'brightness'
                          ? _brightness
                          : _volume,
                      backgroundColor: Colors.white.withOpacity(0.3),
                      color: const Color(0xFFE50914),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${((_gestureIndicator == 'brightness' ? _brightness : _volume) * 100).toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildControls() {
    final position = _dragPosition ?? _controller!.value.position;
    final duration = _controller!.value.duration;
    final progress = duration.inMilliseconds > 0
        ? position.inMilliseconds / duration.inMilliseconds
        : 0.0;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.7),
            Colors.transparent,
            Colors.transparent,
            Colors.black.withOpacity(0.8),
          ],
          stops: const [0.0, 0.2, 0.6, 1.0],
        ),
      ),
      child: Column(
        children: [
          // Top bar with title and back button
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 28),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Expanded(
                    child: Text(
                      widget.video.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.cast, color: Colors.white, size: 26),
                    onPressed: () {
                      // Cast functionality placeholder
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Cast feature coming soon!'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          
          const Spacer(),
          
          // Center play/pause button
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButton(
                  icon: Icons.replay_10,
                  size: 48,
                  onPressed: () {
                    final currentPosition = _controller!.value.position;
                    final newPosition = currentPosition - const Duration(seconds: 10);
                    _controller!.seekTo(
                      newPosition > Duration.zero ? newPosition : Duration.zero,
                    );
                    _showControlsTemporarily();
                  },
                ),
                const SizedBox(width: 40),
                _buildControlButton(
                  icon: _isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 64,
                  onPressed: _togglePlayPause,
                ),
                const SizedBox(width: 40),
                _buildControlButton(
                  icon: Icons.forward_10,
                  size: 48,
                  onPressed: () {
                    final currentPosition = _controller!.value.position;
                    final duration = _controller!.value.duration;
                    final newPosition = currentPosition + const Duration(seconds: 10);
                    _controller!.seekTo(
                      newPosition < duration ? newPosition : duration,
                    );
                    _showControlsTemporarily();
                  },
                ),
              ],
            ),
          ),
          
          const Spacer(),
          
          // Bottom controls
          SafeArea(
            top: false,
            child: Column(
              children: [
                // Progress bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: GestureDetector(
                    onHorizontalDragStart: (details) {
                      setState(() {
                        _isDragging = true;
                      });
                      _hideControlsTimer?.cancel();
                    },
                    onHorizontalDragUpdate: (details) {
                      final RenderBox box = context.findRenderObject() as RenderBox;
                      final tapPosition = details.localPosition.dx;
                      final width = box.size.width - 32;
                      final newProgress = (tapPosition - 16).clamp(0.0, width) / width;
                      
                      setState(() {
                        _dragPosition = duration * newProgress;
                      });
                    },
                    onHorizontalDragEnd: (details) {
                      if (_dragPosition != null) {
                        _controller!.seekTo(_dragPosition!);
                        setState(() {
                          _dragPosition = null;
                          _isDragging = false;
                        });
                      }
                      _showControlsTemporarily();
                    },
                    child: SizedBox(
                      height: 20,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Background
                          Container(
                            height: 4,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          // Buffered
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: _controller!.value.buffered.isNotEmpty
                                  ? _controller!.value.buffered.last.end.inMilliseconds /
                                      duration.inMilliseconds
                                  : 0.0,
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          // Progress
                          Align(
                            alignment: Alignment.centerLeft,
                            child: FractionallySizedBox(
                              widthFactor: progress.clamp(0.0, 1.0),
                              child: Container(
                                height: 4,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE50914),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                          // Seek indicator
                          if (_isDragging && _dragPosition != null)
                            Positioned(
                              left: (progress * (MediaQuery.of(context).size.width - 32))
                                  .clamp(0.0, MediaQuery.of(context).size.width - 32),
                              child: Container(
                                width: 16,
                                height: 16,
                                decoration: const BoxDecoration(
                                  color: Color(0xFFE50914),
                                  shape: BoxShape.circle,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                
                // Time and controls
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      Text(
                        _formatDuration(position),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        ' / ${_formatDuration(duration)}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      // Playback speed
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            _currentSpeed == 1.0 ? '1x' : '${_currentSpeed}x',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        onPressed: _showSpeedMenu,
                      ),
                      // Fullscreen
                      IconButton(
                        icon: Icon(
                          _isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                          color: Colors.white,
                          size: 28,
                        ),
                        onPressed: _toggleFullScreen,
                      ),
                      // Settings
                      IconButton(
                        icon: const Icon(Icons.settings, color: Colors.white, size: 26),
                        onPressed: () {
                          _showSettingsMenu();
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required double size,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 2,
          ),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Colors.white),
        iconSize: size,
        onPressed: onPressed,
      ),
    );
  }
}
