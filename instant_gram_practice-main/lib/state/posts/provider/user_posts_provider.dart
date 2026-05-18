import 'dart:async';
import 'package:flutter/foundation.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/user_id_provider.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post_key.dart';

final userPostsProvider = StreamProvider.autoDispose<Iterable<Post>>((ref) {
  final userId = ref.watch(userIdProvider);

  final controller = StreamController<Iterable<Post>>();

  controller.onListen = () {
    controller.sink.add([]);
  };

  final sub = FirebaseFirestore.instance
      .collection(FirebaseCollectionName.posts)
      .orderBy(FireBaseFieldName.createdAt, descending: true)
      .where(PostKey.userId, isEqualTo: userId)
      .snapshots()
      .listen((snapshot) {
        debugPrint('==== USER POSTS SNAPSHOT NHẬN ĐƯỢC ====');
        debugPrint('Tổng số docs lấy được: ${snapshot.docs.length}');
        
        final documents = snapshot.docs;
        final posts = documents
            .where((doc) {
              if (doc.metadata.hasPendingWrites) {
                debugPrint('⚠️ Bỏ qua doc: ${doc.id} vì đang có pending writes (chưa upload xong lên server)');
                return false;
              }
              return true;
            })
            .map((doc) => Post(postId: doc.id, json: doc.data()));
            
        debugPrint('Số post hiển thị lên màn hình: ${posts.length}');
        controller.sink.add(posts);
      }, onError: (error) {
        debugPrint('🚨 LỖI FIRESTORE TRONG USER POSTS: $error');
        controller.sink.addError(error);
      });

  ref.onDispose(() {
    sub.cancel();
    controller.close();
  });
  return controller.stream;
});
