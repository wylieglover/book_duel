import 'package:flutter/material.dart';
import 'dart:math' show pi, cos, sin;

class StarShapePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    final double radius = size.width / 2;
    
    final int spikes = 12;
    final double outerRadius = radius;
    final double innerRadius = radius * 0.85; 
    
    final Path path = Path();
    
    for (int i = 0; i < spikes * 2; i++) {
      final double angle = (i * pi / spikes);
      // Alternate between outer and inner radius
      final double currentRadius = i % 2 == 0 ? outerRadius : innerRadius;
      final double x = centerX + currentRadius * cos(angle);
      final double y = centerY + currentRadius * sin(angle);
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    path.close();
    
    final Paint borderPaint = Paint()
      ..color = const Color(0xFFFF9EB5)
      ..style = PaintingStyle.fill;
    
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
