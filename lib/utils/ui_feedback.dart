import 'package:flutter/material.dart';

class UIFeedback {
  static Future<void> showSuccess(BuildContext context, String message) async {
    await _showDialog(
      context,
      title: 'Booking Successful',
      message: message,
      icon: Icons.check_circle,
      color: const Color(0xFF10B981),
    );
  }

  static Future<void> showError(BuildContext context, String message) async {
    await _showDialog(
      context,
      title: 'Error',
      message: message,
      icon: Icons.error_outline,
      color: const Color(0xFFEF4444),
    );
  }

  static Future<void> _showDialog(
    BuildContext context, {
    required String title,
    required String message,
    required IconData icon,
    required Color color,
  }) async {
    return showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          children: [
            Icon(icon, color: color),
            const SizedBox(width: 8),
            Expanded(child: Text(title)),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}