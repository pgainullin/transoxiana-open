// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'game_dates.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GameDate _$GameDateFromJson(Map<String, dynamic> json) => GameDate(
      json['year'] as int,
      $enumDecode(_$SeasonEnumMap, json['season']),
    );

Map<String, dynamic> _$GameDateToJson(GameDate instance) => <String, dynamic>{
      'year': instance.year,
      'season': _$SeasonEnumMap[instance.season]!,
    };

const _$SeasonEnumMap = {
  Season.winter: 'winter',
  Season.spring: 'spring',
  Season.summer: 'summer',
  Season.autumn: 'autumn',
};
