// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'army_templates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ArmyTemplateData _$ArmyTemplateDataFromJson(Map<String, dynamic> json) =>
    ArmyTemplateData(
      name: json['name'] as String,
      unitsTypesIds: (json['units'] as List<dynamic>)
          .map((e) => (e as List<dynamic>)
              .map((e) => $enumDecode(_$UnitTypeNamesEnumMap, e))
              .toList())
          .toList(),
      id: json['id'] as String?,
    );

Map<String, dynamic> _$ArmyTemplateDataToJson(ArmyTemplateData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'units': instance.unitsTypesIds
          .map((e) => e.map((e) => _$UnitTypeNamesEnumMap[e]!).toList())
          .toList(),
      'name': instance.name,
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
