import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/services/geometry.dart';

final Paints paints = Paints();

class Paints {
  Paints() {
    healthBarPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.green;

    debugPainter
      ..color = const Color(0xFF942811)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    projectilePaint
      ..color = Colors.black45
      ..strokeWidth = 3.0;

    fortHealthPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..color = Colors.purple;
  }
  final Paint healthBarPaint = Paint();
  final Paint debugPainter = Paint();
  final Paint projectilePaint = Paint();
  final Paint fortHealthPaint = Paint();

  static Paint opacityPaint(final double opacity) {
    return Paint()..color = Colors.red.withOpacity(opacity);
  }

  static Paint selectionPaint(final Paint regularPaint) {
    return Paint()
      ..color = regularPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;
  }
}

void drawPolygon(
    final Canvas canvas, final List<Vector2> points, final Paint paint,) {
  final Path path = Path()
    ..addPolygon(points.map((final e) => Offset(e.x, e.y)).toList(), true);
  canvas.drawPath(path, paint,);
}

const int sidesOfHexagon = 6;

Path hexagonPath(final double radius, final Vector2 center) {
  final path = Path();
  const angle = (math.pi * 2) / sidesOfHexagon;
  final Vector2 firstPoint =
      Vector2(radius * math.cos(0.0), radius * math.sin(0.0));
  path.moveTo(firstPoint.x + center.x, firstPoint.y + center.y);
  for (int i = 1; i <= sidesOfHexagon; i++) {
    final double x = radius * math.cos(angle * i) + center.x;
    final double y = radius * math.sin(angle * i) + center.y;
    path.lineTo(x, y);
  }
  path.close();
  return path;
}

void drawHexagon(final Canvas canvas, final double radius, final Vector2 center,
    final Paint paint,) {
  drawPath(canvas, hexagonPath(radius, center), paint,);
}

/// for hexes indicating where the preceding hex to this one is located
void drawFromDirectionPointer(
  final Canvas canvas,
  final double radius,
  final Vector2 center,
  final int directionIndex,
  final Paint paint,
) {
  //directionIndex refers to the index of the hexagon side

  //shift to account for Direction defined starting from the NorthEast
  final adjustedDirectionIndex = directionIndex + 2;

  const angle = (math.pi * 2) / sidesOfHexagon;
  final Vector2 firstPoint = Vector2(
    radius * math.cos(angle * adjustedDirectionIndex),
    radius * math.sin(angle * adjustedDirectionIndex),
  );
  final Vector2 endPoint = Vector2(
    radius * math.cos(angle * (adjustedDirectionIndex + 1)),
    radius * math.sin(angle * (adjustedDirectionIndex + 1)),
  );
  final Vector2 sideStep = (endPoint - firstPoint) * 0.1;
  final Vector2 midPoint = firstPoint + sideStep * 5;
  final Vector2 arrowPoint = rotate90(endPoint - firstPoint) * 0.25;
  final Vector2 padding = arrowPoint * 0.5;

  drawSegments(
    canvas,
    [
      firstPoint + center + arrowPoint + sideStep + padding,
      midPoint + center + padding,
      endPoint + center + arrowPoint - sideStep + padding
    ],
    paint,
  );
}

void drawSegments(
    final Canvas canvas, final List<Vector2> points, final Paint paint,) {
  final Path path = Path()
  ..addPolygon(points.map((final e) => Offset(e.x, e.y)).toList(), false);
  canvas.drawPath(path, paint);
}

void drawPath(final Canvas canvas, final Path path, final Paint paint) {
  canvas.drawPath(path, paint);
}

class HexagonPainter extends CustomPainter {
  HexagonPainter(this.center, this.radius, {final Paint? painter}) {
    _painter = painter ?? _defaultPaint;
  }
  final double radius;
  final Vector2 center;
  late final Paint _painter;

  final Paint _defaultPaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.blue;

  @override
  void paint(final Canvas canvas, final Size size) {
    final Path path = createHexagonPath();
    canvas.drawPath(path, _painter);
  }

  Path createHexagonPath() => hexagonPath(radius, center);

  @override
  bool shouldRepaint(final CustomPainter oldDelegate) => false;
}

class RadiantGradientMask extends StatelessWidget {
  const RadiantGradientMask({
    required this.child,
    this.startColor = Colors.red,
    this.endColor = Colors.blue,
    this.radius = 1.0,
    final Key? key,
  }) : super(key: key);
  final Color startColor;
  final Color endColor;
  final double radius;
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return ShaderMask(
      shaderCallback: (final bounds) => RadialGradient(
        // center: Alignment.center,
        radius: radius,
        colors: [startColor, endColor],
        tileMode: TileMode.mirror,
      ).createShader(bounds),
      child: child,
    );
  }
}
