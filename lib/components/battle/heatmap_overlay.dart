import 'package:flame/extensions.dart';
import 'package:flame/game.dart' as flame_game;
import 'package:flutter/rendering.dart' as rendering;
import 'package:transoxiana/components/battle/hex_tiled_component.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/services/tactical_ai.dart';

///
/// Debug overlay displaying the TacticalAi evaluation of each node on the Battle map for a given Unit
///

class HeatmapOverlay implements GameRef {
  HeatmapOverlay(this.game);
  @override
  TransoxianaGame game;
  double? lifeInSeconds;
  bool isVisible = false;
  final textConfig = flame_game.TextPaint(
    style: const rendering.TextStyle(
      color: Color(0xFFFFFFFF),
    ),
  );

  final Map<Node, double> _heatMap = {};

  void showUnitHeatmap(final Unit unit) {
    if (!unit.isFighting) return;
    _heatMap.clear();
    _heatMap.addAll(TacticalAi.produceHeatMap(unit));
    showFor(5.0);
  }

  void showFor(final double seconds) {
    lifeInSeconds = seconds;
    isVisible = true;
  }

  void render(final Canvas c) {
    if (isVisible != true) return;
    _heatMap.forEach((final key, final value) {});
    for (final entry in _heatMap.entries) {
      // log('Node $key showing $value');
      final TileInfo? tile = game.activeBattle?.tileData[entry.key.terrainTile];
      final tileCenter = tile?.center;
      if (tileCenter == null) continue;
      textConfig.render(
        c,
        entry.value.toStringAsFixed(1),
        tileCenter,
      );
    }
  }

  void update(final double dt) {
    final resolvedLifeInSeconds = lifeInSeconds;
    if (resolvedLifeInSeconds == null) return;
//      log(lifeInSeconds);
    if (resolvedLifeInSeconds <= 0.0) {
      // log('turning invisible');
      isVisible = false;
      lifeInSeconds = null;
    } else {
      lifeInSeconds = resolvedLifeInSeconds - dt;
    }
  }
}
