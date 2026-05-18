import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:instagram_clone_qthanh/state/image_upload/models/file_type.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_image_view.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_video_view.dart';

class PostImageOrVideoView extends StatefulWidget {
  final Post post;
  const PostImageOrVideoView({super.key, required this.post});

  @override
  State<PostImageOrVideoView> createState() => _PostImageOrVideoViewState();
}

class _PostImageOrVideoViewState extends State<PostImageOrVideoView>
    with SingleTickerProviderStateMixin {
  late AnimationController _heartAnimationController;
  late Animation<double> _heartScaleAnimation;
  bool _showHeartOverlay = false;

  @override
  void initState() {
    super.initState();
    _heartAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _heartScaleAnimation = Tween<double>(begin: 0.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _heartAnimationController,
        curve: Curves.elasticOut,
      ),
    );
  }

  @override
  void dispose() {
    _heartAnimationController.dispose();
    super.dispose();
  }

  void _onDoubleTapToLike() async {
    setState(() {
      _showHeartOverlay = true;
    });

    await HapticFeedback.mediumImpact();

    _heartAnimationController.forward().then((_) async {
      await Future.delayed(const Duration(milliseconds: 300));
      if (mounted) {
        _heartAnimationController.reverse().then((_) {
          if (mounted) {
            setState(() {
              _showHeartOverlay = false;
            });
          }
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget contentWidget;
    switch (widget.post.fileType) {
      case FileType.image:
        contentWidget = PostImageView(post: widget.post);
        break;
      case FileType.video:
        contentWidget = PostVideoView(post: widget.post);
        break;
      default:
        contentWidget = const SizedBox();
    }

    return GestureDetector(
      onDoubleTap: _onDoubleTapToLike,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Hero(
            tag: widget.post.postId, // Đã sửa từ id thành postId chuẩn model của Tiến
            child: contentWidget,
          ),
          if (_showHeartOverlay)
            ScaleTransition(
              scale: _heartScaleAnimation,
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.white,
                size: 110,
                shadows: [
                  Shadow(
                    color: Colors.black38,
                    blurRadius: 12,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}