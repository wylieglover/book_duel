import 'package:flutter/material.dart';
import '../../models/character.dart';
import 'avatars/bunny_painter.dart';
import 'avatars/bear_painter.dart';
import 'avatars/cat_painter.dart';

class StaticCharacter extends StatelessWidget {
  final CharacterType characterType;
  final double size;

  const StaticCharacter({
    super.key,
    required this.characterType,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size * 0.7, size * 0.7),
      painter: _getPainter(characterType),
    );
  }

  CustomPainter _getPainter(CharacterType type) {
    switch (type) {
      case CharacterType.bear:
        return BearPainter();
      case CharacterType.bunny:
        return BunnyPainter();
      case CharacterType.cat:
        return CatPainter();
    }
  }
}
