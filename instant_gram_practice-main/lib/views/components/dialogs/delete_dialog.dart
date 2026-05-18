import 'package:flutter/material.dart' show immutable;
import 'package:instagram_clone_qthanh/views/components/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/alert_dialog_model.dart';

@immutable
class DeleteDialog extends AlertDialogModel<bool> {
  const DeleteDialog({required String titleOfObjectToDelete})
    : super(
        title: '${Strings.delete} $titleOfObjectToDelete',
        message: '${Strings.areYouSureWantToDeleteThis} $titleOfObjectToDelete',
        buttons: const {Strings.cancel: false, Strings.delete: true},
      );
}
