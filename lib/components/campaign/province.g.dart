// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'province.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProvinceData _$ProvinceDataFromJson(Map<String, dynamic> json) => ProvinceData(
      name: json['name'] as String,
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      friendlyX: (json['friendlyX'] as num).toDouble(),
      friendlyY: (json['friendlyY'] as num).toDouble(),
      enemyX: (json['enemyX'] as num).toDouble(),
      enemyY: (json['enemyY'] as num).toDouble(),
      nationId: json['nationId'] as String,
      id: json['id'] as String?,
      weatherType:
          $enumDecodeNullable(_$WeatherTypeEnumMap, json['weatherType']),
      population: (json['population'] as num?)?.toDouble(),
      provisionsCapacity: (json['provisionsCapacity'] as num?)?.toDouble(),
      provisionsStored: (json['provisionsStored'] as num?)?.toDouble(),
      goldYieldPerPop: (json['goldYieldPerPop'] as num?)?.toDouble(),
      goldStored: (json['goldStored'] as num?)?.toDouble(),
      provisionsYield: (json['provisionsYield'] as num?)?.toDouble(),
      cumulativeIrrigation: (json['cumulativeIrrigation'] as num?)?.toDouble(),
      hasBeenTaxedThisSeason: json['hasBeenTaxedThisSeason'] as bool?,
      hasTrainedUnitsThisSeason: json['hasTrainedUnitsThisSeason'] as bool?,
      specialUnitsIds: (json['specialUnits'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$UnitTypeNamesEnumMap, e))
          .toSet(),
      armies: (json['armies'] as List<dynamic>?)
          ?.map((e) => ArmyId.fromJson(e as Map<String, dynamic>))
          .toSet(),
      attackDeploymentPoints: (json['attackDeploymentPoints'] as List<dynamic>?)
          ?.map((e) => (e as List<dynamic>).map((e) => e as int).toList())
          .toList(),
      defenceDeploymentPoints:
          (json['defenceDeploymentPoints'] as List<dynamic>?)
              ?.map((e) => (e as List<dynamic>).map((e) => e as int).toList())
              .toList(),
      edges:
          (json['edges'] as List<dynamic>?)?.map((e) => e as String).toList(),
      visibleForNations: (json['visibleForNations'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet(),
      maskSvgPath: json['mask'] as String?,
      fort: json['fort'] == null
          ? null
          : FortificationData.fromJson(json['fort'] as Map<String, dynamic>),
      fortPath: json['fortPath'] as String?,
      mapPath: json['map'] as String?,
    );

Map<String, dynamic> _$ProvinceDataToJson(ProvinceData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'x': instance.x,
      'y': instance.y,
      'width': instance.width,
      'height': instance.height,
      'friendlyX': instance.friendlyX,
      'friendlyY': instance.friendlyY,
      'enemyX': instance.enemyX,
      'enemyY': instance.enemyY,
      'mask': instance.maskSvgPath,
      'nationId': instance.nationId,
      'id': instance.id,
      'map': instance.mapPath,
      'fortPath': instance.fortPath,
      'fort': instance.fort?.toJson(),
      'visibleForNations': instance.visibleForNations.toList(),
      'attackDeploymentPoints': instance.attackDeploymentPoints,
      'defenceDeploymentPoints': instance.defenceDeploymentPoints,
      'population': instance.population,
      'provisionsCapacity': instance.provisionsCapacity,
      'provisionsStored': instance.provisionsStored,
      'provisionsYield': instance.provisionsYield,
      'cumulativeIrrigation': instance.cumulativeIrrigation,
      'goldStored': instance.goldStored,
      'goldYieldPerPop': instance.goldYieldPerPop,
      'hasBeenTaxedThisSeason': instance.hasBeenTaxedThisSeason,
      'hasTrainedUnitsThisSeason': instance.hasTrainedUnitsThisSeason,
      'specialUnits': instance.specialUnitsIds
          .map((e) => _$UnitTypeNamesEnumMap[e]!)
          .toList(),
      'edges': instance.edges,
      'armies': instance.armies.map((e) => e.toJson()).toList(),
      'weatherType': _$WeatherTypeEnumMap[instance.weatherType]!,
    };

const _$WeatherTypeEnumMap = {
  WeatherType.sunny: 'sunny',
  WeatherType.cloudy: 'cloudy',
  WeatherType.rain: 'rain',
  WeatherType.snow: 'snow',
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
