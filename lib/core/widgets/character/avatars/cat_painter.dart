import 'package:flutter/material.dart';

// Cat character 
class CatPainter extends CustomPainter {
  final double blinkValue;

  CatPainter({this.blinkValue = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // Gradient cat face
    final Rect gradientRect = Rect.fromCircle(
      center: center,
      radius: size.width / 2,
    );
    final Paint gradientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFBFAF), 
          const Color(0xFFFF8E72), 
        ],
        stops: const [0.6, 1.0],
      ).createShader(gradientRect)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, size.width / 2, gradientPaint);

    // Ears - smaller, round cat ears
    _drawCatEar(canvas, size, true);
    _drawCatEar(canvas, size, false);

    // White muzzle circle
    final Paint muzzlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      center.translate(0, size.height * 0.05),
      size.width / 2.5,
      muzzlePaint,
    );

    // Eyes
    _drawCatEye(canvas, size, Offset(size.width * 0.35, size.height * 0.45));
    _drawCatEye(canvas, size, Offset(size.width * 0.65, size.height * 0.45));

    // Nose - tiny cat nose
    _drawCatNose(canvas, size);

    // Whiskers
    _drawWhiskers(canvas, size);

    // Blush
    final Paint blushPaint = Paint()
      ..color = const Color(0xFFFF91A4).withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.25, size.height * 0.58),
      size.width / 8,
      blushPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.75, size.height * 0.58),
      size.width / 8,
      blushPaint,
    );
  }

  void _drawCatEar(Canvas canvas, Size size, bool isLeft) {
    final double centerX = size.width / 2;
    final double baseX = isLeft
        ? centerX - size.width * 0.3
        : centerX + size.width * 0.3;
    final double baseY = size.height * 0.28;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX, baseY - size.height * 0.12),
        width: size.width * 0.2,
        height: size.height * 0.18,
      ),
      Paint()..color = const Color(0xFFFF8E72),
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(baseX, baseY - size.height * 0.12),
        width: size.width * 0.12,
        height: size.height * 0.12,
      ),
      Paint()..color = const Color(0xFFFFADAD),
    );
  }

  void _drawCatEye(Canvas canvas, Size size, Offset position) {
    final double eyeSize = size.width / 10;

    // White eye background
    canvas.drawCircle(
        position,
        eyeSize * 1.2,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill);

    if (blinkValue > 0.5) {
      // Open eye
      canvas.drawCircle(
          position,
          eyeSize * blinkValue,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.fill);

      // Eye highlights
      final Paint highlight = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.fill;

      canvas.drawCircle(position.translate(-eyeSize * 0.3, -eyeSize * 0.3),
          eyeSize * 0.35, highlight);
      canvas.drawCircle(position.translate(eyeSize * 0.3, eyeSize * 0.3),
          eyeSize * 0.15, highlight);
    } else {
      // Closed eye arc
      final Path closedPath = Path()
        ..moveTo(position.dx - eyeSize, position.dy)
        ..quadraticBezierTo(position.dx, position.dy + eyeSize,
            position.dx + eyeSize, position.dy);

      canvas.drawPath(
          closedPath,
          Paint()
            ..color = Colors.black
            ..style = PaintingStyle.stroke
            ..strokeWidth = size.width / 40
            ..strokeCap = StrokeCap.round);
    }
  }

  void _drawCatNose(Canvas canvas, Size size) {
    final Offset noseCenter = Offset(size.width / 2, size.height * 0.56);

    final Path nosePath = Path()
      ..moveTo(noseCenter.dx, noseCenter.dy)
      ..lineTo(noseCenter.dx - size.width * 0.015,
          noseCenter.dy + size.height * 0.015)
      ..lineTo(noseCenter.dx + size.width * 0.015,
          noseCenter.dy + size.height * 0.015)
      ..close();

    canvas.drawPath(
        nosePath,
        Paint()
          ..color = Colors.black
          ..style = PaintingStyle.fill);
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

    // Left whiskers
    _drawWhisker(canvas, Offset(whiskerX, whiskerY - size.height * 0.04),
        Offset(whiskerX - whiskerLength, whiskerY - size.height * 0.08),
        whiskerPaint);
    _drawWhisker(canvas, Offset(whiskerX, whiskerY),
        Offset(whiskerX - whiskerLength, whiskerY), whiskerPaint);
    _drawWhisker(canvas, Offset(whiskerX, whiskerY + size.height * 0.04),
        Offset(whiskerX - whiskerLength, whiskerY + size.height * 0.08),
        whiskerPaint);

    // Right whiskers
    _drawWhisker(
        canvas,
        Offset(size.width - whiskerX, whiskerY - size.height * 0.04),
        Offset(size.width - (whiskerX - whiskerLength),
            whiskerY - size.height * 0.08),
        whiskerPaint);
    _drawWhisker(
        canvas,
        Offset(size.width - whiskerX, whiskerY),
        Offset(size.width - (whiskerX - whiskerLength), whiskerY),
        whiskerPaint);
    _drawWhisker(
        canvas,
        Offset(size.width - whiskerX, whiskerY + size.height * 0.04),
        Offset(size.width - (whiskerX - whiskerLength),
            whiskerY + size.height * 0.08),
        whiskerPaint);
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
          end.dy);

    canvas.drawPath(whiskerPath, paint);
  }

  @override
  bool shouldRepaint(covariant CatPainter oldDelegate) =>
      oldDelegate.blinkValue != blinkValue;
}
