import 'package:flutter/material.dart';

class TrefoilDivider extends StatelessWidget {
  final double width;
  final Color color;

  const TrefoilDivider({
    super.key,
    this.width = 140,
    this.color = const Color(0xFFD4A24A),
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, width * 0.12),
      painter: _TrefoilPainter(color: color),
    );
  }
}

class _TrefoilPainter extends CustomPainter {
  final Color color;
  _TrefoilPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6 * (size.width / 200);

    final sx = size.width / 200;
    final sy = size.height / 24;

    // Center trefoil
    final trefoil1 = Path()
      ..moveTo(100 * sx, 6 * sy)
      ..quadraticBezierTo(92 * sx, 12 * sy, 100 * sx, 18 * sy)
      ..quadraticBezierTo(108 * sx, 12 * sy, 100 * sx, 6 * sy);
    canvas.drawPath(trefoil1, paint);

    final trefoil2 = Path()
      ..moveTo(100 * sx, 6 * sy)
      ..quadraticBezierTo(108 * sx, 12 * sy, 100 * sx, 18 * sy)
      ..quadraticBezierTo(92 * sx, 12 * sy, 100 * sx, 6 * sy);
    canvas.drawPath(trefoil2, paint);

    // Left line
    canvas.drawLine(Offset(20 * sx, 12 * sy), Offset(86 * sx, 12 * sy), paint);
    // Right line
    canvas.drawLine(Offset(114 * sx, 12 * sy), Offset(180 * sx, 12 * sy), paint);
  }

  @override
  bool shouldRepaint(covariant _TrefoilPainter old) => old.color != color;
}
