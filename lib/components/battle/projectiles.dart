import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/services/audio/sfx.dart';
import 'package:transoxiana/services/geometry.dart';
import 'package:transoxiana/services/painting_utils.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

/// component whose position moves in an arc from shooterNode to targetNode for flightTime seconds and then shows hitAnimation for hitTime seconds
class Projectile extends PositionComponent implements GameRef {
  Projectile(
    this.game,
    this.shooterNode,
    this.targetNode, {
    required this.onRemoveCallback,
    this.hitCallback,
    this.flightTime = 0.6,
    this.hitTime = 0.3,
    this.animationSizeFactor = 1.0,
  }) : super(priority: ComponentsRenderPriority.battleLancesAndShoots.value) {
    final newPosition =
        game.activeBattle?.tileData[shooterNode.terrainTile]?.center;
    if (newPosition != null) {
      position = newPosition;
    }

    onStart();
  }
  @override
  TransoxianaGame game;
  double _lifeInSeconds = 0.0;
  final Node shooterNode;
  final Node targetNode;
  final ValueChanged<Projectile> onRemoveCallback;
  bool isDestroyed = false;

  bool _hitAchieved = false;

  // late Offset position;

  /// segment length or circle radius after scaling
  // late double size;

  /// the hit animation is larger than general component size by this factor
  double animationSizeFactor;

  late Rect arcRect;
  late double startAngle;
  late double endAngle;

  SpriteAnimationComponent? hitAnimation;

  /// the time in seconds that it takes for this projectile to land on the targetNode
  final double flightTime;

  /// time in seconds that it takes to play out the hit animation
  final double hitTime;

  /// callback that is triggered once, upon flightTime ending
  final VoidCallback? hitCallback;
  static const squareSize = UiSizes.tileSize / 5;
  bool get renderAllowed => !game.isHeadless && !game.activeBattle!.isAiBattle;

  @override
  void update(final double dt) {
    super.update(dt);
    if (game.temporaryCampaignData.isPaused) return;

    _lifeInSeconds += dt;
    width = squareSize;
    height = squareSize;
    if (_lifeInSeconds >= flightTime + hitTime) {
      if (_hitAchieved == false) {
        onHit();
      }
      //finished
      isDestroyed = true;
    } else if (_lifeInSeconds < flightTime) {
      //flight time
      if (renderAllowed) {
        final progress = max(0.0, min(1.0, _lifeInSeconds / flightTime));
        updatePosition(progress);
      }
    } else {
      if (_hitAchieved == false) {
        //the moment the hit occurs
        if (renderAllowed) {
          hitAnimation?.setByRect(
            Rect.fromLTWH(
              position.x - width,
              position.y - height,
              width * animationSizeFactor,
              height * animationSizeFactor,
            ),
          );
        }

        onHit();
      }

      if (!renderAllowed) return;

      //hit time
      if (hitAnimation != null) {
        // if(hitAnimation!.x == 0.0){
        //position is shifted by size which is assumed to be the radius of the projectile before explosion because the projectile is *centered* on the target center
        // }
        hitAnimation?.update(dt);
      }
    }
  }

  @mustCallSuper
  void onStart() {
    if (!renderAllowed) return;
    width = squareSize;
    height = squareSize;

    updateArcRect();
    updateAngles();
  }

  @mustCallSuper
  void onHit() {
    if (hitCallback != null) {
      hitCallback!.call();
    }
    _hitAchieved = true;
    onRemoveCallback(this);
  }

