import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/foundation.dart' show immutable;
import 'package:instagram_clone_qthanh/state/constants/firebase-field_name.dart';
import 'package:instagram_clone_qthanh/state/constants/firebase_collection_name.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';
import 'package:instagram_clone_qthanh/state/user_info/models/user_info_payload.dart';

@immutable
class UserInfoStorage {
  const UserInfoStorage();

  Future<bool> updateDisplayName({
    required UserId userId,
    required String displayName,
  }) async {
    try {
      // 1. Update Firestore user document
      final querySnapshot = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .where(FireBaseFieldName.userId, isEqualTo: userId)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        await querySnapshot.docs.first.reference.update({
          FireBaseFieldName.displayName: displayName,
        });
      }

      // 2. Update Firebase Auth display name so they stay perfectly in sync
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser != null) {
        await currentUser.updateDisplayName(displayName);
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> saveUserInfo({
    required UserId userId,
    required String displayName,
    required String? email,
  }) async {
    try {
      // first check if we have this user's info from before
      final userInfo = await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .where(FireBaseFieldName.userId, isEqualTo: userId)
          .limit(1)
          .get();

      if (userInfo.docs.isNotEmpty) {
        // we already have this user'info
        await userInfo.docs.first.reference.update({
          FireBaseFieldName.displayName: displayName,
          FireBaseFieldName.email: email,
        });
        return true;
      }

      // we don't have this user's info form before, create a new user

      final payload = UserInfoPayload(
        userId: userId,
        displayName: displayName,
        email: email,
      );
      await FirebaseFirestore.instance
          .collection(FirebaseCollectionName.users)
          .add(payload);
      return true;
    } catch (e) {
      return false;
    }
  }
}
