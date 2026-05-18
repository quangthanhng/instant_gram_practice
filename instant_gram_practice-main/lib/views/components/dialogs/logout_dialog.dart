import 'package:flutter/material.dart' show immutable;
import 'package:instagram_clone_qthanh/views/components/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/alert_dialog_model.dart';

@immutable
class LogoutDialog extends AlertDialogModel<bool> {
  const LogoutDialog()
    : super(
        title: Strings.logOut,
        message: Strings.areYouSureWantToLogOutOfTheApp,
        buttons: const {Strings.cancel: false, Strings.logOut: true},
      );
}
