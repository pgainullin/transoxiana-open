part of 'campaign_data_source.dart';

typedef DiplomaticRelationships
    = Map<NationId, Map<NationId, DiplomaticStatus>>;
typedef Id = String;

/// Reactive runtime class to use any [CampaignDataSource]s
///
/// To load source use [CampaignRuntimeData.load]
/// To save current state use:
/// [runtimeDataService.toData] or
/// [runtimeDataService.toJsonString] or
class CampaignRuntimeData {
  // ************************************
  //       Factories start
  // ************************************
  CampaignRuntimeData._fromData({
    this.currentDate = const GameDate.start(),
    this.startDate = const GameDate.start(),
    this.game,
    final Map<Id, Army>? armies,
    final Map<Id, ArmyTemplate>? armyTemplates,
    final Map<Id, Nation>? nations,
    final Map<Id, Province>? provinces,
    final Map<UnitTypeNames, UnitType>? unitTypes,
    final Map<Id, Unit>? units,
    final Map<Id, Ai>? ais,
    final Map<Id, Battle>? battles,
    final Map<Id, Fortification>? forts,
    this.player,
    this.campaignName = '',
    this.narrative,
    this.backgroundImage,
    this.backgroundImagePath,
    this.data,
    final Id? id,
  })  : id = id ?? uuid.v4(),
        rand = Random(),
        armies = armies ?? {},
        armyTemplates = armyTemplates ?? {},
        nations = nations ?? {},
        provinces = provinces ?? {},
        unitTypes = unitTypes ?? {},
        units = units ?? {},
        ais = ais ?? {},
        forts = forts ?? {},
        battles = battles ?? {};

  /// Use this method to initialize [runtimeDataService] only
  factory CampaignRuntimeData.empty() => CampaignRuntimeData._fromData();

  static Future<void> load({
    required final CampaignDataSource source,
    required final TransoxianaGame game,
  }) async {
    await game.campaignRuntimeDataService.refresh();

    /// we need to separate setState to
    /// 1. Set basic data source for any restoration purposes
    game.campaignRuntimeData
      ..game ??= game
      ..data = source;

    /// 2. Set complex data to actually fill the state

    final newRuntime = await source.toRuntime(game: game);
    if (newRuntime.id.isEmpty) {
      newRuntime.id = uuid.v4();
    }
    await game.campaignRuntimeData.refill(newRuntime);
    game.campaignRuntimeDataService.notify();
  }

  /// Use this function to connect all between
  Future<void> _connectRuntimes() async {
    await Future.wait([
      connectNationsAis(ais: ais, nations: nations),
      connectArmyToProvinces(armies: armies, provinces: provinces),
      connectArmyToUnits(armies: armies, units: units),
      connectProvincesFortifications(provinces: provinces),
    ]);
  }

  Future<void> refill(final CampaignRuntimeData otherState) async {
    id = otherState.id;
    backgroundImage = otherState.backgroundImage;
    backgroundImagePath = otherState.backgroundImagePath;
    gameTime = otherState.gameTime;
    final otherPlayer = otherState.player;
    if (otherPlayer != null) {
      if (player != otherPlayer) {
        player = otherPlayer;
      } else {
        await player?.refillData(otherPlayer);
      }
    }
    campaignName = otherState.campaignName;
    currentDate = otherState.currentDate;
    startDate = otherState.startDate;

    final otherActiveBattle = otherState.activeBattle;
    if (otherActiveBattle != null) {
      await activeBattle?.refillData(otherActiveBattle);
    }

    await Future.wait([
      ais.convertValues(
        (final ai) async => ai.refillData(otherState.ais[ai.id.aiId]!),
      ),
      {...armies}.convertValues(
        (final army) async {
          final otherArmy = otherState.armies[army.id.armyId];
          if (otherArmy == null) {
            armies.remove(army.id.armyId);
          } else {
            await army.refillData(otherArmy);
          }
        },
      ),
      nations.convertValues(
        (final nation) async =>
            nation.refillData(otherState.nations[nation.id]!),
      ),
      armyTemplates.convertValues(
        (final armyTemplate) async =>
            armyTemplate.refillData(otherState.armyTemplates[armyTemplate.id]!),
      ),
      provinces.convertValues(
        (final province) async =>
            province.refillData(otherState.provinces[province.id]!),
      ),
      units.convertValues(
        (final unit) async {
          /// Unit can exist in army but can be not exists in all units
          final maybeUnit = otherState.units[unit.id.unitId];
          if (maybeUnit == null) return;
          return unit.refillData(maybeUnit);
        },
      ),
      unitTypes.convertValues(
        (final unitType) async =>
            unitType.refillData(otherState.unitTypes[unitType.id]!),
      ),
      forts.convertValues(
        (final fort) async => fort.refillData(otherState.forts[fort.id]!),
      ),

      /// As all battles appears only during the turn, it should be not possible
      /// to save game with battles.
      // battles.convertValues(
      //   (battle) async => battle.refillData(otherState.battles[battle.id]!),
      // ),
    ]);

    await Future.wait([
      ais.addAllNew(otherState.ais),
      armies.addAllNew(otherState.armies),
      nations.addAllNew(otherState.nations),
      armyTemplates.addAllNew(otherState.armyTemplates),
      provinces.addAllNew(otherState.provinces),
      units.addAllNew(otherState.units),
      unitTypes.addAllNew(otherState.unitTypes),
      battles.addAllNew(otherState.battles),
    ]);

    final otherNarrative = otherState.narrative;
    if (otherNarrative != null) {
      narrative ??= otherNarrative;
      await narrative?.refillData(otherNarrative);
      narrative?.reloadObjectives();
    }
    await _connectRuntimes();
  }

