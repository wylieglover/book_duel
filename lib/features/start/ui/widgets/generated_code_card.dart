import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'theme_context.dart';

class GeneratedCodeCard extends StatelessWidget {
  final String code;
  final StartScreenTheme theme;
  final VoidCallback onEnterDuel;

  const GeneratedCodeCard({
    super.key,
    required this.code,
    required this.theme,
    required this.onEnterDuel,
  });

  void _copyCode(BuildContext context) {
    // First copy to clipboard
    Clipboard.setData(ClipboardData(text: code));
    
    // Then show feedback immediately with current context
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Code copied to clipboard!'),
        duration: Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.isDarkMode ? Colors.teal.shade700 : Colors.teal.shade200),
        ),
        color: theme.isDarkMode ? Colors.teal.shade900.withAlpha(75) : Colors.teal.shade50,
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'Share this code with your friend',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: theme.isDarkMode ? Colors.teal.shade200 : Colors.teal.shade700,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _copyCode(context),
                child: Stack(
                  alignment: Alignment.centerRight,
                  children: [
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 12,
                      ),
                      decoration: BoxDecoration(
                        color: theme.isDarkMode ? Colors.grey.shade800 : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                            color: theme.isDarkMode ? Colors.teal.shade600 : Colors.teal.shade300,
                            width: 2),
                      ),
                      child: Center(
                        child: Text(
                          code,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 4,
                            color: theme.isDarkMode ? Colors.white : Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: 8,
                      child: Tooltip(
                        message: 'Copy to clipboard',
                        child: IconButton(
                          icon: Icon(Icons.copy, color: theme.isDarkMode ? Colors.white70 : Colors.grey),
                          onPressed: () => _copyCode(context),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onEnterDuel,
                  style: theme.enterDuelButtonStyle,
                  child: const Text(
                    'Enter Duel',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}