// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:angry_ball/engines.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("physics engine", () {
    test('length value', () {
      final ForceEngine engine = ForceEngine(linear: 1, quadratic: 0);
      expect(
          engine.predictLinearValueLength(1, 6.5, 6.5), inInclusiveRange(4, 5));
    });
  });
}
