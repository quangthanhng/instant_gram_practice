import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/post_settings/models/post_setting.dart';
import 'package:instagram_clone_qthanh/state/post_settings/notifiers/post_settings_notifier.dart';

final postSettingProvider =
    StateNotifierProvider<PostSettingsNotifier, Map<PostSetting, bool>>(
      (ref) => PostSettingsNotifier(),
    );
