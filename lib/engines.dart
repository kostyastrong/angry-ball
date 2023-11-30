import 'package:flame/components.dart';

class BallEngine extends Component {
  Vector2 speed = Vector2.zero();
  Vector2 position = Vector2.zero(); // position in real life
  final double mass;

  BallEngine({required this.mass});

  void clear() {
    speed = Vector2.zero();
    position = Vector2.zero();
  }

  void movePosition(double time) {
    position += speed.scaled(time);
  }
}

class ForceEngine {
  final double linear;
  final double quadratic;
  late final Vector2 g = Vector2(0, 9.81);

  ForceEngine({required this.linear, required this.quadratic});

  Vector2 getForceQuadratic(Vector2 speed, double mass) {
    return g.scaled(mass) - speed.scaled(quadratic * speed.length);
  }

  Vector2 getForceLinear(Vector2 speed, double mass) {
    return g.scaled(mass) - speed.scaled(linear);
  }
}
