import 'dart:math';

class PlaneAngle {
  /// Zero.
  static const PlaneAngle ZERO = const PlaneAngle._(0.0);

  /// Half-turn (aka &pi; radians).
  static const PlaneAngle PI = const PlaneAngle._(0.5);

  /// Conversion factor.
  static const double HALF_TURN = 0.5;

  /// Conversion factor.
  static const double TO_RADIANS = 2.0 * pi;

  /// Conversion factor.
  static const double FROM_RADIANS = 1.0 / TO_RADIANS;

  /// Conversion factor.
  static const double TO_DEGREES = 360.0;

  /// Conversion factor.
  static const double FROM_DEGREES = 1.0 / TO_DEGREES;

  /// Value (in turns).
  final double _value;

  const PlaneAngle._(double value) : _value = value;

  const PlaneAngle.ofTurns(double angle) : _value = angle;

  const PlaneAngle.ofRadians(double angle) : _value = angle * FROM_RADIANS;

  const PlaneAngle.ofDegrees(double angle) : _value = angle * FROM_DEGREES;

  double get turns => _value;

  double get radians => _value * TO_RADIANS;

  double get degrees => _value * TO_DEGREES;

  PlaneAngle normalize(PlaneAngle center) {
    return new PlaneAngle._(
        _value - (_value + HALF_TURN - center._value).floor());
  }
}

double normalize(double angle, double center) {
  final PlaneAngle a = PlaneAngle.ofRadians(angle);
  final PlaneAngle c = PlaneAngle.ofRadians(center);
  return a.normalize(c).radians;
}

double normalizeBetweenMinusPiAndPi(double angle) {
  return PlaneAngle.ofRadians(angle).normalize(PlaneAngle.ZERO).radians;
}

double normalizeBetweenZeroAndTwoPi(double angle) {
  return PlaneAngle.ofRadians(angle).normalize(PlaneAngle.PI).radians;
}
