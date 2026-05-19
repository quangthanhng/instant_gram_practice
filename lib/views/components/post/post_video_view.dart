import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:instagram_clone_qthanh/state/posts/models/post.dart';
import 'package:instagram_clone_qthanh/views/components/animations/loading_animation_view.dart';
import 'package:video_player/video_player.dart';

class PostVideoView extends HookWidget {
  final Post post;

  const PostVideoView({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    // Memoize the video player controller to avoid recreating it on rebuilds
    final controller = useMemoized(
      () => VideoPlayerController.networkUrl(Uri.parse(post.fileUrl)),
      [post.fileUrl],
    );

    final isVideoPlayerReady = useState(false);
    final isPlaying = useState(true);
    final isMuted = useState(false);
    final showPlayIndicator = useState(false);

    useEffect(() {
      controller.initialize().then((value) {
        isVideoPlayerReady.value = true;
        controller.setLooping(true);
        controller.setVolume(isMuted.value ? 0 : 1.0);
        controller.play();
      });
      return controller.dispose;
    }, [controller]);

    if (!isVideoPlayerReady.value) {
      return AspectRatio(
        aspectRatio: post.aspectRatio,
        child: const Center(child: LoadingAnimationView()),
      );
    }

    return AspectRatio(
      aspectRatio: post.aspectRatio,
      child: GestureDetector(
        onTap: () {
          if (controller.value.isPlaying) {
            controller.pause();
            isPlaying.value = false;
          } else {
            controller.play();
            isPlaying.value = true;
          }
          showPlayIndicator.value = true;
          Future.delayed(const Duration(milliseconds: 600), () {
            showPlayIndicator.value = false;
          });
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            VideoPlayer(controller),
            
            // Play/Pause indicator animation overlay
            AnimatedOpacity(
              opacity: showPlayIndicator.value ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isPlaying.value ? Icons.play_arrow_rounded : Icons.pause_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),

            // Sleek iOS-style Mute/Unmute toggle in corner
            Positioned(
              bottom: 12,
              right: 12,
              child: GestureDetector(
                onTap: () {
                  isMuted.value = !isMuted.value;
                  controller.setVolume(isMuted.value ? 0 : 1.0);
                },
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isMuted.value ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

            // Tiny linear progress bar at the bottom of the video
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoProgressIndicator(
                controller,
                allowScrubbing: false,
                colors: VideoProgressColors(
                  playedColor: Theme.of(context).colorScheme.primary,
                  bufferedColor: Colors.white24,
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
