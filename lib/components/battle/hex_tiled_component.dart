import 'dart:async';
import 'dart:developer';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flame/src/extensions/offset.dart' as flame_offset;
import 'package:flutter/material.dart' as widgets;
import 'package:tiled/tiled.dart' hide Image;
import 'package:transoxiana/components/battle/foreground.dart';
import 'package:transoxiana/components/battle/to_tiled.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';

/// hack on top of the TiledComponent to offset the hexagonal tiles to align
/// (only works for straight hexes with height and width approximately equal to two sides
class HexTiledComponent extends TransoxianaTiledComponent {
  HexTiledComponent({
    required final String filename,
    required this.destTileHeight,
    required this.gameSize,
    required this.renderEnabled,
  }) : super(filename, Size(destTileHeight, destTileHeight));
  bool renderEnabled;
// @override
  // final String filename;

  // Vector2? _initialVector2;

  // double scale = 1.0;
  double destTileHeight;

  /// Needed to fit map boundries to device screen in case if map is too small
  Vector2 gameSize;

  static const double apothem = 0.866;

  final Map<Tile, TileInfo> tileData = {};

  @override
  Future<void>? onLoad() async {
    await super.onLoad();
    setTileData();
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    if (!renderEnabled) return;

    for (final layer in map.layers) {
      if (layer.visible) {
        _renderLayer(canvas, layer);
      }
    }
  }

  /// manually generate tileData that is normally generated in the render cycle which does not get called in headless or AI battle modes.
  void populateHeadlessTileData() {
    for (final layer in map.layers) {
      for (final tileRow in layer.tiles) {
        for (final tile in tileRow) {
          if (tileData[tile] == null) {
            tileData[tile] = TileInfo(
              center: Vector2(tile.x.toDouble(), tile.y.toDouble()),
              collisionDiameter: 0.1,
            );
          }
        }
      }
    }
  }

  void verifyWorldBounds({
    required final Vector2 gameSize,
    required final widgets.ValueChanged<Rect> onWorldBoundsChange,
  }) {
    final oldWorldBounds = mapBounds;
    final safeBound = backgroundBoundryOffset * 2;
    final approxWorldBounds = Rect.fromLTWH(
      0,
      0,
      gameSize.x + safeBound,
      gameSize.y + safeBound,
    );

    bool verifyChanges() {
      if (approxWorldBounds.width > oldWorldBounds.width ||
          approxWorldBounds.height > oldWorldBounds.height) {
        final widthRatio = (approxWorldBounds.width - oldWorldBounds.width) /
            oldWorldBounds.width;
        final heightRatio = (approxWorldBounds.height - oldWorldBounds.height) /
            oldWorldBounds.height;

        final ratio = math.max(widthRatio, heightRatio);
        setTileScale(tileScale + ratio + 0.1);
        final mapSize = mapBounds.bottomRight;
        final gameMapSize = gameSize.toRect().bottomRight;
        log('recalculating size: mapSize <= gameMapSize $mapSize $gameMapSize');
        if (mapSize < gameMapSize) {
          verifyChanges();
        } else {
          return true;
        }
      }
      return false;
    }

    final changesMade = verifyChanges();
    if (changesMade) onWorldBoundsChange(mapBounds);
  }

  /// Made it higher number to make possible center camera to units
  /// which can be on map edge
  double get backgroundBoundryOffset => destTileHeight * 3;

  double tileScale = 1.0;
  void setTileScale(final double scale) {
    tileScale = scale;
    _mapHeight = 0.0;
    _mapWidth = 0.0;
    setTileData();
  }

