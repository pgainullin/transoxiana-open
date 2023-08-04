import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

Vector2 ellipsePointFromRect(final Rect rect, final double percentage) {
  assert(percentage <= 1.0);
  assert(percentage >= -1.0);

  double x;
  double y;

  //simplifying assumption: percentage refers to x-axis length, not arc length %: falls down for rect width = zero
  x = rect.center.dx + percentage * rect.width / 2;

  y =
      -(rect.height / 2) * //-1 is to reflect that the y-coordinate run top down
              pow(1 - (pow(percentage, 2)), 0.5) +
          rect.center.dy;

  if (!rect.isEmpty) {
    assert(
      ((pow(x - rect.center.dx, 2.0) / pow(rect.width / 2.0, 2.0)) +
                  (pow(y - rect.center.dy, 2.0) / pow(rect.height / 2.0, 2.0)))
              .toStringAsFixed(6) ==
          '1.000000',
      ((pow(x - rect.center.dx, 2.0) / pow(rect.width / 2.0, 2.0)) +
              (pow(y - rect.center.dy, 2.0) / pow(rect.height / 2.0, 2.0)))
          .toString(),
    );
  }
  assert((percentage < 0.0 && x < rect.center.dx) ||
      (percentage >= 0.0 && x >= rect.center.dx),);

  return Vector2(x, y);
}

/// calculate coordinates of a point on an ellipse that fits within a given rect, defined by a given angle in radians starting from the East
Vector2 ellipsePointFromAngle(final Rect rect, final double angle) {
  double x;
  double y;

  x = rect.center.dx + (rect.width / 2.0) * cos(angle);
  y = rect.center.dy + (rect.height / 2.0) * sin(angle);

  //TODO: track down why this assert sometimes fails
  if (!rect.isEmpty) {
    assert(
      ((pow(x - rect.center.dx, 2.0) / pow(rect.width / 2.0, 2.0)) +
                  (pow(y - rect.center.dy, 2.0) / pow(rect.height / 2.0, 2.0)))
              .toStringAsFixed(6) ==
          '1.000000',
      ((pow(x - rect.center.dx, 2.0) / pow(rect.width / 2.0, 2.0)) +
              (pow(y - rect.center.dy, 2.0) / pow(rect.height / 2.0, 2.0)))
          .toString(),
    );
  }

  return Vector2(x, y);
}

Vector2 pointFromSegment(
  final Vector2 p1,
  final Vector2 p2,
  final double percentage,
) {
  assert(p1 != p2);

  if (p1.x == p2.x) {
    return p1;
  } else {
    final double a = (p1.y - p2.y) / (p1.x - p2.x);
    final double b = p2.y - p2.x * a;

    final double x = p1.x + (p2.x - p1.x) * percentage;
    return Vector2(x, a * x + b);
  }
}

Vector2 rotate90(final Vector2 vector) {
  return Vector2(vector.y, -vector.x);
}

/// returns another offset which has the same angle but a magnitude of 1
Vector2 normalized(final Vector2 vector) {
  final double magnitude = vector.length;
  return Vector2(vector.x / magnitude, vector.y / magnitude);
}

//https://en.wikipedia.org/wiki/Smoothstep#Variations
double smoothStep(final double edge0, final double edge1, final double x) {
  // Scale, and clamp x to 0..1 range
  final double newX = clamp((x - edge0) / (edge1 - edge0), 0.0, 1.0);

  return edge0 +
      (edge1 - edge0) * newX * newX * newX * (newX * (newX * 6 - 15) + 10);
}

double clamp(final double x, final double lowerlimit, final double upperlimit) {
  if (x < lowerlimit) return lowerlimit;
  if (x > upperlimit) return upperlimit;
  return x;
}
