import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/user_posts_provider.dart';
import 'package:instagram_clone_qthanh/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/error_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/loading_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_grid_view.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';

class UserPostsView extends ConsumerWidget {
  const UserPostsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(userPostsProvider);
    return RefreshIndicator(
      onRefresh: () {
        ref.refresh(userPostsProvider);
        return Future.delayed(const Duration(seconds: 1));
      },
      child: posts.when(
        data: (posts) {
          if (posts.isEmpty) {
            return EmptyContentsWithTextAnimationView(
              text: Strings.youHaveNoPost,
            );
          } else {
            return PostGridView(posts: posts);
          }
        },
        error: (error, stackTrace) => ErrorAnimationView(),
        loading: () => LoadingAnimationView(),
      ),
    );
  }
}
