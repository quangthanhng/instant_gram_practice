import 'package:flutter/material.dart';

extension DismissKeyboard on Widget {
  void dissMissKeyboard() => FocusManager.instance.primaryFocus?.unfocus();
}
