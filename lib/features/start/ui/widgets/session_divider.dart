import 'package:flutter/material.dart';
import 'theme_context.dart';

/// Divider widget with "OR" centered between two fading lines
class SessionDivider extends StatelessWidget {
  final StartScreenTheme theme;

  const SessionDivider({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final tealColor = theme.isDarkMode ? Colors.teal.shade600 : Colors.teal.shade400;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        children: [
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.dividerColor.withValues(alpha: 0.6),
                    theme.dividerColor,
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'OR',
              style: TextStyle(
                color: tealColor,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    theme.dividerColor,
                    theme.dividerColor.withValues(alpha: 0.6),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
    );
  }
}