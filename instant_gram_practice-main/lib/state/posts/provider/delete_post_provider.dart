import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/image_upload/typedefs/is_loading.dart';
import 'package:instagram_clone_qthanh/state/posts/notifiers/delete_post_state_notifier.dart';

final deletePostProvider =
    StateNotifierProvider<DeletePostStateNotifier, IsLoading>(
      (_) => DeletePostStateNotifier(),
    );
