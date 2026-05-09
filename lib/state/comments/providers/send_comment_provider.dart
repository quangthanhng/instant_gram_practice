import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/comments/notifiers/send_comment_notifier.dart';
import 'package:instagram_clone_qthanh/state/image_upload/typedefs/is_loading.dart';

final sendCommentProvider =
    StateNotifierProvider<SendCommentNotifier, IsLoading>(
      (ref) => SendCommentNotifier(),
    );
