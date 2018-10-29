import 'dart:math';

import 'package:flutter/material.dart';

import 'plane_angle_radians.dart';

const double TO_RADIANS = 2.0 * pi;

double convertRadiusToSigma(double radius) {
  return radius * 0.57735 + 0.5;
}

class Thermostat extends StatefulWidget {
  final double radius;
  final Color glowColor;
  final Color tickColor;
  final Color thumbColor;
  final Color dividerColor;
  final Color turnOnColor;
  final bool turnOn;
  final Widget modeIcon;
  final int minValue;
  final int maxValue;
  final int initialValue;
  final ValueChanged<int> onValueChanged;
  final TextStyle textStyle;

  const Thermostat({
    Key key,
    this.radius,
    this.glowColor = const Color(0xFF3F5BFA),
    this.tickColor = const Color(0xFFD5D9F0),
    this.thumbColor = const Color(0xFFF3F4FA),
    this.dividerColor = const Color(0xFF3F5BFA),
    this.turnOnColor = const Color(0xFF66f475),
    @required this.turnOn,
    @required this.modeIcon,
    @required this.minValue,
    @required this.maxValue,
    @required this.initialValue,
    this.onValueChanged,
    this.textStyle,
  }) : super(key: key);

  @override
  _ThermostatState createState() => _ThermostatState();
}

