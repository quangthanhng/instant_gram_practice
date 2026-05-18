import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/state/comments/models/comment.dart';
import 'package:instagram_clone_qthanh/views/components/comment/compact_comment_tile.dart';

class CompactCommentColumn extends StatelessWidget {
  final Iterable<Comment> comments;
  const CompactCommentColumn({super.key, required this.comments});

  @override
  Widget build(BuildContext context) {
    if (comments.isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: comments
            .map((comment) => CompactCommentTile(comment: comment))
            .toList(),
      ),
    );
  }
}
