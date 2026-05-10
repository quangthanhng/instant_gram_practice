import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';

class PostThumbnailView extends StatelessWidget {
  const PostThumbnailView({
    super.key,
    required this.post,
    required this.onTapped,
  });

  final Post post;
  final VoidCallback onTapped;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTapped,
      child: Image.network(
        post.thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Icon(Icons.error_outline, color: Colors.red),
          );
        },
      ),
    );
  }
}
