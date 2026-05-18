import 'dart:collection' show MapView;

import 'package:flutter/foundation.dart' show immutable;
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/post_id.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';

@immutable
class Like extends MapView<String, String> {
  Like({
    required PostId postId,
    required UserId likedBy,
    required DateTime date,
  }) : super({
         FireBaseFieldName.postId: postId,
         FireBaseFieldName.userId: likedBy,
         FireBaseFieldName.date: date.toIso8601String(),
       });
}
