import 'package:flutter/material.dart';

class ErrorBanner extends StatelessWidget {
  final String message;
  final bool isDarkMode;

  const ErrorBanner({
    super.key,
    required this.message,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Colors.red.shade900.withAlpha(75) : Colors.red[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isDarkMode ? Colors.red.shade800 : Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: isDarkMode ? Colors.red[400] : Colors.red[700],
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: isDarkMode ? Colors.red[400] : Colors.red[700]),
            ),
          ),
        ],
      ),
    );
  }
}