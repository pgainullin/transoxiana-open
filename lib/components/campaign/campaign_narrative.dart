import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:utils/utils.dart';

part 'campaign_narrative.g.dart';

@JsonSerializable()
class CampaignNarrativeData {
  CampaignNarrativeData({
    required this.menuIntroText,
    required this.campaignTitle,
    final Map<String, dynamic>? sentences,
  }) : sentences = sentences ?? {};
  static CampaignNarrativeData fromLocaleJson(final Map<String, dynamic> json) {
    final narrativeJson = <String, dynamic>{};
    const inIsolate = true;
    if (kIsWeb || inIsolate) {
      narrativeJson.addAll(json['en_GB'] as Map<String, dynamic>);
    } else {
      // TODO(arenukvern): figure out how to access S.current in isolate
      // assert(
      //   json[Intl.defaultLocale] != null,
      //   "No narrative for default locale (${Intl.defaultLocale.toString()}) provided in the campaign file",
      // );
      // if (json[Intl.systemLocale] != null) {
      //   narrativeJson.addAll(json[Intl.systemLocale] as Map<String, dynamic>);
      // } else {
      //   narrativeJson.addAll(json[Intl.defaultLocale] as Map<String, dynamic>);
      // }
    }
    return fromJson({...narrativeJson, 'sentences': narrativeJson});
  }

  static CampaignNarrativeData fromJson(final Map<String, dynamic> json) =>
      _$CampaignNarrativeDataFromJson(json);
  Map<String, dynamic> toJson() => _$CampaignNarrativeDataToJson(this);

  CampaignNarrative toNarrative({required final TransoxianaGame game}) {
    return CampaignNarrative._fromData(
      game: game,
      objectives: _loadObjectives(game: game),
      data: this,
    );
  }

  List<String> _loadObjectives({required final TransoxianaGame game}) {
    final objectives = <String>[];
    final int playableNationCount =
        game.campaignRuntimeData.playableNations.length;
    objectives.length = playableNationCount;
    for (int i = 0; i < playableNationCount; i++) {
      objectives[i] = sentences['objectiveText${i.toString()}'] as String;
      //add(sentences['objectiveText${i.toString()}'] as String);
    }
    return objectives;
  }

  String menuIntroText;
  String campaignTitle;
  final Map<String, dynamic> sentences;
}

///
///
///
/// Handling campaign text providing narrative context to the player. Two main parts:
///
/// 1) Static descriptions pulled from campaign file with localisation
///
/// 2) TODO: Events that trigger based on game events
///
///
///
class CampaignNarrative
    implements
        GameRef,
        DataSourceRef<CampaignNarrativeData, CampaignNarrative> {
  CampaignNarrative._fromData({
    required this.game,
    required this.objectives,
    required this.data,
  });
  @override
  Future<CampaignNarrativeData> toData() async => CampaignNarrativeData(
        menuIntroText: data.menuIntroText,
        campaignTitle: data.campaignTitle,
        sentences: sentences,
      );

  @override
  Future<void> refillData(final CampaignNarrative otherType) async {
    final newData = await otherType.toData();
    data = newData;
    objectives.assignAll(otherType.objectives);
  }

  void reloadObjectives() =>
      objectives.assignAll(data._loadObjectives(game: game));

  @override
  TransoxianaGame game;
  @override
  CampaignNarrativeData data;
  String get menuIntroText => data.menuIntroText;
  String get campaignTitle => data.campaignTitle;
  Map<String, dynamic> get sentences => data.sentences;
  final List<String> objectives;
}
