import 'package:flutter/material.dart';

@immutable
class AppColors {
  const AppColors._();

  // Core colors (Instagram-inspired brand colors)
  static const primary = Color(0xFFE1306C); // Instagram pink
  static const secondary = Color(0xFFC13584); // Instagram purple
  static const tertiary = Color(0xFFFD1D1D); // Instagram red/pink
  static const accent = Color(0xFF405DE6); // Instagram blue

  // Dark Theme Neutral Colors
  static const background = Color(0xFF000000); // Pure black background
  static const surface = Color(0xFF121212); // Slightly elevated black for app bar / bottom nav
  static const cardBackground = Color(0xFF1A1A1A); // Sleek card background
  static const surfaceContainerLow = Color(0xFF161616);
  static const surfaceContainer = Color(0xFF1E1E1E);
  static const surfaceContainerHigh = Color(0xFF262626);
  static const surfaceContainerHighest = Color(0xFF333333);
  static const outline = Color(0xFF262626); // Divider / borders
  static const outlineVariant = Color(0xFF363636);

  // Text Colors
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = Color(0xFFA8A8A8);
  static const textHint = Color(0xFF737373);

  // Social / Action Colors
  static const facebook = Color(0xFF1877F2);
  static const google = Color(0xFF4285F4);
  static const error = Color(0xFFED4956); // Instagram error red
  static const success = Color(0xFF4BB543);

  // Button legacy colors
  static const loginButtonTextColor = Colors.black;
  static const loginButtonColor = Color(0xFFCFC8C2);
  static const googleColor = Color(0xFF4285F4);
  static const facebookColor = Color(0xFF3B5998);

  // Premium Gradients
  static const instagramGradient = LinearGradient(
    colors: [
      Color(0xFF833AB4), // Purple
      Color(0xFFFD1D1D), // Red
      Color(0xFFF56040), // Orange
      Color(0xFFFCAF45), // Yellow
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const storyGradient = LinearGradient(
    colors: [
      Color(0xFFFBAA47), // Orange/yellow
      Color(0xFFD91A5F), // Pink/red
      Color(0xFFA60F93), // Purple
    ],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );
}
