import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/views/theme/app_colors.dart';

class AvatarWidget extends StatelessWidget {
  final String userId;
  final String displayName;
  final double radius;
  final bool hasStoryRing;

  const AvatarWidget({
    super.key,
    required this.userId,
    required this.displayName,
    this.radius = 18.0,
    this.hasStoryRing = true,
  });

  @override
  Widget build(BuildContext context) {
    // Generate a consistent vibrant color based on display name hash
    final hash = displayName.hashCode;
    final colors = [
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.pink,
      Colors.teal,
      Colors.indigo,
      Colors.redAccent,
      Colors.deepOrange,
    ];
    final avatarColor = colors[hash.abs() % colors.length];
    
    final displayLetter = displayName.isNotEmpty ? displayName[0].toUpperCase() : '?';

    Widget innerAvatar() {
      return CircleAvatar(
        radius: radius,
        backgroundColor: avatarColor,
        child: Text(
          displayLetter,
          style: TextStyle(
            color: Colors.white,
            fontSize: radius * 0.9,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    if (!hasStoryRing) {
      return innerAvatar();
    }

    return Container(
      padding: const EdgeInsets.all(2.5), // Space between ring and avatar
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: AppColors.storyGradient,
      ),
      child: Container(
        padding: const EdgeInsets.all(1.5), // Black gap inside the ring
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black,
        ),
        child: innerAvatar(),
      ),
    );
  }
}
