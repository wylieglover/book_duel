import 'package:flutter/material.dart';

/// Creates a pulse animation controller and animation.
/// 
/// Usage:
///   final (controller, animation) = createPulseAnimation(this);
/// 
/// Always remember to dispose the controller in your State's dispose().
Tuple2<AnimationController, Animation<double>> createPulseAnimation(TickerProvider vsync,
    {Duration duration = const Duration(milliseconds: 1500),
     double begin = 1.0,
     double end = 1.1}) {

  final controller = AnimationController(
    duration: duration,
    vsync: vsync,
  )..repeat(reverse: true);

  final animation = Tween<double>(begin: begin, end: end).animate(
    CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ),
  );

  return Tuple2(controller, animation);
}

/// Simple Tuple2 class for returning two values (since Flutter doesn't have built-in tuples).
class Tuple2<T1, T2> {
  final T1 item1;
  final T2 item2;

  Tuple2(this.item1, this.item2);
}
