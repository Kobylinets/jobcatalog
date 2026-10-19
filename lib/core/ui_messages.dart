import 'package:flutter/material.dart';

// Єдине оформлення інформаційних повідомлень у застосунку.
Future<void> showAppMessage(
  BuildContext context, {
  required String title,
  required String message,
}) async {
  await showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(dialogContext).pop(),
          child: const Text('Зрозуміло'),
        ),
      ],
    ),
  );
}
