import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/user_id_provider.dart';
import 'package:instagram_clone_qthanh/state/comments/models/comment.dart';
import 'package:instagram_clone_qthanh/state/comments/providers/delete_comment_provider.dart';
import 'package:instagram_clone_qthanh/state/user_info/providers/user_info_model_providers.dart';
import 'package:instagram_clone_qthanh/views/components/animations/small_error_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/delete_dialog.dart';
import 'package:timeago/timeago.dart' as timeago;

class CommentTile extends ConsumerWidget {
  const CommentTile({super.key, required this.comment});

  final Comment comment;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoModelProvider(comment.fromUserId));

    return userInfo.when(
      data: (userInfo) {
        final currentUserId = ref.read(userIdProvider);
        final isOwner = currentUserId == comment.fromUserId;
        final timeString = timeago.format(comment.createdAt, locale: 'vi');

        Widget tileContent = Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  userInfo.displayName.isNotEmpty
                      ? userInfo.displayName[0].toUpperCase()
                      : 'U',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: [
                          TextSpan(
                            text: '${userInfo.displayName} ',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          TextSpan(
                            text: comment.comment,
                            style: const TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeString,
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );

        // Hiệu ứng vuốt trái xóa bài viết/bình luận chính chủ
        if (isOwner) {
          return Dismissible(
            key: Key(comment.id),
            direction: DismissDirection.endToStart,
            confirmDismiss: (direction) async {
              await HapticFeedback.lightImpact();
              
              // Tạo một AlertDialog chuẩn từ các thuộc tính cấu hình của DeleteDialog gốc
              final shouldDeleteComment = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text(Strings.comment),
                  content: const Text('Bạn có chắc chắn muốn xóa bình luận này không?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Hủy'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      style: TextButton.styleFrom(foregroundColor: Colors.red),
                      child: const Text('Xóa'),
                    ),
                  ],
                ),
              );
              return shouldDeleteComment ?? false;
            },
            onDismissed: (direction) async {
              await ref
                  .read(deleteCommentProvider.notifier)
                  .deleteComment(commentId: comment.id);
            },
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              color: Colors.redAccent.withValues(alpha: 0.9),
              child: const Icon(
                Icons.delete_sweep_rounded,
                color: Colors.white,
                size: 28,
              ),
            ),
            child: tileContent,
          );
        }

        return tileContent;
      },
      loading: () {
        return const Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      },
      error: (error, stackTrace) => const SmallErrorAnimationView(),
    );
  }
}