  void setTileData() {
    // log('Updating HexTiledComponent Rects with scale: ${game.scale}');

    // if (newScale != null) scale = newScale;

    for (final layer in map.layers) {
      double cumulativeExtraOffsetX = 0.0; //used for hex alignment
      double cumulativeExtraOffsetY = 0.0;

//    int lastTileY = 0;

      for (final tileRow in layer.tiles) {
        for (final tile in tileRow) {
          if (tile.isEmpty) continue;

          final rect = tile.computeDrawRect();

          cumulativeExtraOffsetX = -0.25 *
              (tile.x - tileRow.first.x) *
              destTileHeight; //TODO: generalise to other hexes by accessing hex properties

//        log("${tile.x} ~/ ${tile.width} ");
          if (tile.x.isOdd) {
            //rect.height *
            cumulativeExtraOffsetY = destTileHeight *
                apothem *
                0.5; //TODO: generalise to other hexes by accessing hex properties
          } else {
            cumulativeExtraOffsetY =
                0.0; //TODO: generalise to other hexes by accessing hex properties
          }

          final src = Rect.fromLTWH(
            rect.left.toDouble(),
            rect.top.toDouble(),
            rect.width.toDouble(),
            rect.height.toDouble(),
          );
          final dst = Rect.fromLTWH(
            backgroundBoundryOffset +
                (tile.x) * destTileHeight * tileScale +
                cumulativeExtraOffsetX * tileScale,
            backgroundBoundryOffset +
                (tile.y) * destTileHeight * apothem * tileScale +
                cumulativeExtraOffsetY * tileScale,
            destTileHeight * tileScale,
            destTileHeight * apothem * tileScale,
          );

          if (tileData[tile] == null) {
            tileData[tile] = TileInfo(
              center: dst.center.toVector2(),
              collisionDiameter: dst.shortestSide * 0.9,
            );
          } else {
//          log('TileInfo updated for tile ${tile.x}:${tile.y}');
            tileData[tile]?.center = dst.center.toVector2();
            tileData[tile]?.collisionDiameter = dst.shortestSide * 0.9;
            // game.map.tileData[tile].terrainType = tile.properties['terrainType'];
          }
          tileData[tile]?.srcRect = src;
          tileData[tile]?.dstRect = dst;

          _mapWidth = math.max(_mapWidth, dst.right.toDouble());
          _mapHeight = math.max(_mapHeight, dst.bottom.toDouble());
        }
      }
    }
  }

  double _mapWidth = 0.0;
  double _mapHeight = 0.0;

  Rect get mapBounds => Rect.fromLTWH(
        0,
        0,
        _mapWidth + backgroundBoundryOffset,
        _mapHeight + backgroundBoundryOffset,
      );

  static final shadowPaint = Paint()
    ..color = widgets.Colors.black.withAlpha(ShadowBackground.alpha);

  void _renderLayer(final Canvas c, final Layer layer) {
//    int lastTileY = 0;
    for (int rowIndex = 0; rowIndex < layer.tiles.length; rowIndex++) {
      final tileRow = layer.tiles[rowIndex];
      for (int cellIndex = 0; cellIndex < tileRow.length; cellIndex++) {
        final tile = tileRow[cellIndex];
        if (tile.gid == 0 || tile.isEmpty || tileData[tile] == null) {
          continue;
        }

        // final flips = _SimpleFlips.fromFlips(tile.flips);
        // c.save();
        // c.translate(game.activeBattle.tileData[tile].dstRect.center.dx,
        //     game.activeBattle.tileData[tile].dstRect.center.dy);
        // c.rotate(flips.angle * math.pi / 2);
        // c.scale(flips.flipV ? -1.0 : 1.0, flips.flipH ? -1.0 : 1.0);
        // c.translate(-game.activeBattle.tileData[tile].dstRect.center.dx,
        //     -game.activeBattle.tileData[tile].dstRect.center.dy);
        // maxWidth = math.max(
        //   maxWidth,
        //   tileData[tile]?.dstRect?.right.toDouble() ?? 0.0,
        // );
        // maxHeight = math.max(
        //   maxHeight,
        //   tileData[tile]?.dstRect?.bottom.toDouble() ?? 0.0,
        // );

        // c.drawImage(image, game.activeBattle.tileData[tile].dstRect.topLeft, TiledComponent.paint);
        final tileInfo = tileData[tile];
        final srcRect = tileInfo?.srcRect;
        final dstRect = tileInfo?.dstRect;
        if (srcRect == null) throw ArgumentError.notNull('srcRect');
        if (dstRect == null) throw ArgumentError.notNull('dstRect');

        final effectiveImage = () {
          final resolvedImage = image;
          if (resolvedImage != null) return resolvedImage;
          final atlas = batches[tile.image.source]?.atlas;
          if (atlas == null) throw ArgumentError.notNull('atlas');
          return atlas;
        }();

        c.drawImageRect(effectiveImage, srcRect, dstRect, paint);
        useShadowBuilder(
          cellIndex: cellIndex,
          cellsLength: tileRow.length,
          rowIndex: rowIndex,
          rowsLength: layer.tiles.length,
          shadowBuilder: (final type, final position) {
            final shadow = shadowCornerPathByRect(
              dstRect,
              type: type,
              position: position,
            );
            if (shadow != null) {
              c.drawPath(
                shadow,
                shadowPaint,
              );
            }
          },
        );
//        c.drawCircle(dst.center, 0.9 * dst.shortestSide / 2, _debugPainter);
//         c.restore();

//      lastTileY = tile.y;
      }
    }
  }

