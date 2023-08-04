// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitId _$UnitIdFromJson(Map<String, dynamic> json) => UnitId(
      unitId: json['unitId'] as String?,
      typeId: $enumDecode(_$UnitTypeNamesEnumMap, json['typeId']),
      nationId: json['nationId'] as String,
    );

Map<String, dynamic> _$UnitIdToJson(UnitId instance) => <String, dynamic>{
      'unitId': instance.unitId,
      'typeId': _$UnitTypeNamesEnumMap[instance.typeId]!,
      'nationId': instance.nationId,
    };

const _$UnitTypeNamesEnumMap = {
  UnitTypeNames.cannon: 'Cannon',
  UnitTypeNames.catapult: 'Catapult',
  UnitTypeNames.lightCavalry: 'Light cavalry',
  UnitTypeNames.chuckNorris: 'CHUCK NORRIS',
  UnitTypeNames.heavyCavalry: 'Heavy cavalry',
  UnitTypeNames.swordsmen: 'Swordsmen',
  UnitTypeNames.pikemen: 'Pikemen',
  UnitTypeNames.archers: 'Archers',
  UnitTypeNames.elephants: 'Elephants',
  UnitTypeNames.camelRiders: 'Camel riders',
  UnitTypeNames.mongolianLightCavalry: 'Mongolian light cavalry',
  UnitTypeNames.captives: 'Captives',
};

UnitData _$UnitDataFromJson(Map<String, dynamic> json) => UnitData(
      id: UnitId.fromJson(json['id'] as Map<String, dynamic>),
      visionProvinceRange: json['visionProvinceRange'] as int? ?? 1,
      health: (json['health'] as num?)?.toDouble() ?? 100.0,
      morale: (json['morale'] as num?)?.toDouble() ?? 100.0,
      progress: (json['progress'] as num?)?.toDouble() ?? 0.0,
      shotProgress: (json['shotProgress'] as num?)?.toDouble() ?? 0.0,
      meleeProgress: (json['meleeProgress'] as num?)?.toDouble() ?? 0.0,
      flankCount: json['flankCount'] as int? ?? 0,
      direction: $enumDecodeNullable(_$DirectionEnumMap, json['direction']) ??
          Direction.south,
      stance:
          $enumDecodeNullable(_$StanceEnumMap, json['stance']) ?? Stance.attack,
      destinationSetByAi: json['destinationSetByAi'] as bool? ?? false,
      engaged: json['engaged'] as bool? ?? false,
      armyId: json['armyId'] == null
          ? null
          : ArmyId.fromJson(json['armyId'] as Map<String, dynamic>),
    )..momentum = json['momentum'] as int;

Map<String, dynamic> _$UnitDataToJson(UnitData instance) => <String, dynamic>{
      'armyId': instance.armyId?.toJson(),
      'id': instance.id.toJson(),
      'health': instance.health,
      'morale': instance.morale,
      'progress': instance.progress,
      'shotProgress': instance.shotProgress,
      'meleeProgress': instance.meleeProgress,
      'flankCount': instance.flankCount,
      'direction': _$DirectionEnumMap[instance.direction]!,
      'stance': _$StanceEnumMap[instance.stance]!,
      'destinationSetByAi': instance.destinationSetByAi,
      'engaged': instance.engaged,
      'momentum': instance.momentum,
      'visionProvinceRange': instance.visionProvinceRange,
    };

const _$DirectionEnumMap = {
  Direction.northEast: 'northEast',
  Direction.southEast: 'southEast',
  Direction.south: 'south',
  Direction.southWest: 'southWest',
  Direction.northWest: 'northWest',
  Direction.north: 'north',
};

const _$StanceEnumMap = {
  Stance.attack: 'attack',
  Stance.defend: 'defend',
  Stance.bombard: 'bombard',
};
