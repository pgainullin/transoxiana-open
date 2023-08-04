part of 'campaign_data_source.dart';

/// Holds all templates in one place
/// Never mutates
/// Serializable/deserializable
///
/// If you need to mutate data - create copyWith method
///
/// This class should not be used anywhere in game
/// except of game configurators
///
/// For game runtime use [RuntimeTemplateGameData]
@JsonSerializable(explicitToJson: true)
class CampaignTemplateData implements CampaignDataSource {
  CampaignTemplateData({
    required this.unitTypesJson,
    required this.armyTemplatesJson,
    required this.campaignJson,
    required this.provincesJson,
    required this.armyTemplates,
    required this.unitTypes,
    final String? campaignName,
    final GameDate? currentDate,
    final GameDate? startDate,
    final double? gameTime,
    final Id? id,
    final Map<Id, AiData>? ais,
    final Map<Id, ArmyData>? armies,
    final Map<Id, NationData>? nations,
    final Map<Id, ProvinceData>? provinces,
    final Map<Id, UnitData>? units,
    final Map<Id, BattleData>? battles,
    final Map<Id, FortificationData>? forts,
    this.activeBattle,
    this.backgroundImagePath,
    this.narrative,
    this.player,
    final DiplomaticRelationships? diplomaticRelationships,
    final int? startYear,
    final int? startSeason,
    final Set<EventData>? events,
    final DateTime? gameSaveDate,
    final CampaignDataSourceType? sourceType,
  })  : rand = Random(),
        sourceType = sourceType ?? CampaignDataSourceType.campaign,
        events = events ?? {},
        ais = ais ?? {},
        battles = battles ?? {},
        armies = armies ?? {},
        campaignName = campaignName ?? '',
        currentDate = currentDate ?? const GameDate.start(),
        startDate = startDate ?? const GameDate.start(),
        gameTime = gameTime ?? 0.0,
        id = id ?? '',
        nations = nations ?? {},
        forts = forts ?? {},
        diplomaticRelationships = diplomaticRelationships ?? {},
        provinces = provinces ?? {},
        units = units ?? {},
        gameSaveDate = gameSaveDate ?? DateTime.now() {
    /// this is a fix for start year and season serialization
    if (startDate == null && startYear != null && startSeason != null) {
      this.startDate = GameDate(startYear, Season.values[startSeason]);
      this.currentDate = this.startDate.copyWith();
    }
  }

  static Future<CampaignTemplateData> fromNamedJson({
    required final String unitTypesJson,
    required final String armyTemplatesJson,
    required final String campaignJson,
    required final String provincesJson,
  }) async {
    final campaignJsonMap = jsonDecode(campaignJson) as Map<String, dynamic>;
    return fromJson({
      'campaignJson': campaignJson,
      'unitTypesJson': unitTypesJson,
      'armyTemplatesJson': armyTemplatesJson,
      'provincesJson': provincesJson,
      ...jsonDecode(armyTemplatesJson),
      ...jsonDecode(unitTypesJson),
      ...jsonDecode(provincesJson),
      ...campaignJsonMap,
      ...campaignJsonMap['parameters']
    });
  }

  static Future<CampaignTemplateData> fromJson(
    final Map<String, dynamic> json,
  ) async =>
      compute(_$CampaignTemplateDataFromJson, json);

  @override
  Future<Map<String, dynamic>> toJson() async =>
      compute(_$CampaignTemplateDataToJson, this);

  @override
  String toJsonString() => jsonEncode(toJson());

  @override
  Future<CampaignRuntimeData> toRuntime({
    required final TransoxianaGame game,
  }) async {
    final effectiveNations = await _loadNations(game: game);
    await connectDiplomaticRelationships(
      matrix: diplomaticRelationships,
      nations: effectiveNations,
      game: game,
    );
    final effectiveEvents = await events.convert(
      (final data) async => data.toEvent(game: game),
    );
    await connectNationsEvents(
      nations: effectiveNations,
      events: effectiveEvents,
    );
    final resolvedPlayer = player;
    Nation? effectivePlayer;
    if (resolvedPlayer != null) {
      if (!nations.containsKey(resolvedPlayer.id)) {
        effectivePlayer = await resolvedPlayer.toNation(game: game);
        effectiveNations[effectivePlayer.id] = effectivePlayer;
      } else {
        effectivePlayer = effectiveNations[effectivePlayer?.id];
      }
    }

    return CampaignRuntimeData._fromData(
      id: id,
      data: this,
      ais: await _loadNationsAis(game: game),
      backgroundImagePath: backgroundImagePath,
      campaignName: campaignName,
      currentDate: currentDate,
      narrative: narrative?.toNarrative(game: game),
      player: effectivePlayer,
      startDate: startDate,
      nations: effectiveNations,
      forts: await _loadForts(game: game),
      game: game,
      backgroundImage: await _loadBackgroundImage(backgroundImagePath),
      unitTypes: await _loadUnitTypes(),
      armyTemplates: await _loadArmyTemplates(game: game),
      provinces: await _loadProvinces(game: game),
      armies: await _loadArmies(game: game),
      units: await _loadUnits(game: game),
    );
  }

