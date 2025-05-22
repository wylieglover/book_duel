// lib/widgets/character/animated_character.dart

import 'package:flutter/material.dart';
import '../../models/character.dart';
import 'avatars/bunny_painter.dart';
import 'avatars/bear_painter.dart';
import 'avatars/cat_painter.dart';

class AnimatedCharacter extends StatefulWidget {
  final CharacterType characterType;
  final double size;

  const AnimatedCharacter({
    super.key,
    required this.characterType,
    required this.size,
  });

  @override
  State<AnimatedCharacter> createState() => _AnimatedCharacterState();
}

class _AnimatedCharacterState extends State<AnimatedCharacter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _blinkAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    _blinkAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 90),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 1.0), weight: 8),
    ]).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return CustomPaint(
          size: Size(widget.size * 0.7, widget.size * 0.7),
          painter: _getPainter(widget.characterType, _blinkAnimation.value),
        );
      },
    );
  }

  CustomPainter _getPainter(CharacterType type, double blinkValue) {
    switch (type) {
      case CharacterType.bear:
        return BearPainter(blinkValue: blinkValue);
      case CharacterType.bunny:
        return BunnyPainter(blinkValue: blinkValue);
      case CharacterType.cat:
        return CatPainter(blinkValue: blinkValue);
    }
  }
}
