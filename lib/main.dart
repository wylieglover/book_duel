import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'features/start/ui/screens/start_screen.dart';
import 'core/services/session_service.dart';
import 'features/profile/data/services/profile_service.dart';
import 'core/theme/theme_provider.dart';
import 'features/profile/data/providers/profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  bool firebaseOk = false;

  // 1) Initialize Firebase
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    firebaseOk = true;
    debugPrint('✅ Firebase initialized');
  } catch (e) {
    debugPrint('⚠️ Firebase init failed: $e');
  }

  // 2) **Web-only**: force SessionStorage (or NONE) before any sign-in
  if (kIsWeb && firebaseOk) {
    await FirebaseAuth.instance
        .setPersistence(Persistence.SESSION)
        .catchError((e) => debugPrint('⚠️ Auth persistence failed: $e'));
    // you can also use Persistence.NONE if you really want no storage
  }

  // small delay to let everything settle
  await Future.delayed(const Duration(milliseconds: 200));

  // 3) Initialize your ProfileService (which does the sign-in under the hood)
  if (firebaseOk) {
    try {
      await ProfileService.instance.init();
      debugPrint('✅ Profile service initialized');
    } catch (e) {
      debugPrint('⚠️ Profile service init failed: $e');
    }
  } else {
    debugPrint('⚠️ Skipping Firebase-backed Profile init');
    await ProfileService.instance.init();
  }

  // 4) Restore any saved session
  try {
    await SessionService().restoreAndValidateSession();
    if (SessionService().isConnected) {
      debugPrint('✅ Session validated (restored "${SessionService().currentSessionId}")');
    } else {
      debugPrint('⚠️ No session to restore, skipping validation.');
    }
  } catch (e) {
    debugPrint('⚠️ Session validation failed: $e');
  }

  // 5) Run app
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => ProfileProvider()),
      ],
      child: const BookDuelApp(),
    ),
  );
}

class BookDuelApp extends StatelessWidget {
  const BookDuelApp({super.key});
  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      title: 'Book Duel',
      debugShowCheckedModeBanner: false,
      theme: theme.currentTheme,
      home: const StartScreen(),
    );
  }
}
