// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tutorial_states.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TutorialHistory _$TutorialHistoryFromJson(Map<String, dynamic> json) =>
    TutorialHistory(
      statePointers: (json['statePointers'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry($enumDecode(_$TutorialModesEnumMap, k), e as int),
      ),
      playedTutorialModes: (json['playedTutorialModes'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$TutorialModesEnumMap, e))
          .toSet(),
    );

Map<String, dynamic> _$TutorialHistoryToJson(TutorialHistory instance) =>
    <String, dynamic>{
      'statePointers': instance.statePointers
          .map((k, e) => MapEntry(_$TutorialModesEnumMap[k]!, e)),
      'playedTutorialModes': instance.playedTutorialModes
          .map((e) => _$TutorialModesEnumMap[e]!)
          .toList(),
    };

const _$TutorialModesEnumMap = {
  TutorialModes.campaignIntro: 'campaignIntro',
  TutorialModes.campaignButtonsIntro: 'campaignButtonsIntro',
  TutorialModes.battleIntro: 'battleIntro',
  TutorialModes.mainMenu: 'mainMenu',
  TutorialModes.campaignIndependent: 'campaignIndependent',
  TutorialModes.battleIndependent: 'battleIndependent',
  TutorialModes.fromString: 'fromString',
};
