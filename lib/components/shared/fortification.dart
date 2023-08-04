import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:equatable/equatable.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:ordered_set/comparing.dart';
import 'package:ordered_set/ordered_set.dart';
import 'package:transoxiana/components/battle/node.dart';
import 'package:transoxiana/components/campaign/city_walls_indicator.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/services/battle_map_services.dart';
import 'package:utils/utils.dart';

part 'fortification.g.dart';

enum FortificationType {
  wall,
  tower,
  gate,
}

@JsonSerializable(explicitToJson: true)
class SegmentData {
  SegmentData({
    required this.type,
    required this.x,
    required this.y,
    required this.entranceX,
    required this.entranceY,
    this.open = false,
    this.life = wallsMaxLife,
  });

  static SegmentData fromJson(final Map<String, dynamic> json) =>
      _$SegmentDataFromJson(json);

  Map<String, dynamic> toJson() => _$SegmentDataToJson(this);

  Segment toSegment({
    required final TransoxianaGame game,
  }) =>
      Segment._fromData(data: this, game: game);
  final FortificationType type;

  /// health of the segment 0.0-wallsMaxLife where 0.0 means destroyed
  double life = wallsMaxLife;
  bool open = false; //for gates in the future
  double x;
  double y;
  double entranceX;
  double entranceY;
}

