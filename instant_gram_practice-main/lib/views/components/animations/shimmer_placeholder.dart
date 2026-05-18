import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerPlaceholder extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerPlaceholder({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Shimmer.fromColors(
      // Tự động đổi màu lấp lánh theo chế độ Sáng/Tối của máy ảo
      baseColor: isDarkMode ? Colors.grey[800]! : Colors.grey[300]!,
      highlightColor: isDarkMode ? Colors.grey[700]! : Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

// ── KHUNG XƯƠNG GIẢ LẬP MỘT DÒNG COMMENT ─────────────────────────────────────
class CommentTileSkeleton extends StatelessWidget {
  const CommentTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerPlaceholder(width: 36, height: 36, borderRadius: 18), // Avatar
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerPlaceholder(width: 120, height: 14), // Tên user
                SizedBox(height: 6),
                ShimmerPlaceholder(width: double.infinity, height: 14), // Nội dung text
                SizedBox(height: 6),
                ShimmerPlaceholder(width: 60, height: 10), // Thời gian
              ],
            ),
          ),
        ],
      ),
    );
  }
}