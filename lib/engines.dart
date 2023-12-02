import 'dart:math';

import 'package:angry_ball/static.dart';
import 'package:flame/components.dart';

import 'main.dart';

class BallEngine extends Component with HasGameRef<MyGame> {
  Vector2 speed = Vector2.zero();
  Vector2 position = Vector2.zero(); // position in real life
  final double mass;
  int k = 0;

  BallEngine({required this.mass});

  void clear() {
    speed = Vector2.zero();
    position = Vector2.zero();
  }

  void groundCollapse(
    Vector2 direction,
  ) {
    double coefX = -position.y / direction.y;
    position.y = 0;
    position.x = position.x + direction.x * coefX;
    speed.y = -speed.y * 0.6;
    speed.x =
        speed.x * (1 - gameRef.engine.g.length * WorldConfig.frictionCoef);
    gameRef.flightDistance.landed = true;
  }

  void movePosition(Vector2 vector) {
    bool valid = true;
    if (position.y + vector.y < 0) {
      groundCollapse(vector);
      valid = false;
    }
    if (valid) {
      position += vector;
    }
  }

  @override
  void update(double dt) {
    ForceEngine engine = gameRef.engine;
    Vector2 force = engine.getForceLinear(speed, mass);
    if (position.y > 0) {
      speed += force.scaled(1 / mass) * dt;
    }
    movePosition(speed.scaled(dt));
    super.update(dt);
  }
}

class ForceEngine {
  late final double linear;
  final double quadratic;
  final Vector2 g = Vector2(0, -9.81).scaled(WorldConfig.meter);

  ForceEngine({double linear = 0, this.quadratic = 0}) {
    if (linear <= 0) {
      this.linear = 0.00001;
    } else {
      this.linear = linear;
    }
  }

  Vector2 getForceQuadratic(Vector2 speed, double mass) {
    return g.scaled(mass) - speed.scaled(quadratic * speed.length);
  }

  Vector2 getForceLinear(Vector2 speed, double mass) {
    return g.scaled(mass) - speed.scaled(linear);
  }

  // y'(t) = (e^(-(βt)/m)*(gm + βu) - gm)/β, derivative of function of height from time
  // t is time, t >= 0
  // u is velocity at t = 0, u is start y speed
  // beta - linear coefficient
  // m - ball mass
  double linearDerivativeHeight(double t, double mass, double start_y_speed) {
    double beta = this.linear;
    double gravity = g.y.abs(); // gravity is negative in formula
    return (exp(-(beta * t) / mass) * (gravity * mass + beta * start_y_speed) -
            gravity * mass) /
        beta;
  }

  // y(t) = (m(g(m(-e^{(-(βt)/m)})+m-βt)+βu(1-e^{(-(βt)/m)})))/β^{2} - height from time
  double linearValueHeight(double t, double mass, double start_y_speed) {
    double beta = this.linear;
    double gravity = g.y.abs(); // gravity is negative in formula already
    return (mass *
            (gravity * (mass * (-exp(-(beta * t) / mass)) + mass - beta * t) +
                beta * start_y_speed * (1 - exp(-(beta * t) / mass)))) /
        (beta * beta);
  }

  // x(t)=(mu(1-e^(-(βt)/m)))/β, u is start x speed
  double linearValueLength(double t, double mass, double start_x_speed) {
    double beta = this.linear;
    return (mass * start_x_speed * (1 - exp(-(beta * t) / mass))) / beta;
  }

  // to calculateLength distance with non-zero
  double predictLinearValueLength(
      double mass, double start_x_speed, double start_y_speed) {
    // alpha in degrees

    if (mass < 0 || this.linear < 0) {
      return 0;
    }
    double l_bound = 0,
        r_bound = 10; // max_flight_seconds  todo: change to world config
    for (int i = 0; i < 50; ++i) {
      double time = l_bound + (r_bound - l_bound) / 2;
      double val = linearValueHeight(time, mass, start_y_speed);
      double der = linearDerivativeHeight(time, mass, start_y_speed);
      if (val < 0 && der < 0) {
        r_bound = time;
      } else {
        l_bound = time;
      }
    }
    return linearValueLength(l_bound, mass, start_x_speed);
  }
}
