import 'package:flutter/material.dart';

// Bear character (You)
class BearPainter extends CustomPainter {
  final double blinkValue;
  
  BearPainter({this.blinkValue = 1.0});
  
  @override
  void paint(Canvas canvas, Size size) {
    // Define the color palette for the bear
    final bearColor = const Color(0xFFD9B27C); // Warmer, more honey-like brown
    final bearDarkColor = const Color(0xFFBD9868); // Darker shade
    final muzzleColor = const Color(0xFFE8DABC); // Lighter muzzle color
    
    // Apply subtle gradient for more dimension
    final Rect gradientRect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2,
    );
    
    final Paint gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          bearColor,
          bearDarkColor.withValues(
            alpha: 0.7,
            red: null,
            green: null,
            blue: null,
          ),
        ],
        stops: const [0.6, 1.0],
      ).createShader(gradientRect)
      ..style = PaintingStyle.fill;
    
    // Bear body (circle) with gradient
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2), 
      size.width / 2, 
      gradientPaint
    );
    
    // Bear ears with better shape and positioning
    _drawBearEar(canvas, size, Offset(size.width * 0.25, size.height * 0.25), bearColor, bearDarkColor);
    _drawBearEar(canvas, size, Offset(size.width * 0.75, size.height * 0.25), bearColor, bearDarkColor);
    
    // More defined face/muzzle area
    final Paint facePaint = Paint()
      ..color = muzzleColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2 + size.height / 12), 
      size.width / 2.5, 
      facePaint
    );
    
    // Add subtle highlight
    final Paint highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.4, size.height * 0.4), 
      size.width / 6, 
      highlightPaint
    );
    
    // Bear eyes - more expressive with blink animation
    _drawBearEye(
      canvas, 
      Offset(size.width * 0.35, size.height * 0.45),
      size.width / 11,
      blinkValue,
      size
    );
    
    _drawBearEye(
      canvas, 
      Offset(size.width * 0.65, size.height * 0.45),
      size.width / 11,
      blinkValue,
      size
    );
    
    // Bear nose - improved oval shape
    final Paint nosePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height * 0.58),
        width: size.width / 5,
        height: size.height / 10
      ),
      nosePaint
    );
    
    // Add nose highlight
    final Paint noseHighlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.47, size.height * 0.57), 
      size.width / 25, 
      noseHighlightPaint
    );
    
    // Bear mouth - more gentle curve with smile
    final Paint mouthPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width / 35
      ..strokeCap = StrokeCap.round;
    
    final Path mouthPath = Path()
      ..moveTo(size.width * 0.4, size.height * 0.65)
      ..quadraticBezierTo(
        size.width / 2, 
        size.height * 0.72, 
        size.width * 0.6, 
        size.height * 0.65
      );
    
    canvas.drawPath(mouthPath, mouthPaint);
    
    // Add subtle cheek blush
    final Paint blushPaint = Paint()
      ..color = const Color(0xFFD88C81).withValues(alpha: 0.2)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.6), 
      size.width / 8, 
      blushPaint
    );
    
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.6), 
      size.width / 8, 
      blushPaint
    );
  }
  
  void _drawBearEar(Canvas canvas, Size size, Offset position, Color mainColor, Color darkColor) {
    // Main ear
    final Paint earPaint = Paint()
      ..color = mainColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      position, 
      size.width / 5, 
      earPaint
    );
    
    // Inner ear
    final Paint innerEarPaint = Paint()
      ..color = darkColor
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(
      position, 
      size.width / 8, 
      innerEarPaint
    );
  }
  
  void _drawBearEye(Canvas canvas, Offset position, double size, double blinkValue, Size totalSize) {
    // Eye white
    final Paint eyeWhitePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, size * 1.2, eyeWhitePaint);
    
    // Eye (with blink animation)
    final Paint eyePaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill;
    
    if (blinkValue > 0.5) {
      // Normal eye
      canvas.drawCircle(position, size * blinkValue, eyePaint);
      
      // Eye highlight
      final Paint eyeHighlightPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(position.dx - size * 0.2, position.dy - size * 0.2), 
        size * 0.35, 
        eyeHighlightPaint
      );
    } else {
      // Closed eye (line)
      final Paint closedEyePaint = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.stroke
        ..strokeWidth = totalSize.width / 40
        ..strokeCap = StrokeCap.round;
      
      canvas.drawLine(
        Offset(position.dx - size, position.dy),
        Offset(position.dx + size, position.dy),
        closedEyePaint
      );
    }
  }

  @override
  bool shouldRepaint(covariant BearPainter oldDelegate) => 
      oldDelegate.blinkValue != blinkValue;
}