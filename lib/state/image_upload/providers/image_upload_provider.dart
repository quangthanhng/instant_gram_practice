import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/image_upload/notifiers/image_upload_notifier.dart';
import 'package:instagram_clone_qthanh/state/image_upload/typedefs/is_loading.dart';

final imageUploadProvider =
    StateNotifierProvider<ImageUploadNotifier, IsLoading>(
      (ref) => ImageUploadNotifier(),
    );
