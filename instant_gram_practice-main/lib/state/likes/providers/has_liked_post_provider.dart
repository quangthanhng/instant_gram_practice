import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/user_id_provider.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/post_id.dart';

final hasLikedPostProvider = StreamProvider.family.autoDispose<bool, PostId>((
  ref,
  PostId postId,
) {
  final userId = ref.watch(userIdProvider);

  if (userId == null) {
    return Stream<bool>.value(false);
  }

  final controller = StreamController<bool>();

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.likes)
      .where(FireBaseFieldName.postId, isEqualTo: postId)
      .where(FireBaseFieldName.userId, isEqualTo: userId)
      .snapshots()
      .listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          controller.add(true);
        } else {
          controller.add(false);
        }
      });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });

  return controller.stream;
});
