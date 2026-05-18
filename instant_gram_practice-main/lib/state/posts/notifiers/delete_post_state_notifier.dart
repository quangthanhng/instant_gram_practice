import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone_qthanh/state/image_upload/extensions/get_collection_name_from_file_type.dart';
import 'package:instagram_clone_qthanh/state/image_upload/typedefs/is_loading.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/post_id.dart';

class DeletePostStateNotifier extends StateNotifier<IsLoading> {
  DeletePostStateNotifier() : super(false);

  set isLoading(bool value) => state = value;

  Future<bool> deletePost({required Post post}) async {
    isLoading = true;

    try {
      // delete the post's thumbnail
      try {
        await FirebaseStorage.instance
            .ref()
            .child(post.userId)
            .child(FirebaseCollectionName.thumbnails)
            .child(post.thumbnailStorageId)
            .delete();
      } catch (_) {
        // ignore error if thumbnail is already deleted
      }

      // delete the post's original file (video or image)
      try {
        await FirebaseStorage.instance
            .ref()
            .child(post.userId)
            .child(post.fileType.collectionName)
            .child(post.originalFileStorageId)
            .delete();
      } catch (_) {
        // ignore error if original file is already deleted
      }

      // delete all comments associated with the post
      await _deleteAllDocuments(
        postId: post.postId,
        inCollection: FirebaseCollectionName.comments,
      );

      // delete all likes associated with the post
      await _deleteAllDocuments(
        postId: post.postId,
        inCollection: FirebaseCollectionName.likes,
      );

      // finally delete the post itself

      // finally delete the post itself
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.posts)
          .doc(post.postId)
          .delete();
      return true;
    } catch (_) {
      return false;
    } finally {
      isLoading = false;
    }
  }

  Future<void> _deleteAllDocuments({
    required PostId postId,
    required String inCollection,
  }) {
    return FirebaseFirestore.instance.runTransaction(
      maxAttempts: 3,
      timeout: const Duration(seconds: 20),
      (transaction) async {
        final query = await FirebaseFirestore.instance
            .collection(inCollection)
            .where(FireBaseFieldName.postId, isEqualTo: postId)
            .get();
        for (final doc in query.docs) {
          transaction.delete(doc.reference);
        }
      },
    );
  }
}
