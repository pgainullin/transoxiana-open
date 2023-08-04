import 'package:equatable/equatable.dart';
import 'package:flame/game.dart';
import 'package:flame/sprite.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/direction.dart';
import 'package:utils/utils.dart';

part 'unit_types.g.dart';

enum UnitTypeNames {
  @JsonValue('Cannon')
  cannon,
  @JsonValue('Catapult')
  catapult,
  @JsonValue('Light cavalry')
  lightCavalry,
  @JsonValue('CHUCK NORRIS')
  chuckNorris,
  @JsonValue('Heavy cavalry')
  heavyCavalry,
  @JsonValue('Swordsmen')
  swordsmen,
  @JsonValue('Pikemen')
  pikemen,
  @JsonValue('Archers')
  archers,
  @JsonValue('Elephants')
  elephants,
  @JsonValue('Camel riders')
  camelRiders,
  @JsonValue('Mongolian light cavalry')
  mongolianLightCavalry,
  @JsonValue('Captives')
  captives,
}

/// immutable core parameters of a unit that are the same for all units
/// of this type
///
/// This class is not serializable and should be always created from
/// serializable [UnitTypeData]
class UnitType extends UnitTypeData
    implements DataSourceRef<UnitTypeData, UnitType> {
  // ************************************
  //       Factories start
  // ************************************
  UnitType._fromData({
    required this.data,
    required this.sprites,
    required this.sprite,
  }) : super(
          id: data.id,
          bombardFactor: data.bombardFactor,
          cost: data.cost,
          maxMomentum: data.maxMomentum,
          meleeReach: data.meleeReach,
          meleeStrength: data.meleeStrength,
          momentumBreak: data.momentumBreak,
          name: data.name,
          rangedSpeed: data.rangedSpeed,
          rangedStrength: data.rangedStrength,
          shootingRange: data.shootingRange,
          speed: data.speed,
          spriteId: data.spriteId,
          spritePath: data.spritePath,
          x: data.x,
          y: data.y,
        );

  @override
  Future<void> refillData(final UnitType otherType) async {
    assert(
      otherType == this,
      'You trying to update different UnitType.',
    );
    final newData = await otherType.toData();
    data = newData;
    bombardFactor = newData.bombardFactor;
    cost = newData.cost;
    maxMomentum = newData.maxMomentum;
    meleeReach = newData.meleeReach;
    meleeStrength = newData.meleeStrength;
    momentumBreak = newData.momentumBreak;
    name = newData.name;
    rangedSpeed = newData.rangedSpeed;
    rangedStrength = newData.rangedStrength;
    shootingRange = newData.shootingRange;
    speed = newData.speed;
    spriteId = newData.spriteId;
    spritePath = newData.spritePath;
    x = newData.x;
    y = newData.y;
    sprites.assignAll(otherType.sprites);
    sprite = otherType.sprite;
  }

  @override
  Future<UnitTypeData> toData() async => UnitTypeData(
        meleeReach: meleeReach,
        meleeStrength: meleeStrength,
        name: name,
        rangedSpeed: rangedSpeed,
        rangedStrength: rangedStrength,
        shootingRange: shootingRange,
        speed: speed,
        spriteId: spriteId,
        spritePath: spritePath,
        id: id,
        x: x,
        y: y,
        bombardFactor: bombardFactor,
        cost: cost,
        maxMomentum: maxMomentum,
        momentumBreak: momentumBreak,
      );

  // for AI training API
  Map<String, dynamic> toAiJson() {
    return Map<String, dynamic>.fromEntries([
      MapEntry('unitTypeIndex', id),
    ]);
  }

  UnitData toUnitData({
    required final NationData nation,
    required final UnitId? id,
  }) {
    return UnitData(
      id: id ??
          UnitId(
            unitId: null,
            typeId: this.id,
            nationId: nation.id,
          ),
    );
  }

  Future<Unit> toUnit({
    required final TransoxianaGame game,
    required final NationData nation,
    required final UnitId? id,
  }) async {
    return toUnitData(
      nation: nation,
      id: id,
    ).toUnit(game: game);
  }
  // ************************************
  //       Factories end
  // ************************************

  Sprite sprite;
  final Map<Direction, Sprite> sprites;
  @override
  UnitTypeData data;
  double spriteScaleForHUD(final double customScale) =>
      customScale * liveSpriteScale;
  Vector2 spriteSizeForHUD(final double customScale) =>
      unscaledSpriteSize * spriteScaleForHUD(customScale);
  double get liveSpriteScale {
    return (sprites[Direction.south] != null
            ? unitSpriteScaleWithDirections
            : 1.0) *
        0.5;
  }

  Vector2 get unscaledSpriteSize {
    final southSprite = sprites[Direction.south];
    return southSprite != null
        ? Vector2(
            southSprite.image.width.toDouble(),
            southSprite.image.height.toDouble(),
          )
        : Vector2(
            unitSpriteWidthScaled,
            unitSpriteHeightScaled,
          );
  }
}

