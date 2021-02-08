import 'package:flutter/cupertino.dart';

enum WavePainterType { signal, spect }

class WavePainter extends CustomPainter {
  final List<double> array;
  final Color color;
  final WavePainterType type;

  WavePainter(this.array, this.color, [this.type = WavePainterType.signal]);

  @override
  void paint(Canvas canvas, Size size) {
    if (array.isNotEmpty) {
      final paint = Paint();
      paint.color = color;
      paint.strokeWidth = 2;

      final resizeX = size.width / array.length;
      double resizeY;
      if (type == WavePainterType.signal) {
        resizeY = size.height / 2;
      } else {
        resizeY = size.height;
      }

      var oldP = Offset(0 * resizeX, array[0] * resizeY + resizeY);
      for (var i = 1; i < array.length; i++) {
        Offset p;
        if (type == WavePainterType.signal) {
          p = Offset((i) * resizeX, array[i] * resizeY + resizeY);
        } else {
          p = Offset((i) * resizeX, resizeY - array[i] * resizeY);
        }
        canvas.drawLine(oldP, p, paint);
        oldP = p;
      }
    }
  }

  @override
  bool shouldRepaint(covariant WavePainter old) {
    return old.array != array || old.color != color;
  }
}
