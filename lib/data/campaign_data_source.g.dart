// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'campaign_data_source.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CampaignDataSource _$CampaignDataSourceFromJson(Map<String, dynamic> json) =>
    CampaignDataSource(
      currentDate:
          GameDate.fromJson(json['currentDate'] as Map<String, dynamic>),
      startDate: GameDate.fromJson(json['startDate'] as Map<String, dynamic>),
      armies: (json['armies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, ArmyData.fromJson(e as Map<String, dynamic>)),
      ),
      armyTemplates: (json['armyTemplates'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ArmyTemplateData.fromJson(e as Map<String, dynamic>)),
      ),
      nations: (json['nations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, NationData.fromJson(e as Map<String, dynamic>)),
      ),
      provinces: (json['provinces'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, ProvinceData.fromJson(e as Map<String, dynamic>)),
      ),
      unitTypes: (json['unitTypes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry($enumDecode(_$UnitTypeNamesEnumMap, k),
            UnitTypeData.fromJson(e as Map<String, dynamic>)),
      ),
      units: (json['units'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, UnitData.fromJson(e as Map<String, dynamic>)),
      ),
      ais: (json['ais'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, AiData.fromJson(e as Map<String, dynamic>)),
      ),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      battles: (json['battles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, BattleData.fromJson(e as Map<String, dynamic>)),
      ),
      forts: (json['forts'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, FortificationData.fromJson(e as Map<String, dynamic>)),
      ),
      campaignName: json['campaignName'] as String? ?? '',
      player: json['player'] == null
          ? null
          : NationData.fromJson(json['player'] as Map<String, dynamic>),
      activeBattle: json['activeBattle'] == null
          ? null
          : BattleData.fromJson(json['activeBattle'] as Map<String, dynamic>),
      narrative: json['narrative'] == null
          ? null
          : CampaignNarrativeData.fromJson(
              json['narrative'] as Map<String, dynamic>),
      backgroundImagePath: json['backgroundImagePath'] as String?,
      diplomaticRelationships:
          (json['diplomaticRelationships'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, $enumDecode(_$DiplomaticStatusEnumMap, e)),
            )),
      ),
      id: json['id'] as String?,
      gameSaveDate: json['gameSaveDate'] == null
          ? null
          : DateTime.parse(json['gameSaveDate'] as String),
      sourceType: $enumDecodeNullable(
          _$CampaignDataSourceTypeEnumMap, json['sourceType']),
    )..gameTime = (json['gameTime'] as num).toDouble();

Map<String, dynamic> _$CampaignDataSourceToJson(CampaignDataSource instance) =>
    <String, dynamic>{
      'sourceType': _$CampaignDataSourceTypeEnumMap[instance.sourceType]!,
      'unitTypes': instance.unitTypes
          .map((k, e) => MapEntry(_$UnitTypeNamesEnumMap[k]!, e.toJson())),
      'armyTemplates':
          instance.armyTemplates.map((k, e) => MapEntry(k, e.toJson())),
      'units': instance.units.map((k, e) => MapEntry(k, e.toJson())),
      'provinces': instance.provinces.map((k, e) => MapEntry(k, e.toJson())),
      'nations': instance.nations.map((k, e) => MapEntry(k, e.toJson())),
      'armies': instance.armies.map((k, e) => MapEntry(k, e.toJson())),
      'ais': instance.ais.map((k, e) => MapEntry(k, e.toJson())),
      'forts': instance.forts.map((k, e) => MapEntry(k, e.toJson())),
      'battles': instance.battles.map((k, e) => MapEntry(k, e.toJson())),
      'id': instance.id,
      'backgroundImagePath': instance.backgroundImagePath,
      'diplomaticRelationships': instance.diplomaticRelationships.map((k, e) =>
          MapEntry(
              k, e.map((k, e) => MapEntry(k, _$DiplomaticStatusEnumMap[e]!)))),
      'gameTime': instance.gameTime,
      'player': instance.player?.toJson(),
      'campaignName': instance.campaignName,
      'currentDate': instance.currentDate.toJson(),
      'startDate': instance.startDate.toJson(),
      'events': instance.events.map((e) => e.toJson()).toList(),
      'gameSaveDate': instance.gameSaveDate.toIso8601String(),
      'activeBattle': instance.activeBattle?.toJson(),
      'narrative': instance.narrative?.toJson(),
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

const _$CampaignDataSourceTypeEnumMap = {
  CampaignDataSourceType.campaign: 'campaign',
  CampaignDataSourceType.battle: 'battle',
};

CampaignSaveData _$CampaignSaveDataFromJson(Map<String, dynamic> json) =>
    CampaignSaveData(
      currentDate:
          GameDate.fromJson(json['currentDate'] as Map<String, dynamic>),
      startDate: GameDate.fromJson(json['startDate'] as Map<String, dynamic>),
      campaignName: json['campaignName'] as String? ?? '',
      provinces: (json['provinces'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, ProvinceData.fromJson(e as Map<String, dynamic>)),
      ),
      ais: (json['ais'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, AiData.fromJson(e as Map<String, dynamic>)),
      ),
      armies: (json['armies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, ArmyData.fromJson(e as Map<String, dynamic>)),
      ),
      nations: (json['nations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, NationData.fromJson(e as Map<String, dynamic>)),
      ),
      units: (json['units'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, UnitData.fromJson(e as Map<String, dynamic>)),
      ),
      battles: (json['battles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, BattleData.fromJson(e as Map<String, dynamic>)),
      ),
      armyTemplates: (json['armyTemplates'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, ArmyTemplateData.fromJson(e as Map<String, dynamic>)),
      ),
      unitTypes: (json['unitTypes'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry($enumDecode(_$UnitTypeNamesEnumMap, k),
            UnitTypeData.fromJson(e as Map<String, dynamic>)),
      ),
      forts: (json['forts'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, FortificationData.fromJson(e as Map<String, dynamic>)),
      ),
      player: json['player'] == null
          ? null
          : NationData.fromJson(json['player'] as Map<String, dynamic>),
      activeBattle: json['activeBattle'] == null
          ? null
          : BattleData.fromJson(json['activeBattle'] as Map<String, dynamic>),
      backgroundImagePath: json['backgroundImagePath'] as String?,
      narrative: json['narrative'] == null
          ? null
          : CampaignNarrativeData.fromJson(
              json['narrative'] as Map<String, dynamic>),
      id: json['id'] as String?,
      diplomaticRelationships:
          (json['diplomaticRelationships'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, $enumDecode(_$DiplomaticStatusEnumMap, e)),
            )),
      ),
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      gameSaveDate: json['gameSaveDate'] == null
          ? null
          : DateTime.parse(json['gameSaveDate'] as String),
      sourceType: $enumDecodeNullable(
          _$CampaignDataSourceTypeEnumMap, json['sourceType']),
    )..gameTime = (json['gameTime'] as num).toDouble();

Map<String, dynamic> _$CampaignSaveDataToJson(CampaignSaveData instance) =>
    <String, dynamic>{
      'sourceType': _$CampaignDataSourceTypeEnumMap[instance.sourceType]!,
      'unitTypes': instance.unitTypes
          .map((k, e) => MapEntry(_$UnitTypeNamesEnumMap[k]!, e.toJson())),
      'armyTemplates':
          instance.armyTemplates.map((k, e) => MapEntry(k, e.toJson())),
      'units': instance.units.map((k, e) => MapEntry(k, e.toJson())),
      'provinces': instance.provinces.map((k, e) => MapEntry(k, e.toJson())),
      'nations': instance.nations.map((k, e) => MapEntry(k, e.toJson())),
      'armies': instance.armies.map((k, e) => MapEntry(k, e.toJson())),
      'ais': instance.ais.map((k, e) => MapEntry(k, e.toJson())),
      'forts': instance.forts.map((k, e) => MapEntry(k, e.toJson())),
      'battles': instance.battles.map((k, e) => MapEntry(k, e.toJson())),
      'id': instance.id,
      'backgroundImagePath': instance.backgroundImagePath,
      'diplomaticRelationships': instance.diplomaticRelationships.map((k, e) =>
          MapEntry(
              k, e.map((k, e) => MapEntry(k, _$DiplomaticStatusEnumMap[e]!)))),
      'gameTime': instance.gameTime,
      'player': instance.player?.toJson(),
      'campaignName': instance.campaignName,
      'currentDate': instance.currentDate.toJson(),
      'startDate': instance.startDate.toJson(),
      'events': instance.events.map((e) => e.toJson()).toList(),
      'gameSaveDate': instance.gameSaveDate.toIso8601String(),
      'activeBattle': instance.activeBattle?.toJson(),
      'narrative': instance.narrative?.toJson(),
    };

CampaignTemplateData _$CampaignTemplateDataFromJson(
        Map<String, dynamic> json) =>
    CampaignTemplateData(
      unitTypesJson: json['unitTypesJson'] as String,
      armyTemplatesJson: json['armyTemplatesJson'] as String,
      campaignJson: json['campaignJson'] as String,
      provincesJson: json['provincesJson'] as String,
      armyTemplates: (json['armyTemplates'] as Map<String, dynamic>).map(
        (k, e) =>
            MapEntry(k, ArmyTemplateData.fromJson(e as Map<String, dynamic>)),
      ),
      unitTypes: (json['unitTypes'] as Map<String, dynamic>).map(
        (k, e) => MapEntry($enumDecode(_$UnitTypeNamesEnumMap, k),
            UnitTypeData.fromJson(e as Map<String, dynamic>)),
      ),
      campaignName: json['name'] as String?,
      currentDate: json['currentDate'] == null
          ? null
          : GameDate.fromJson(json['currentDate'] as Map<String, dynamic>),
      startDate: json['startDate'] == null
          ? null
          : GameDate.fromJson(json['startDate'] as Map<String, dynamic>),
      gameTime: (json['gameTime'] as num?)?.toDouble(),
      id: json['id'] as String?,
      ais: (json['ais'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, AiData.fromJson(e as Map<String, dynamic>)),
      ),
      armies: (json['armies'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, ArmyData.fromJson(e as Map<String, dynamic>)),
      ),
      nations: (json['nations'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, NationData.fromJson(e as Map<String, dynamic>)),
      ),
      provinces: (json['provinces'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, ProvinceData.fromJson(e as Map<String, dynamic>)),
      ),
      units: (json['units'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, UnitData.fromJson(e as Map<String, dynamic>)),
      ),
      battles: (json['battles'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(k, BattleData.fromJson(e as Map<String, dynamic>)),
      ),
      forts: (json['forts'] as Map<String, dynamic>?)?.map(
        (k, e) =>
            MapEntry(k, FortificationData.fromJson(e as Map<String, dynamic>)),
      ),
      activeBattle: json['activeBattle'] == null
          ? null
          : BattleData.fromJson(json['activeBattle'] as Map<String, dynamic>),
      backgroundImagePath: json['image'] as String?,
      narrative: CampaignNarrativeData.fromLocaleJson(
          json['locales'] as Map<String, dynamic>),
      player: json['player'] == null
          ? null
          : NationData.fromJson(json['player'] as Map<String, dynamic>),
      diplomaticRelationships:
          (json['diplomaticRelationships'] as Map<String, dynamic>?)?.map(
        (k, e) => MapEntry(
            k,
            (e as Map<String, dynamic>).map(
              (k, e) => MapEntry(k, $enumDecode(_$DiplomaticStatusEnumMap, e)),
            )),
      ),
      startYear: json['startYear'] as int?,
      startSeason: json['startSeason'] as int?,
      events: (json['events'] as List<dynamic>?)
          ?.map((e) => EventData.fromJson(e as Map<String, dynamic>))
          .toSet(),
      gameSaveDate: json['gameSaveDate'] == null
          ? null
          : DateTime.parse(json['gameSaveDate'] as String),
      sourceType: $enumDecodeNullable(
          _$CampaignDataSourceTypeEnumMap, json['sourceType']),
    );

Map<String, dynamic> _$CampaignTemplateDataToJson(
        CampaignTemplateData instance) =>
    <String, dynamic>{
      'armyTemplatesJson': instance.armyTemplatesJson,
      'unitTypesJson': instance.unitTypesJson,
      'campaignJson': instance.campaignJson,
      'provincesJson': instance.provincesJson,
      'gameSaveDate': instance.gameSaveDate.toIso8601String(),
      'ais': instance.ais.map((k, e) => MapEntry(k, e.toJson())),
      'armies': instance.armies.map((k, e) => MapEntry(k, e.toJson())),
      'forts': instance.forts.map((k, e) => MapEntry(k, e.toJson())),
      'armyTemplates':
          instance.armyTemplates.map((k, e) => MapEntry(k, e.toJson())),
      'image': instance.backgroundImagePath,
      'nations': instance.nations.map((k, e) => MapEntry(k, e.toJson())),
      'provinces': instance.provinces.map((k, e) => MapEntry(k, e.toJson())),
      'unitTypes': instance.unitTypes
          .map((k, e) => MapEntry(_$UnitTypeNamesEnumMap[k]!, e.toJson())),
      'units': instance.units.map((k, e) => MapEntry(k, e.toJson())),
      'activeBattle': instance.activeBattle?.toJson(),
      'name': instance.campaignName,
      'currentDate': instance.currentDate.toJson(),
      'gameTime': instance.gameTime,
      'locales': instance.narrative?.toJson(),
      'player': instance.player?.toJson(),
      'startDate': instance.startDate.toJson(),
      'id': instance.id,
      'diplomaticRelationships': instance.diplomaticRelationships.map((k, e) =>
          MapEntry(
              k, e.map((k, e) => MapEntry(k, _$DiplomaticStatusEnumMap[e]!)))),
      'events': instance.events.map((e) => e.toJson()).toList(),
      'battles': instance.battles.map((k, e) => MapEntry(k, e.toJson())),
      'sourceType': _$CampaignDataSourceTypeEnumMap[instance.sourceType]!,
      'startSeason': instance.startSeason,
      'startYear': instance.startYear,
    };
