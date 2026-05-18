import 'package:instagram_clone_qthanh/state/post_settings/constants/constants.dart';

enum PostSetting {
  allowLikes(
    title: Constants.allowCommentsStorageKey,
    description: Constants.allowLikesDescription,
    storageKey: Constants.allowLikesStorageKey,
  ),

  allowComments(
    title: Constants.allowCommentsTitle,
    description: Constants.alllowCommentsDescription,
    storageKey: Constants.allowCommentsStorageKey,
  );

  final String title;
  final String description;
  final String storageKey;

  const PostSetting({
    required this.title,
    required this.description,
    required this.storageKey,
  });
}
