// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tactical_ai.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TacticalInfoData _$TacticalInfoDataFromJson(Map<String, dynamic> json) =>
    TacticalInfoData(
      battleId: json['battleId'] as String,
      nationId: json['nationId'] as String,
      initialized: json['initialized'] as bool? ?? false,
    );

Map<String, dynamic> _$TacticalInfoDataToJson(TacticalInfoData instance) =>
    <String, dynamic>{
      'battleId': instance.battleId,
      'nationId': instance.nationId,
      'initialized': instance.initialized,
    };