  void updateAngles() {
    final Vector2? shooterOffset =
        game.activeBattle?.tileData[shooterNode.terrainTile]!.center;
    final Vector2? targetOffset =
        game.activeBattle?.tileData[targetNode.terrainTile]!.center;

    if (shooterNode.x == targetNode.x) {
      //left half of the arcRect
      if (shooterNode.y > targetNode.y) {
        //shooting up

        startAngle = pi / 2;
        endAngle = 3 * pi / 2;
      } else {
        //shooting down

        startAngle = 3 * pi / 2;
        endAngle = pi / 2;
      }
    } else {
      final shooterOffsetDy = shooterOffset?.y;
      if (shooterOffsetDy == null) {
        throw ArgumentError.notNull('shooterOffsetDy');
      }
      final targetOffsetDy = targetOffset?.y;
      if (targetOffsetDy == null) {
        throw ArgumentError.notNull('targetOffsetDy');
      }
      if (shooterNode.x < targetNode.x) {
        //shooting right

        if (shooterOffsetDy > targetOffsetDy) {
          //shooting up

          startAngle = pi;
          endAngle = 3 * pi / 2;
        } else if (shooterOffsetDy < targetOffsetDy) {
          //shooting down

          startAngle = 3 * pi / 2;
          endAngle = 2 * pi;
        } else {
          //arc starts and ends at the same height
          startAngle = pi;
          endAngle = 2 * pi;
        }
      } else {
        //shooting left

        if (shooterOffsetDy > targetOffsetDy) {
          //shooting up

          startAngle = 2 * pi;
          endAngle = 3 * pi / 2;
        } else if (shooterOffsetDy < targetOffsetDy) {
          //shooting down

          startAngle = 3 * pi / 2;
          endAngle = pi;
        } else {
          //arc starts and ends at the same height
          startAngle = 2 * pi;
          endAngle = pi;
        }
      }
    }
  }

  void updateArcRect() {
    final Vector2? shooterPosition =
        game.activeBattle?.tileData[shooterNode.terrainTile]?.center;
    final Vector2? targetPosition =
        game.activeBattle?.tileData[targetNode.terrainTile]?.center;
    if (shooterPosition == null || targetPosition == null) {
      throw ArgumentError.notNull(
        'shooterPosition: $shooterPosition '
        'targetPosition: $targetPosition',
      );
    }
    final double yDistance = (shooterPosition.y - targetPosition.y).abs();
    final double xDistance = (shooterPosition.x - targetPosition.x).abs();

    if (shooterNode.x == targetNode.x) {
      arcRect = Rect.fromLTRB(
        shooterPosition.x - yDistance / 2,
        min(shooterPosition.y, targetPosition.y),
        targetPosition.x + yDistance / 2,
        max(shooterPosition.y, targetPosition.y),
      );

      // c.drawArc(arcRect, pi * 6 / 4, pi * 4 / 4, false, painter);
    } else {
      Vector2 leftPoint;
      Vector2 rightPoint;
      if (shooterNode.x < targetNode.x) {
        leftPoint = shooterPosition;
        rightPoint = targetPosition;
      } else {
        leftPoint = targetPosition;
        rightPoint = shooterPosition;
      }

      if (leftPoint.y > rightPoint.y) {
        //left point is lower, so need to add the right half and bottom half
        // [/]+
        //  + +

        arcRect = Rect.fromLTRB(
          leftPoint.x,
          rightPoint.y,
          rightPoint.x + xDistance,
          leftPoint.y + yDistance,
        );
//        log('NW ' + arcRect.toString() + ' ${xDistance} for ${shooterNode.x}:${shooterNode.y} to ${targetNode.x}:${targetNode.y}');

      } else if (leftPoint.y < rightPoint.y) {
        //right point is lower, so need to add the left half and bottom half
        //  +[\]
        //  + +
        arcRect = Rect.fromLTRB(
          leftPoint.x - xDistance,
          leftPoint.y,
          rightPoint.x,
          rightPoint.y + yDistance,
        );
      } else {
        //equal height, so need to add the bottom half and top half
        //  [/-\]
        //   + +
        arcRect = Rect.fromLTRB(
          leftPoint.x,
          leftPoint.y - xDistance * 0.5,
          rightPoint.x,
          rightPoint.y + xDistance * 0.5,
        );
      }
    }
  }

  void updatePosition(final double progress) {
    // log('Updating offset for progress = $progress');

    if (arcRect.isEmpty) {
      //line
      // log('$shooterNode');
      // log('$targetNode');
      final shooterCenter =
          game.activeBattle?.tileData[shooterNode.terrainTile]?.center;
      final targetCenter =
          game.activeBattle?.tileData[targetNode.terrainTile]?.center;
      if (shooterCenter == null || targetCenter == null) {
        throw ArgumentError.notNull(
          'shooterCenter: $shooterCenter '
          'targetCenter: $targetCenter',
        );
      }

      position = pointFromSegment(shooterCenter, targetCenter, progress);
      // log(          '${game.activeBattle.tileData[shooterNode.terrainTile].center}');
      //   log('${game.activeBattle.tileData[targetNode.terrainTile].center}');
      // log(this.position);
    } else {
      position = ellipsePointFromAngle(
        arcRect,
        startAngle + progress * (endAngle - startAngle),
      );
    }
  }

//   @override
//   void render(final Canvas canvas) {
//     super.render(canvas);
//     if (!renderAllowed) return;
// //    c.drawLine(map.tileData[shooterNode.terrainTile]['center'], map.tileData[targetNode.terrainTile]['center'], debugPainter);
//     if (isDestroyed) return;
//     // c.drawRect(arcRect, painter);
//     canvas.drawCircle(
//       position.toOffset(),
//       width,
//       Paint()..color = Colors.red,
//     );
//   }
}

