import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/user_id_provider.dart';
import 'package:instagram_clone_qthanh/state/image_upload/models/file_type.dart';
import 'package:instagram_clone_qthanh/state/image_upload/models/thumbnail_request.dart';
import 'package:instagram_clone_qthanh/state/image_upload/providers/image_upload_provider.dart';
import 'package:instagram_clone_qthanh/state/post_settings/models/post_setting.dart';
import 'package:instagram_clone_qthanh/state/post_settings/providers/post_settings_provider.dart';
import 'package:instagram_clone_qthanh/views/components/file_thumbnail_view.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';

class CreateNewPostView extends StatefulHookConsumerWidget {
  final File fileToPost;
  final FileType fileType;
  const CreateNewPostView({
    super.key,
    required this.fileToPost,
    required this.fileType,
  });

  @override
  ConsumerState<CreateNewPostView> createState() => _CreateNewPostViewState();
}

class _CreateNewPostViewState extends ConsumerState<CreateNewPostView> {
  // Hàm bổ trợ hiển thị Bottom Sheet cài đặt nâng cao gọn gàng chuẩn 2026
  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Consumer(
          builder: (context, editRef, child) {
            final postSettings = editRef.watch(postSettingProvider);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[600],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Cài đặt bài viết',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const Divider(),
                  ...PostSetting.values.map(
                    (postSetting) => ListTile(
                      title: Text(postSetting.title),
                      subtitle: Text(postSetting.description),
                      trailing: Switch(
                        value: postSettings[postSetting] ?? false,
                        onChanged: (isOn) {
                          editRef
                              .read(postSettingProvider.notifier)
                              .setSetting(postSetting, isOn);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final thumbnailRequest = ThumbnailRequest(
      file: widget.fileToPost,
      fileType: widget.fileType,
    );

    final postSettings = ref.watch(postSettingProvider);
    final postController = useTextEditingController();
    final isPostButtonEnabled = useState(false);
    final currentTextLength = useState(0);

    useEffect(() {
      void listener() {
        isPostButtonEnabled.value = postController.text.isNotEmpty;
        currentTextLength.value = postController.text.length;
      }

      postController.addListener(listener);
      return () => postController.removeListener(listener);
    }, [postController]);

    // Lắng nghe sự kiện bật nút thành công để rung phản hồi nhẹ cho người dùng biết
    ref.listen(imageUploadProvider, (previous, next) {
      if (next == true) {
        HapticFeedback.mediumImpact();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.createNewPost),
        elevation: 0,
        actions: [
          // Nút bánh răng mở khu vực cài đặt ẩn nâng cao dưới Bottom Sheet
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => _showSettingsBottomSheet(context),
          ),
        ],
      ),
      // ── NÚT ĐĂNG BÀI DẠNG FAB NỔI ĐỘNG (MATERIAL 3) ───────────────────────
      floatingActionButton: AnimatedScale(
        scale: isPostButtonEnabled.value ? 1.0 : 0.0, // Ẩn mượt nếu text rỗng
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          onPressed: isPostButtonEnabled.value
              ? () async {
                  await HapticFeedback.lightImpact(); // Rung nhẹ khi chạm gửi
                  final userId = ref.read(userIdProvider);
                  if (userId == null) return;

                  final message = postController.text;
                  final isUploaded = await ref
                      .read(imageUploadProvider.notifier)
                      .upload(
                        file: widget.fileToPost,
                        fileType: widget.fileType,
                        message: message,
                        postSettings: postSettings,
                        userId: userId,
                      );
                  if (isUploaded && mounted) {
                    Navigator.pop(context);
                  }
                }
              : null,
          label: const Text('Đăng ngay', style: TextStyle(fontWeight: FontWeight.bold)),
          icon: const Icon(Icons.send_rounded),
        ),
      ),
      // ── TỰ ĐỘNG KHÓA ẨN BÀN PHÍM KHI CUỘN ──────────────────────────────────
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollStartNotification) {
            FocusScope.of(context).unfocus(); // Tự động ẩn keyboard khi cuộn lên xuống
          }
          return false;
        },
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── BỌC HIỆU ỨNG CROP/ZOOM/PAN CHO HÌNH ẢNH PREVIEW ─────────────────
              Container(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.45,
                ),
                color: Colors.black12,
                child: InteractiveViewer(
                  clipBehavior: Clip.none,
                  minScale: 0.5, // Phóng to thu nhỏ thu nhỏ kịch sàn
                  maxScale: 3.0, // Phóng to tối đa x3 lần
                  child: Center(
                    child: FileThumbnailView(thumbnailRequest: thumbnailRequest),
                  ),
                ),
              ),
              const Divider(height: 1),
              
              // Ô nhập nội dung và khu vực đếm số ký tự Realtime
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    TextField(
                      controller: postController,
                      maxLines: 4,
                      minLines: 1,
                      maxLength: 220, // Giới hạn từ chuẩn caption Instagram
                      autofocus: true,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        hintText: Strings.pleseWriteyourMessageHere,
                        hintStyle: TextStyle(color: Colors.grey[500]),
                        border: InputBorder.none,
                        counterText: '', // Ẩn counter mặc định thô kệch đi
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Bộ đếm ký tự Custom đổi màu cảnh báo đỏ khi viết quá nhiều chữ
                    Text(
                      '${currentTextLength.value}/220',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: currentTextLength.value >= 200
                            ? Colors.redAccent
                            : Colors.grey[500],
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
            ],
          ),
        ),
      ),
    );
  }
}