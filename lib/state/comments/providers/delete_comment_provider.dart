import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/comments/notifiers/delete_comment_notifier.dart';
import 'package:instagram_clone_qthanh/state/image_upload/typedefs/is_loading.dart';

final deleteCommentProvider =
    StateNotifierProvider<DeleteCommentNotifier, IsLoading>(
      (ref) => DeleteCommentNotifier(),
    );
