import 'package:flutter/material.dart';

class UIHelper {
  static void showSuccessMessage({
    required BuildContext context,
    String message = 'Record saved successfully!',
    bool shouldPop = true,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );

    if (shouldPop) {
      Navigator.pop(context);
    }
  }

  static void showErrorMessage({
    required BuildContext context,
    required String message,
    Color color = Colors.red,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }
}
