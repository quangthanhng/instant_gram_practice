import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/state/user_info/providers/user_info_model_providers.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/can_current_user_delete_post_provider.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/delete_post_provider.dart';
import 'package:instagram_clone_qthanh/views/components/avatar_widget.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/alert_dialog_model.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/delete_dialog.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';

class PostHeader extends ConsumerWidget {
  final Post post;

  const PostHeader({super.key, required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userInfo = ref.watch(userInfoModelProvider(post.userId));
    final canDelete = ref.watch(canCurrentUserDeletePostProvider(post)).value ?? false;

    return userInfo.when(
      data: (userInfoModel) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
          child: Row(
            children: [
              AvatarWidget(
                userId: post.userId,
                displayName: userInfoModel.displayName,
                radius: 16.0,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  userInfoModel.displayName,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (canDelete)
                IconButton(
                  onPressed: () async {
                    final shouldDelete = await const DeleteDialog(
                      titleOfObjectToDelete: Strings.post,
                    )
                        .present(context)
                        .then((value) => value ?? false);
                    if (shouldDelete) {
                      await ref
                          .read(deletePostProvider.notifier)
                          .deletePost(post: post);
                    }
                  },
                  icon: const Icon(Icons.more_horiz_rounded),
                ),
            ],
          ),
        );
      },
      error: (error, stackTrace) => const SizedBox(),
      loading: () => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Row(
          children: [
            const CircleAvatar(radius: 16, backgroundColor: Colors.white10),
            const SizedBox(width: 10),
            Container(width: 80, height: 12, color: Colors.white10),
          ],
        ),
      ),
    );
  }
}
