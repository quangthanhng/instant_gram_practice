import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_thumbnail_view.dart';
import 'package:instagram_clone_qthanh/views/post_detail/post_details_view.dart';
import 'package:instagram_clone_qthanh/views/theme/page_transitions.dart';

class PostSliverGridView extends StatelessWidget {
  final Iterable<Post> posts;
  const PostSliverGridView({super.key, required this.posts});

  @override
  Widget build(BuildContext context) {
    return SliverGrid(
      delegate: SliverChildBuilderDelegate(childCount: posts.length, (
        context,
        index,
      ) {
        final post = posts.elementAt(index);
        return PostThumbnailView(
          post: post,
          onTapped: () {
            // Navigate to the post details view
            Navigator.push(
              context,
              SlideRightPageRoute(
                child: PostDetailsView(post: post),
              ),
            );
          },
        );
      }),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
      ),
    );
  }
}
