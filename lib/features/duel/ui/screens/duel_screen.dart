// lib/screens/book_duel_screen.dart

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_widgetkit/flutter_widgetkit.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/book.dart';
import '../../../../core/models/character.dart';
import '../../../../core/theme/theme_provider.dart';
import '../../../../core/services/session_service.dart';
import '../../../profile/data/services/profile_service.dart';
import '../../../../utils/animations.dart';
import '../widgets/book_dialog.dart';
import '../widgets/leave_button.dart';
import '../widgets/user_side_card.dart';
import '../widgets/vs_badge.dart';
import '../../../settings/ui/screens/settings_screen.dart';
import '../../../profile/ui/screens/profile_screen.dart';

class BookDuelScreen extends StatefulWidget {
  const BookDuelScreen({super.key});

  @override
  State<BookDuelScreen> createState() => _BookDuelScreenState();
}

class _BookDuelScreenState extends State<BookDuelScreen> with SingleTickerProviderStateMixin {
  List<Book> yourBooks = [];
  List<Book> friendBooks = [];
  String? yourName;
  String? friendName;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription? _sessionSub;
  bool _isMounted = true;

  @override
  void initState() {
    super.initState();

    final pulse = createPulseAnimation(this);
    _pulseController = pulse.item1;
    _pulseAnimation = pulse.item2;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isMounted || !mounted) return;

      final session = SessionService();
      final profile = ProfileService.instance.currentProfile;

      yourName = profile?.displayName ?? 'You';
      friendName = session.friendName;

      setState(() {
        yourName = profile?.displayName ?? 'You';
        friendName = session.friendName;
      });
      
      if (profile != null) {
        await session.updateMeta({
          session.isCreator ? 'creatorName' : 'joinerName': profile.displayName,
        });
      }

      _sessionSub = session.sessionStream?.listen((event) async {
        final data = event.snapshot.value as Map<dynamic,dynamic>?;
        if (data == null) return;

        final isCreator = session.isCreator;
        final yourRaw = isCreator ? data['creatorBooks'] : data['joinerBooks'] as Map<dynamic,dynamic>? ?? {};
        final friendRaw = isCreator ? data['joinerBooks'] : data['creatorBooks'] as Map<dynamic,dynamic>? ?? {};

        final yourParsed = await session.parseAndEnhanceBooks(yourRaw);
        final friendParsed = await session.parseAndEnhanceBooks(friendRaw);

        // 2) Migrate _your_ missing pageCounts back to Firebase immediately
        if (yourRaw != null) {
          for (final e in yourRaw.entries) {
            final id     = e.key as String;
            final rawMap = Map<String, dynamic>.from(e.value as Map);
            final book   = yourParsed.firstWhere((b) => b.id == id);

            final hadNoCount = rawMap['pageCount'] == null;
            if (hadNoCount && book.pageCount != null) {
              // write pageCount back up
              await session.editBook(true /* isYou */, book);
            }
          }
        }

        if (!_isMounted || !mounted) return;

        setState(() {
          yourBooks = yourParsed;
          friendBooks = friendParsed;

          if (data.containsKey('meta')) {
            final meta = data['meta'] as Map?;
            if (meta != null) {
              friendName = isCreator ? meta['joinerName'] : meta['creatorName'];
              final yourCharIndex = isCreator ? meta['creatorCharacter'] ?? 0 : meta['joinerCharacter'] ?? 1;
              final friendCharIndex = isCreator ? meta['joinerCharacter'] ?? 1 : meta['creatorCharacter'] ?? 0;

              if (SessionService().currentSession != null) {
                SessionService().currentSession!
                  ..character = CharacterType.values[yourCharIndex]
                  ..friendCharacter = CharacterType.values[friendCharIndex];
              }
            }
          }
        });

        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.iOS) {
          final widgetData = {
            'yourBooks': yourRaw,
            'friendBooks': friendRaw,
            'yourName': yourName,
            'friendName': friendName,
          };
          WidgetKit.setItem('widget_books', jsonEncode(widgetData), 'group.bookduel');
          WidgetKit.reloadAllTimelines();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final profile = ProfileService.instance.currentProfile;
    if (mounted && profile != null) {
      setState(() {
        yourName = profile.displayName;
        SessionService().updateMeta({
          SessionService().isCreator ? 'creatorName' : 'joinerName': profile.displayName,
        });
      });
    }
  }

  @override
  void dispose() {
    _isMounted = false;
    _sessionSub?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _showAddBookDialog(bool isYou) {
    showBookDialog(
      context,
      isYou,
      (newBook) => SessionService().addBook(isYou, newBook),
    );
  }

  Future<void> _showEditBookDialog(bool isYou, Book book) async {
    await showBookDialog(
      context,
      isYou,
      (updated) => SessionService().editBook(isYou, updated),
      existingBook: book,
    );
  }

  Future<void> _deleteBook(bool isYou, Book book) async {
    await SessionService().deleteBook(isYou, book);
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color(0xFF121212) : Colors.grey[100];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: bgColor,
          ),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 70),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: UserSideCard(
                                name: 'Me',
                                displayName: yourName ?? 'You',
                                books: yourBooks,
                                color: const Color(0xFF7ED7C1),
                                isYou: true,
                                onAddBook: () => _showAddBookDialog(true),
                                onEditBook: (book) => _showEditBookDialog(true, book),
                                onDeleteBook: (book) => _deleteBook(true, book),
                                animateAvatar: true,
                                characterType: SessionService().currentSession?.character ?? CharacterType.bear,
                              ),
                            ),
                            VsBadge(scale: _pulseAnimation),
                            Expanded(
                              child: UserSideCard(
                                name: 'Friend',
                                displayName: friendName ?? 'Friend',
                                books: friendBooks,
                                color: const Color(0xFFFFAFCC),
                                isYou: false,
                                onAddBook: () => _showAddBookDialog(false),
                                animateAvatar: true,
                                characterType: SessionService().currentSession?.friendCharacter ?? CharacterType.bunny,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20.0),
                      child: LeaveButton(),
                    ),
                    if (yourName != null && friendName != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '$yourName vs $friendName',
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.grey[400] : Colors.grey[600],
                            fontWeight: FontWeight.w500,
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Stack(
                    children: [
                      // CENTERED LABEL
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.only(top: 32.0, bottom: 12.0),
                          child: Text(
                            SessionService().currentSessionId != null
                                ? 'Book Duel: ${SessionService().currentSessionId}'
                                : 'Book Duel',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: themeProvider.isDarkMode ? Colors.white : Colors.black87,
                              decoration: TextDecoration.none,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),

                      // RIGHT ICONS
                      Positioned(
                        right: 0,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 20.0, right: 12.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.person, color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
                                tooltip: 'Profile',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                                  );
                                  if (!mounted) return;
                                  final updatedProfile = ProfileService.instance.currentProfile;
                                  setState(() {
                                    yourName = updatedProfile?.displayName ?? yourName;
                                    if (updatedProfile != null) {
                                      SessionService().updateMeta({
                                        SessionService().isCreator ? 'creatorCharacter' : 'joinerCharacter': updatedProfile.avatarIndex,
                                        SessionService().isCreator ? 'creatorName' : 'joinerName': updatedProfile.displayName,
                                      });
                                      SessionService().currentSession?.character = CharacterType.values[updatedProfile.avatarIndex];
                                    }
                                  });
                                },
                              ),
                              IconButton(
                                icon: Icon(Icons.settings, color: themeProvider.isDarkMode ? Colors.white : Colors.black87),
                                tooltip: 'Settings',
                                onPressed: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                                  );
                                  if (!mounted) return;
                                  setState(() {});
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}