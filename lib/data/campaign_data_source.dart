import 'dart:convert';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flame/extensions.dart';
import 'package:flame/flame.dart';
import 'package:flutter/foundation.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:transoxiana/components/battle/battle.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/campaign/campaign.dart';
import 'package:transoxiana/components/campaign/campaign_narrative.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/events/events.dart';
import 'package:transoxiana/components/shared/fortification.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/data/army_templates.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/game_dates.dart';
import 'package:transoxiana/data/season.dart';
import 'package:transoxiana/data/unit_types.dart';
import 'package:transoxiana/services/ai.dart';
import 'package:utils/utils.dart';

part 'campaign_data_helpers.dart';
part 'campaign_data_source.g.dart';
part 'campaign_runtime_data.dart';
part 'campaign_save_data.dart';
part 'campaign_template_data.dart';

enum CampaignDataSourceType {
  campaign,
  battle,
}

/// Abstract class to unify campaign data sources
///
/// There is two types of [CampaignDataSource]:
///
/// [CampaignTemplateData] - used to start new Campaign or Battle
/// has initial data from assets json files
///
/// [CampaignSaveData] - used to load existed Campaign or Battle
/// has initial data from [CampaignTemplateData] and never should
/// be resetted or loaded from assets
///
/// To use it in game you have to load source
/// to [CampaignRuntimeData] by doing
/// [CampaignRuntimeData.load]
@JsonSerializable(explicitToJson: true)
class CampaignDataSource {
  CampaignDataSource({
    required this.currentDate,
    required this.startDate,
    final Map<Id, ArmyData>? armies,
    final Map<Id, ArmyTemplateData>? armyTemplates,
    final Map<Id, NationData>? nations,
    final Map<Id, ProvinceData>? provinces,
    final Map<UnitTypeNames, UnitTypeData>? unitTypes,
    final Map<Id, UnitData>? units,
    final Map<Id, AiData>? ais,
    final Set<EventData>? events,
    final Map<Id, BattleData>? battles,
    final Map<Id, FortificationData>? forts,
    this.campaignName = '',
    this.player,
    this.activeBattle,
    this.narrative,
    this.backgroundImagePath,
    final DiplomaticRelationships? diplomaticRelationships,
    final Id? id,
    final DateTime? gameSaveDate,
    final CampaignDataSourceType? sourceType,
  })  : id = id ?? uuid.v4(),
        rand = Random(),
        sourceType = sourceType ?? CampaignDataSourceType.campaign,
        diplomaticRelationships = diplomaticRelationships ?? {},
        armies = armies ?? {},
        armyTemplates = armyTemplates ?? {},
        nations = nations ?? {},
        provinces = provinces ?? {},
        unitTypes = unitTypes ?? {},
        units = units ?? {},
        ais = ais ?? {},
        events = events ?? {},
        battles = battles ?? {},
        forts = forts ?? {},
        gameSaveDate = gameSaveDate ?? DateTime.now();

  CampaignDataSourceType sourceType;
  final Map<UnitTypeNames, UnitTypeData> unitTypes;
  final Map<Id, ArmyTemplateData> armyTemplates;
  final Map<Id, UnitData> units;
  final Map<Id, ProvinceData> provinces;
  final Map<Id, NationData> nations;
  final Map<Id, ArmyData> armies;
  final Map<Id, AiData> ais;
  final Map<Id, FortificationData> forts;
  final Map<Id, BattleData> battles;
  final Id id;
  final String? backgroundImagePath;
  final DiplomaticRelationships diplomaticRelationships;
  @JsonKey(ignore: true)
  final Random rand;

  /// in seconds
  double gameTime = 0;
  NationData? player;
  String campaignName;
  GameDate currentDate;
  GameDate startDate;

  final Set<EventData> events;

  /// Date when this save was created/saved
  /// This date should be created by [DateTime.now()]
  /// every time when [toData] is used (i.e. new save created)
  final DateTime gameSaveDate;

  BattleData? activeBattle;
  CampaignNarrativeData? narrative;

  Future<CampaignRuntimeData> toRuntime({
    required final TransoxianaGame game,
  }) =>
      throw UnimplementedError();
  Future<Map<String, dynamic>> toJson() async => throw UnimplementedError();
  String toJsonString() => jsonEncode(toJson());
}

/// Use this class used for class that have
/// data classes factories
///
/// Example:
/// [Unit] implements [DataSourceRef]
/// because it has [UnitData] class as a factory class
///
/// [TType] is a type of the class that implements [DataSourceRef]
/// [TData] is a type of data class that used to create [TType]
///
/// For example:
/// [Unit] is [TType]
/// [UnitData] is [TData]
abstract class DataSourceRef<TData, TType> {
  DataSourceRef(this.data);
  TData data;

  /// Use this function to convert all runtime params back to data
  Future<TData> toData();

  /// Use this function to update values based on the same class
  ///
  /// For example
  /// once [Unit] was restored by [UnitId] it has no loaded params
  /// when we load these params we can update actual [Unit] with these params
  Future<void> refillData(final TType otherType);
}