/// Destructible fortifications placed on top of the tiled map
/// can be destroyed by units with a bombardFactor > 0.0
/// can be built up in campaign mode?
/// units can be on top of fortification tiles
/// 3 types: wall, tower, gate
/// each has 22 configurations with a different sprite for them
///
/// (1 single-node config where only this tile is covered, 6 dead-ends
/// with an entry from another tile, 15 (6 choose 2)
/// combinations of entry tile+exit tile)
class Segment extends PositionComponent
    implements GameRef, DataSourceRef<SegmentData, Segment> {
  Segment._fromData({
    required this.data,
    required this.game,
  }) : super(priority: ComponentsRenderPriority.battleWalls.index);

  @override
  Future<void> refillData(final Segment otherType) async {
    data = otherType.data;
  }

  @override
  Future<SegmentData> toData() async => SegmentData(
        entranceX: data.entranceX,
        entranceY: data.entranceY,
        type: type,
        x: x,
        y: y,
        life: life,
        open: open,
      );

  @override
  TransoxianaGame game;
  @override
  SegmentData data;

  FortificationType get type => data.type;

  double get life => data.life;

  bool get open => data.open; //for gates in the future
  final Map<WallsDamageLevel, Sprite?> sprites = {};

  /// gates have an additional sprite displayed when they are opened
  final Map<WallsDamageLevel, Sprite?> openSprites = {};

  Node? firstConnectedNode;
  Node? secondConnectedNode;
  late Node node;
  late Node entrance;

  void refreshNodes(final List<Node> nodes) {
    node = nodes.firstWhere(
      (final node) => node.x == data.x && node.y == data.y,
    );
    entrance = nodes.firstWhere(
      (final node) => node.x == data.entranceX && node.y == data.entranceY,
    );

    node.fortificationSegment = this;

    //these will have to be updated within updateNodeConnections
    // which presumes null starting values.
    firstConnectedNode = null;
    secondConnectedNode = null;
  }

  void receiveDamage(final double damage) {
    data.life = math.max(0.0, life - damage);
    if (life <= 0.0 && game.activeBattle != null) triggerPathFindingUpdate();
    // log('Received $damage, life now at $life (${node.x}:${node.y})');
  }

  void repair(final double lifeGain) {
    assert(lifeGain >= 0.0, 'repair lifeGain should be positive');
    data.life = math.min(wallsMaxLife, life + lifeGain);
  }

  void toggleOpenStatus() {
    data.open = !open;
    triggerPathFindingUpdate();
  }

  /// If gates have opened or a segment got destroyed,
  /// a path finding update needs to be triggered
  void triggerPathFindingUpdate() {
    game.activeBattle!.isPathFindingUpdateQueued = true;
    causeAdjacentUnitsToRecalculatePaths();
  }

  /// if adjacent distances have changed, units around the segment
  /// causing the change should recalculate their paths
  void causeAdjacentUnitsToRecalculatePaths() {
    final Set<Node> nodes = node.adjacentLocations..add(node);
    for (final affectedNode in nodes) {
      if (affectedNode.unit != null) {
        affectedNode.unit!.considerAlternativePaths();
      }
    }
  }

  Offset? nodesToVector(final Node startNode, final Node? endNode) {
    if (endNode == null) return null;

    if (startNode.x.isEven) {
      if (node.y > endNode.y) {
        if (node.x > endNode.x) {
          //NW
          return const Offset(-1.0, -1.0);
        } else if (node.x == endNode.x) {
          //N
          return const Offset(0.0, -1.0);
        } else if (node.x < endNode.x) {
          //NE
          return const Offset(1.0, -1.0);
        }
      } else {
        if (node.x > endNode.x) {
          //SW
          return const Offset(-1.0, 1.0);
        } else if (node.x == endNode.x) {
          //S
          return const Offset(0.0, 1.0);
        } else if (node.x < endNode.x) {
          //SE
          return const Offset(1.0, 1.0);
        }
      }
    } else {
      if (node.y >= endNode.y) {
        if (node.x > endNode.x) {
          //NW
          return const Offset(-1.0, -1.0);
        } else if (node.x == endNode.x) {
          //N
          return const Offset(0.0, -1.0);
        } else if (node.x < endNode.x) {
          //NE
          return const Offset(1.0, -1.0);
        }
      } else {
        if (node.x > endNode.x) {
          //SW
          return const Offset(-1.0, 1.0);
        } else if (node.x == endNode.x) {
          //S
          return const Offset(0.0, 1.0);
        } else if (node.x < endNode.x) {
          //SE
          return const Offset(1.0, 1.0);
        }
      }
    }

    throw Exception('No vector returned by nodesToVector');
  }

  // up against some stiff competition this is the worst code I ever wrote, but
  // here goes take the two direction.dart vectors and map them to the
  //  y coordinate in the tileset for the tile connecting the two vectors
  // -1 = North/West, 0 = no move, +1 = South/East
  int orientationIndexFromVectorsOmnidirectional(
    final Offset? vector1,
    final Offset? vector2,
  ) {
    final int? orientation = _orientationIndexFromVectors(vector1, vector2) ??
        _orientationIndexFromVectors(vector2, vector1);
    if (orientation == null) {
      throw Exception(
        'No sprite orientation found for inputs [$vector1, $vector2]',
      );
    }

    return orientation;
  }

  int? _orientationIndexFromVectors(
    final Offset? vector1,
    final Offset? vector2,
  ) {
    if (vector1 == null && vector2 == null) return 0;

    if (vector1 == null || vector2 == null) {
      final Offset vector = (vector1 ?? vector2)!;
      if (vector == const Offset(-1.0, -1.0)) return 1; //NE
      if (vector == const Offset(0.0, -1.0)) return 2; //N
      if (vector == const Offset(1.0, -1.0)) return 3; //NW
      if (vector == const Offset(1.0, 1.0)) return 4; //SE
      if (vector == const Offset(0.0, 1.0)) return 5; //S
      if (vector == const Offset(-1.0, 1.0)) return 6; //SW
    }

    if (vector1 == const Offset(-1.0, -1.0)) {
      if (vector2 == const Offset(0.0, -1.0)) return 7;
      if (vector2 == const Offset(1.0, -1.0)) return 8;
      if (vector2 == const Offset(1.0, 1.0)) return 9;
      if (vector2 == const Offset(0.0, 1.0)) return 10;
      if (vector2 == const Offset(-1.0, 1.0)) return 11;
    } else if (vector1 == const Offset(0.0, -1.0)) {
      if (vector2 == const Offset(1.0, -1.0)) return 12;
      if (vector2 == const Offset(1.0, 1.0)) return 13;
      if (vector2 == const Offset(0.0, 1.0)) return 14;
      if (vector2 == const Offset(-1.0, 1.0)) return 15;
    } else if (vector1 == const Offset(1.0, -1.0)) {
      if (vector2 == const Offset(1.0, 1.0)) return 16;
      if (vector2 == const Offset(0.0, 1.0)) return 17;
      if (vector2 == const Offset(-1.0, 1.0)) return 18;
    } else if (vector1 == const Offset(0.0, 1.0)) {
      if (vector2 == const Offset(1.0, 1.0)) return 19;
      if (vector2 == const Offset(-1.0, 1.0)) return 20;
    } else if (vector1 == const Offset(1.0, 1.0)) {
      if (vector2 == const Offset(-1.0, 1.0)) return 21;
    } else {
      return null;
    }

    return null;
    // throw ('No coordinate returned for [$vector1, $vector2]');
  }

  Future<void> setSprite() async {
    int orientationIndex;

    // log('$node : $firstConnectedNode, $secondConnectedNode');
    // assert(firstConnectedNode != secondConnectedNode);
    // log(
    //     '${nodesToVector(node, firstConnectedNode)},
    //     ${nodesToVector(node, secondConnectedNode)}');
    orientationIndex = orientationIndexFromVectorsOmnidirectional(
      nodesToVector(node, firstConnectedNode),
      nodesToVector(node, secondConnectedNode),
    );
    sprites.addAll(await _spritesFromCoordinates(type.index, orientationIndex));

    // print(
    //     '$node has connections to $firstConnectedNode and
    //     $secondConnectedNode so its orientationIndex
    //     returned $orientationIndex');
    if (type == FortificationType.gate) {
      openSprites.addAll(
        await _spritesFromCoordinates(type.index + 1, orientationIndex),
      );
    }
  }

  Future<Map<WallsDamageLevel, Sprite>> _spritesFromCoordinates(
    final int x,
    final int y,
  ) async {
    // print(
    //     'loading sprite positioned at: ${Vector2(wallTileSize.x * x,
    //     wallTileSize.y * y)}');
    final Map<WallsDamageLevel, Sprite> newSprites = {};

    await Future.forEach<WallsDamageLevel>(
      WallsDamageLevel.values,
      (final damageLevelValue) async => newSprites[damageLevelValue] =
          await _getSingleSprite(x, y, damageLevelValue),
    );

    return newSprites;
    //TODO: deal with map edges
  }

  Future<Sprite> _getSingleSprite(
    final int x,
    final int y,
    final WallsDamageLevel damageLevel,
  ) {
    return Sprite.load(
      wallsSpriteSource[damageLevel]!,
      srcPosition: Vector2(wallTileSize.x * x, wallTileSize.y * y),
      srcSize: wallTileSize,
    );
  }

  WallsDamageLevel get damageLevel {
    if (life < wallsMaxLife * 0.25) {
      return WallsDamageLevel.destroyed;
    } else if (life < wallsMaxLife * 0.5) {
      return WallsDamageLevel.severe;
    } else if (life < wallsMaxLife * 0.85) {
      return WallsDamageLevel.light;
    } else {
      return WallsDamageLevel.undamaged;
    }
  }

  @override
  Future<void> onLoad() async {
    await setSprite();
    return super.onLoad();
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    final resolvedActiveBattle = game.activeBattle;
    if (resolvedActiveBattle == null ||
        resolvedActiveBattle.battleOutcomeCompleter.isCompleted ||
        resolvedActiveBattle.isAiBattle) return;

    final tileInfo = resolvedActiveBattle.tileData[node.terrainTile]!;
    final effectiveSprite = ((type == FortificationType.gate && open)
        ? openSprites[damageLevel]
        : sprites[damageLevel])!;

    effectiveSprite.render(
      canvas,
      position: tileInfo.dstRect!.topLeft.toVector2(),
      size: tileInfo.dstRect!.size.toVector2(),
    );
  }
}

