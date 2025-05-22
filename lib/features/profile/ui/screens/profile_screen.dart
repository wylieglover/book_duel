// lib/screens/profile_screen.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' hide Badge;
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../data/models/activity_data.dart';
import '../../data/models/user_profile.dart';
import '../../../../core/models/character.dart';
import '../../../matches/data/models/match_record.dart';
import '../../data/providers/profile_provider.dart';
import '../../data/services/activity_service.dart';
import '../../../../core/widgets/character/character_avatar.dart';
import '../../../../core/theme/theme_provider.dart';
import '../widgets/activity_heatmap.dart';
import '../widgets/stat_card.dart';
import '../../../matches/ui/match_detail_screen.dart';
import '../../../matches/ui/full_match_history_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String? viewingUid;
  const ProfileScreen({super.key, this.viewingUid});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool get _isEditable => widget.viewingUid == null;

  final _nameController = TextEditingController();
  late final AnimationController _avatarCtrl;
  late final Animation<double> _avatarScale;
  bool _isEditingName = false;
  late Future<List<ActivityData>> _heatmapFuture = Future.value([]);

  @override
  void initState() {
    super.initState();
    _avatarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _avatarScale = Tween(begin: 0.8, end: 1.0)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_avatarCtrl);

    ActivityService.instance.init().then((_) {
      setState(() {
        _heatmapFuture = ActivityService.instance.getActivityData();
      });
    });
  }

  @override
  void dispose() {
    _avatarCtrl.dispose();
    _nameController.dispose();
    super.dispose();
  }

  int xpForLevel(int level) => 100 + (level * 50);

  int xpTotalForLevel(int level) {
    int total = 0;
    for (int i = 0; i < level; i++) {
      total += xpForLevel(i);
    }
    return total;
  }

  Future<void> _saveName(ProfileProvider provider, UserProfile profile) async {
    final newName = _nameController.text.trim();
    await provider.updateDisplayName(newName.isEmpty ? profile.displayName : newName);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profile saved! 🎉')),
    );
  }

  Future<void> _pickAvatar(ProfileProvider provider, int idx) async {
    await provider.updateAvatar(idx);
  }

  void _showAvatarPicker(ProfileProvider provider, UserProfile profile) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SizedBox(
        height: 100,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.all(12),
          itemCount: CharacterType.values.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (_, idx) {
            final selected = idx == profile.avatarIndex;
            return GestureDetector(
              onTap: () {
                _pickAvatar(provider, idx);
                Navigator.pop(context);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: selected
                      ? Provider.of<ThemeProvider>(context, listen: false).accent
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Provider.of<ThemeProvider>(context, listen: false)
                                .accent
                                .withValues(alpha: 0.4),
                            blurRadius: 8,
                          ),
                        ]
                      : null,
                ),
                child: CharacterAvatar(
                  characterType: CharacterType.values[idx],
                  size: 64,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    final provider = Provider.of<ProfileProvider>(context);

    final profile = provider.profile;

    if (provider.isLoading || profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    _nameController.text = profile.displayName;
    final xpNeeded = xpForLevel(profile.currentLevel);
    final progress = profile.currentXP / xpNeeded;

    return Scaffold(
      backgroundColor: theme.bgColor,
      appBar: AppBar(
        backgroundColor: theme.currentTheme.appBarTheme.backgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          _isEditable ? 'My Profile' : 'Profile',
          style: theme.currentTheme.appBarTheme.titleTextStyle,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 48, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Avatar
                      ScaleTransition(
                        scale: _avatarScale,
                        child: GestureDetector(
                          onTap: _isEditable
                              ? () => _showAvatarPicker(provider, profile)
                              : null,
                          child: CharacterAvatar(
                            characterType:
                                CharacterType.values[profile.avatarIndex],
                            size: 100,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      _isEditable
                          ? AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child: _isEditingName
                                  ? Padding(
                                      key: const ValueKey('field'),
                                      padding: const EdgeInsets.symmetric(horizontal: 40),
                                      child: TextField(
                                        controller: _nameController,
                                        textAlign: TextAlign.center,
                                        style: theme.textStyle.copyWith(fontSize: 20),
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: theme.primary.withValues(alpha: 0.5)),
                                          ),
                                          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                                          suffixIcon: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              IconButton(
                                                icon: Icon(Icons.check, color: theme.accent),
                                                onPressed: () {
                                                  _saveName(provider, profile);
                                                  setState(() => _isEditingName = false);
                                                },
                                              ),
                                              IconButton(
                                                icon: const Icon(Icons.close, color: Colors.grey),
                                                onPressed: () {
                                                  _nameController.text = profile.displayName;
                                                  setState(() => _isEditingName = false);
                                                },
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    )
                                  : GestureDetector(
                                      key: const ValueKey('label'),
                                      onTap: () => setState(() => _isEditingName = true),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            profile.displayName,
                                            style: theme.textStyle.copyWith(fontSize: 20),
                                          ),
                                          const SizedBox(width: 8),
                                          Icon(Icons.edit, size: 20, color: theme.primary),
                                        ],
                                      ),
                                    ),
                            )
                          : Text(
                              profile.displayName,
                              style: theme.textStyle.copyWith(fontSize: 20),
                            ),
                      const SizedBox(height: 24),

                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Level ${profile.currentLevel}',
                          style: theme.textStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: progress.clamp(0.0, 1.0),
                              minHeight: 12,
                              backgroundColor: theme.isDarkMode ? Colors.white24 : Colors.black12,
                              valueColor: AlwaysStoppedAnimation<Color>(theme.accent),
                            ),
                          ),
                          Text(
                            '${profile.currentXP} / $xpNeeded XP',
                            style: theme.textStyle.copyWith(fontSize: 12),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Points: ${profile.pointsBalance}',
                          style: theme.textStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          StatCard(
                            label: 'Wins',
                            value: profile.wins,
                            icon: Icons.military_tech,
                            iconColor: theme.accent,
                          ),
                          StatCard(
                            label: 'Losses',
                            value: profile.losses,
                            icon: Icons.heart_broken,
                            iconColor: Colors.redAccent,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'My Badges',
                          style: theme.textStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Reading Heatmap',
                          style: theme.textStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FutureBuilder<List<ActivityData>>(
                        future: _heatmapFuture,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const Center(child: CircularProgressIndicator());
                          }
                          final data = snapshot.data ?? [];
                          return ActivityHeatmap(activityData: data);
                        },
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Recent Matches',
                          style: theme.textStyle.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(height: 6),
                      if (profile.matchHistory.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20),
                          child: Text(
                            'No matches yet',
                            style: theme.textStyle.copyWith(color: Colors.grey),
                          ),
                        )
                      else
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: profile.matchHistory.length,
                            itemBuilder: (ctx, i) {
                              final match = profile.matchHistory[i];
                              final didWin = match.result == MatchResult.win;
                              return ListTile(
                                leading: Icon(
                                  didWin ? Icons.emoji_events : Icons.sentiment_dissatisfied,
                                  color: didWin ? theme.accent : Colors.grey,
                                ),
                                title: Text(
                                  '${didWin ? "Won against" : "Lost to"} ${match.opponentName}',
                                  style: theme.textStyle,
                                ),
                                subtitle: Text(
                                  DateFormat.yMMMd().add_jm().format(match.timestamp),
                                  style: theme.textStyle.copyWith(fontSize: 12),
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text('+${match.xpEarned} XP',
                                        style: theme.textStyle.copyWith(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                        )),
                                    Text('+${match.pointsEarned} pts',
                                        style: theme.textStyle.copyWith(
                                          color: theme.accent,
                                          fontSize: 12,
                                        )),
                                  ],
                                ),
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => MatchDetailScreen(record: match),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      if (profile.matchHistory.isNotEmpty)
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => FullMatchHistoryScreen(matches: profile.matchHistory),
                              ),
                            );
                          },
                          child: Text(
                            'View All Matches',
                            style: theme.textStyle.copyWith(color: theme.accent),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (!kReleaseMode && _isEditable)
            Positioned(
              bottom: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton.extended(
                    label: const Text('Add Match'),
                    icon: const Icon(Icons.sports_kabaddi),
                    heroTag: 'addMatch',
                    onPressed: () async {
                      await provider.recordMatchResult(
                        MatchRecord(
                          sessionId: 'test-123',
                          opponentUid: 'opponent123',
                          opponentName: 'Test Opponent',
                          timestamp: DateTime.now(),
                          result: MatchResult.win,
                          pointsEarned: 15,
                          xpEarned: 30,
                        ),
                      );
                      setState(() {
                        _heatmapFuture =
                            ActivityService.instance.getActivityData();
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.extended(
                    label: const Text('Add Loss'),
                    icon: const Icon(Icons.cancel),
                    heroTag: 'addLoss',
                    onPressed: () async {
                      await provider.recordMatchResult(
                        MatchRecord(
                          sessionId: 'test-123',
                          opponentUid: 'opponent123',
                          opponentName: 'Test Opponent',
                          timestamp: DateTime.now(),
                          result: MatchResult.loss,
                          pointsEarned: 5,
                          xpEarned: 10,
                        ),
                      );
                      setState(() {
                        _heatmapFuture =
                            ActivityService.instance.getActivityData();
                      });
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
