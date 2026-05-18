import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show immutable;
import 'package:instagram_clone_qthanh/state/comments/typedefs/comment_id.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/post_id.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';

@immutable
class Comment {
  final CommentId id;
  final String comment;
  final DateTime createdAt;
  final UserId fromUserId;
  final PostId onPostId;

  Comment(Map<String, dynamic> json, {required this.id})
    : comment = json[FireBaseFieldName.comment],
      createdAt = (json[FireBaseFieldName.createdAt] as Timestamp).toDate(),
      fromUserId = json[FireBaseFieldName.userId] as UserId,
      onPostId = json[FireBaseFieldName.postId];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Comment &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          comment == other.comment &&
          createdAt == other.createdAt &&
          fromUserId == other.fromUserId &&
          onPostId == other.onPostId;

  @override
  int get hashCode =>
      Object.hashAll([id, comment, createdAt, fromUserId, onPostId]);
}
