import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class PostDateView extends StatelessWidget {
  final DateTime dateTime;
  const PostDateView({super.key, required this.dateTime});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8),
      child: Text(
        timeago.format(dateTime).toUpperCase(),
        style: theme.textTheme.bodySmall?.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.2,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
