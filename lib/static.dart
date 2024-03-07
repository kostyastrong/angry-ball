import 'package:flame/components.dart';
import 'package:flutter/material.dart';

class WorldConfig {
  // to set centimeter, put 100.0, to set feet, put 0.3048 and etc
  static const double meter = 1.0;

  static const double stopMoving = 0.00003;

  // to have bigger impact on screen
  static const double groundScale = 140.0;

  // mass in kg
  static const double ballMass = 4.0;

  // max ball speed
  static const double ballMaxSpeed = 10 * meter;

  // elastic bounce of ball [0, 1], if 1, then no energy is spent and 0 is zero bounce
  static const double ballBounceCoefY = 0.7;

  // number of digits after a point
  static const int valuePrecision = 2;

  // friction
  static const double rollingFrictionCoef = 0.003;
}

class Ground extends PositionComponent {
  late final Vector2 screen;
  final double ballRadius;
  final double thickness; // thickness of line of ground itself

  Ground(
      {required this.thickness, required this.screen, required this.ballRadius})
      : super();

  @override
  void render(Canvas canvas) {
    final p1 = Offset(0, screen.y * 0.3 + thickness + ballRadius);
    final p2 = Offset(screen.x, screen.y * 0.3 + thickness + ballRadius);
    canvas.drawLine(
        p1,
        p2,
        Paint()
          ..color = Colors.greenAccent
          ..strokeWidth = thickness);
  }
}
