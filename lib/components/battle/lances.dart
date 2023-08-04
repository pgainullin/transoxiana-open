import 'package:flame/components.dart';
import 'package:flutter/cupertino.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/services/painting_utils.dart';

/// draws a line indicating the melee attack from one tile to another tile
/// on start triggers sound effects
/// on completion triggers a callback if provided
class Lance extends PositionComponent implements GameRef {
  Lance(
    this.game,
    this.attackerNode,
    this.targetNode, {
    required this.onRemoveCallback,
    this.totalLife = 0.4,
    this.hitCallback,
  }) : super(priority: ComponentsRenderPriority.battleLancesAndShoots.value) {
    onStart();
  }

  @override
  TransoxianaGame game;
  double _lifeInSeconds = 0.0;
  final Node attackerNode;
  final Node targetNode;
  bool isDestroyed = false;
  final double totalLife;

  bool _hitAchieved = false;

  /// callback that is triggered once, upon flightTime ending
  final VoidCallback? hitCallback;
  final ValueChanged<Lance> onRemoveCallback;
  bool get renderAllowed => !game.isHeadless && !game.activeBattle!.isAiBattle;

  @override
  void update(final double dt) {
    if (game.temporaryCampaignData.isPaused) return;
    _lifeInSeconds += dt;
    if (_lifeInSeconds >= totalLife) {
      if (_hitAchieved == false) {
        onHit();
      }

      isDestroyed = true;
    }
    super.update(dt);
  }

  @mustCallSuper
  void onStart() {
    if (game.isHeadless || game.activeBattle!.isAiBattle) return;
  }

  @mustCallSuper
  void onHit() {
    if (hitCallback != null) {
      hitCallback!.call();
    }
    _hitAchieved = true;

    onRemoveCallback(this);
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    final resolvedActiveBattle = game.activeBattle;
    if (resolvedActiveBattle == null ||
        game.isHeadless ||
        resolvedActiveBattle.isAiBattle ||
        isDestroyed) return;

    final attackerTileInfo =
        resolvedActiveBattle.tileData[attackerNode.terrainTile];
    if (attackerTileInfo == null) throw ArgumentError.notNull('tileInfo');
    final attackerCollisionDiameter = attackerTileInfo.collisionDiameter;
    if (attackerCollisionDiameter == null) {
      throw ArgumentError.notNull('attackerCollisionDiameter');
    }

    final double size = attackerCollisionDiameter / 10.0;
    final Vector2? start = attackerTileInfo.center;
    final Vector2? finish =
        resolvedActiveBattle.tileData[targetNode.terrainTile]?.center;

    if (start == null || finish == null) {
      throw ArgumentError.notNull('start: $start , finish: $finish');
    }

    canvas
      ..drawLine(
        start.toOffset(),
        (start + (finish - start) * (_lifeInSeconds / totalLife)).toOffset(),
        paints.projectilePaint,
      )
      ..drawLine(
        start.toOffset() + Offset(size, 0),
        Offset(size, 0) +
            (start + (finish - start) * (_lifeInSeconds / totalLife))
                .toOffset(),
        paints.projectilePaint,
      )
      ..drawLine(
        start.toOffset() - Offset(size, size),
        (start + (finish - start) * (_lifeInSeconds / totalLife)).toOffset() -
            Offset(size, size),
        paints.projectilePaint,
      );
  }
}
