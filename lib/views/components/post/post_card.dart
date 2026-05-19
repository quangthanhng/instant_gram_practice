import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/views/components/likes_count_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_action_bar.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_date_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_display_name_and_message_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_header.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_image_or_video_view.dart';
import 'package:instagram_clone_qthanh/views/post_comments/post_comments_view.dart';
import 'package:instagram_clone_qthanh/views/theme/page_transitions.dart';

class PostCard extends StatelessWidget {
  final Post post;

  const PostCard({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Post Header (Avatar + Username + Delete option)
          PostHeader(post: post),

          // 2. Main Media (Image / Video with Shimmer and Double Tap Like)
          PostImageOrVideoView(post: post),

          // 3. Social Interaction Buttons (Like, Comment, Share)
          PostActionBar(post: post),

          // 4. Post Likes Count
          if (post.allowLikes)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 2.0),
              child: DefaultTextStyle(
                style: theme.textTheme.titleSmall!.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                child: LikesCountView(postId: post.postId),
              ),
            ),

          // 5. Post Caption (User Display Name + Message)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: PostDisplayNameAndMessageView(post: post),
          ),

          // 6. Comments Teaser Link
          if (post.allowCommnets)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    SlideBottomPageRoute(
                      child: PostCommentsView(postId: post.postId),
                    ),
                  );
                },
                child: Text(
                  'Xem tất cả bình luận...',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
            ),

          // 7. Post Timestamp (Relative time like "2 hours ago")
          PostDateView(dateTime: post.createdAt),
          
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
