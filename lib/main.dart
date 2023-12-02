import 'dart:math';

import 'package:angry_ball/static.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame/text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'engines.dart';
import 'metrics.dart';

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
  late final BallEngine ballEngine = BallEngine(mass: WorldConfig.ballMass);
  final ForceEngine engine = ForceEngine(linear: 3, quadratic: 0);
  late Vector2 startPosition;
  late Vector2 endPosition;
  late LaunchSpeed launchSpeed;
  late ActualDistance actualDistance;
  late TheoreticalDistance theoreticalDistance;
  late FlightDistance flightDistance;

  Future<void> initObjects() async {
    const ballRadius = 5.0;
    const groundWidth = 5.0;
    const forceWidth = 1.0;
    ball = Ball(
        radius: ballRadius, position: Vector2(size.x * 0.05, size.y * 0.3));
    ball.defaultPosition = Vector2(size.x * 0.05, size.y * 0.3);
    ball.xMax = size.x;
    vectorForce = VectorForce(thickness: forceWidth);
    digitsAngle = DigitsAngle();
    launchSpeed = LaunchSpeed(position: Vector2(size.x * 0.1, size.y * 0.5));
    actualDistance =
        ActualDistance(position: Vector2(size.x * 0.1, size.y * 0.6));
    flightDistance =
        FlightDistance(position: Vector2(size.x * 0.1, size.y * 0.7));
    theoreticalDistance =
        TheoreticalDistance(position: Vector2(size.x * 0.1, size.y * 0.8));

    await add(Ground(
        thickness: groundWidth, screen: size, ballRadius: ballRadius / 2));
  }

  @override
  Future<void> onLoad() async {
    Flame.device.setPortrait();
    initObjects();

    add(ballEngine);
    add(ball);
    add(launchSpeed);
    add(actualDistance);
    add(flightDistance);
    add(theoreticalDistance);
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

    Vector2 initSpeed = (endPosition - startPosition)
        .scaled(1 / size.length)
        .scaled(WorldConfig.ballMaxSpeed);
    // we don't reverse y because endPosition.y > startPosition.y
    initSpeed.x = -initSpeed.x;
    launchSpeed.updateField(initSpeed.length);
    theoreticalDistance.predict(ballEngine.mass, initSpeed.x, initSpeed.y);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    actualDistance.startX = ballEngine.position.x;
    Vector2 initSpeed = (endPosition - startPosition)
        .scaled(1 / size.length)
        .scaled(WorldConfig.ballMaxSpeed);
    // we don't reverse y because endPosition.y > startPosition.y
    initSpeed.x = -initSpeed.x;
    ballEngine.speed = initSpeed;
    vectorForce.visible = false;
    flightDistance.landed = false;
    super.onDragEnd(event);
  }
}

class Ball extends CircleComponent with HasGameRef<MyGame> {
  late final Vector2 defaultPosition;
  late final double xMax;

  Ball({super.radius, super.position}) : super(anchor: Anchor.center);

  @override
  void update(double dt) {
    position = defaultPosition +
        Vector2(gameRef.ballEngine.position.x, -gameRef.ballEngine.position.y)
            .scaled(WorldConfig.groundScale);
    position.x %= xMax;
    super.update(dt);
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
  double currentAngle = 0;

  // if length of force is more than 15px, then show the angle
  int visibleNumber = 15;

  TextPaint textPaint = TextPaint(
    style: TextStyle(
      fontSize: 48.0,
      fontFamily: 'Awesome Font',
    ),
  );

  @override
  void render(Canvas canvas) {
    if (gameRef.vectorForce.visible &&
        gameRef.vectorForce.vector.length > visibleNumber) {
      super.render(canvas);
    }
  }

  bool setPushAngle() {
    // Ox = true => positive projection of Push is positive
    currentAngle = gameRef.vectorForce.vector.angleTo(Vector2(1, 0));
    int degrees = currentAngle * 360 ~/ (2 * pi);
    bool Ox = degrees < 90;
    if (!Ox) {
      degrees = 180 - degrees;
    }
    text = degrees.toString() + '°';
    return Ox;
  }

  @override
  void update(double dt) {
    bool Ox = setPushAngle();
    position = gameRef.ball.position +
        Vector2(0, -5) +
        Vector2(27, 0).scaled(Ox ? 1 : -1);
  }

  DigitsAngle() : super(anchor: Anchor.center);
}
