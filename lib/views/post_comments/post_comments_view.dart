import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/user_id_provider.dart';
import 'package:instagram_clone_qthanh/state/comments/models/post_comments_request.dart';
import 'package:instagram_clone_qthanh/state/comments/providers/post_comment_provider.dart';
import 'package:instagram_clone_qthanh/state/comments/providers/send_comment_provider.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/post_id.dart';
import 'package:instagram_clone_qthanh/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/error_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/loading_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/comment/comment_tile.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/extensions/dismiss_keyboard.dart';
import 'package:instagram_clone_qthanh/views/components/avatar_widget.dart';
import 'package:instagram_clone_qthanh/state/user_info/providers/user_info_model_providers.dart';

class PostCommentsView extends HookConsumerWidget {
  const PostCommentsView({super.key, required this.postId});

  final PostId postId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final commentsController = useTextEditingController();

    final hasText = useState(false);

    final request = useState(RequestForPostAndComments(postId: postId));

    final comments = ref.watch(postCommentsProvider(request.value));

    useEffect(() {
      commentsController.addListener(() {
        hasText.value = commentsController.text.isNotEmpty;
      });
      return () {};
    }, [commentsController]);

    final userId = ref.watch(userIdProvider);
    final userInfo = userId != null ? ref.watch(userInfoModelProvider(userId)).value : null;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.comments),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 1. Comments list occupying full remaining space
            Expanded(
              child: comments.when(
                data: (comments) {
                  if (comments.isEmpty) {
                    return const SingleChildScrollView(
                      child: EmptyContentsWithTextAnimationView(
                        text: Strings.noCommentsYet,
                      ),
                    );
                  }
                  return RefreshIndicator(
                    onRefresh: () {
                      ref.refresh(postCommentsProvider(request.value));
                      return Future.delayed(const Duration(seconds: 1));
                    },
                    child: ListView.builder(
                      itemCount: comments.length,
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      itemBuilder: (context, index) {
                        final comment = comments.elementAt(index);
                        return CommentTile(comment: comment);
                      },
                    ),
                  );
                },
                error: (error, stackTrace) {
                  return const ErrorAnimationView();
                },
                loading: () {
                  return const LoadingAnimationView();
                },
              ),
            ),
            
            // 2. High-fidelity floating bottom comment input bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                border: Border(
                  top: BorderSide(
                    color: theme.colorScheme.outline.withValues(alpha: 0.1),
                    width: 0.5,
                  ),
                ),
              ),
              child: Row(
                children: [
                  // Active user's avatar
                  if (userId != null)
                    AvatarWidget(
                      userId: userId,
                      displayName: userInfo?.displayName ?? '?',
                      radius: 16.0,
                      hasStoryRing: false,
                    ),
                  const SizedBox(width: 12),
                  
                  // Text input field
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: TextField(
                        controller: commentsController,
                        textInputAction: TextInputAction.send,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14,
                        ),
                        onSubmitted: (comment) {
                          if (comment.isNotEmpty) {
                            _submitCommentWithController(commentsController, ref);
                          }
                        },
                        decoration: InputDecoration(
                          hintText: Strings.writeYourCommentHere,
                          hintStyle: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 13.5,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  
                  // Send action button
                  IconButton(
                    onPressed: hasText.value
                        ? () {
                            _submitCommentWithController(commentsController, ref);
                          }
                        : null,
                    icon: Icon(
                      Icons.send_rounded,
                      color: hasText.value
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface.withValues(alpha: 0.3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submitCommentWithController(
    TextEditingController controller,
    WidgetRef ref,
  ) async {
    final userId = ref.read(userIdProvider);
    if (userId == null) {
      return;
    }
    final isSent = await ref
        .read(sendCommentProvider.notifier)
        .sendComments(
          fromUserId: userId,
          onPostId: postId,
          comment: controller.text,
        );
    if (isSent) {
      controller.clear();
      dissMissKeyboard();
    }
  }
}