  bool get isCampaignStarted {
    final campaign = game?.children.whereType<Campaign>() ?? [];
    if (campaign.isEmpty) return false;
    return campaign.first.isLoaded;
  }

  bool get inCampaign => isCampaignStarted && !isBattleStarted;
  bool get isBattleStarted =>
      activeBattle != null && activeBattle?.isAiBattle == true
          ? true
          : (game?.children.whereType<Battle>().isNotEmpty ?? false);

  /// collects all data files and create  [CampaignSaveData]
  /// which should be saved automatically
  /// to user device storage
  ///
  /// This can be used as regular user saves
  Future<CampaignSaveData> toSaveData({final String? reservedId}) async {
    final effectiveAis =
        await ais.convertValues((final item) async => item.toData());
    final effectiveArmies =
        await armies.convertValues((final item) async => item.toData());
    final effectiveArmyTemplates =
        await armyTemplates.convertValues((final item) async => item.toData());
    final effectiveNations =
        await nations.convertValues((final item) async => item.toData());
    final effectiveProvinces =
        await provinces.convertValues((final item) async => item.toData());
    final effectiveUnitTypes =
        await unitTypes.convertValues((final item) async => item.toData());
    final effectiveUnits =
        await units.convertValues((final item) async => item.toData());
    final effectiveDiplomaticRelations =
        await getDiplomaticRelationships(nations: nations);
    final effectiveEvents = await getNationsEvents(nations: nations);
    final effectiveBattles =
        await battles.convertValues((final battle) async => battle.toData());
    final effectiveForts =
        await forts.convertValues((final fort) async => fort.toData());
    return CampaignSaveData(
      id: reservedId ?? id,
      events: effectiveEvents,
      sourceType: data?.sourceType,
      activeBattle: await activeBattle?.toData(),
      ais: effectiveAis,
      armies: effectiveArmies,
      armyTemplates: effectiveArmyTemplates,
      backgroundImagePath: backgroundImagePath,
      campaignName: campaignName,
      currentDate: currentDate,
      forts: effectiveForts,
      narrative: await narrative?.toData(),
      nations: effectiveNations,
      player: player?.data,
      provinces: effectiveProvinces,
      startDate: startDate,
      unitTypes: effectiveUnitTypes,
      units: effectiveUnits,
      battles: effectiveBattles,
      diplomaticRelationships: effectiveDiplomaticRelations,
    );
  }

  TransoxianaGame? game;

  /// collects all data files and create [CampaignTemplateData]
  /// which should be saved manually to assets json files
  ///
  /// It can be used for in-game editor for development
  Future<CampaignTemplateData> toTemplateData() async =>
      throw UnimplementedError();

  // ************************************
  //       Factories end
  // ************************************

  Future<UnitType> getUnitTypeById(final UnitTypeNames unitTypeId) async {
    final existedUnitType = unitTypes[unitTypeId];
    if (existedUnitType != null) return existedUnitType;

    final existedUnitTypeData = data?.unitTypes[unitTypeId];
    if (existedUnitTypeData != null) {
      final unitType = await existedUnitTypeData.toType();
      unitTypes[unitTypeId] = unitType;
      return unitType;
    }
    throw ArgumentError.notNull(
      'unitType with id: $id not found. '
      'Try load unitTypes first or create this unitType',
    );
  }

  final Map<UnitTypeNames, UnitType> unitTypes;
  List<UnitType?> get defaultUnitTypes =>
      defaultUnitTypeIndices.map((final id) => unitTypes[id]).toList();

