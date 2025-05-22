import 'package:flutter/material.dart';

/// A class that provides theme-related colors and styles for the start screen
/// 
// TODO: Start screend widgets should use theme provider in the future
class StartScreenTheme {
  final BuildContext context;
  final bool isDarkMode;

  StartScreenTheme(this.context, this.isDarkMode);

  // Background colors
  Color get backgroundColor => isDarkMode 
      ? const Color(0xFF121212)
      : Colors.grey.shade100;
  
  List<Color> get gradientColors => isDarkMode 
      ? [Colors.teal.shade900, const Color(0xFF121212)] 
      : [Colors.teal.shade50, Colors.grey.shade100];
  
  // Card colors
  Color get cardBorderColor => isDarkMode 
      ? Colors.teal.shade800
      : Colors.teal.shade100;
  
  Color get cardColor => isDarkMode 
      ? Colors.grey.shade900
      : Colors.white;
  
  // Text colors
  Color get textColor => isDarkMode 
      ? Colors.white
      : Colors.black87;
  
  Color get subtitleColor => isDarkMode 
      ? Colors.grey.shade400
      : Colors.grey.shade700;
  
  // Circle indicator
  Color get circleColor => isDarkMode 
      ? Colors.teal.shade800
      : Colors.teal.shade100;
  
  Color get circleTextColor => isDarkMode 
      ? Colors.teal.shade200
      : Colors.teal.shade700;
  
  // Divider
  Color get dividerColor => isDarkMode 
      ? Colors.grey.shade800
      : Colors.grey.shade300;

  // Input fields
  Color get inputFillColor => isDarkMode 
      ? Colors.grey.shade800 
      : Colors.white;

  InputDecoration getInputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      filled: true,
      fillColor: inputFillColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.teal.shade400, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  // Button styles
  ButtonStyle get primaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF7ED7C1),
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  );

  ButtonStyle get secondaryButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: isDarkMode ? Colors.grey.shade700 : Colors.grey.shade800,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  );

  ButtonStyle get enterDuelButtonStyle => ElevatedButton.styleFrom(
    backgroundColor: isDarkMode ? Colors.teal.shade600 : Colors.teal.shade700,
    foregroundColor: Colors.white,
    padding: const EdgeInsets.symmetric(vertical: 14),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    elevation: 0,
  );
}