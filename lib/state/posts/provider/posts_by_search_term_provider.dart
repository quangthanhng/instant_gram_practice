import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart' show Post;
import 'package:instagram_clone_qthanh/state/posts/typedefs/search_term.dart';

final postsBySearchTermProvider = StreamProvider.family
    .autoDispose<Iterable<Post>, SearchTerm>((ref, SearchTerm searchTerm) {
      final controller = StreamController<Iterable<Post>>();

      final sub = FirebaseFirestore.instance
          .collection(FirebaseCollectionName.posts)
          .orderBy(FireBaseFieldName.createdAt, descending: true)
          .snapshots()
          .listen((snapshot) {
            final posts = snapshot.docs
                .map((doc) => Post(postId: doc.id, json: doc.data()))
                .where(
                  (post) => post.message.toLowerCase().contains(
                    searchTerm.toLowerCase(),
                  ),
                );
            controller.sink.add(posts);
          });

      ref.onDispose(() {
        sub.cancel();
        controller.close();
      });

      return controller.stream;
    });