  Future<ArmyTemplate> getArmyTemplateById(
      {required final Id templateId,}) async {
    final existingTemplate = armyTemplates[templateId];
    if (existingTemplate != null) return existingTemplate;

    final existingTemplateData = data?.armyTemplates[templateId];
    if (existingTemplateData != null) {
      final template = await existingTemplateData.toTemplate(game: game!);
      armyTemplates[templateId] = template;
      return template;
    }
    throw ArgumentError.notNull(
      'armyTemplate with id: $templateId not found. '
      'Try load armyTemplates first or create this armyTemplate',
    );
  }

  final Map<String, ArmyTemplate> armyTemplates;
  Future<Unit> getUnitById({required final UnitId unitId}) async {
    final existedUnit = units[unitId.unitId];
    if (existedUnit != null) return existedUnit;
    final unitType = await getUnitTypeById(unitId.typeId);
    final nation = await getNationById(unitId.nationId);
    final newUnit = await unitType.toUnit(
      id: unitId,
      game: game!,
      nation: nation.data,
    );
    units[unitId.unitId] = newUnit;
    return newUnit;
  }

  final Map<Id, Unit> units;
  Future<Battle> getBattleById({required final String battleId}) async {
    final existedBattle = battles[battleId];
    if (existedBattle != null) return existedBattle;

    throw ArgumentError.notNull('battleId');
  }

  final Map<Id, Battle> battles;
  Future<Province> getProvinceById(final String provinceId) async {
    final existedProvince = provinces[provinceId];
    if (existedProvince != null) return existedProvince;
    final existedProvinceData = data?.provinces[provinceId];
    if (existedProvinceData != null) {
      final province = await existedProvinceData.toProvince(game: game!);
      provinces[provinceId] = province;
      return province;
    }
    throw ArgumentError.notNull(
      'province with id: $provinceId not found. '
      'Try load provinces first or create this province',
    );
  }

  final Map<String, Province> provinces;
  Future<Nation> getNationById(final String nationId) async {
    final existedNation = nations[nationId];
    if (existedNation != null) return existedNation;
    final existedNationData = data?.nations[nationId];
    if (existedNationData != null) {
      final nation = await existedNationData.toNation(
        game: game!,
        nations: nations,
      );
      return nation;
    }
    throw ArgumentError.notNull(
      'nation with id: $nationId not found. '
      'Try load nations first or create this nation',
    );
  }

  final Map<Id, Nation> nations;
  Future<Army> getArmyById(final ArmyId armyId) async {
    final existedArmy = armies[armyId.armyId];
    if (existedArmy != null) return existedArmy;
    final newArmy = await ArmyData(id: armyId).toArmy(game: game!);
    armies[armyId.armyId] = newArmy;
    return newArmy;
  }

  Iterable<Nation> get playableNations =>
      nations.values.where((final e) => e.isPlayable);

  Iterable<Nation> get nonPlayableNations =>
      nations.values.where((final e) => !e.isPlayable);

  final Map<Id, Army> armies;
  Future<Ai> getAiById(final AiId id) async {
    final existedAi = ais[id.aiId];
    if (existedAi != null) return existedAi;
    final newAi = await AiData(id: id).toAi(game: game!);
    ais[id.aiId] = newAi;
    return newAi;
  }

  final Map<Id, Fortification> forts;
  Future<Fortification> getFortById(final Id id) async {
    final existedFort = forts[id];
    if (existedFort != null) return existedFort;
    final newFort =
        await FortificationData(id: id).toFortification(game: game!);
    forts[id] = newFort;
    return newFort;
  }

  final Map<Id, Ai> ais;

  /// This id is not constant and changing
  /// every time the game is saving.
  /// It is made to ensure that we our last save is current game.
  Id id;
  bool get isGameExists => id.isNotEmpty;
  bool get isGameNotExists => id.isEmpty;

  Image? backgroundImage;
  final Random rand;
  String? backgroundImagePath;

  /// This data used for restoration and debugging purposes
  CampaignDataSource? data;

  double gameTime = 0; // in seconds
  Nation? player;
  String campaignName;
  GameDate currentDate;
  GameDate startDate;
  Battle getBattle({required final Id battleId}) {
    final effectiveActiveBattle = activeBattle;
    if (effectiveActiveBattle != null && battleId == effectiveActiveBattle.id) {
      return effectiveActiveBattle;
    }
    final maybeBattle = battles[battleId];
    if (maybeBattle != null) return maybeBattle;
    throw ArgumentError.notNull('battle for $battleId');
  }

  Battle? activeBattle;
  CampaignNarrative? narrative;

  int get currentYear => currentDate.year;
  set currentYear(final int val) =>
      currentDate = currentDate.copyWith(year: val);

  Season get currentSeason => currentDate.season;
  set currentSeason(final Season val) =>
      currentDate = currentDate.copyWith(season: val);

  int get startYear => startDate.year;
  Season get startSeason => startDate.season;
}
