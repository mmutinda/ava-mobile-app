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
    if (!context.mounted) return;

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.error, color: Colors.red, size: 24),
              SizedBox(width: 8),
              Text('Error'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
