
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_theme.dart';

/// Provides the app's theme mode (light/dark) and convenient theme properties.
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  
  bool get isDarkMode => _isDarkMode;
  
  ThemeProvider() {
    _loadThemePreference();
  }
  
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('darkMode') ?? false;
    notifyListeners();
  }
  
  Future<void> toggleTheme(bool isDark) async {
    _isDarkMode = isDark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('darkMode', isDark);
    notifyListeners();
  }
  
  /// The active ThemeData from your AppTheme class.
  ThemeData get currentTheme => 
    AppTheme.getTheme(isDarkMode: _isDarkMode);

  /// Primary text style.
  TextStyle get textStyle => currentTheme.textTheme.bodyMedium!;

  /// Primary color (buttons, accents).
  Color get primary => currentTheme.colorScheme.primary;

  /// Secondary/accent color.
  Color get accent => currentTheme.colorScheme.secondary;

  /// Scaffold background color.
  Color get bgColor => currentTheme.scaffoldBackgroundColor;

  /// Surface/card color.
  Color get cardColor => currentTheme.colorScheme.surface;
}
