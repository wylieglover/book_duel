// lib/widgets/privacy_policy_widget.dart

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter/services.dart'; 
import 'package:provider/provider.dart';
import '../../../../core/theme/theme_provider.dart';

/// Widget to display privacy policy in a polished bottom sheet
class PrivacyPolicyWidget extends StatelessWidget {
  const PrivacyPolicyWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (_, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: theme.bgColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle, with top padding so it's not right at the sheet edge
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 8),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              // Markdown content
              Expanded(
                child: FutureBuilder<String>(
                  future: rootBundle.loadString('assets/privacy.md'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Error loading policy', style: theme.textStyle),
                      );
                    }
                    return Markdown(
                      data: snapshot.data ?? '',
                      controller: scrollController,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      styleSheet: MarkdownStyleSheet(
                        h1: theme.textStyle.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.primary,
                        ),
                        h2: theme.textStyle.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                        p: theme.textStyle.copyWith(height: 1.5),
                        listBullet: theme.textStyle.copyWith(fontSize: 14),
                        listIndent: 16.0,
                        listBulletPadding: const EdgeInsets.only(right: 8),
                        blockSpacing: 16.0,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
