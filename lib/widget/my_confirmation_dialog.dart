import 'package:flutter/material.dart';

Future<bool> showMyConfirmationDialog({required BuildContext context, required String body}) async {
  Widget dialog = _confirmationDialog(context, body);
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

Widget _cancelButton(BuildContext context) {
  return TextButton(
    child: const Text(
      "Cancel",
      style: TextStyle(
        color: Colors.redAccent,
      ),
    ),
    onPressed: () {
      Navigator.of(context).pop(false);
    },
  );
}

Widget _confirmButton(BuildContext context) {
  return TextButton(
    child: const Text(
      "Confirm",
    ),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );
}

Widget _confirmationDialog(BuildContext context, String body) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    // backgroundColor: stmGradientEnd,
    title: const Text(
      "Confirmation",
      style: TextStyle(
          color: Colors.black87
      ),
    ),
    content: Text(body),
    actions: [_cancelButton(context), _confirmButton(context)],
  );
}