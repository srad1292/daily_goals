import 'package:flutter/material.dart';

Future<String?> showMyInputDialog({required BuildContext context, required String currentText}) async {
  final FocusNode focusNode = FocusNode();
  bool gottenFocus = false;
  TextEditingController inputController = TextEditingController();
  inputController.text = currentText;


  Widget dialog = _confirmationDialog(context, inputController, focusNode);
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        if(!gottenFocus) {
          focusNode.requestFocus();
          gottenFocus = true;
        }
        return dialog;
      },
      barrierDismissible: false
  ).then((value) {
    if(value == true) {
      return inputController.text;
    } else {
      return null;
    }
  });
}

Widget _cancelButton(BuildContext context) {
  return TextButton(
    child: const Text(
      "Cancel",
    ),
    onPressed: () {
      Navigator.of(context).pop(false);
    },
  );
}

Widget _confirmButton(BuildContext context) {
  return TextButton(
    child: const Text(
      "Save",
    ),
    onPressed: () {
      Navigator.of(context).pop(true);
    },
  );
}

Widget _confirmationDialog(BuildContext context, TextEditingController inputController, FocusNode focusNode) {
  return AlertDialog(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    // backgroundColor: stmGradientEnd,
    title: const Text(
      "Edit Goal",
      style: TextStyle(
          color: Colors.black87
      ),
    ),
    content: TextField(
      controller: inputController,
      style: Theme.of(context).textTheme.bodyMedium,
      keyboardType: TextInputType.text,
      focusNode: focusNode,
    ),
    actions: [_cancelButton(context), _confirmButton(context)],
  );
}