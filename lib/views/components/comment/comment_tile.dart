import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/user_id_provider.dart';
import 'package:instagram_clone_qthanh/state/comments/models/comment.dart';
import 'package:instagram_clone_qthanh/state/comments/providers/delete_comment_provider.dart';
import 'package:instagram_clone_qthanh/state/user_info/providers/user_info_model_providers.dart';
import 'package:instagram_clone_qthanh/views/components/animations/small_error_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/avatar_widget.dart';
import 'package:instagram_clone_qthanh/views/components/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/alert_dialog_model.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/delete_dialog.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentTile extends ConsumerWidget {
  const CommentTile({super.key, required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoModelProvider(comment.fromUserId));
    final theme = Theme.of(context);

    return userInfo.when(
      data: (userInfo) {
        final currentUserId = ref.read(userIdProvider);
        final isOwner = currentUserId == comment.fromUserId;
        
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Commenter Avatar (Clean look, no active ring inside comments list)
              AvatarWidget(
                userId: comment.fromUserId,
                displayName: userInfo.displayName,
                radius: 16.0,
                hasStoryRing: false,
              ),
              const SizedBox(width: 12),
              
              // 2. Comment Content Block
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Username + Comment Text
                    RichText(
                      text: TextSpan(
                        style: theme.textTheme.bodyMedium,
                        children: [
                          TextSpan(
                            text: '${userInfo.displayName} ',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 13.5,
                            ),
                          ),
                          TextSpan(
                            text: comment.comment,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: 13.5,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    
                    // Metadata Row (Relative Time, Reply action)
                    Row(
                      children: [
                        Text(
                          timeago.format(comment.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                            fontSize: 11.5,
                          ),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            // Reply action placeholder (native premium style)
                          },
                          child: Text(
                            'Reply',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // 3. Delete Comment Option
              if (isOwner)
                IconButton(
                  onPressed: () async {
                    final shouldDeleteComment = await displayDeleteDialog(context);
                    if (shouldDeleteComment) {
                      await ref
                          .read(deleteCommentProvider.notifier)
                          .deleteComment(commentId: comment.id);
                    }
                  },
                  icon: Icon(
                    Icons.delete_outline_rounded,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
        );
      },
      loading: () {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const CircleAvatar(radius: 16, backgroundColor: Colors.white10),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(width: 80, height: 10, color: Colors.white10),
                    const SizedBox(height: 6),
                    Container(width: 150, height: 12, color: Colors.white10),
                  ],
                ),
              ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const SmallErrorAnimationView(),
    );
  }

  Future<bool> displayDeleteDialog(BuildContext context) => DeleteDialog(
        titleOfObjectToDelete: Strings.comment,
      ).present(context).then((value) => value ?? false);
}
