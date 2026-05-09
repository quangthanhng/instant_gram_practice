import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/comments/models/comment_payload.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone_qthanh/state/image_upload/typedefs/is_loading.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/post_id.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';

class SendCommentNotifier extends StateNotifier<IsLoading> {
  SendCommentNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> sendComments({
    required UserId fromUserId,
    required PostId onPostId,
    required String comment,
  }) async {
    isLoading = true;

    final payload = CommentPayload(
      userId: fromUserId,
      onPostId: onPostId,
      comment: comment,
    );

    try {
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.comments)
          .add(payload);

      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }
}
