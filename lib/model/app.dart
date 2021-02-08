class AppData {
  final String name;
  final List<double> signal;
  final List<double> spect;
  final double ch1;
  final double ch2;
  final double ch3;

  AppData(
      {this.name = '',
      this.signal = const [],
      this.spect = const [],
      this.ch1 = 0,
      this.ch2 = 0,
      this.ch3 = 0});
}
