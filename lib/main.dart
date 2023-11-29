import 'package:angry_ball/static.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'engines.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: PopScope(
        canPop: false,
        child: GameWidget(game: MyGame()),
      ),
    );
  }
}

class MyGame extends FlameGame with DragCallbacks {
  late final Ball ball;
  late final VectorForce vectorForce;
  late final BallEngine ballEngine = BallEngine(mass: 1);
  final ForceEngine engine = ForceEngine(linear: 0, quadratic: 0); // 1 kg
  late Vector2 startPosition;
  late Vector2 endPosition;

  @override
  Future<void> onLoad() async {
    const ballRadius = 5.0;
    const groundWidth = 5.0;
    const forceWidth = 1.0;
    ball = Ball(
        radius: ballRadius, position: Vector2(size.x * 0.05, size.y * 0.3));
    ball.defaultPosition = Vector2(size.x * 0.05, size.y * 0.3);
    ball.xMax = size.x;
    vectorForce = VectorForce(thickness: forceWidth);

    await add(vectorForce);
    add(ball);
    await add(Ground(
        thickness: groundWidth, screen: size, ballRadius: ballRadius / 2));
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    startPosition = event.canvasPosition;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    endPosition = event.canvasPosition;
    Vector2 vector = endPosition - startPosition;
    vectorForce.vector = vector.scaled(-0.2);
    vectorForce.position = ball.position;
    vectorForce.visible = true;
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    Vector2 initForce = endPosition - startPosition;
    // initForce.scale(1 / initForce.length);
    ballEngine.speed = -initForce;
    vectorForce.visible = false;
  }

  @override
  Future<void> update(double dt) async {
    Vector2 force = engine.getForceQuadratic(ballEngine.speed, ballEngine.mass);
    ballEngine.speed += force.scaled(1 / ballEngine.mass) * dt * 50;
    ball.move(ballEngine.speed.scaled(dt));
    super.update(dt);
  }
}

class Ball extends CircleComponent {
  late final Vector2 defaultPosition;
  late final double xMax;

  Ball({super.radius, super.position}) : super(anchor: Anchor.center);

  void move(Vector2 vector) {
    bool valid = true;
    if (position.y + vector.y >= defaultPosition.y) {
      position.y = defaultPosition.y;
      valid = false;
    }
    if (valid) {
      position += vector;
      position.x %= xMax;
    }
  }

  void restart() {
    position = Vector2(size.x * 0.05, size.y * 0.3);
  }
}

class VectorForce extends PositionComponent {
  bool visible = false;
  late Vector2 vector;
  final thickness;

  VectorForce({required this.thickness});

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (visible) {
      print("${position.x}");
      final p1 = Offset(0.0, 0.0); // wtf
      final p2 = p1 + Offset(vector.x, vector.y);
      canvas.drawLine(
          p1,
          p2,
          Paint()
            ..color = Colors.greenAccent
            ..strokeWidth = thickness);
    } // If not visible none of the children will be rendered
  }
}