  void useShadowBuilder({
    required final int rowIndex,
    required final int cellIndex,
    required final int rowsLength,
    required final int cellsLength,
    required final void Function(
      ShadowType type,
      ShadowPosition position,
    )
        shadowBuilder,
  }) {
    ShadowType type = ShadowType.none;
    ShadowPosition position = ShadowPosition.none;

    if (rowIndex == 0) {
      if (cellIndex == 0) {
        type = ShadowType.corner;
        position = ShadowPosition.topLeft;
      } else if (cellIndex == cellsLength - 1) {
        type = ShadowType.corner;
        position = ShadowPosition.topRight;
      } else if (cellIndex.isOdd) {
        type = ShadowType.line;
        position = ShadowPosition.top;
      } else {
        type = ShadowType.hex;
        position = ShadowPosition.top;
      }
    } else if (rowIndex == rowsLength - 1) {
      if (cellIndex == 0) {
        type = ShadowType.corner;
        position = ShadowPosition.bottomLeft;
      } else if (cellIndex.isEven) {
        type = ShadowType.line;
        position = ShadowPosition.bottom;
      } else if (cellIndex == cellsLength - 1) {
        type = ShadowType.corner;
        position = ShadowPosition.bottomRight;
      } else {
        type = ShadowType.hex;
        position = ShadowPosition.bottom;
      }
    } else {
      if (cellIndex == 0) {
        type = ShadowType.hex;
        position = ShadowPosition.left;
      } else if (cellIndex == cellsLength - 1) {
        type = ShadowType.hex;
        position = ShadowPosition.right;
      }
    }
    shadowBuilder(type, position);
  }

  Path? shadowCornerPathByRect(
    final Rect destRect, {
    required final ShadowType type,
    required final ShadowPosition position,
  }) {
    final hexShadow = hexShadowPathByRect(destRect);
    final hole = holePathByRect(
      destRect,
      type: type,
      position: position,
    );
    if (hole == null) return null;
    final path = Path.combine(PathOperation.difference, hexShadow, hole);
    return path.shift(destRect.topLeft);
  }

  Path hexShadowPathByRect(final Rect rect) {
    final double height = rect.height;
    final double width = rect.width;

    /// Start with left center
    final path = Path()
      ..moveTo(0.0, (height / 2))
      ..lineTo((width / 4), 0.0)
      ..lineTo(width - (width / 4), 0.0)
      ..lineTo(width, (height / 2))
      ..lineTo(width - (width / 4), height)
      ..lineTo((width / 4), height)
      ..close();

    return path;
  }

