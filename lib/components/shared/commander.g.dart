// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'commander.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CommanderData _$CommanderDataFromJson(Map<String, dynamic> json) =>
    CommanderData(
      name: json['name'] as String? ?? 'Unknown Commander',
      birthYear: json['birthYear'] as int? ?? 1195,
      moraleBoostMultiple:
          (json['moraleBoostMultiple'] as num?)?.toDouble() ?? 1.0,
      moraleRange: json['moraleRange'] as int? ?? 3,
      attritionMultiple: (json['attritionMultiple'] as num?)?.toDouble() ?? 1.0,
      unitMeleeBonus: (json['unitMeleeBonus'] as num?)?.toDouble() ?? 1.0,
      unitRangedBonus: (json['unitRangedBonus'] as num?)?.toDouble() ?? 1.0,
      unit: json['unit'] == null
          ? null
          : UnitData.fromJson(json['unit'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$CommanderDataToJson(CommanderData instance) =>
    <String, dynamic>{
      'name': instance.name,
      'birthYear': instance.birthYear,
      'unit': instance.unit?.toJson(),
      'moraleBoostMultiple': instance.moraleBoostMultiple,
      'moraleRange': instance.moraleRange,
      'attritionMultiple': instance.attritionMultiple,
      'unitMeleeBonus': instance.unitMeleeBonus,
      'unitRangedBonus': instance.unitRangedBonus,
    };
