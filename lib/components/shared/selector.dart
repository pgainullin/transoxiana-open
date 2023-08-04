import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/battle/hex_tiled_component.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/direction.dart';
import 'package:transoxiana/services/battle_map_services.dart';
import 'package:transoxiana/services/geometry.dart';
import 'package:transoxiana/services/painting_utils.dart';

class PathSelector extends TimedLifeComponent implements GameRef {
  PathSelector(
    this.game, {
    this.color = Colors.amberAccent,
    this.strokeWidth = 3.0,
    final double? lifeInSeconds,
  }) : super(lifeInSeconds: lifeInSeconds) {
    selectionPainter = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
  }

  late Paint selectionPainter;

  @override
  TransoxianaGame game;
  Color color;
  double strokeWidth;
  final Set<Node> _nodePath = {};
  final Set<NodeSelector> _selectors = {};

  void showPath(final Set<Node> nodePath, {final Color? color}) {
    _nodePath.clear();
    _nodePath.addAll(nodePath);
    _selectors.clear();
    Node? previousNode;
    for (final element in _nodePath) {
      final NodeSelector newSelector =
          color == null ? NodeSelector(game) : NodeSelector(game, color: color);
      newSelector.selectNode(
        element,
        direction: previousNode != null
            ? directionBetweenAdjacentNodes(previousNode, element)
            : null,
      );
      _selectors.add(newSelector);
      previousNode = element;
    }
    showFor(1.0);
  }

  @override
  void render(final Canvas canvas) {
    if (isVisible == true) {
      for (final element in _selectors) {
        element.render(canvas);
      }
    }
    super.render(canvas);
  }
}

class NodeSelector extends TimedLifeComponent implements GameRef {
  NodeSelector(
    this.game, {
    this.color = Colors.white70,
    this.strokeWidth = 3.0,
    final double? lifeInSeconds,
  }) : super(lifeInSeconds: lifeInSeconds) {
    selectionPainter = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    fillPainter = Paint()
      ..color = color.withOpacity(0.70)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill;
  }
  late Paint selectionPainter;
  late Paint fillPainter;

  Color color;
  double strokeWidth;
  Direction? _direction;

  @override
  TransoxianaGame game;
  Node? _node;

  @override
  void render(final Canvas canvas) {
    if (isVisible == true) {
      final TileInfo tile = game.activeBattle!.tileData[_node!.terrainTile]!;
      final collisionDiameter = tile.collisionDiameter;
      if (collisionDiameter == null) {
        throw ArgumentError.notNull('tile.collisionDiameter');
      }
      final tileCenter = tile.center;
      if (tileCenter == null) throw ArgumentError.notNull('tile.center');

      drawHexagon(
        canvas,
        collisionDiameter / 2.0,
        tileCenter,
        selectionPainter,
      );

      if (_direction != null) {
        drawFromDirectionPointer(
          canvas,
          collisionDiameter / 2.0,
          tileCenter,
          _direction!.index,
          selectionPainter,
        );
      }
    }
    super.render(canvas);
  }

  void selectNode(final Node node, {final Direction? direction}) {
    if (direction != null) {
      // log('Selecting $node with direction.dart $direction.dart');
      _direction = direction;
    }
    _node = node;
    showFor(1.0);
  }

  void deselect() {
    _node = null;
    _direction = null;
    isVisible = false;
  }
}

class ProvincePathSelector extends TimedLifeComponent {
  ProvincePathSelector(
    this.army, {
    this.overrideColor,
    this.strokeWidth = 3.0,
    final double? lifeInSeconds,
  }) : super(lifeInSeconds: lifeInSeconds) {
    updatePainters();
  }
  late Paint selectionPainter;
  late Paint fillPainter;

  // final CampaignMap map;
  late Color color;
  final Color? overrideColor;
  double strokeWidth;

  final Army
      army; //used to determine whether the path goes through unitXY or enemyXY and progress indication