@JsonSerializable(explicitToJson: true)
class FortificationData {
  FortificationData({
    required final Id? id,
    final Set<SegmentData>? segments,
    this.provinceId,
  })  : id = id ?? uuid.v4(),
        segments = segments ?? {};

  static FortificationData fromJson(final Map<String, dynamic> json) =>
      _$FortificationDataFromJson(json);

  /// The principle of work:
  ///
  /// Asset preprocessor is filling names for fortification files:
  /// fort_small
  /// fort_test
  /// fort_city etc..
  ///
  /// File `provinces_forts.json` is responsible for assigning
  /// fort names for provinces.
  /// By [name]=[fortName]
  /// For example:
  /// ```json
  /// {
  ///   "Balasaghun": "city",
  ///   "all_provinces": "small"
  /// }
  /// ```
  /// Then asset preprocessor generates a name like 'fort_[fortName].json'
  /// which will be used for the first game start
  /// In-game save, every province will always use own
  /// fort with saved state, life etc

  static Future<FortificationData> fromJsonPath(final String fortName) async {
    assert(
      fortName.isNotEmpty,
      'path should be filled, otherwise do not use this method',
    );
    final jsonString = await Flame.assets.readFile('json/$fortName');
    return fromJson(jsonDecode(jsonString));
  }

