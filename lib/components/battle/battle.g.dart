// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'battle.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BattleData _$BattleDataFromJson(Map<String, dynamic> json) => BattleData(
      armies: (json['armies'] as List<dynamic>)
          .map((e) => ArmyId.fromJson(e as Map<String, dynamic>))
          .toSet(),
      provinceId: json['provinceId'] as String,
      mapPath: json['mapPath'] as String,
      id: json['id'] as String?,
      tacticalInfo: (json['tacticalInfo'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, TacticalInfoData.fromJson(e as Map<String, dynamic>)),
      ),
      units: (json['units'] as List<dynamic>?)
          ?.map((e) => UnitId.fromJson(e as Map<String, dynamic>))
          .toSet(),
      nations:
          (json['nations'] as List<dynamic>?)?.map((e) => e as String).toSet(),
      isFirst: json['isFirst'] as bool? ?? false,
      isLast: json['isLast'] as bool? ?? false,
    );

Map<String, dynamic> _$BattleDataToJson(BattleData instance) =>
    <String, dynamic>{
      'mapPath': instance.mapPath,
      'isFirst': instance.isFirst,
      'isLast': instance.isLast,
      'armies': instance.armies.map((e) => e.toJson()).toList(),
      'provinceId': instance.provinceId,
      'nations': instance.nations.toList(),
      'tacticalInfo':
          instance.tacticalInfo.map((k, e) => MapEntry(k, e.toJson())),
      'units': instance.units.map((e) => e.toJson()).toList(),
      'id': instance.id,
    };
