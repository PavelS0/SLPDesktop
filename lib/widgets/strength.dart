import 'package:flutter/cupertino.dart';

class StrengthPainter extends CustomPainter {
  final double strength;
  final Color color;

  StrengthPainter(this.strength, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    paint.color = color;
    paint.strokeWidth = 2;
    final top = size.height - size.height * strength;
    canvas.drawRect(Rect.fromLTRB(0, top, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant StrengthPainter old) {
    return old.strength != strength || old.color != color;
  }
}
