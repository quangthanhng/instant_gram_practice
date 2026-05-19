import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:instagram_clone_qthanh/state/user_info/providers/user_info_model_providers.dart';

class EditProfileSheet extends HookConsumerWidget {
  final String currentDisplayName;
  final String userId;

  const EditProfileSheet({
    super.key,
    required this.currentDisplayName,
    required this.userId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    final nameController = useTextEditingController(text: currentDisplayName);
    final isLoading = useState(false);
    final isValid = useState(currentDisplayName.trim().isNotEmpty);

    useEffect(() {
      void listener() {
        isValid.value = nameController.text.trim().isNotEmpty;
      }
      nameController.addListener(listener);
      return () => nameController.removeListener(listener);
    }, [nameController]);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHigh,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(28),
          ),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outline.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const Gap(24),

            // Sheet Title
            Text(
              'Edit Profile',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            const Gap(24),

            // Label
            Text(
              'Name',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurface.withValues(alpha: 0.6),
                fontWeight: FontWeight.w600,
              ),
            ),
            const Gap(8),

            // TextField
            TextField(
              controller: nameController,
              enabled: !isLoading.value,
              textCapitalization: TextCapitalization.words,
              maxLength: 30,
              style: TextStyle(color: colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'Enter your name...',
                hintStyle: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.4),
                ),
                counterText: '',
                filled: true,
                fillColor: colorScheme.surfaceContainer.withValues(alpha: 0.6),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.outline.withValues(alpha: 0.08),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: colorScheme.primary.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            const Gap(28),

            // Action Buttons (Cancel / Save)
            Row(
              children: [
                // Cancel Button
                Expanded(
                  child: OutlinedButton(
                    onPressed: isLoading.value
                        ? null
                        : () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
                      side: BorderSide(
                        color: colorScheme.outline.withValues(alpha: 0.12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const Gap(12),
                
                // Save Button
                Expanded(
                  child: ElevatedButton(
                    onPressed: (!isValid.value || isLoading.value)
                        ? null
                        : () async {
                            HapticFeedback.mediumImpact();
                            isLoading.value = true;
                            final newName = nameController.text.trim();
                            
                            final success = await ref
                                .read(userInfoStorageProvider)
                                .updateDisplayName(
                                  userId: userId,
                                  displayName: newName,
                                );
                                
                            isLoading.value = false;
                            
                            if (context.mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    success
                                        ? 'Profile updated successfully!'
                                        : 'Failed to update profile. Please try again.',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  backgroundColor: success
                                      ? colorScheme.primary
                                      : colorScheme.error,
                                  behavior: SnackBarBehavior.floating,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      disabledBackgroundColor: colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Save',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
