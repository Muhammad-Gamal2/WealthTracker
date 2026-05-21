import 'package:flutter/material.dart';

class SproutLogo extends StatelessWidget {
  final double size;
  final Color color;

  const SproutLogo({
    super.key,
    this.size = 100,
    this.color = const Color(0xFFD4A24A), // saffron default
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _SproutPainter(color: color),
    );
  }
}

class _SproutPainter extends CustomPainter {
  final Color color;
  _SproutPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 100; // scale factor
    final paint = Paint()..color = color..style = PaintingStyle.fill;

    // Branch — thin, tapered to a point at the base
    final branch = Path()
      ..moveTo(48.5 * s, 58 * s)
      ..lineTo(51.5 * s, 58 * s)
      ..lineTo(51 * s, 90 * s)
      ..lineTo(50 * s, 95 * s)
      ..lineTo(49 * s, 90 * s)
      ..close();
    canvas.drawPath(branch, paint);

    // Center leaf — pointing straight up
    final centerLeaf = Path()
      ..moveTo(50 * s, 58 * s)
      ..cubicTo(41 * s, 52 * s, 39 * s, 26 * s, 50 * s, 14 * s)
      ..cubicTo(61 * s, 26 * s, 59 * s, 52 * s, 50 * s, 58 * s)
      ..close();
    canvas.drawPath(centerLeaf, paint);

    // Left leaf — angled outward (rotate -38 degrees around (50, 60))
    canvas.save();
    canvas.translate(50 * s, 60 * s);
    canvas.rotate(-38 * 3.14159 / 180);
    canvas.translate(-50 * s, -60 * s);
    final leftLeaf = Path()
      ..moveTo(50 * s, 60 * s)
      ..cubicTo(42 * s, 54 * s, 40 * s, 30 * s, 50 * s, 20 * s)
      ..cubicTo(60 * s, 30 * s, 58 * s, 54 * s, 50 * s, 60 * s)
      ..close();
    canvas.drawPath(leftLeaf, paint);
    canvas.restore();

    // Right leaf — mirror (rotate +38 degrees)
    canvas.save();
    canvas.translate(50 * s, 60 * s);
    canvas.rotate(38 * 3.14159 / 180);
    canvas.translate(-50 * s, -60 * s);
    canvas.drawPath(leftLeaf, paint); // same path, just rotated the other way
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SproutPainter old) => old.color != color;
}
