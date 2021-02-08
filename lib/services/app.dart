import 'dart:math';
import 'package:slp_desktop/model/app.dart';

class AppService {
  AppData getSources(double step) {
    final source = <double>[];
    var rad = 0.0;
    for (var x = 0; x < 100; x++) {
      rad += step;
      source.add(sin(rad));
    }
    return AppData(
        name: 'аааа а я апп дата',
        signal: source,
        ch1: sin(step * 5).abs(),
        ch2: sin(step * 6).abs(),
        ch3: sin(step * 7).abs());
  }
}