  final String armyTemplatesJson;
  final String unitTypesJson;
  final String campaignJson;
  final String provincesJson;

  Future<Map<Id, Army>> _loadArmies({
    required final TransoxianaGame game,
  }) async {
    final loadedArmies = await armies
        .convertValues((final item) async => item.toArmy(game: game));
    assert(loadedArmies.isNotEmpty);
    return loadedArmies;
  }

  Future<Map<Id, Ai>> _loadNationsAis({
    required final TransoxianaGame game,
  }) async {
    final loadedAis =
        await ais.convertValues((final item) async => item.toAi(game: game));
    return loadedAis;
  }

  Future<Map<Id, Nation>> _loadNations({
    required final TransoxianaGame game,
  }) async {
    final loadedNations = await nations
        .convertValues((final item) async => item.toNation(game: game));
    assert(loadedNations.isNotEmpty);
    return loadedNations;
  }

  Future<Map<Id, Province>> _loadProvinces({
    required final TransoxianaGame game,
  }) async {
    final loadedProvinces = await provinces
        .convertValues((final item) async => item.toProvince(game: game));
    assert(loadedProvinces.isNotEmpty);
    return loadedProvinces;
  }

  Future<Map<Id, ArmyTemplate>> _loadArmyTemplates({
    required final TransoxianaGame game,
  }) async {
    final loadedArmyTemplates = await armyTemplates
        .convertValues((final item) async => item.toTemplate(game: game));
    assert(loadedArmyTemplates.isNotEmpty);
    return loadedArmyTemplates;
  }

  Future<Map<UnitTypeNames, UnitType>> _loadUnitTypes() async {
    final loadedUnitTypes =
        await unitTypes.convertValues((final item) => item.toType());
    assert(loadedUnitTypes.isNotEmpty);
    return loadedUnitTypes;
  }

  Future<Map<Id, Unit>> _loadUnits(
      {required final TransoxianaGame game,}) async {
    final loadedUnit =
        await units.convertValues((final item) => item.toUnit(game: game));
    return loadedUnit;
  }

  Future<Map<Id, Fortification>> _loadForts({
    required final TransoxianaGame game,
  }) async {
    final loadedFort = await forts
        .convertValues((final item) async => item.toFortification(game: game));
    return loadedFort;
  }

  @override
  DateTime gameSaveDate;

  @override
  final Map<Id, AiData> ais;

  @override
  final Map<Id, ArmyData> armies;

  @override
  final Map<Id, FortificationData> forts;

  @override
  final Map<Id, ArmyTemplateData> armyTemplates;

  @override
  @JsonKey(name: 'image')
  final String? backgroundImagePath;

  @override
  final Map<Id, NationData> nations;

  @override
  final Map<Id, ProvinceData> provinces;

  @override
  final Map<UnitTypeNames, UnitTypeData> unitTypes;

  @override
  final Map<Id, UnitData> units;

  @override
  BattleData? activeBattle;

  @override
  @JsonKey(name: 'name')
  String campaignName;

  @override
  GameDate currentDate;

  @override
  double gameTime;

  @override
  @JsonKey(
    name: 'locales',
    fromJson: CampaignNarrativeData.fromLocaleJson,
  )
  CampaignNarrativeData? narrative;

  @override
  NationData? player;

  @override
  GameDate startDate;

  @override
  Id id;

  @override
  final Random rand;

  @override
  final DiplomaticRelationships diplomaticRelationships;

  @override
  final Set<EventData> events;
  @override
  final Map<Id, BattleData> battles;

  @override
  CampaignDataSourceType sourceType;

  @override
  int? startSeason;

  @override
  int? startYear;
}
