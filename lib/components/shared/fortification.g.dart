// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'fortification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

SegmentData _$SegmentDataFromJson(Map<String, dynamic> json) => SegmentData(
      type: $enumDecode(_$FortificationTypeEnumMap, json['type']),
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      entranceX: (json['entranceX'] as num).toDouble(),
      entranceY: (json['entranceY'] as num).toDouble(),
      open: json['open'] as bool? ?? false,
      life: (json['life'] as num?)?.toDouble() ?? wallsMaxLife,
    );

Map<String, dynamic> _$SegmentDataToJson(SegmentData instance) =>
    <String, dynamic>{
      'type': _$FortificationTypeEnumMap[instance.type]!,
      'life': instance.life,
      'open': instance.open,
      'x': instance.x,
      'y': instance.y,
      'entranceX': instance.entranceX,
      'entranceY': instance.entranceY,
    };

const _$FortificationTypeEnumMap = {
  FortificationType.wall: 'wall',
  FortificationType.tower: 'tower',
  FortificationType.gate: 'gate',
};

FortificationData _$FortificationDataFromJson(Map<String, dynamic> json) =>
    FortificationData(
      id: json['id'] as String?,
      segments: (json['segments'] as List<dynamic>?)
          ?.map((e) => SegmentData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      provinceId: json['provinceId'] as String?,
    );

Map<String, dynamic> _$FortificationDataToJson(FortificationData instance) =>
    <String, dynamic>{
      'segments': instance.segments.map((e) => e.toJson()).toList(),
      'id': instance.id,
      'provinceId': instance.provinceId,
    };
