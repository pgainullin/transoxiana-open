// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ai.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AiId _$AiIdFromJson(Map<String, dynamic> json) => AiId(
      aiId: json['aiId'] as String?,
      nationId: json['nationId'] as String,
    );

Map<String, dynamic> _$AiIdToJson(AiId instance) => <String, dynamic>{
      'aiId': instance.aiId,
      'nationId': instance.nationId,
    };

AiData _$AiDataFromJson(Map<String, dynamic> json) => AiData(
      id: AiId.fromJson(json['id'] as Map<String, dynamic>),
      dateOfLastPeaceOffer:
          (json['dateOfLastPeaceOffer'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, GameDate.fromJson(e as Map<String, dynamic>)),
      ),
    );

Map<String, dynamic> _$AiDataToJson(AiData instance) => <String, dynamic>{
      'id': instance.id.toJson(),
      'dateOfLastPeaceOffer':
          instance.dateOfLastPeaceOffer.map((k, e) => MapEntry(k, e.toJson())),
    };