  void updatePainters() {
    color = overrideColor ?? army.nation.color;
    selectionPainter = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;
    fillPainter = Paint()
      ..color = color.withOpacity(0.85)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.fill;
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    if (army.touchRect == null) return;

    /// from the center of the touchRect to the center of the marker
    final Vector2 translation =
        // Offset.zero
        Vector2(0.0, army.unitSize.x * armyMarkerVerticalOffsetFactor)
        // army.touchRect!.center -
        // army.touchRect!.topLeft
        // +
        // Offset(0.0, army.touchRect!.height * 0.25)
        ;
    // - this.army.sizeOffset;

    if (isVisible) {
      final double width = army.unitSize.x * 0.1;

      Province? previousProvince;
      Vector2? previousOffset;

      army.provincePath.asMap().forEach((final index, final province) {
        final Vector2 currentOffset = army.nation.isFriendlyTo(province.nation)
            ? province.friendlyVector2
            : province.enemyVector2;

        if (previousProvince != null) {
          final Vector2 shift =
              normalized(rotate90(previousOffset! - currentOffset)) * width;
          final Vector2 moveToMarkerEdge = index == 1
              ? normalized(currentOffset - previousOffset!) *
                  army.touchRect!.width /
                  3.0
              : Vector2.zero();

          if (index < army.provincePath.length - 1) {
            //interim segments of the selector are rectangles
            drawPolygon(
              canvas,
              [
                previousOffset! + translation - shift + moveToMarkerEdge,
                previousOffset! + translation + shift + moveToMarkerEdge,
                currentOffset + translation + shift,
                currentOffset + translation - shift,
              ],
              fillPainter,
            );
            //hexagon instead of rounded edges
            drawHexagon(
              canvas,
              width * 1.2,
              currentOffset + translation,
              fillPainter,
            );
          } else {
            //last segment of the selector is an arrow (triangle)
            drawPolygon(
              canvas,
              [
                previousOffset! + translation - shift + moveToMarkerEdge,
                previousOffset! + translation + shift + moveToMarkerEdge,
                currentOffset + translation,
              ],
              fillPainter,
            );
          }
        }
        previousProvince = province;
        previousOffset = currentOffset;
      });
    } else if (army.game.temporaryCampaignData.isPaused == false) {
      final double width = army.unitSize.x * 0.1;
      //when not set to visible but in real-time mode show the first section
      if (army.provincePath.isNotEmpty && army.provincePath.length > 1) {
        final Vector2 finish =
            army.nation.isFriendlyTo(army.provincePath[1].nation)
                ? army.provincePath[1].friendlyVector2
                : army.provincePath[1].enemyVector2;
        final Vector2 start =
            army.nation.isFriendlyTo(army.provincePath[0].nation)
                ? army.provincePath[0].friendlyVector2
                : army.provincePath[0].enemyVector2;

        final Vector2 moveToMarkerEdge =
            normalized(finish - start) * army.touchRect!.width / 3.0;
        final Vector2 pointReached = start +
            moveToMarkerEdge +
            (finish - start - moveToMarkerEdge) * army.progress;
        // log('$start to $finish for (${this.location.name} to ${this.nextProvince.name})');

        final Vector2 shift =
            normalized(rotate90(pointReached - start)) * width;

        //progress path
        if (army.progress > 0.0) {
          drawPolygon(
            canvas,
            [
              start + translation - shift + moveToMarkerEdge,
              start + translation + shift + moveToMarkerEdge,
              pointReached + translation,
            ],
            fillPainter,
          );
        }
      }
    }
  }
}

class TimedLifeComponent extends PositionComponent {
  TimedLifeComponent({this.lifeInSeconds})
      : super(priority: ComponentsRenderPriority.battleNodeSelector.value);

  /// set to null on initialization and upon the timer finishing. Unless update is overridden null will correspond to isVisible being false
  double? lifeInSeconds;

  /// can be used in the render() override to determine what to show on screen
  bool isVisible = false;
  bool isDestroyed = false;

  /// sets the component isVisible to true and starts the counter of a given number of seconds
  void showFor(final double seconds) {
    lifeInSeconds = seconds;
    isVisible = true;
  }

  @override
  void update(final double dt) {
    if (lifeInSeconds != null) {
//      log(lifeInSeconds);
      if (lifeInSeconds! <= 0.0) {
        // log('turning invisible');
        isVisible = false;
        lifeInSeconds = null;
      } else {
        lifeInSeconds = lifeInSeconds! - dt;
      }
    }

    super.update(dt);
  }

  // @override
  // void resize(Size size) {
  //   super.resize(size);
  // }
}
