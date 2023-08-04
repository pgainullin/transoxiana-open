import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:collection/collection.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart' show Colors;
import 'package:tiled/tiled.dart' as tiled;
import 'package:xml/xml.dart' as xml;

/// Tiled represents all flips and rotation using three possible flips: horizontal, vertical and diagonal.
/// This class converts that representation to a simpler one, that uses one angle (with pi/2 steps) and two flips (H or V).
/// More reference: https://doc.mapeditor.org/en/stable/reference/tmx-map-format/#tile-flipping
class _SimpleFlips {
  _SimpleFlips(this.angle, this.flipH, this.flipV);

  /// This is the conversion from the truth table that I drew.
  factory _SimpleFlips.fromFlips(final tiled.Flips flips) {
    int angle;
    bool flipV, flipH;

    if (!flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 0;
      flipV = false;
      flipH = false;
    } else if (!flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 0;
      flipV = false;
      flipH = true;
    } else if (!flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 0;
      flipV = true;
      flipH = false;
    } else if (!flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 2;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && !flips.vertically && !flips.horizontally) {
      angle = 1;
      flipV = false;
      flipH = true;
    } else if (flips.diagonally && !flips.vertically && flips.horizontally) {
      angle = 1;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && flips.vertically && !flips.horizontally) {
      angle = 3;
      flipV = false;
      flipH = false;
    } else if (flips.diagonally && flips.vertically && flips.horizontally) {
      angle = 1;
      flipV = true;
      flipH = false;
    } else {
      // this should be exhaustive
      throw 'Invalid combination of booleans: $flips';
    }

    return _SimpleFlips(angle, flipH, flipV);
  }

  /// The angle (in steps of pi/2 rads), clockwise, around the center of the tile.
  final int angle;

  /// Whether to flip across a central vertical axis (passing through the center).
  final bool flipH;

  /// Whether to flip across a central horizontal axis (passing through the center).
  final bool flipV;
}

/// This component renders a tile map based on a TMX file from Tiled.
class Tiled {
  /// Creates this Tiled with the filename (for the tmx file resource)
  /// and destTileSize is the tile size to be rendered (not the tile size in the texture, that one is configured inside Tiled).
  Tiled._(this.filename, this.destTileSize);
  static Future<Tiled> create({
    required final String filename,
    final Size? destTileSize,
  }) async {
    final tiled = Tiled._(filename, destTileSize);
    await tiled._load();
    return tiled;
  }

  String filename;
  late tiled.TileMap map;
  Image? image;
  Map<String, SpriteBatch> batches = <String, SpriteBatch>{};
  Size? destTileSize;

  static Paint paint = Paint()..color = Colors.white;

  Future<void> _load() async {
    map = await _loadMap();
    final maybeImage = map.tilesets[0].image as tiled.Image?;
    if (maybeImage != null) {
      image = await Flame.images.load(maybeImage.source);
    }
    batches = await _loadImages(map);
    generate();
  }

  xml.XmlDocument _parseXml(final String input) => xml.XmlDocument.parse(input);

  Future<tiled.TileMap> _loadMap() async {
    final String file = await Flame.bundle.loadString('assets/tiles/$filename');
    final parser = tiled.TileMapParser();

    final String? tsxSourcePath = _parseXml(file)
        .rootElement
        .children
        .whereType<xml.XmlElement>()
        .firstWhereOrNull((final element) => element.name.local == 'tileset')
        ?.getAttribute('source');
    if (tsxSourcePath != null) {
      final TiledTsxProvider tsxProvider = TiledTsxProvider(tsxSourcePath);
      await tsxProvider.initialize();

      return parser.parse(file, tsx: tsxProvider);
    } else {
      return parser.parse(file);
    }
  }

  Future<Map<String, SpriteBatch>> _loadImages(final tiled.TileMap map) async {
    final Map<String, SpriteBatch> result = {};
    await Future.forEach<tiled.Tileset>(map.tilesets, (final tileset) async {
      await Future.forEach<tiled.Image>(tileset.images, (final tmxImage) async {
        final sourceString = tmxImage.source;
        if (sourceString is String) {
          result[sourceString] = await SpriteBatch.load(sourceString);
        } else {
          throw ArgumentError('_loadImages: image source must be string');
        }
      });
    });
    return result;
  }

  /// Generate the sprite batches from the existing tilemap.
  void generate() {
    for (final batch in batches.keys) {
      batches[batch]?.clear();
    }
    _drawTiles(map);
  }

  void _drawTiles(final tiled.TileMap map) {
    map.layers.where((final layer) => layer.visible).forEach((final layer) {
      for (final tileRow in layer.tiles) {
        for (final tile in tileRow) {
          if (tile.isEmpty) continue;

          if (tile.image == null) {
            throw 'Tile ${tile.x}:${tile.y} gid ${tile.gid} image is null';
          } else {
            final batch = batches[tile.image.source];

            final rect = tile.computeDrawRect();

            final source = Rect.fromLTWH(
              rect.left.toDouble(),
              rect.top.toDouble(),
              rect.width.toDouble(),
              rect.height.toDouble(),
            );

            final flips = _SimpleFlips.fromFlips(tile.flips);
            final Size tileSize = destTileSize ??
                Size(tile.width.toDouble(), tile.height.toDouble());

            batch?.add(
              source: source,
              offset: Vector2(
                tile.x.toDouble() * tileSize.width +
                    (tile.flips.horizontally ? tileSize.width : 0),
                tile.y.toDouble() * tileSize.height +
                    (tile.flips.vertically ? tileSize.height : 0),
              ),
              rotation: flips.angle * math.pi / 2,
              scale: tileSize.width / tile.width,
            );
          }
        }
      }
    });
  }

  void render(final Canvas c) {
    batches.forEach((final _, final batch) => batch.render(c));
  }

  /// This returns an object group fetch by name from a given layer.
  /// Use this to add custom behaviour to special objects and groups.
  tiled.ObjectGroup getObjectGroupFromLayer(final String name) {
    return map.objectGroups
        .firstWhere((final objectGroup) => objectGroup.name == name);
  }
}

class TiledTsxProvider implements tiled.TsxProvider {
  TiledTsxProvider(this.key);
  String data = '';
  final String key;

  Future<void> initialize() async {
    data = await Flame.bundle.loadString('assets/tiles/$key');
  }

  @override
  String getSource(final String key) {
    return data;
  }
}
