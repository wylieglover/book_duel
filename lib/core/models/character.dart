// lib/models/character.dart

import 'package:flutter/material.dart';

enum CharacterType { 
  bear, 
  bunny,
  cat
}

class Character {
  final CharacterType type;

  const Character({ required this.type });

  /// Dynamic display name
  String get name {
    switch (type) {
      case CharacterType.bear:
        return 'Bear';
      case CharacterType.bunny:
        return 'Bunny';
      case CharacterType.cat:
        return 'Cat';
    }
  }

  /// Avatar border color
  Color get borderColor {
    switch (type) {
      case CharacterType.bear:
        return const Color(0xFF96CEB4);  // teal green
      case CharacterType.bunny:
        return const Color(0xFFFFADAD);  // pink
      case CharacterType.cat:
        return const Color(0xFF7DC6FF);  // soft blue
    }
  }

  /// Emoji icon
  String get emoji {
    switch (type) {
      case CharacterType.bear:
        return '🐻';
      case CharacterType.bunny:
        return '🐰';
      case CharacterType.cat:
        return '🐱';
    }
  }

  /// Static list of available characters
  static List<Character> get all => CharacterType.values.map((type) => Character(type: type)).toList();
}
