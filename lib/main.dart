import 'dart:math';

import 'package:angry_ball/static.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'engines.dart';

void main() {
  runApp(ProviderScope(
    child: MyApp(),
  ));
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
  late final DigitsAngle digitsAngle;
  late final BallEngine ballEngine = BallEngine(mass: 1); // 1 kg
  final ForceEngine engine = ForceEngine(linear: 0, quadratic: 0);
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
    digitsAngle = DigitsAngle();

    add(ball);
    await add(Ground(
        thickness: groundWidth, screen: size, ballRadius: ballRadius / 2));
    await add(vectorForce);
    await add(digitsAngle);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    startPosition = event.canvasPosition;
    vectorForce.visible = true;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    endPosition = event.canvasPosition;
    Vector2 vector = endPosition - startPosition;
    vectorForce.vector = vector.scaled(-0.2);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    Vector2 initSpeed = endPosition - startPosition;
    // initSpeed.scale(1 / 50);
    print(initSpeed.length);
    // initForce.scale(1 / initForce.length);
    ballEngine.speed = -initSpeed;
    vectorForce.visible = false;
  }

  @override
  Future<void> update(double dt) async {
    Vector2 force = engine.getForceQuadratic(ballEngine.speed, ballEngine.mass);
    ballEngine.speed +=
        force.scaled(1 / ballEngine.mass) * dt * 50; // todo: remove 50
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

class VectorForce extends PositionComponent with HasGameRef<MyGame> {
  bool visible = false;
  Vector2 vector = Vector2.zero();
  final double thickness;

  VectorForce({required this.thickness});

  @override
  void update(double dt) {
    position = gameRef.ball.position;
    super.update(dt);
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    if (visible) {
      const p1 = Offset(0.0, 0.0); // wtf
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

class DigitsAngle extends TextComponent with HasGameRef<MyGame> {
  bool visible = false;
  int visibleNumber = 15;
  TextPaint textPaint = TextPaint(
    style: TextStyle(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
    ),
  );

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  (bool, int) getPushAngle() {
    // Ox = true => positive projection of Push is positive
    int val =
        gameRef.vectorForce.vector.angleTo(Vector2(1, 0)) * 360 ~/ (2 * pi);
    bool Ox = val < 90;
    return (Ox, Ox ? val : 180 - val);
  }

  @override
  void update(double dt) {
    var (Ox, angleNumber) = getPushAngle();
    position = gameRef.ball.position +
        Vector2(0, -5) +
        Vector2(20, 0).scaled(Ox ? 1 : -1);
    visible = gameRef.vectorForce.visible &&
        gameRef.vectorForce.vector.length > visibleNumber;
    text = angleNumber.toString();
  }

  DigitsAngle() : super(anchor: Anchor.center);
}
