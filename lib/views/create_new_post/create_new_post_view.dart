import 'dart:io';

import 'package:flutter/material.dart';
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
  @override
  Widget build(BuildContext context) {
    final thumbnailRequest = ThumbnailRequest(
      file: widget.fileToPost,
      fileType: widget.fileType,
    );

    final postSettings = ref.watch(postSettingProvider);
    final isLoading = ref.watch(imageUploadProvider);

    final postController = useTextEditingController();
    final isPostButtonEnabled = useState(false);
    
    useEffect(() {
      void listener() {
        isPostButtonEnabled.value = postController.text.isNotEmpty;
      }

      postController.addListener(listener);

      return () {
        postController.removeListener(listener);
      };
    }, [postController]);

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(Strings.createNewPost),
        actions: [
          IconButton(
            onPressed: isPostButtonEnabled.value && !isLoading
                ? () async {
                    final userId = ref.read(userIdProvider);
                    if (userId == null) {
                      return;
                    }
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
            icon: Icon(
              Icons.send_rounded,
              color: isPostButtonEnabled.value && !isLoading
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurface.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Uploading progress indicator
            if (isLoading)
              const LinearProgressIndicator(),
              
            // Instagram-style top Row: Caption input on left, media preview on right
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Caption input
                  Expanded(
                    child: TextField(
                      controller: postController,
                      maxLines: 4,
                      maxLength: 250,
                      decoration: InputDecoration(
                        hintText: Strings.pleseWriteyourMessageHere,
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        hintStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                        ),
                        counterText: '',
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  
                  // Media Thumbnail Preview
                  Container(
                    width: 75,
                    height: 75,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        )
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SizedBox(
                        width: 75,
                        height: 75,
                        child: FileThumbnailView(thumbnailRequest: thumbnailRequest),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Standard thin divider
            Divider(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
              height: 1,
              thickness: 0.5,
            ),
            
            // Styled card settings switches
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Column(
                children: PostSetting.values.map((setting) {
                  final IconData icon;
                  switch (setting) {
                    case PostSetting.allowLikes:
                      icon = Icons.favorite_outline_rounded;
                      break;
                    case PostSetting.allowComments:
                      icon = Icons.chat_bubble_outline_rounded;
                      break;
                  }
                  
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainer.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: theme.colorScheme.outline.withValues(alpha: 0.08),
                          width: 1,
                        ),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            color: theme.colorScheme.primary,
                            size: 22,
                          ),
                        ),
                        title: Text(
                          setting.title,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 14.5,
                          ),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            setting.description,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                        trailing: Switch.adaptive(
                          value: postSettings[setting] ?? false,
                          onChanged: isLoading
                              ? null
                              : (isOn) {
                                  ref
                                      .read(postSettingProvider.notifier)
                                      .setSetting(setting, isOn);
                                },
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
