// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'events.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventData _$EventDataFromJson(Map<String, dynamic> json) => EventData(
      nationId: json['nationId'] as String,
      condition: EventConditionData.fromJson(
          json['condition'] as Map<String, dynamic>),
      consequence: EventConsequenceData.fromJson(
          json['consequence'] as Map<String, dynamic>),
      triggerType:
          $enumDecodeNullable(_$EventTriggerTypeEnumMap, json['triggerType']),
      triggered: json['triggered'] as bool?,
    );

Map<String, dynamic> _$EventDataToJson(EventData instance) => <String, dynamic>{
      'triggerType': _$EventTriggerTypeEnumMap[instance.triggerType]!,
      'triggered': instance.triggered,
      'nationId': instance.nationId,
      'condition': instance.condition.toJson(),
      'consequence': instance.consequence.toJson(),
    };

const _$EventTriggerTypeEnumMap = {
  EventTriggerType.startTurn: 'startTurn',
  EventTriggerType.endTurn: 'endTurn',
  EventTriggerType.selection: 'selection',
};

EventConditionData _$EventConditionDataFromJson(Map<String, dynamic> json) =>
    EventConditionData(
      type: $enumDecode(_$EventConditionTypeEnumMap, json['type']),
      nationId: json['nationId'] as String,
      subconditions: (json['subconditions'] as List<dynamic>?)
          ?.map((e) => EventConditionData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      nationsToCapture: (json['nationsToCapture'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet(),
      provincesToCapture: (json['provincesToCapture'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet(),
      armiesToKill: (json['armiesToKill'] as List<dynamic>?)
          ?.map((e) => ArmyId.fromJson(e as Map<String, dynamic>))
          .toSet(),
    );

Map<String, dynamic> _$EventConditionDataToJson(EventConditionData instance) =>
    <String, dynamic>{
      'type': _$EventConditionTypeEnumMap[instance.type]!,
      'nationId': instance.nationId,
      'subconditions': instance.subconditions.map((e) => e.toJson()).toList(),
      'nationsToCapture': instance.nationsToCapture.toList(),
      'provincesToCapture': instance.provincesToCapture.toList(),
      'armiesToKill': instance.armiesToKill.map((e) => e.toJson()).toList(),
    };

const _$EventConditionTypeEnumMap = {
  EventConditionType.soleSurvivor: 'soleSurvivor',
  EventConditionType.captureNations: 'captureNations',
  EventConditionType.captureProvinces: 'captureProvinces',
  EventConditionType.killArmies: 'killArmies',
  EventConditionType.composedConditionAND: 'composedConditionAND',
  EventConditionType.alwaysFalse: 'alwaysFalse',
  EventConditionType.alwaysTrue: 'alwaysTrue',
  EventConditionType.dateIsOrAfter: 'dateIsOrAfter',
  EventConditionType.dateIsOrBefore: 'dateIsOrBefore',
  EventConditionType.dateIs: 'dateIs',
  EventConditionType.composedConditionOR: 'composedConditionOR',
  EventConditionType.campaignStart: 'campaignStart',
  EventConditionType.battleStart: 'battleStart',
  EventConditionType.battleSelectPlayerUnit: 'battleSelectPlayerUnit',
  EventConditionType.campaignSelectPlayerArmy: 'campaignSelectPlayerArmy',
  EventConditionType.composedConditionNOT: 'composedConditionNOT',
};

EventConsequenceData _$EventConsequenceDataFromJson(
        Map<String, dynamic> json) =>
    EventConsequenceData(
      type: $enumDecode(_$EventConsequenceTypeEnumMap, json['type']),
      nationId: json['nationId'] as String,
      otherConsequences: (json['otherConsequences'] as List<dynamic>?)
          ?.map((e) => EventConsequenceData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      provincesAffected: (json['provincesAffected'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toSet(),
      armiesAffected: (json['armiesAffected'] as List<dynamic>?)
          ?.map((e) => ArmyId.fromJson(e as Map<String, dynamic>))
          .toSet(),
      message: json['message'] as String?,
      otherNationId: json['otherNationId'] as String?,
    );

Map<String, dynamic> _$EventConsequenceDataToJson(
        EventConsequenceData instance) =>
    <String, dynamic>{
      'type': _$EventConsequenceTypeEnumMap[instance.type]!,
      'nationId': instance.nationId,
      'otherConsequences':
          instance.otherConsequences.map((e) => e.toJson()).toList(),
      'provincesAffected': instance.provincesAffected.toList(),
      'armiesAffected': instance.armiesAffected.map((e) => e.toJson()).toList(),
      'message': instance.message,
      'otherNationId': instance.otherNationId,
    };

const _$EventConsequenceTypeEnumMap = {
  EventConsequenceType.victory: 'victory',
  EventConsequenceType.defeat: 'defeat',
  EventConsequenceType.dialogue: 'dialogue',
  EventConsequenceType.composedConsequenceOR: 'composedConsequenceOR',
  EventConsequenceType.composedConsequenceAND: 'composedConsequenceAND',
  EventConsequenceType.declareWar: 'declareWar',
  EventConsequenceType.annex: 'annex',
  EventConsequenceType.peaceOffer: 'peaceOffer',
  EventConsequenceType.fortifiedBattleStarted: 'fortifiedBattleStarted',
  EventConsequenceType.nonFortifiedBattleStarted: 'nonFortifiedBattleStarted',
  EventConsequenceType.battlePlayerUnitSelected: 'battlePlayerUnitSelected',
  EventConsequenceType.campaignPlayerArmySelected: 'campaignPlayerArmySelected',
  EventConsequenceType.campaignStarted: 'campaignStarted',
  EventConsequenceType.handoverProvinces: 'handoverProvinces',
  EventConsequenceType.handoverArmies: 'handoverArmies',
};
