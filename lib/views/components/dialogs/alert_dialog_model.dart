import 'package:flutter/material.dart';

@immutable
class AlertDialogModel<T> {
  final String title;
  final String message;
  final Map<String, T> buttons;

  const AlertDialogModel({
    required this.title,
    required this.message,
    required this.buttons,
  });
}

extension Present<T> on AlertDialogModel<T> {
  Future<T?> present(BuildContext context) {
    return showGeneralDialog<T>(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (context, animation, secondaryAnimation) {
        return const SizedBox();
      },
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final scale = 0.85 + (0.15 * Curves.easeOutBack.transform(animation.value));
        final opacity = animation.value;
        
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: opacity,
            child: _buildDialogContent(context),
          ),
        );
      },
    );
  }

  Widget _buildDialogContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Detect if this is a destructive dialog (contains "Log Out" or "Delete")
    final isDestructive = title.toLowerCase().contains('delete') || 
                          title.toLowerCase().contains('log out');
    
    // Choose appropriate top icon based on title context
    IconData topIcon = Icons.info_outline_rounded;
    Color iconBgColor = colorScheme.primary.withValues(alpha: 0.12);
    Color iconColor = colorScheme.primary;

    if (title.toLowerCase().contains('log out')) {
      topIcon = Icons.logout_rounded;
      iconBgColor = Colors.red.withValues(alpha: 0.12);
      iconColor = Colors.redAccent;
    } else if (title.toLowerCase().contains('delete')) {
      topIcon = Icons.delete_outline_rounded;
      iconBgColor = Colors.red.withValues(alpha: 0.12);
      iconColor = Colors.redAccent;
    }

    return AlertDialog(
      backgroundColor: colorScheme.surfaceContainerHigh,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      actionsPadding: const EdgeInsets.only(left: 24, right: 24, bottom: 20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Styled Icon Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: iconBgColor,
            ),
            child: Icon(
              topIcon,
              color: iconColor,
              size: 32,
            ),
          ),
          const SizedBox(height: 20),
          
          // Dialog Title (Centered)
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              color: colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          
          // Dialog Message (Centered, elegant muted color)
          Text(
            message,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.7),
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        Row(
          children: buttons.entries.map((entry) {
            final isCancel = entry.key.toLowerCase().contains('cancel');
            
            final buttonStyle = isCancel 
                ? OutlinedButton.styleFrom(
                    foregroundColor: colorScheme.onSurface.withValues(alpha: 0.6),
                    side: BorderSide(color: colorScheme.outline.withValues(alpha: 0.12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  )
                : ElevatedButton.styleFrom(
                    backgroundColor: isDestructive ? Colors.redAccent : colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  );

            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(
                  left: isCancel ? 0 : 8,
                  right: isCancel ? 8 : 0,
                ),
                child: isCancel
                    ? OutlinedButton(
                        onPressed: () => Navigator.pop(context, entry.value),
                        style: buttonStyle,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      )
                    : ElevatedButton(
                        onPressed: () => Navigator.pop(context, entry.value),
                        style: buttonStyle,
                        child: Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
