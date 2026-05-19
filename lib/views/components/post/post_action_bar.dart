import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/views/components/like_button.dart';
import 'package:instagram_clone_qthanh/views/post_comments/post_comments_view.dart';
import 'package:instagram_clone_qthanh/views/theme/page_transitions.dart';
import 'package:share_plus/share_plus.dart';

class PostActionBar extends StatelessWidget {
  final Post post;

  const PostActionBar({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 2.0),
      child: Row(
        children: [
          // Like Button
          if (post.allowLikes) LikeButton(postId: post.postId),
          
          // Comment Button
          if (post.allowCommnets)
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  SlideBottomPageRoute(
                    child: PostCommentsView(postId: post.postId),
                  ),
                );
              },
              icon: const FaIcon(FontAwesomeIcons.comment, size: 22),
            ),
            
          // Share Button
          IconButton(
            onPressed: () {
              // ignore: deprecated_member_use
              Share.share(
                post.fileUrl,
                subject: post.message,
              );
            },
            icon: const FaIcon(FontAwesomeIcons.paperPlane, size: 21),
          ),
        ],
      ),
    );
  }
}