  Map<String, dynamic> toJson() => _$FortificationDataToJson(this);

  Future<Fortification> toFortification({
    required final TransoxianaGame game,
  }) async =>
      Fortification._fromData(
        data: this,
        game: game,
        province: await _loadProvince(game: game),
        segments: await _loadSegments(game: game),
      );

  final Set<SegmentData> segments;
  final Id id;
  final Id? provinceId;

  Future<Province?> _loadProvince({required final TransoxianaGame game}) async {
    if (provinceId == null || provinceId?.isEmpty == true) return null;
    return game.campaignRuntimeData.getProvinceById(provinceId!);
  }

  Future<Set<Segment>> _loadSegments({
    required final TransoxianaGame game,
  }) async {
    final loadedSegments =
        await segments.convert((final e) async => e.toSegment(game: game));
    return loadedSegments.toSet();
  }
}

class Fortification extends Component
    with EquatableMixin
    implements GameRef, DataSourceRef<FortificationData, Fortification> {
  Fortification._fromData({
    required this.data,
    required this.game,
    required this.segments,
    required this.province,
  }) : super(priority: ComponentsRenderPriority.battleWalls.value) {
    cityWallsIndicator = CityWallsIndicator(game, this);
  }

  final orderedSegments = OrderedSet<Segment>(
    Comparing.on((final t) => t.node.y + (t.node.x.isEven ? 0.5 : 0)),
  );

  Id get id => data.id;

  @override
  Future<FortificationData> toData() async => FortificationData(
        id: id,
        provinceId: province?.id,
        segments: await segments.convert((final e) async => e.toData()),
      );

  @override
  Future<void> refillData(final Fortification otherType) async {
    data = otherType.data;
  }

  late CityWallsIndicator cityWallsIndicator;

  @override
  FortificationData data;
  Province? province;
  Set<Segment> segments;
  @override
  TransoxianaGame game;

  /// average life of segments of this fortification from 0.0 to wallsMaxLife
  double get integrity =>
      segments.fold<double>(
        0.0,
        (final previousValue, final element) => previousValue + element.life,
      ) /
      segments.length;

  @override
  Future<void>? onLoad() async {
    updateNodeConnections();
    if (province == null || province?.isNotVisibleToPlayer == true) return;
    await addAll(orderedSegments);
    await super.onLoad();
  }

  void updateNodeConnections() {
    log('Updating fort node connections');

    assert(game.activeBattle != null, 'activeBattle is null');

    // update references to node with values from the current activeBattle
    for (final Segment segment in segments) {
      segment
        ..removeFromParent()
        ..refreshNodes(game.activeBattle!.nodes);
    }

    //update connected nodes
    for (final Segment segment in segments) {
      final Set<Node> cachedAdjacentNodes = adjacentNodes(segment.node, game);
      // segment.node.adjacentNodeDistances.keys.toSet();//adjacentNodes(segment.node, game);//do not use as these have not been updated yet

      assert(
        cachedAdjacentNodes.isNotEmpty,
        'no adjacent nodes returned for ${segment.node}',
      );

      for (final Segment otherSegment in segments) {
        if (cachedAdjacentNodes.contains(otherSegment.node)) {
          if (segment.firstConnectedNode == null &&
              otherSegment.secondConnectedNode == null &&
              segment.secondConnectedNode != otherSegment.node) {
            segment.firstConnectedNode = otherSegment.node;
            otherSegment.secondConnectedNode = segment.node;
          } else if (segment.secondConnectedNode == null &&
              otherSegment.firstConnectedNode == null &&
              segment.secondConnectedNode != otherSegment.node) {
            segment.secondConnectedNode = otherSegment.node;
            otherSegment.firstConnectedNode = segment.node;
          }
        }
      }
    }
    orderedSegments.addAll(segments);
  }

  @override
  List<Object?> get props => [id];
}
