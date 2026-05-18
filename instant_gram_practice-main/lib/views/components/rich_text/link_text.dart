import 'package:flutter/foundation.dart' show VoidCallback, immutable;
import 'package:instagram_clone_qthanh/views/components/rich_text/base_text.dart';

@immutable
class LinkText extends BaseText {
  final VoidCallback onTap;

  const LinkText({required super.text, required this.onTap, super.style});
}
