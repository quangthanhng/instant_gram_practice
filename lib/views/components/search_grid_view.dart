import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/all_posts_provider.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/posts_by_search_term_provider.dart';
import 'package:instagram_clone_qthanh/views/components/animations/data_not_found_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/error_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_sliver_grid_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_thumbnail_view.dart';
import 'package:instagram_clone_qthanh/views/post_detail/post_details_view.dart';
import 'package:instagram_clone_qthanh/views/theme/page_transitions.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';

class SearchGridView extends ConsumerWidget {
  final String searchTerm;
  const SearchGridView({super.key, required this.searchTerm});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // If no search query, show Pinterest-style Explore staggered grid of all posts!
    if (searchTerm.isEmpty) {
      final allPosts = ref.watch(allPostsProvider);
      
      return allPosts.when(
        data: (posts) {
          if (posts.isEmpty) {
            return const SliverToBoxAdapter(
              child: EmptyContentsWithTextAnimationView(
                text: Strings.noPostsAvailable,
              ),
            );
          }
          
          return SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            sliver: SliverMasonryGrid.count(
              crossAxisCount: 2,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              itemBuilder: (context, index) {
                final post = posts.elementAt(index);
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: post.aspectRatio,
                    child: PostThumbnailView(
                      post: post,
                      onTapped: () {
                        Navigator.push(
                          context,
                          SlideRightPageRoute(
                            child: PostDetailsView(post: post),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
              childCount: posts.length,
            ),
          );
        },
        error: (error, stackTrace) => const SliverToBoxAdapter(
          child: ErrorAnimationView(),
        ),
        loading: () => const SliverToBoxAdapter(
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: CircularProgressIndicator(),
            ),
          ),
        ),
      );
    }

    // Active search view
    final posts = ref.watch(postsBySearchTermProvider(searchTerm));

    return posts.when(
      data: (posts) {
        if (posts.isEmpty) {
          return const SliverToBoxAdapter(child: DataNotFoundAnimationView());
        } else {
          return PostSliverGridView(posts: posts);
        }
      },
      error: (error, stackTrace) =>
          const SliverToBoxAdapter(child: ErrorAnimationView()),
      loading: () {
        return const SliverToBoxAdapter(
          child: Center(child: CircularProgressIndicator()),
        );
      },
    );
  }
}
