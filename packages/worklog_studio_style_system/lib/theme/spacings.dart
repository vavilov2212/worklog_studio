class Spacings {
  /// Size: none
  final double s0 = 0;

  /// Size: xs
  final double s2 = 2;

  /// Size: xxs
  final double s4 = 4;

  /// Size: s
  final double s8 = 8;

  /// Size: m
  final double s12 = 12;

  /// Size: l
  final double s16 = 16;

  /// Size: xl
  final double s24 = 24;

  /// Size: xxl
  final double s32 = 32;

  /// Size: xxxl
  final double s40 = 40;

  /// Size: xxxxl
  final double s48 = 48;

  /// Size: xxxxxl
  final double s64 = 64;

  /// Size: xxxxxxl
  final double s80 = 80;

  static const Spacings _instance = Spacings._();
  factory Spacings() => _instance;
  const Spacings._();
}
