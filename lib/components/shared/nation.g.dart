// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NationData _$NationDataFromJson(Map<String, dynamic> json) => NationData(
      name: json['name'] as String,
      color: colorFromJson(json['color'] as String),
      id: json['id'] as String?,
      aiId: json['aiId'] == null
          ? null
          : AiId.fromJson(json['aiId'] as Map<String, dynamic>),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      battleEvents: (json['battleEvents'] as List<dynamic>?)
          ?.map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      isDefeated: json['isDefeated'] as bool?,
      takeCaptives: json['takeCaptives'] as bool?,
      isIndependent: json['isIndependent'] as bool?,
      isPlayable: json['isPlayable'] as bool?,
      unemployedCommanders: (json['unemployedCommanders'] as List<dynamic>?)
          ?.map((e) => CommanderData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      armyTemplatesIds: (json['armyTemplates'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet(),
      specialUnitsIds: (json['specialUnits'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$UnitTypeNamesEnumMap, e))
          .toSet(),
      diplomaticRelationships:
          (json['diplomaticRelationships'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, $enumDecode(_$DiplomaticStatusEnumMap, e)),
      ),
    );

Map<String, dynamic> _$NationDataToJson(NationData instance) =>
    <String, dynamic>{
      'id': instance.id,
      'aiId': instance.aiId?.toJson(),
      'name': instance.name,
      'color': colorToJson(instance.color),
      'specialUnits': instance.specialUnitsIds
          .map((e) => _$UnitTypeNamesEnumMap[e]!)
          .toList(),
      'armyTemplates': instance.armyTemplatesIds.toList(),
      'unemployedCommanders':
          instance.unemployedCommanders.map((e) => e.toJson()).toList(),
      'diplomaticRelationships': instance.diplomaticRelationships
          .map((k, e) => MapEntry(k, _$DiplomaticStatusEnumMap[e]!)),
      'isDefeated': instance.isDefeated,
      'takeCaptives': instance.takeCaptives,
      'isPlayable': instance.isPlayable,
      'isIndependent': instance.isIndependent,
      'events': instance.events.map((e) => e.toJson()).toList(),
      'battleEvents': instance.battleEvents.map((e) => e.toJson()).toList(),
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

const _$DiplomaticStatusEnumMap = {
  DiplomaticStatus.war: 'war',
  DiplomaticStatus.peace: 'peace',
  DiplomaticStatus.alliance: 'alliance',
};
