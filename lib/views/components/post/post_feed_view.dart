import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_card.dart';

class PostFeedView extends StatelessWidget {
  final Iterable<Post> posts;

  const PostFeedView({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(top: 8.0, bottom: 24.0),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts.elementAt(index);
        return PostCard(post: post)
            .animate()
            .fadeIn(
              duration: 350.ms,
              delay: (index * 50).ms,
              curve: Curves.easeOutCubic,
            )
            .slideY(
              begin: 0.1,
              end: 0,
              duration: 350.ms,
              delay: (index * 50).ms,
              curve: Curves.easeOutCubic,
            );
      },
    );
  }
}
