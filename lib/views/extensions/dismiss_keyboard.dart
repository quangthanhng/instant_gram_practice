import 'package:flutter/material.dart';

extension DismissKeyboard on Widget {
  void dissMissKeyboar() => FocusManager.instance.primaryFocus?.unfocus();
}
