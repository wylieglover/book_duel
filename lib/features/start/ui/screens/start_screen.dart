// lib/screens/start_screen.dart

import 'package:flutter/material.dart';
import '../../../../core/services/session_service.dart';
import '../../../duel/ui/screens/duel_screen.dart';
import '../../../settings/ui/screens/settings_screen.dart';
import '../../../profile/ui/screens/profile_screen.dart';
import '../../../../core/theme/theme_provider.dart';
import 'package:provider/provider.dart';

// Import all the widget components
import '../widgets/theme_context.dart';
import '../widgets/start_header.dart';
import '../widgets/create_session_card.dart';
import '../widgets/join_session_card.dart';
import '../widgets/generated_code_card.dart';
import '../widgets/session_divider.dart';
import '../widgets/error_banner.dart';

class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _joinNameController = TextEditingController();
  String? generatedCode;
  String? errorMessage;
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    // If already in a session, skip to duel
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      if (SessionService().isConnected) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const BookDuelScreen()),
        );
      }
    });
  }

  Future<void> _createSession() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your name';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final code = await SessionService().createSession(name);
      setState(() {
        generatedCode = code;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to create session: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _joinSession() async {
    final code = _codeController.text.trim().toUpperCase();
    final name = _joinNameController.text.trim();

    if (code.isEmpty) {
      setState(() {
        errorMessage = 'Please enter a friend code';
      });
      return;
    }

    if (name.isEmpty) {
      setState(() {
        errorMessage = 'Please enter your name';
      });
      return;
    }

    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final success = await SessionService().joinSession(code, name);
      if (success) {
        _proceedToDuel();
      } else {
        setState(() {
          errorMessage = 'Session full or not found. Check the code and try again.';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Failed to join session: ${e.toString()}';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _proceedToDuel() {
    if (SessionService().currentSessionId == null) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BookDuelScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    // Create theme context for all widgets
    final theme = StartScreenTheme(context, isDarkMode);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: theme.gradientColors,
          ),
        ),
        child: Stack(
          children: [
            // The scrollable form — push it down a bit
            SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 80, 24, 24), // <-- more top padding!
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      StartHeader(theme: theme),
                      const SizedBox(height: 40),
                      CreateSessionCard(
                        nameController: _nameController,
                        theme: theme,
                        isLoading: isLoading,
                        onCreateSession: _createSession,
                      ),
                      if (generatedCode != null) ...[
                        const SizedBox(height: 20),
                        GeneratedCodeCard(
                          code: generatedCode!,
                          theme: theme,
                          onEnterDuel: _proceedToDuel,
                        ),
                      ],
                      SessionDivider(theme: theme),
                      JoinSessionCard(
                        codeController: _codeController,
                        nameController: _joinNameController,
                        theme: theme,
                        isLoading: isLoading,
                        onJoinSession: _joinSession,
                      ),
                      if (errorMessage != null) ...[
                        const SizedBox(height: 20),
                        ErrorBanner(
                          message: errorMessage!,
                          isDarkMode: isDarkMode,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            // Icon row overlaid at the top right
            Positioned(
              top: 20,
              right: 20,
              child: SafeArea(
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.person),
                      tooltip: 'Profile',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ProfileScreen()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      tooltip: 'Settings',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SettingsScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}