/// immutable core parameters of a unit that are the same for all units
/// of this type
///
/// This class holds all serializable data
///
/// Use [toType] function to create [UnitType]
@JsonSerializable(explicitToJson: true)
class UnitTypeData with EquatableMixin {
  UnitTypeData({
    required this.id,
    required this.meleeReach,
    required this.meleeStrength,
    required this.name,
    required this.rangedSpeed,
    required this.rangedStrength,
    required this.shootingRange,
    required this.speed,
    required this.x,
    required this.y,
    required this.spriteId,
    required this.spritePath,
    this.cost = 1000.0,
    this.maxMomentum = 0,
    final double? bombardFactor,
    this.momentumBreak = 0,
  }) : bombardFactor = bombardFactor ?? 0;
  final UnitTypeNames id;
  String name;

  /// number of road-to-road tiles a unit can march in a turn
  int speed;

  /// 1-10
  int meleeStrength;

  /// 1-2  - how many tiles away can they perform a melee attack
  int meleeReach;

  /// 0-10
  int rangedStrength;

  /// 1.0 = full ranged strength vs fortifications
  double bombardFactor;

  /// number of shots in a turn
  int rangedSpeed;

  ///1-3 number of tiles away the unit can hit a target without obstacles
  int shootingRange;
  int maxMomentum;
  int momentumBreak;
  double cost;

  // ************************************
  //          sprites params
  // ************************************
  int x;
  int y;
  @JsonKey(name: 'spriteSet')
  String spritePath;
  @JsonKey(name: 'stringId')
  String? spriteId;

  static UnitTypeData fromJson(final Map<String, dynamic> json) =>
      _$UnitTypeDataFromJson(json);
  Map<String, dynamic> toJson() => _$UnitTypeDataToJson(this);

  Future<UnitType> toType() async {
    // Map<String, dynamic> unitTypeMap = this.game.unitTypes[unitTypeIndex];
    final sprite = await _loadSprite(path: spritePath, x: x, y: y);
    Map<Direction, Sprite> sprites = {};
    final resolvedSpriteId = spriteId;
    if (resolvedSpriteId != null && resolvedSpriteId.isNotEmpty) {
      sprites = await _loadSprites(spriteId: resolvedSpriteId);
    }
    return UnitType._fromData(
      sprites: sprites,
      sprite: sprite,
      data: this,
    );
  }

  static Future<Sprite> _loadSprite({
    required final String path,
    required final num x,
    required final num y,
  }) async =>
      await Sprite.load(
        path,
        srcSize: Vector2(64.0, 48.0),
        srcPosition: Vector2(
          (x * 64.0).toDouble(),
          (y * 48.0).toDouble(),
        ),
      );
  static Future<Map<Direction, Sprite>> _loadSprites({
    required final String spriteId,
  }) async {
    final sprites = <Direction, Sprite>{};
    await Future.forEach<Direction>(Direction.values, (final direction) async {
      sprites[direction] = await Sprite.load(
        'units/$spriteId-${direction.index}.png',
        // x: 0.0,
        // y: 0.0,
        // width: unitSpriteWidthOriginal,
        // height: unitSpriteHeightOriginal,
      );
    });
    return sprites;
  }

  @JsonKey(ignore: true)
  @override
  List<Object?> get props => [id];

  @JsonKey(ignore: true)
  @override
  bool? get stringify => true;

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;
}
