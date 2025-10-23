import 'package:flutter/material.dart';
import '../models/video.dart';
import '../widgets/video_card.dart';

class CategoryScreen extends StatelessWidget {
  final String categoryName;
  final List<Video> videos;

  const CategoryScreen({
    super.key,
    required this.categoryName,
    required this.videos,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0F0F0F),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          categoryName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: videos.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.movie_outlined,
                    size: 80,
                    color: Colors.grey[700],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No videos in this category',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: videos.length,
              itemBuilder: (context, index) {
                return VideoCard(video: videos[index]);
              },
            ),
    );
  }
}