  Path? holePathByRect(
    final Rect rect, {
    required final ShadowType type,
    required final ShadowPosition position,
  }) {
    final double height = rect.height;
    final double width = rect.width;
    const thickness = 10.0;
    Path topHex() => Path()
      ..moveTo(0.0, (height / 2) + thickness)
      ..lineTo((width / 4), thickness)
      ..lineTo(width - (width / 4), thickness)
      ..lineTo(width, (height / 2) + thickness)
      ..lineTo(width, height)
      ..lineTo(0.0, height)
      ..close();

    Path topLine() => Path()
      ..moveTo(0.0, height)
      ..lineTo(0.0, thickness / 2)
      ..lineTo(width, thickness / 2)
      ..lineTo(width, height)
      ..close();

    Path leftHex() => Path()
      ..moveTo((width / 4) + thickness / 1.5, 0.0)
      ..lineTo(width, 0.0)
      ..lineTo(width, height)
      ..lineTo((width / 4) + thickness / 1.5, height)
      ..lineTo(thickness / 1.5, height / 2)
      ..close();

    Path topLeftCorner() => Path()
      ..moveTo((width / 4) + thickness / 1.5, height)
      ..lineTo(thickness / 1.5, height / 2)
      ..lineTo((width / 4), thickness)
      ..lineTo(width - (width / 4), thickness)
      ..lineTo(width, height / 2 + thickness)
      ..lineTo(width, height)
      ..close();

    Path bottomLeftCorner() => Path()
      ..moveTo((width / 4) + thickness / 1.5, 0.0)
      ..lineTo(thickness / 1.5, height / 2)
      ..lineTo((width / 4) + (thickness / 2.5), height - (thickness / 2))
      ..lineTo(width, height - (thickness / 2))
      ..lineTo(width, 0.0)
      ..close();

    switch (type) {
      case ShadowType.hex:
        switch (position) {
          case ShadowPosition.top:
            return topHex();
          case ShadowPosition.bottom:
            final rotate = Matrix4.rotationZ(radians(180))
              ..translate(-width, -height);
            return topHex().transform(rotate.storage);

          case ShadowPosition.left:
            return leftHex();
          case ShadowPosition.right:
            final rotate = Matrix4.rotationZ(radians(180))
              ..translate(-width, -height);
            return leftHex().transform(rotate.storage);
          default:
        }
        break;
      case ShadowType.corner:
        switch (position) {
          case ShadowPosition.topLeft:
            return topLeftCorner();
          case ShadowPosition.topRight:
            final rotate = Matrix4.rotationZ(radians(180))
              ..translate(-width, -height);
            return bottomLeftCorner().transform(rotate.storage);
          case ShadowPosition.bottomLeft:
            return bottomLeftCorner();
          case ShadowPosition.bottomRight:
            final rotate = Matrix4.rotationZ(radians(180))
              ..translate(-width, -height);
            return topLeftCorner().transform(rotate.storage);
          default:
        }
        break;
      case ShadowType.line:
        switch (position) {
          case ShadowPosition.top:
            return topLine();
          case ShadowPosition.bottom:
            final rotate = Matrix4.rotationZ(radians(180))
              ..translate(-width, -height);
            return topLine().transform(rotate.storage);
          default:
        }
        break;
      default:
    }
    return null;
  }
}

enum ShadowType {
  corner,
  line,
  hex,
  none,
}

enum ShadowPosition {
  top,
  topLeft,
  topRight,
  left,
  right,
  bottom,
  bottomLeft,
  bottomRight,
  none,
}

/// Stores rendering information of a particular tile relating to its scaled Rects, center and collisionDiameter
class TileInfo {
  TileInfo({
    this.center,
    this.collisionDiameter,
  });
  Vector2? center;
  Rect? srcRect;
  Rect? dstRect;
  double? collisionDiameter;
  // Unit unit;
  // final List<Unit> deadUnits = [];
  // bool selected = false;

}

class TransoxianaTiledComponent extends Component {
  TransoxianaTiledComponent(this.filename, this.destTileSize)
      : super(priority: ComponentsRenderPriority.battleHexMap.value);
  TransoxianaTiledComponent.fromTiled(this._tiled, this.filename)
      : super(priority: ComponentsRenderPriority.battleHexMap.value);

  late Tiled _tiled;
  Size? destTileSize;
  @override
  Future<void>? onLoad() async {
    _tiled = await Tiled.create(filename: filename, destTileSize: destTileSize);
    return super.onLoad();
  }

  final String filename;

  TileMap get map => _tiled.map;
  Image? get image => _tiled.image;

  Map<String, SpriteBatch> get batches => _tiled.batches;
  // Future future;
  // bool _loaded = false;
  // Size destTileSize;
  Paint get paint => Tiled.paint;

  // @override
  // void update(double dt) {
  // }

  // @override
  // void render(Canvas canvas) {
  //   super.render(canvas);
  //   _tiled.render(canvas);
  // }

  ObjectGroup getObjectGroupFromLayer(final String name) =>
      _tiled.getObjectGroupFromLayer(name);
}
