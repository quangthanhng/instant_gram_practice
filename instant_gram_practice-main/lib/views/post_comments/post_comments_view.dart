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

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.comments),
        actions: [
          IconButton(
            onPressed: hasText.value
                ? () {
                    _submitCommentWithController(commentsController, ref);
                  }
                : null,
            icon: const Icon(Icons.send),
          ),
        ],
      ),
      body: SafeArea(
        child: Flex(
          direction: Axis.vertical,
          children: [
            Expanded(
              flex: 4,
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
                      padding: const EdgeInsets.all(8),
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
            Expanded(
              flex: 1,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8, right: 8),
                  child: TextField(
                    textInputAction: TextInputAction.send,
                    controller: commentsController,
                    onSubmitted: (comment) {
                      if (comment.isNotEmpty) {
                        _submitCommentWithController(commentsController, ref);
                      }
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: Strings.writeYourCommentHere,
                    ),
                  ),
                ),
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
