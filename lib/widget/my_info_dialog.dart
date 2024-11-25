import 'package:flutter/material.dart';

import '../enum/info_dialog_type.dart';

Future<bool> showMyInfoDialog({required BuildContext context, required InfoDialogType dialogType, required String body}) async {
  Widget dialog = _confirmationDialog(context, dialogType, body);
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return dialog;
      },
      barrierDismissible: false
  )
      .then((value) {
    return value == true;
  });
}

Widget confirmButton(BuildContext context) {
  return TextButton(
    child: const Text(
      "Okay",
    ),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );
}

Widget _confirmationDialog(BuildContext context, InfoDialogType dialogType, String body) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    // backgroundColor: stmGradientEnd,
    title: Text(
      _getTitleText(dialogType),
    ),
    content: Text(body),
    actions: [confirmButton(context)],
  );
}

String _getTitleText(InfoDialogType dialogType) {
  if(dialogType == InfoDialogType.info) {
    return "Info";
  } else if(dialogType == InfoDialogType.warning) {
    return "Warning";
  } else if(dialogType == InfoDialogType.error) {
    return "Error";
  }
  return '';
}