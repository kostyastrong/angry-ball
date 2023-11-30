import 'package:flame/components.dart';
import 'package:flutter/material.dart';

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
