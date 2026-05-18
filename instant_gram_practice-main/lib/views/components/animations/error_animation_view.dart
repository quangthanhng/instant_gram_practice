import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class ErrorAnimationView extends StatelessWidget {
  final VoidCallback? onRetry;

  const ErrorAnimationView({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Gọi trực tiếp file Lottie lỗi theo cấu trúc chuỗi chuẩn để không sợ lỗi enum
            Lottie.asset(
              'assets/animations/error.json',
              width: 150,
              height: 150,
              errorBuilder: (context, error, stackTrace) {
                // Phương án dự phòng nếu file assets không tồn tại hoặc sai đường dẫn
                return const Icon(Icons.error_outline_rounded, color: Colors.red, size: 80);
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'Đã xảy ra lỗi kết nối mạng!',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Vui lòng kiểm tra lại đường truyền và thử lại.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 20),
            // Nút bấm Thử lại phục hồi dữ liệu mạng
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Thử lại ngay'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              ),
          ],
        ),
      ),
    );
  }
}