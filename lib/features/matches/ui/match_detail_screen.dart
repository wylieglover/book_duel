// lib/screens/match_detail_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/models/match_record.dart';
import '../../../core/theme/theme_provider.dart';

class MatchDetailScreen extends StatelessWidget {
  final MatchRecord record;

  const MatchDetailScreen({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final bool didWin = record.result == MatchResult.win;
    
    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        backgroundColor: theme.currentTheme.appBarTheme.backgroundColor,
        title: Text(
          'Match Details',
          style: theme.currentTheme.appBarTheme.titleTextStyle,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Match result header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: didWin ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    didWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                    size: 48,
                    color: didWin ? Colors.amber.shade800 : Colors.red.shade800,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    didWin ? 'Victory!' : 'Defeat',
                    style: theme.textStyle.copyWith(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: didWin ? Colors.green.shade800 : Colors.red.shade800,
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Match info
            _InfoItem(
              title: 'Opponent',
              value: record.opponentName,
              icon: Icons.person,
              theme: theme,
            ),
            _InfoItem(
              title: 'Date',
              value: DateFormat.yMMMMd().add_jm().format(record.timestamp),
              icon: Icons.calendar_today,
              theme: theme,
            ),
            _InfoItem(
              title: 'Session ID',
              value: record.sessionId,
              icon: Icons.tag,
              theme: theme,
            ),
            _InfoItem(
              title: 'XP Earned',
              value: '+${record.xpEarned}',
              icon: Icons.star,
              theme: theme,
            ),
            _InfoItem(
              title: 'Points Earned',
              value: '+${record.pointsEarned}',
              icon: Icons.monetization_on,
              theme: theme,
            ),
            
            const SizedBox(height: 16),
            
            // Match metadata if available
            if (record.metadata != null && record.metadata!.isNotEmpty) ...[
              Divider(),
              const SizedBox(height: 8),
              Text(
                'Additional Details',
                style: theme.textStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              
              // Display metadata
              ...record.metadata!.entries.map((entry) => 
                _InfoItem(
                  title: entry.key,
                  value: entry.value.toString(),
                  icon: Icons.info_outline,
                  theme: theme,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final ThemeProvider theme;

  const _InfoItem({
    required this.title,
    required this.value,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Icon(icon, color: theme.accent),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textStyle.copyWith(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: theme.textStyle.copyWith(
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}