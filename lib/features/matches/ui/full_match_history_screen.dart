// lib/screens/full_match_history_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/models/match_record.dart';
import '../../../core/theme/theme_provider.dart';
import 'match_detail_screen.dart';

class FullMatchHistoryScreen extends StatefulWidget {
  final List<MatchRecord> matches;

  const FullMatchHistoryScreen({super.key, required this.matches});

  @override
  State<FullMatchHistoryScreen> createState() => _FullMatchHistoryScreenState();
}

class _FullMatchHistoryScreenState extends State<FullMatchHistoryScreen> {
  late final List<MatchRecord> _sortedMatches;
  late List<MatchRecord> _filteredMatches;
  MatchResult?   _filterResult;
  
  @override
  void initState() {
    super.initState();
    // 1) copy & sort once
    _sortedMatches = List.of(widget.matches)
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

    // 2) initialize filtered = all
    _filteredMatches = List.of(_sortedMatches);
  }

  void _applyFilter(MatchResult? result) {
    setState(() {
      _filterResult = result;
      if (result == null) {
        _filteredMatches = List.of(_sortedMatches);
      } else {
        _filteredMatches =
          _sortedMatches.where((m) => m.result == result).toList();
      }
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    
    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        backgroundColor: theme.currentTheme.appBarTheme.backgroundColor,
        title: Text(
          'Match History',
          style: theme.currentTheme.appBarTheme.titleTextStyle,
        ),
        actions: [
          // Filter menu
          PopupMenuButton<MatchResult?>(
            icon: Icon(Icons.filter_list, color: theme.accent),
            onSelected: _applyFilter,           // handles win/loss/draw
            itemBuilder: (_) => [
              // 1) “All Matches” with its own onTap
              PopupMenuItem<MatchResult?>(
                value: null,
                onTap: () {
                  // schedule after menu closes
                  Future.delayed(Duration.zero, () => _applyFilter(null));
                },
                child: Text('All Matches', style: theme.textStyle),
              ),

              // 2) The rest still use onSelected
              PopupMenuItem<MatchResult?>(
                value: MatchResult.win,
                child: Text('Wins Only', style: theme.textStyle),
              ),
              PopupMenuItem<MatchResult?>(
                value: MatchResult.loss,
                child: Text('Losses Only', style: theme.textStyle),
              ),
              PopupMenuItem<MatchResult?>(
                value: MatchResult.draw,
                child: Text('Draws Only', style: theme.textStyle),
              ),
            ],
          ),
        ],
      ),
      body: _filteredMatches.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.hourglass_empty,
                    size: 64,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _filterResult == null
                        ? 'No matches yet'
                        : 'No ${_filterResult.toString().split('.').last} matches',
                    style: theme.textStyle.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: _filteredMatches.length,
              separatorBuilder: (context, index) => Divider(),
              itemBuilder: (context, index) {
                final match = _filteredMatches[index];
                final bool didWin = match.result == MatchResult.win;
                final bool isDraw = match.result == MatchResult.draw;
                
                return ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: didWin
                          ? Colors.green.withValues(alpha: 0.2)
                          : isDraw
                              ? Colors.amber.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Icon(
                        didWin
                            ? Icons.emoji_events
                            : isDraw
                                ? Icons.handshake
                                : Icons.sentiment_dissatisfied,
                        color: didWin
                            ? Colors.green
                            : isDraw
                                ? Colors.amber
                                : Colors.red,
                        size: 20,
                      ),
                    ),
                  ),
                  title: Text(
                    didWin
                        ? 'Victory vs ${match.opponentName}'
                        : isDraw
                            ? 'Draw with ${match.opponentName}'
                            : 'Loss vs ${match.opponentName}',
                    style: theme.textStyle.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Row(
                    children: [
                      Text(
                        DateFormat.yMd().format(match.timestamp),
                        style: theme.textStyle.copyWith(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '+${match.xpEarned} XP',
                        style: theme.textStyle.copyWith(
                          fontSize: 12,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                  trailing: Text(
                    '+${match.pointsEarned}',
                    style: theme.textStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.accent,
                    ),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MatchDetailScreen(record: match),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}