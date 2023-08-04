// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'army.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArmyId _$ArmyIdFromJson(Map<String, dynamic> json) => ArmyId(
      armyId: json['armyId'] as String?,
      nationId: json['nationId'] as String,
    );

Map<String, dynamic> _$ArmyIdToJson(ArmyId instance) => <String, dynamic>{
      'armyId': instance.armyId,
      'nationId': instance.nationId,
    };

ArmyData _$ArmyDataFromJson(Map<String, dynamic> json) => ArmyData(
      id: ArmyId.fromJson(json['id'] as Map<String, dynamic>),
      name: json['name'] as String?,
      locationId: json['locationId'] as String?,
      destinationId: json['destinationId'] as String?,
      nextProvinceId: json['nextProvinceId'] as String?,
      commander: json['commander'] == null
          ? null
          : CommanderData.fromJson(json['commander'] as Map<String, dynamic>),
      mode: json['mode'] as int?,
      progress: (json['progress'] as num?)?.toDouble(),
      goldCarried: (json['goldCarried'] as num?)?.toDouble(),
      defeated: json['defeated'] as bool?,
      siegeMode: json['siegeMode'] as bool?,
      unitIds: (json['units'] as List<dynamic>?)
          ?.map((e) => UnitId.fromJson(e as Map<String, dynamic>))
          .toSet(),
    );

Map<String, dynamic> _$ArmyDataToJson(ArmyData instance) => <String, dynamic>{
      'id': instance.id.toJson(),
      'name': instance.name,
      'mode': instance.mode.toJson(),
      'units': instance.unitIds?.map((e) => e.toJson()).toList(),
      'commander': instance.commander?.toJson(),
      'locationId': instance.locationId,
      'destinationId': instance.destinationId,
      'nextProvinceId': instance.nextProvinceId,
      'progress': instance.progress,
      'goldCarried': instance.goldCarried,
      'defeated': instance.defeated,
      'siegeMode': instance.siegeMode,
    };
