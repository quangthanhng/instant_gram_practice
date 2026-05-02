import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/views/components/rich_text/base_text.dart';
import 'package:instagram_clone_qthanh/views/components/rich_text/link_text.dart';

class RichTextWidget extends StatelessWidget {
  const RichTextWidget({super.key, required this.texts, this.styleForAll});

  final Iterable<BaseText> texts;
  final TextStyle? styleForAll;
  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: texts.map((baseText) {
          if (baseText is LinkText) {
            return TextSpan(
              text: baseText.text,
              style: styleForAll?.merge(baseText.style),
              recognizer: TapGestureRecognizer()..onTap = baseText.onTap,
            );
          } else {
            return TextSpan(
              text: baseText.text,
              style: styleForAll?.merge(baseText.style),
            );
          }
        }).toList(),
      ),
    );
  }
}



/*
Trong Flutter, RichText là một widget cho phép bạn hiển thị một đoạn văn bản có nhiều kiểu định dạng (style) khác nhau trên cùng một dòng hoặc một đoạn.

Khác với widget Text thông thường (chỉ áp dụng một TextStyle duy nhất cho toàn bộ chuỗi), RichText sử dụng một cấu trúc cây gọi là TextSpan để chia nhỏ đoạn văn bản thành nhiều phần, mỗi phần có thể có một định dạng riêng.
*/