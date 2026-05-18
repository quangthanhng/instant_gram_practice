import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';

@immutable
class UserInfoPayload extends MapView<String, String> {
  UserInfoPayload({
    required UserId userId,
    required String? displayName,
    required String? email,
  }) : super({
         FireBaseFieldName.userId: userId,
         FireBaseFieldName.displayName: displayName ?? '',
         FireBaseFieldName.email: email ?? '',
       });
}
