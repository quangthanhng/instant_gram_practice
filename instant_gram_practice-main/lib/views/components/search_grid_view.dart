import 'package:flutter/material.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:instagram_clone_qthanh/state/posts/provider/posts_by_search_term_provider.dart';

import 'package:instagram_clone_qthanh/views/components/animations/data_not_found_animation_view.dart';

import 'package:instagram_clone_qthanh/views/components/animations/empty_contents_with_text_animation_view.dart';

import 'package:instagram_clone_qthanh/views/components/animations/error_animation_view.dart';

import 'package:instagram_clone_qthanh/views/components/post/post_grid_view.dart';

import 'package:instagram_clone_qthanh/views/components/post/post_sliver_grid_view.dart';

import 'package:instagram_clone_qthanh/views/constants/strings.dart';



class SearchGridView extends ConsumerWidget {

  final String searchTerm;

  const SearchGridView({super.key, required this.searchTerm});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    if (searchTerm.isEmpty) {

      return const SliverToBoxAdapter(

        child: EmptyContentsWithTextAnimationView(

          text: Strings.enterYourSearchTermHere,

        ),

      );

    }



    final posts = ref.watch(postsBySearchTermProvider(searchTerm));



    return posts.when(

      data: (posts) {

        if (posts.isEmpty) {

          return SliverToBoxAdapter(child: const DataNotFoundAnimationView());

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