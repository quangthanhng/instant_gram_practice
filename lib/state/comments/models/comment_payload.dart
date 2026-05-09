import 'dart:collection' show MapView;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/post_id.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';

@immutable
class CommentPayload extends MapView<String, dynamic> {
  CommentPayload({
    required UserId userId,
    required PostId onPostId,
    required String comment,
  }) : super({
         FireBaseFieldName.userId: userId,
         FireBaseFieldName.postId: onPostId,
         FireBaseFieldName.comment: comment,
         FireBaseFieldName.createdAt: FieldValue.serverTimestamp(),
       });
}
