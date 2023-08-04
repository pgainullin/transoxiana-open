// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'unit_types.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UnitTypeData _$UnitTypeDataFromJson(Map<String, dynamic> json) => UnitTypeData(
      id: $enumDecode(_$UnitTypeNamesEnumMap, json['id']),
      meleeReach: json['meleeReach'] as int,
      meleeStrength: json['meleeStrength'] as int,
      name: json['name'] as String,
      rangedSpeed: json['rangedSpeed'] as int,
      rangedStrength: json['rangedStrength'] as int,
      shootingRange: json['shootingRange'] as int,
      speed: json['speed'] as int,
      x: json['x'] as int,
      y: json['y'] as int,
      spriteId: json['stringId'] as String?,
      spritePath: json['spriteSet'] as String,
      cost: (json['cost'] as num?)?.toDouble() ?? 1000.0,
      maxMomentum: json['maxMomentum'] as int? ?? 0,
      bombardFactor: (json['bombardFactor'] as num?)?.toDouble(),
      momentumBreak: json['momentumBreak'] as int? ?? 0,
    );

Map<String, dynamic> _$UnitTypeDataToJson(UnitTypeData instance) =>
    <String, dynamic>{
      'id': _$UnitTypeNamesEnumMap[instance.id]!,
      'name': instance.name,
      'speed': instance.speed,
      'meleeStrength': instance.meleeStrength,
      'meleeReach': instance.meleeReach,
      'rangedStrength': instance.rangedStrength,
      'bombardFactor': instance.bombardFactor,
      'rangedSpeed': instance.rangedSpeed,
      'shootingRange': instance.shootingRange,
      'maxMomentum': instance.maxMomentum,
      'momentumBreak': instance.momentumBreak,
      'cost': instance.cost,
      'x': instance.x,
      'y': instance.y,
      'spriteSet': instance.spritePath,
      'stringId': instance.spriteId,
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
