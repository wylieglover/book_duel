// lib/widgets/character/character_avatar.dart

import 'package:flutter/material.dart';
import '../../models/character.dart';
import 'animated_character.dart';
import 'static_character.dart';

class CharacterAvatar extends StatelessWidget {
  final CharacterType characterType;
  final double size;
  final bool animate;

  const CharacterAvatar({
    super.key,
    required this.characterType,
    this.size = 35,
    this.animate = false,
  });

  @override
  Widget build(BuildContext context) {
    final character = Character(type: characterType);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.transparent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
        border: Border.all(
          color: character.borderColor,
          width: 2,
        ),
      ),
      child: animate
          ? AnimatedCharacter(characterType: characterType, size: size)
          : StaticCharacter(characterType: characterType, size: size),
    );
  }
}