class Cannonball extends Projectile {
  Cannonball(
    final TransoxianaGame game,
    final Node shooterNode,
    final Node targetNode, {
    required super.onRemoveCallback,
    super.hitCallback,
  }) : super(
          game,
          shooterNode,
          targetNode,
          animationSizeFactor: 4.5,
        );

  @override
  Future<void>? onLoad() async {
    if (renderAllowed) {
      final animation = await SpriteAnimation.load(
        'explosion.png',
        SpriteAnimationData.sequenced(
          amount: 6,
          stepTime: flightTime / 6,
          textureSize: Vector2(128.0, 128.0),
          loop: false,
        ),
      );
      hitAnimation = SpriteAnimationComponent(
        animation: animation,
        removeOnFinish: true,
        size: Vector2(
          width * animationSizeFactor,
          height * animationSizeFactor,
        ),
      );
    }
    return super.onLoad();
  }

  @override
  void onHit() {
    super.onHit();
    if (!renderAllowed) return;
    MultiTrackSfx.explosion.startPlayer(volume: 0.7);
    //TODO: add a proper explosion sound
  }

  @override
  void onStart() {
    super.onStart();
    if (!renderAllowed) return;
    MultiTrackSfx.cannonShot.startPlayer(volume: 0.4);
    //TODO: add catapult sound alternative
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    final isAiBattle = game.activeBattle?.isAiBattle ?? true;
    if (game.isHeadless || isAiBattle) return;
    if (isDestroyed) return;
    if (_lifeInSeconds <= flightTime) {
      canvas.drawCircle(
        // position.toOffset(),
        Offset.zero,
        width,
        paints.projectilePaint,
      );
    } else {
      // canvas.save();
      hitAnimation?.render(canvas);
      // canvas.restore();
    }
  }
}

class Arrows extends Projectile {
  Arrows(
    final TransoxianaGame game,
    final Node shooterNode,
    final Node targetNode, {
    required super.onRemoveCallback,
    super.hitCallback,
  }) : super(
          game,
          shooterNode,
          targetNode,
          hitTime: 0.0,
        );

  @override
  void onStart() {
    super.onStart();
    if (!renderAllowed) return;
    MultiTrackSfx.bows.startPlayer();
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    final resolvedActiveBattle = game.activeBattle;
    if (game.isHeadless ||
        resolvedActiveBattle == null ||
        resolvedActiveBattle.isAiBattle) return;
    if (isDestroyed) return;
    // c.drawRect(arcRect, painter);

    final Vector2 start = Vector2(0, 0);
    // position.toOffset();

    final Vector2? target =
        resolvedActiveBattle.tileData[targetNode.terrainTile]?.center;
    if (target == null) throw ArgumentError.notNull('target');
    Vector2 offset;
    if ((target - start).x == 0.0) {
      offset = Vector2(0.0, height);
    } else {
      final double angle = (target - start).y / (target - start).x;
      final double x = pow(pow(width, 2) / (pow(angle, 2) + 1), 0.5).toDouble();
      offset = Vector2(x, angle * x);
    }
    // double projectileScale =
    //     (Transoxiana.tileSize / 3.0) / (finish.dx - start.dx);
    // finish = pointFromSegment(start, finish, projectileScale);
    // finish = start + (finish - start).scale(projectileScale, projectileScale);

    canvas
      ..drawLine(
        start.toOffset(),
        (start + offset).toOffset(),
        paints.projectilePaint,
      )
      ..drawLine(
        (start + size).toOffset(),
        (start + offset + size).toOffset(),
        paints.projectilePaint,
      )
      ..drawLine(
        start.toOffset() - Offset(width, 0),
        (start + offset).toOffset() - Offset(width, 0),
        paints.projectilePaint,
      );
  }
}
