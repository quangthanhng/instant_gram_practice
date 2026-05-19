import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/user_id_provider.dart';
import 'package:instagram_clone_qthanh/state/likes/models/like_dislike_request.dart';
import 'package:instagram_clone_qthanh/state/likes/providers/has_liked_post_provider.dart';
import 'package:instagram_clone_qthanh/state/likes/providers/like_dislike_post_provider.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:shimmer/shimmer.dart';

class PostImageView extends HookConsumerWidget {
  final Post post;
  const PostImageView({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showHeart = useState(false);

    Future<void> handleDoubleTap() async {
      final userId = ref.read(userIdProvider);
      if (userId == null) return;

      // Check if user has already liked the post
      final hasLiked = ref.read(hasLikedPostProvider(post.postId)).value ?? false;
      
      if (!hasLiked) {
        final likeRequest = LikeDislikeRequest(
          postId: post.postId,
          likedBy: userId,
        );
        ref.read(likeDislikePostProvider(likeRequest));
      }

      // Show heart animation
      showHeart.value = true;
      await Future.delayed(const Duration(milliseconds: 700));
      showHeart.value = false;
    }

    return AspectRatio(
      aspectRatio: post.aspectRatio,
      child: GestureDetector(
        onDoubleTap: handleDoubleTap,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.network(
              post.fileUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Shimmer.fromColors(
                  baseColor: Colors.grey.shade900,
                  highlightColor: Colors.grey.shade800,
                  child: Container(
                    color: Colors.black,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return const Center(
                  child: Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 40,
                  ),
                );
              },
            ),
            if (showHeart.value)
              const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 90,
              )
                  .animate()
                  .scale(
                    begin: const Offset(0.3, 0.3),
                    end: const Offset(1.1, 1.1),
                    duration: 150.ms,
                    curve: Curves.easeOutBack,
                  )
                  .then()
                  .shake(hz: 4, duration: 200.ms)
                  .then(delay: 200.ms)
                  .scale(
                    begin: const Offset(1.0, 1.0),
                    end: const Offset(0.0, 0.0),
                    duration: 150.ms,
                    curve: Curves.easeIn,
                  )
                  .fadeOut(duration: 100.ms),
          ],
        ),
      ),
    );
  }
}
