import 'package:flutter/foundation.dart' show immutable;
import 'package:flutter/material.dart' show TextStyle, Colors, TextDecoration;
import 'package:flutter/scheduler.dart';
import 'package:instagram_clone_qthanh/views/components/rich_text/link_text.dart';

@immutable
class BaseText {
  final String text;
  final TextStyle? style;

  const BaseText({required this.text, this.style});

  factory BaseText.plain({
    required String text,
    TextStyle? style = const TextStyle(),
  }) => BaseText(text: text, style: style);

  factory BaseText.link({
    required String text,
    required VoidCallback onTap,
    TextStyle? style = const TextStyle(
      color: Colors.blue,
      decoration: TextDecoration.none,
    ),
  }) => LinkText(text: text, onTap: onTap, style: style);
}
