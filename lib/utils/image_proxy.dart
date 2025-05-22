// lib/config/image_proxy.dart

import 'package:flutter/foundation.dart';
import '../firebase_options.dart';

/// Handles building the correct base for your cover-image proxy URL.
class ImageProxyConfig {
  /// On mobile/desktop we can hit the origin directly (no CORS proxy needed).
  /// On Web debug we talk straight to the Functions emulator.
  /// On Web release we use our Hosting rewrite at `/proxy`.
  static String get baseUrl {
    if (!kIsWeb) {
      return '';
    }
    if (kDebugMode) {
      final pid = DefaultFirebaseOptions.currentPlatform.projectId;
      return 'http://127.0.0.1:5001/$pid/us-central1/imageProxy';
    }
    return '/proxy';
  }
}
