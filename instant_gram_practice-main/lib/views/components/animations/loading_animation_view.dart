import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/views/components/animations/shimmer_placeholder.dart';

class LoadingAnimationView extends StatelessWidget {
  const LoadingAnimationView({super.key});

  @override
  Widget build(BuildContext context) {
    // Thay vì hiện Lottie full màn hình gây giật, hiện danh sách khung xương giả lập dữ liệu đang chạy
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 5, // Vẽ ra 5 dòng comment giả lập lấp lánh
      itemBuilder: (context, index) => const CommentTileSkeleton(),
    );
  }
}