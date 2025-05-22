import 'package:flutter/material.dart';
import 'theme_context.dart';

class StartHeader extends StatelessWidget {
  final StartScreenTheme theme;

  const StartHeader({
    super.key,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              const Color(0xFF7ED7C1),
              Colors.teal.shade400,
              Colors.cyan.shade500,
            ],
          ).createShader(bounds),
          child: const Text(
            'Book Duel',
            style: TextStyle(
              fontSize: 38,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Challenge friends to literary battles',
          style: TextStyle(
            fontSize: 16,
            color: theme.subtitleColor,
          ),
        ),
      ],
    );
  }
}