class _ThermostatState extends State<Thermostat>
    with SingleTickerProviderStateMixin {
  static const double MIN_RING_RAD = 4.538;
  static const double MID_RING_RAD = 4.7123889803847;
  static const double MAX_RING_RAD = 4.895;
  static const double DEG_90_TO_RAD = 1.5708;

  AnimationController _glowController;

  double _angle;
  int _value;

  @override
  void initState() {
    _value = widget.initialValue;
    if (widget.initialValue == widget.minValue) {
      _angle = MAX_RING_RAD;
    } else if (widget.initialValue == widget.maxValue) {
      _angle = MIN_RING_RAD;
    } else {
      final normalizedInitialValue = (widget.initialValue - widget.minValue) /
          (widget.maxValue - widget.minValue);
      final initialAngle = TO_RADIANS * normalizedInitialValue - DEG_90_TO_RAD;
      final normalizedAngle = normalizeBetweenZeroAndTwoPi(initialAngle);
      _angle = _clampAngleValue(normalizedAngle);
    }

    _glowController =
        AnimationController(duration: Duration(milliseconds: 300), vsync: this);
    _glowController.addListener(_handleChange);

    super.initState();
  }

  @override
  void dispose() {
    _glowController.removeListener(_handleChange);
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double width = widget.radius * 2.0;
    final double halfWidth = widget.radius;
    final size = new Size(width, width);
    return new GestureDetector(
      onPanStart: _onPanStart,
      onPanUpdate: _onPanUpdate,
      onPanEnd: _onPanEnd,
      child: new Container(
        width: width,
        height: width,
        child: new Stack(
          children: <Widget>[
            new Positioned(
              top: halfWidth - 16.0,
              left: halfWidth - 62.0,
              width: 32.0,
              height: 32.0,
              child: widget.modeIcon,
            ),
            new Positioned(
              top: halfWidth - 4.0,
              right: halfWidth - 55.0,
              child: new Container(
                width: 8.0,
                height: 8.0,
                decoration: widget.turnOn
                    ? new BoxDecoration(
                        color: widget.turnOnColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          new BoxShadow(
                            color: widget.turnOnColor,
                            blurRadius: 4.0,
                            offset: const Offset(0.0, 3.0),
                          )
                        ],
                      )
                    : null,
              ),
            ),
            new Center(
              child: new Text(
                '$_value',
                style: widget.textStyle ?? Theme.of(context).textTheme.display1,
              ),
            ),
            new CustomPaint(
              size: size,
              painter: new RingPainter(
                dividerColor: widget.dividerColor,
                glowColor: widget.glowColor,
                glowness: _glowController.value,
              ),
            ),
            new CustomPaint(
              size: size,
              painter: new TickThumbPainter(
                tickColor: widget.tickColor,
                thumbColor: widget.thumbColor,
                scoop: _glowController.value,
                angle: _angle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  ///
  void _handleChange() {
    setState(() {
      // The listenable's state is our build state, and it changed already.
    });
  }

  ///
  void _onPanStart(DragStartDetails details) {
    // final polarCoord = _polarCoordFromGlobalOffset(details.globalPosition);
    _glowRing();
  }

  ///
  void _onPanUpdate(DragUpdateDetails details) {
    final polarCoord = _polarCoordFromGlobalOffset(details.globalPosition);
    final angle = normalizeBetweenZeroAndTwoPi(polarCoord.angle);
    final double clampedAngle = _clampAngleValue(angle);

    if (clampedAngle != _angle) {
      setState(() {
        _angle = clampedAngle;
        final normalizedValue =
            (normalizeBetweenZeroAndTwoPi(clampedAngle + DEG_90_TO_RAD) /
                TO_RADIANS);
        final value = ((widget.maxValue - widget.minValue) * normalizedValue) +
            widget.minValue;

        final val = value.round();
        if (val != _value) {
          _value = val;
        }
      });
    }
  }

  ///
  void _onPanEnd(DragEndDetails details) {
    _dimRing();
    if (widget.onValueChanged != null) {
      widget.onValueChanged(_value);
    }
  }

  ///
  void _glowRing() {
    _glowController.forward();
  }

  ///
  void _dimRing() {
    _glowController.reverse();
  }

  ///
  double _clampAngleValue(double angle) {
    double clampedAngle = angle;
    if (angle > MIN_RING_RAD && angle < MID_RING_RAD) {
      clampedAngle = MIN_RING_RAD;
    } else if (angle >= MID_RING_RAD && angle < MAX_RING_RAD) {
      clampedAngle = MAX_RING_RAD;
    }
    return clampedAngle;
  }

  ///
  PolarCoord _polarCoordFromGlobalOffset(globalOffset) {
    // Convert the user's global touch offset to an offset that is local to
    // this Widget.
    final localTouchOffset =
        (context.findRenderObject() as RenderBox).globalToLocal(globalOffset);

    // Convert the local offset to a Point so that we can do math with it.
    final localTouchPoint = new Point(localTouchOffset.dx, localTouchOffset.dy);

    // Create a Point at the center of this Widget to act as the origin.
    final originPoint =
        new Point(context.size.width / 2, context.size.height / 2);

    return new PolarCoord.fromPoints(originPoint, localTouchPoint);
  }
}

///
///
///
class RingPainter extends CustomPainter {
  final Color dividerColor;
  final Color glowColor;
  final double glowness;

  RingPainter({
    @required this.dividerColor,
    @required this.glowColor,
    @required this.glowness,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Rect rect = Offset.zero & size;
    final double center = size.width / 2.0;
    final Offset centerOffset = new Offset(center, center);
    final double outerRingRadius = (size.width / 2.0) - 30.0;
    final double innerRingRadius = outerRingRadius - 32.0;

    final dividerGlowPaint = Paint()
      ..color = dividerColor
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        convertRadiusToSigma(4.0),
      );

    final dividerPaint = Paint()..color = dividerColor;

    final outerGlowPaint = Paint()
      ..color = glowColor
      ..maskFilter = MaskFilter.blur(
        BlurStyle.outer,
        convertRadiusToSigma(18.0 + (5.0 * glowness)),
      );

    final gradient = new RadialGradient(
      colors: <Color>[
        glowColor.withOpacity(0.0),
        glowColor.withOpacity(0.5),
      ],
      stops: [
        0.8 - (0.13 * glowness),
        1.0,
      ],
    );

    final Rect gradientRect =
        new Rect.fromCircle(center: centerOffset, radius: innerRingRadius);

    final Paint paint = new Paint()
      ..shader = gradient.createShader(gradientRect);

    canvas.saveLayer(rect, new Paint());
    canvas.drawCircle(centerOffset, outerRingRadius, outerGlowPaint);
    canvas.drawCircle(centerOffset, innerRingRadius, paint);

    //
    canvas.translate(center, center);
    final dividerRect = Rect.fromLTWH(
        -2.0, -outerRingRadius, 4.0, outerRingRadius - innerRingRadius);
    canvas.drawRect(dividerRect, dividerPaint);
    canvas.drawRect(dividerRect, dividerGlowPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(RingPainter oldDelegate) {
    return oldDelegate.glowColor != glowColor ||
        oldDelegate.glowness != glowness ||
        oldDelegate.dividerColor != dividerColor;
  }
}

///
///
///
class TickThumbPainter extends CustomPainter {
  final Color tickColor;
  final Color thumbColor;
  final double scoop;
  final double angle;

  static const int tickCount = 180;

  TickThumbPainter({
    @required this.tickColor,
    @required this.thumbColor,
    @required this.scoop,
    @required this.angle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final double center = size.width / 2.0;
    final double outerRingRadius = (size.width / 2.0) - 30.0;
    final Offset centerOffset = new Offset(center, center);
    final double innerRingRadius =
        outerRingRadius - 32.0 + 15.0; //15 is thumb radius

    final double dx = innerRingRadius * cos(angle) + center;
    final double dy = innerRingRadius * sin(angle) + center;

    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = tickColor.withOpacity(0.3)
      ..strokeWidth = 1.5;

    canvas.save();
    canvas.translate(center, center);

    final radians = TO_RADIANS / tickCount;
    double tRadians = 0.0;
    final curve = Curves.easeOut;
    for (int i = 0; i < tickCount; i++) {
      double lomber = 0.0;
      final diff = acos(cos(angle - tRadians));
      if (diff <= 0.3) {
        lomber =
            curve.transform((1 - (diff / 0.3))) * (15.0 * scoop); // working
      }

      canvas.drawLine(
        new Offset(outerRingRadius + 0.5, 0.0),
        new Offset(outerRingRadius + 15.0 + lomber, 0.0),
        tickPaint,
      );

      tRadians += radians;
      canvas.rotate(radians);
    }
    canvas.restore();

    final thumbPaint = Paint()
      ..color = thumbColor.withOpacity(0.7 + (0.3 * scoop));

    canvas.drawCircle(new Offset(dx, dy), 14.0, thumbPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}

///
///
///
class PolarCoord {
  final double angle;
  final double radius;

  factory PolarCoord.fromPoints(Point origin, Point point) {
    // Subtract the origin from the point to get the vector from the origin
    // to the point.
    final vectorPoint = point - origin;
    final vector = new Offset(vectorPoint.x, vectorPoint.y);

    // The polar coordinate is the angle the vector forms with the x-axis, and
    // the distance of the vector.
    return new PolarCoord(
      vector.direction,
      vector.distance,
    );
  }

  PolarCoord(this.angle, this.radius);

  @override
  toString() {
    return 'Polar Coord: ${radius.toStringAsFixed(2)}' +
        ' at ${(angle / TO_RADIANS * 360).toStringAsFixed(2)}°';
  }
}
