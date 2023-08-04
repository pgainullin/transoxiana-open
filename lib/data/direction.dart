import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';

/// direction.dart on the hexagonal map
enum Direction {
  //indices should correspond to the painting_utils hexagonPath sides and unit sprite indices in order for these to work correctly
  northEast,
  southEast,
  south,
  southWest,
  northWest,
  north,
}

/// angle of a single hexagon side
const double _directionSegmentAngle = 2 * pi / 6;

/// takes a direction vector as an offset and returns the closest Direction enum
Direction offsetToDirection(final Vector2 vector) {
  /// angle to the unit vector pointing East
  double angle = vector.angleToSigned(Vector2(1.0, 0.0));

  // log('$offset is $angle');

  if (angle < 0.0) {
    angle = 2 * pi + angle;
  }

  if (angle <= _directionSegmentAngle) {
    return Direction.southWest;
  } else if (angle <= 2 * _directionSegmentAngle) {
    return Direction.south;
  } else if (angle <= 3 * _directionSegmentAngle) {
    return Direction.southEast;
  } else if (angle <= 4 * _directionSegmentAngle) {
    return Direction.northEast;
  } else if (angle <= 5 * _directionSegmentAngle) {
    return Direction.north;
  } else if (angle <= 6 * _directionSegmentAngle) {
    return Direction.northWest;
  } else {
    throw 'Invalid angle in offsetToDirection($vector) = $angle';
  }
}

/// takes a Direction enum and returns the mean direction vector as an offset
Offset directionToOffset(final Direction direction) {
  throw UnimplementedError();
}
