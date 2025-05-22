import 'package:flutter/material.dart';

// Bunny character (Friend)
class BunnyPainter extends CustomPainter {
  final double blinkValue;
  
  BunnyPainter({this.blinkValue = 1.0});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Define the color palette for the bunny
    final bunnyColor = const Color(0xFFFFD6DE); // Soft pink
    final bunnyDarkColor = const Color(0xFFFFBDCB); // Slightly darker pink
    final earInnerColor = const Color(0xFFFFADAD); // Inner ear color
    
    // Apply subtle gradient for more dimension
    final Rect gradientRect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    
    final Paint gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          bunnyColor,
          bunnyDarkColor.withValues(alpha: 0.7),
        ],
        stops: const [0.6, 1.0],
      ).createShader(gradientRect)
      ..style = PaintingStyle.fill;
    
    // Bunny body (circle) with gradient
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2), 
      size.width / 2, 
      gradientPaint
    );
    
    // Bunny ears - improved shape and position
    _drawBunnyEar(canvas, size, true, bunnyColor, earInnerColor);  // Left ear
    _drawBunnyEar(canvas, size, false, bunnyColor, earInnerColor); // Right ear
    
    // Face - more defined
    final Paint facePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 + size.height / 15), 
      size.width / 2.3, 
      facePaint
    );
    
    // Add highlight
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.4), 
      size.width / 6, 
      highlightPaint
    );
    
    // Bunny eyes - with blink animation
    _drawBunnyEye(
      canvas, 
      Offset(size.width * 0.35, size.height * 0.45),
      size.width / 10,
      blinkValue,
      size
    );
    
    _drawBunnyEye(
      canvas, 
      Offset(size.width * 0.65, size.height * 0.45),
      size.width / 10,
      blinkValue,
      size
    );
    
    // Nose - small heart-shaped nose
    _drawBunnyNose(canvas, size);
    
    // Whiskers - fine and delicate
    _drawWhiskers(canvas, size);
    
    // Small smile mouth
    final Paint mouthPaint = Paint()
      ..color = const Color(0xFFE56B87)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 40
      ..strokeCap = StrokeCap.round;
    
    final Path mouthPath = Path()
      ..moveTo(size.width * 0.42, size.height * 0.63)
      ..quadraticBezierTo(
        size.width / 2, 
        size.height * 0.68, 
        size.width * 0.58, 
        size.height * 0.63
      );
    
    canvas.drawPath(mouthPath, mouthPaint);
    
    // Add subtle blush
    final Paint blushPaint = Paint()
      ..color = const Color(0xFFFF91A4).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.58), 
      size.width / 8, 
      blushPaint
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.58), 
      size.width / 8, 
      blushPaint
    );
  }
  
  void _drawBunnyEar(Canvas canvas, Size size, bool isLeft, Color mainColor, Color innerColor) {
    final centerX = size.width / 2;
    
    // Base of ear is along edge of head
    final earBaseX = isLeft ? centerX - size.width * 0.3 : centerX + size.width * 0.3;
    final earBaseY = size.height * 0.3;
    
    // Create ear path - tall, elongated oval shape for each ear
    final Paint earPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill;
    
    // Draw ear as elongated oval
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          earBaseX, 
          earBaseY - size.height * 0.25  // Position ear above the base point
        ),
        width: size.width * 0.25,
        height: size.height * 0.6
      ),
      earPaint
    );
    
    // Inner ear - slightly smaller oval with different color
    final Paint innerEarPaint = Paint()
      ..color = innerColor
      ..style = PaintingStyle.fill;
      
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(
          earBaseX, 
          earBaseY - size.height * 0.25  // Same position as outer ear
        ),
        width: size.width * 0.15,  // Smaller width
        height: size.height * 0.5   // Smaller height
      ),
      innerEarPaint
    );
  }
  
  void _drawBunnyEye(Canvas canvas, Offset position, double size, double blinkValue, Size totalSize) {
    // Eye background
    final Paint eyeBackgroundPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, size * 1.2, eyeBackgroundPaint);
    
    if (blinkValue > 0.5) {
      // Normal eye
      final Paint eyePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(position, size * blinkValue, eyePaint);
      
      // Eye highlight
      final Paint eyeHighlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(position.dx - size * 0.3, position.dy - size * 0.3), 
        size * 0.35, 
        eyeHighlightPaint
      );
      
      // Additional small highlight
      canvas.drawCircle(
        Offset(position.dx + size * 0.3, position.dy + size * 0.3), 
        size * 0.15, 
        eyeHighlightPaint
      );
    } else {
      // Closed eye - happy arc
      final Paint closedEyePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = totalSize.width / 40
        ..strokeCap = StrokeCap.round;
      
      final Path closedEyePath = Path()
        ..moveTo(position.dx - size, position.dy)
        ..quadraticBezierTo(
          position.dx, 
          position.dy + size, 
          position.dx + size, 
          position.dy
        );
      
      canvas.drawPath(closedEyePath, closedEyePaint);
    }
  }
  
  void _drawBunnyNose(Canvas canvas, Size size) {
    // Heart-shaped nose
    final double noseWidth = size.width / 8;
    final double noseHeight = size.height / 14;
    final Offset noseCenter = Offset(size.width / 2, size.height * 0.56);
    
    final Paint nosePaint = Paint()
      ..color = const Color(0xFFFF9CAD)
      ..style = PaintingStyle.fill;
    
    final Path nosePath = Path();
    
    // First circle of heart
    nosePath.addOval(
      Rect.fromCircle(
        center: Offset(noseCenter.dx - noseWidth / 4, noseCenter.dy - noseHeight / 4),
        radius: noseWidth / 2,
      ),
    );
    
    // Second circle of heart
    nosePath.addOval(
      Rect.fromCircle(
        center: Offset(noseCenter.dx + noseWidth / 4, noseCenter.dy - noseHeight / 4),
        radius: noseWidth / 2,
      ),
    );
    
    // Bottom point of heart
    nosePath.moveTo(noseCenter.dx - noseWidth / 2, noseCenter.dy);
    nosePath.quadraticBezierTo(
      noseCenter.dx, 
      noseCenter.dy + noseHeight / 1.5, 
      noseCenter.dx + noseWidth / 2, 
      noseCenter.dy,
    );
    
    canvas.drawPath(nosePath, nosePaint);
    
    // Add shine to nose
    final Paint noseHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(noseCenter.dx - noseWidth / 5, noseCenter.dy - noseHeight / 5), 
      noseWidth / 5, 
      noseHighlightPaint
    );
  }
  
  void _drawWhiskers(Canvas canvas, Size size) {
    final Paint whiskerPaint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 80
      ..strokeCap = StrokeCap.round;
    
    final double whiskerY = size.height * 0.58;
    final double whiskerX = size.width * 0.3;
    final double whiskerLength = size.width * 0.25;
    
    // Left whiskers (3 with subtle curve)
    _drawWhisker(canvas, 
      Offset(whiskerX, whiskerY - size.height * 0.04),
      Offset(whiskerX - whiskerLength, whiskerY - size.height * 0.08),
      whiskerPaint
    );
    
    _drawWhisker(canvas, 
      Offset(whiskerX, whiskerY),
      Offset(whiskerX - whiskerLength, whiskerY),
      whiskerPaint
    );
    
    _drawWhisker(canvas, 
      Offset(whiskerX, whiskerY + size.height * 0.04),
      Offset(whiskerX - whiskerLength, whiskerY + size.height * 0.08),
      whiskerPaint
    );
    
    // Right whiskers (3 with subtle curve)
    _drawWhisker(canvas, 
      Offset(size.width - whiskerX, whiskerY - size.height * 0.04),
      Offset(size.width - (whiskerX - whiskerLength), whiskerY - size.height * 0.08),
      whiskerPaint
    );
    
    _drawWhisker(canvas, 
      Offset(size.width - whiskerX, whiskerY),
      Offset(size.width - (whiskerX - whiskerLength), whiskerY),
      whiskerPaint
    );
    
    _drawWhisker(canvas, 
      Offset(size.width - whiskerX, whiskerY + size.height * 0.04),
      Offset(size.width - (whiskerX - whiskerLength), whiskerY + size.height * 0.08),
      whiskerPaint
    );
  }
  
  void _drawWhisker(Canvas canvas, Offset start, Offset end, Paint paint) {
    final Path whiskerPath = Path()
      ..moveTo(start.dx, start.dy)
      ..cubicTo(
        start.dx + (end.dx - start.dx) * 0.3, 
        start.dy, 
        end.dx - (end.dx - start.dx) * 0.3, 
        end.dy, 
        end.dx, 
        end.dy
      );
    
    canvas.drawPath(whiskerPath, paint);
  }

  @override
  bool shouldRepaint(covariant BunnyPainter oldDelegate) => 
      oldDelegate.blinkValue != blinkValue;
}
