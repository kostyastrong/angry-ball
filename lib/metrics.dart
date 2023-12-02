import 'dart:ui';

import 'package:angry_ball/static.dart';
import 'package:flame/components.dart';

import 'main.dart';

class PhysicalQuantity extends TextComponent {
  double storedValue = 0;

  PhysicalQuantity({required super.position})
      : super(anchor: Anchor.centerLeft) {
    updateField(0);
  }

  String getTextWithValue(double value) {
    throw ArgumentError("method is not implemented", "TextValue");
  }

  void updateField(double value, {bool remember = false}) {
    text = getTextWithValue(value);
  }
}

class LaunchSpeed extends PhysicalQuantity {
  LaunchSpeed({required super.position});

  @override
  String getTextWithValue(double value) {
    return "Launch speed: ${value.toStringAsFixed(WorldConfig.valuePrecision)} m/s";
  }
}

class ActualDistance extends PhysicalQuantity with HasGameRef<MyGame> {
  ActualDistance({required super.position});

  double startX = 0;

  @override
  void update(double dt) {
    super.updateField((gameRef.ballEngine.position.x - startX).abs());
    super.update(dt);
  }

  @override
  String getTextWithValue(double value) {
    return "Absolute distance: ${value.toStringAsFixed(WorldConfig.valuePrecision)} meters";
  }
}

class FlightDistance extends PhysicalQuantity with HasGameRef<MyGame> {
  FlightDistance({required super.position});

  bool landed = false;

  @override
  void update(double dt) {
    if (!landed) {
      super.updateField(
          (gameRef.ballEngine.position.x - gameRef.actualDistance.startX));
      super.update(dt);
    }
  }

  @override
  String getTextWithValue(double value) {
    return "Flight distance: ${value.toStringAsFixed(WorldConfig.valuePrecision)} meters";
  }
}

class TheoreticalDistance extends PhysicalQuantity with HasGameRef<MyGame> {
  bool visible = true;

  TheoreticalDistance({required super.position});

  void predict(mass, start_speed, alpha) {
    super.updateField(
        gameRef.engine.predictLinearValueLength(mass, start_speed, alpha));
  }

  @override
  void render(Canvas canvas) {
    if (visible) {
      super.render(canvas);
    }
  }

  @override
  String getTextWithValue(double value) {
    return "Flight theoretical distance:\n ${value.toStringAsFixed(WorldConfig.valuePrecision)} meters";
  }
}
