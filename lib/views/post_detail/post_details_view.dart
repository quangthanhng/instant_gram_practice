import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/enums/date_sorting.dart';
import 'package:instagram_clone_qthanh/state/comments/models/post_comments_request.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/can_current_user_delete_post_provider.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/delete_post_provider.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/specific_post_with_comments_provider.dart';
import 'package:instagram_clone_qthanh/views/components/animations/loading_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/small_error_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/comment/compact_comment_column.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/alert_dialog_model.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/delete_dialog.dart';
import 'package:instagram_clone_qthanh/views/components/like_button.dart';
import 'package:instagram_clone_qthanh/views/components/likes_count_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_date_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_display_name_and_message_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_image_or_video_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_header.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/post_comments/post_comments_view.dart';
import 'package:instagram_clone_qthanh/views/theme/page_transitions.dart';
import 'package:share_plus/share_plus.dart';
import 'package:gap/gap.dart';

class PostDetailsView extends ConsumerStatefulWidget {
  final Post post;
  const PostDetailsView({super.key, required this.post});

  @override
  ConsumerState<PostDetailsView> createState() => _PostDetailsViewState();
}

class _PostDetailsViewState extends ConsumerState<PostDetailsView> {
  @override
  Widget build(BuildContext context) {
    final request = RequestForPostAndComments(
      postId: widget.post.postId,
      limit: 3,
      sortByCreatedAt: true,
      dateSorting: DateSorting.oldestOnTop,
    );

    // get the actual post together with its comments
    final postWithComments = ref.watch(
      specificPostWithCommentsProvider(request),
    );

    // can we delete this post?
    final canDeletePost = ref.watch(
      canCurrentUserDeletePostProvider(widget.post),
    );
    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.postDetails),
        actions: [
          // share button is always present
          postWithComments.when(
            data: (postWithComments) {
              return IconButton(
                onPressed: () {
                  final url = postWithComments.post.fileUrl;
                  SharePlus.instance.share(
                    ShareParams(text: url, subject: Strings.checkOutThisPost),
                  );
                },
                icon: const Icon(Icons.share),
              );
            },
            error: (error, stackTrace) {
              return SmallErrorAnimationView();
            },
            loading: () {
              return const Center(child: LoadingAnimationView());
            },
          ),
          // delete button or no delete button if user cannot delete this post
          if (canDeletePost.value ?? false)
            IconButton(
              onPressed: () async {
                final shouldDeletePost =
                    await const DeleteDialog(
                          titleOfObjectToDelete: Strings.post,
                        )
                        .present(context)
                        .then((shouldDelete) => shouldDelete ?? false);
                if (shouldDeletePost) {
                  await ref
                      .read(deletePostProvider.notifier)
                      .deletePost(post: widget.post);
                  if (mounted) {
                    Navigator.pop(context);
                  }
                }
              },
              icon: const Icon(Icons.delete),
            ),
        ],
      ),
      body: postWithComments.when(
        data: (postWithComments) {
          final postId = postWithComments.post.postId;
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Post Author Header
                PostHeader(post: postWithComments.post),
                
                // 2. Post Media
                PostImageOrVideoView(post: postWithComments.post),
                
                // 3. Action Row
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: Row(
                    children: [
                      // Like button
                      if (postWithComments.post.allowLikes)
                        LikeButton(postId: postId),
                      // Comment button
                      if (postWithComments.post.allowCommnets)
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              SlideBottomPageRoute(
                                child: PostCommentsView(postId: postId),
                              ),
                            );
                          },
                          icon: const Icon(Icons.mode_comment_outlined),
                        ),
                      const Spacer(),
                      // Share icon
                      IconButton(
                        onPressed: () {
                          final url = postWithComments.post.fileUrl;
                          SharePlus.instance.share(
                            ShareParams(text: url, subject: Strings.checkOutThisPost),
                          );
                        },
                        icon: const Icon(Icons.send_rounded),
                      ),
                    ],
                  ),
                ),
                
                // 4. Like Count (indented nicely)
                if (postWithComments.post.allowLikes)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Row(
                      children: [LikesCountView(postId: postId)],
                    ),
                  ),
                
                // 5. Display Name and Caption message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: PostDisplayNameAndMessageView(post: postWithComments.post),
                ),
                
                // 6. Relative Post Date Time
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PostDateView(dateTime: postWithComments.post.createdAt),
                ),
                
                // 7. Standard Divider
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                  child: Divider(height: 1, thickness: 0.5),
                ),
                
                // 8. Compact Comments Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: CompactCommentColumn(comments: postWithComments.comments),
                ),
                
                // add spacing to bottom of the screen
                const Gap(100),
              ],
            ),
          );
        },
        error: (error, stackTrace) {
          return const SmallErrorAnimationView();
        },
        loading: () {
          return const Center(child: LoadingAnimationView());
        },
      ),
    );
  }
}
