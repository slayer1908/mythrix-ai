import 'package:flutter/animation.dart';

/// Motion tokens — durations and curves used consistently across the app.
class AppMotion {
  AppMotion._();

  // Durations
  static const Duration instant = Duration(milliseconds: 80);
  static const Duration fast = Duration(milliseconds: 160);
  static const Duration base = Duration(milliseconds: 240);
  static const Duration medium = Duration(milliseconds: 360);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration languid = Duration(milliseconds: 800);

  // Curves — engineered for the MYTHRIX feel: confident, springy, never bouncy.
  static const Curve standard = Cubic(0.2, 0.0, 0.0, 1.0); // material-emphasized
  static const Curve emphasized = Cubic(0.05, 0.7, 0.1, 1.0);
  static const Curve entrance = Cubic(0.0, 0.0, 0.2, 1.0);
  static const Curve exit = Cubic(0.4, 0.0, 1.0, 1.0);
  static const Curve spring = Cubic(0.34, 1.56, 0.64, 1.0); // gentle overshoot
}
