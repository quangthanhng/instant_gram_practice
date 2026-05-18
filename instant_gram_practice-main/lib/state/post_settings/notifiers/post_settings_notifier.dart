import 'package:collection/collection.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/post_settings/models/post_setting.dart';

class PostSettingsNotifier extends StateNotifier<Map<PostSetting, bool>> {
  PostSettingsNotifier()
    : super(
        UnmodifiableMapView({
          for (final setting in PostSetting.values) setting: true,
        }),
      );

  void setSetting(PostSetting setting, bool value) {
    final existingValue = state[setting];
    if (existingValue == null || existingValue == value) {
      return;
    }
    state = Map.from(state)..[setting] = value;
  }
}
