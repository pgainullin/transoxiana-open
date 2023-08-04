import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/army.dart';
import 'package:transoxiana/components/shared/commander.dart';
import 'package:transoxiana/components/shared/events/events.dart';
import 'package:transoxiana/data/army_modes.dart';
import 'package:transoxiana/data/army_templates.dart';
import 'package:transoxiana/data/campaign_data_source.dart';
import 'package:transoxiana/data/unit_types.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/services/ai.dart';
import 'package:transoxiana/widgets/base/dialogues.dart';
import 'package:utils/utils.dart';

part 'nation.g.dart';

enum DiplomaticStatus {
  war,
  peace,
  alliance,
}

@JsonSerializable(explicitToJson: true)
class NationData {
  NationData({
    required this.name,
    required this.color,
    required final Id? id,
    this.aiId,
    final Set<EventData>? events,
    final Set<EventData>? battleEvents,
    final bool? isDefeated,
    final bool? takeCaptives,
    final bool? isIndependent,
    final bool? isPlayable,
    final Set<CommanderData>? unemployedCommanders,
    final Set<String>? armyTemplatesIds,
    final Set<UnitTypeNames>? specialUnitsIds,
    final Map<NationId, DiplomaticStatus>? diplomaticRelationships,
  })
      : id = id ?? uuid.v4(),
        events = events ?? {},
        battleEvents = battleEvents ?? {},
        isDefeated = isDefeated ?? false,
        takeCaptives = takeCaptives ?? false,
        isIndependent = isIndependent ?? false,
        isPlayable = isPlayable ?? false,
        unemployedCommanders = unemployedCommanders ?? {},
        armyTemplatesIds = armyTemplatesIds ?? {},
        specialUnitsIds = specialUnitsIds ?? {},
        diplomaticRelationships = diplomaticRelationships ?? {};

  static NationData fromJson(final Map<String, dynamic> json) =>
      _$NationDataFromJson(json);

  Map<String, dynamic> toJson() => _$NationDataToJson(this);

  Future<Nation> toNation({
    required final TransoxianaGame game,
    final Map<Id, Nation?>? nations,
  }) async {
    final nation = Nation._fromData(
      game: game,
      data: this,
      battleEvents: {},
      events: {},
      armyTemplates: await _loadArmyTemplates(game: game),
      specialUnitsTypes: await _loadSpecialUnits(game: game),
      unemployedCommanders: await _loadUnemployedCommanders(game: game),
      diplomaticRelationships: {},
      ai: null,
    );

    if (nations != null) nations[id] = nation;
    nation
      ..ai = await _loadAi(game: game)
      ..diplomaticRelationships
          .addAll(await _loadDiplomaticRelationships(game: game));
    return nation;
  }

  final Id id;
  AiId? aiId;

  String name;
  @JsonKey(
    fromJson: colorFromJson,
    toJson: colorToJson,
  )
  Color color;

  /// UnitTypes that this nation can build in addition to basic units
  /// and Province specialUnits
  @JsonKey(name: 'specialUnits')
  final Set<UnitTypeNames> specialUnitsIds;

  /// Template armies that this nation prefers to build
  @JsonKey(name: 'armyTemplates')
  final Set<Id> armyTemplatesIds;

  /// Set of commanders not currently leading any armies in the field.
  /// Will be assigned to new armies prior to recruiting new ones
  final Set<CommanderData> unemployedCommanders;

  final Map<NationId, DiplomaticStatus> diplomaticRelationships;

  /// used to identify if this nation has been completely defeated
  /// (i.e. lost all its armies and provinces)
  bool isDefeated;

  /// special ability to add Captive units from sacked provinces
  bool takeCaptives;

  /// whether player can take control of this nation in campaign.
  /// Also affects soleSurvivor victory event type
  bool isPlayable;

  /// whether this nation is an independent / barbarian nation which will get
  /// random armies and not engage in diplomacy
  bool isIndependent;

  final Set<EventData> events;
  final Set<EventData> battleEvents;

  Future<Set<Event>> loadBattleEvents({
    required final TransoxianaGame game,
  }) async =>
      battleEvents.convert((final data) async => data.toEvent(game: game));

  Future<Set<Event>> loadEvents({required final TransoxianaGame game}) async {
    // this.victoryCondition = EventCondition(this.game, this, this.playable ?
    // EventConditionType.soleSurvivor : EventConditionType.alwaysFalse);
    final eventData = EventData.fromConditionAndConsequenceTypes(
      nationId: id,
      condition: isPlayable
          ? EventConditionType.soleSurvivor
          : EventConditionType.alwaysFalse,
      consequenceOtherNationId: id,
      consequence: EventConsequenceType.victory,
    );
    final victoryEvent = await eventData.toEvent(game: game);
    final effectiveEvents =
    (await events.convert((final data) async => data.toEvent(game: game)))
        .toSet()
      ..add(victoryEvent);

    return effectiveEvents;
  }

  Future<Map<Nation, DiplomaticStatus>> _loadDiplomaticRelationships({
    required final TransoxianaGame game,
  }) async =>
      diplomaticRelationships.convertKeys(
            (final nationId) async =>
            game.campaignRuntimeData.getNationById(nationId),
      );

  Future<List<ArmyTemplate>> _loadArmyTemplates({
    required final TransoxianaGame game,
  }) async {
    final list = await armyTemplatesIds.convert(
          (final templateId) async =>
          game.campaignRuntimeData.getArmyTemplateById(templateId: templateId),
    );
    return list.toList();
  }

  Future<List<UnitType>> _loadSpecialUnits({
    required final TransoxianaGame game,
  }) async {
    final list = await specialUnitsIds.convert(
          (final unitId) async =>
          game.campaignRuntimeData.getUnitTypeById(unitId),
    );
    return list.toList();
  }

  Future<Ai?> _loadAi({required final TransoxianaGame game}) async {
    if (aiId == null) return null;
    return game.campaignRuntimeData.getAiById(aiId!);
  }

  Future<Set<Commander>> _loadUnemployedCommanders({
    required final TransoxianaGame game,
  }) async =>
      (await unemployedCommanders
          .convert((final item) => item.toCommander(game: game)))
          .toSet();
}

/// the entity controlled by a player or an AI which has provinces
/// and armies under its control.
class Nation
    with EquatableMixin
    implements GameRef, DataSourceRef<NationData, Nation> {
  Nation._fromData({
    required this.game,
    required this.data,
    required this.specialUnitsTypes,
    required this.armyTemplates,
    required this.unemployedCommanders,
    required this.diplomaticRelationships,
    required this.events,
    required this.battleEvents,
    required this.ai,
  }) {
    _init();
  }

  void _init() {
    updatePaints();
  }

  @override
  Future<void> refillData(final Nation otherType) async {
    assert(
    otherType == this,
    'You trying to update different nation.',
    );
    final newData = await otherType.toData();
    data = newData;
    if (events.length != otherType.data.events.length) {
      events.assignAll(await data.loadEvents(game: game));
      battleEvents.assignAll(await data.loadBattleEvents(game: game));
    }
    specialUnitsTypes.assignAll(otherType.specialUnitsTypes);
    armyTemplates.assignAll(otherType.armyTemplates);
    unemployedCommanders.assignAll(otherType.unemployedCommanders);
    diplomaticRelationships.assignAll(otherType.diplomaticRelationships);
    events.assignAll(otherType.events);
    battleEvents.assignAll(otherType.battleEvents);
    final otherAi = otherType.ai;
    if (otherAi != null) {
      if (ai == null) {
        ai = otherAi;
      } else {
        await ai?.refillData(otherAi);
      }
    }
    _init();
  }

  static Map<Id, AiData> createAis({
    required final Iterable<NationData> nations,
    required final NationData player,
  }) {
    final ais = <Id, AiData>{};
    for (final nation in nations) {
      if (nation != player) {
        final newAiData = AiData(
          id: AiId(
            aiId: null,
            nationId: nation.id,
          ),
        );
        ais[newAiData.id.aiId] = newAiData;
      }
    }
    return ais;
  }

  @override
  Future<NationData> toData() async =>
      NationData(
        name: name,
        color: color,
        id: id,
        aiId: ai?.id,
        armyTemplatesIds: armyTemplates.map((final e) => e.id).toSet(),
        diplomaticRelationships: diplomaticRelationships.map(
              (final key, final value) => MapEntry(key.id, value),
        ),
        isDefeated: isDefeated,
        isIndependent: isIndependent,
        isPlayable: isPlayable,
        specialUnitsIds: specialUnitsTypes.map((final e) => e.id).toSet(),
        takeCaptives: takeCaptives,
        unemployedCommanders: data.unemployedCommanders,
      );

  @override
  NationData data;
  final Paint painter = Paint();
  final Paint commanderPaint = Paint();

  String get name => data.name;

  Color get color => data.color;

  /// UnitTypes that this nation can build in addition to basic units and
  /// Province specialUnits
  final List<UnitType> specialUnitsTypes;

  /// Template armies that this nation prefers to build
  final List<ArmyTemplate> armyTemplates;

  /// Set of commanders not currently leading any armies in the field.
  /// Will be assigned to new armies prior to recruiting new ones
  final Set<Commander> unemployedCommanders;

  /// used to identify if this nation has been completely defeated
  /// (i.e. lost all its armies and provinces)
  bool get isDefeated => data.isDefeated;

  /// special ability to add Captive units from sacked provinces
  bool get takeCaptives => data.takeCaptives;

  @override
  TransoxianaGame game;

  Ai? ai;

  /// whether player can take control of this nation in campaign.
  /// Also affects soleSurvivor victory event type
  bool get isPlayable => data.isPlayable;

  /// whether this nation is an independent / barbarian nation which will get
  /// random armies and not engage in diplomacy
  bool get isIndependent => data.isIndependent;

  /// [EventCondition] victoryCondition;
  final Events events;

  /// The events for nation, that exists only during active battle
  /// Will be cleared after every battle
  final Events battleEvents;

  final Map<Nation, DiplomaticStatus> diplomaticRelationships;

  /// denotes the index of this nation in the list of nations in the campaign
  /// JSON. Used to identify the nation when hashCodes change as a save / new
  /// campaign is loaded
  Id get id => data.id;

  /// This factory should be used in case if player
  /// is not set before game started. In that case player
  /// must be set during game load

  void updatePaints() {
    painter
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..color = color;

    commanderPaint
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.yellow;
  }

  @override
  String toString() {
    return '<Nation>: $name';
  }

  /// List of all Armies owned by this Nation including the defeated
  /// / empty ones
  @useResult
  Iterable<Army> getArmies() =>
      game.campaignRuntimeData.armies.values
          .where((final element) => element.nation == this);

  /// List of all Provinces owned by this Nation
  @useResult
  Iterable<Province> getProvinces() =>
      game.campaign!.provinces.where((final element) => element.nation == this);

  /// Total unit count of undefeated armies.
  /// used in simple AI nation strength calculations
  int get unitCount =>
      getArmies().fold<int>(
        0,
            (final previousValue, final element) =>
        previousValue + (element.defeated ? 0 : element.units.length),
      );

  /// Total unit count of undefeated armies that are not in defender mode.
  /// used in simple AI nation strength calculations
  int get unitCountOffensive =>
      getArmies()
          .where((final element) => element.mode != ArmyMode.defender())
          .fold<int>(
        0,
            (final previousValue, final element) =>
        previousValue + (element.defeated ? 0 : element.units.length),
      );

  /// returns true if this nation has fortified provinces that
  /// have no armies defending them
  bool get haveUndefendedForts =>
      getProvinces()
          .where(
            (final province) =>
        province.isFortified &&
            province.armies.values
                .where((final army) => army.nation == this)
                .isEmpty,
      )
          .isNotEmpty;

  /// Returns true if the given nation is this nation or allied to it
  bool isFriendlyTo(final Nation otherNation) {
    return this == otherNation ||
        diplomaticRelationships[otherNation] == DiplomaticStatus.alliance;
  }

  /// Returns true if the given nation is NOT this nation AND is at War with it
  bool isHostileTo(final Nation otherNation) {
    return this != otherNation &&
        diplomaticRelationships[otherNation] == DiplomaticStatus.war;
  }

  /// check if this nation has no Provinces and no undefeated armies,
  /// in which case set isDefeated to true
  void checkIfDefeated() {
    if (getProvinces().isEmpty &&
        getArmies()
            .where((final element) => element.defeated == false)
            .isEmpty) {
      data.isDefeated = true;
    }
  }

  Future<ConfirmAction> confirmWarDeclaration(final Nation otherNation) async {
    ConfirmAction confirm = ConfirmAction.accept;
    confirm = await asyncConfirmDialog(
      getScaffoldKeyContext(),
      S.current.confirmWarDeclarationTitle,
      S.current.confirmWarDeclarationContent(otherNation.name),
    ) ??
        ConfirmAction.accept;

    if (confirm == ConfirmAction.accept) {
      declareWar(otherNation);
    }
    return confirm;
  }

  /// Declare war on otherNation and all of its allies
  void declareWar(final Nation otherNation) {
    _forceTwoNationsRelationshipToWar(this, otherNation);

    if (otherNation != game.player) {
      otherNation.ai?.dateOfLastPeaceOffer[this] =
          game.campaign!.runtimeData.currentDate;
    }

    final thisAlliesNotAtWar = diplomaticRelationships.keys.where(
          (final potentialAlly) =>
      diplomaticRelationships[potentialAlly] == DiplomaticStatus.alliance &&
          potentialAlly.diplomaticRelationships[otherNation] !=
              DiplomaticStatus.war,
    );
    if (thisAlliesNotAtWar.isNotEmpty) {
      for (final ally in thisAlliesNotAtWar) {
        ally.declareWar(otherNation);
      }
    }
    final Iterable<Nation> otherNationAlliesNotAtWar =
    diplomaticRelationships.keys.where(
          (final potentialEnemyAllies) =>
      otherNation.diplomaticRelationships[potentialEnemyAllies] ==
          DiplomaticStatus.alliance &&
          potentialEnemyAllies.diplomaticRelationships[this] !=
              DiplomaticStatus.war,
    );
    if (otherNationAlliesNotAtWar.isNotEmpty) {
      for (final enemyAlly in otherNationAlliesNotAtWar) {
        declareWar(enemyAlly);
      }
    }

    assert(!isFriendlyTo(otherNation));
    assert(isHostileTo(otherNation));
  }

  /// set the mutual relationship between the two Nations to War
  /// without going through allies
  static void _forceTwoNationsRelationshipToWar(final Nation firstNation,
      final Nation secondNation,) {
    firstNation.diplomaticRelationships[secondNation] = DiplomaticStatus.war;
    secondNation.diplomaticRelationships[firstNation] = DiplomaticStatus.war;
  }

  /// Create a new event offering peace to the otherNation.
  Future<void> addPeaceOfferEvent(final Nation nation) async {
    final eventData = EventData.fromConditionAndConsequenceTypes(
      nationId: nation.id,
      condition: EventConditionType.alwaysTrue,
      consequenceOtherNationId: id,
      consequence: EventConsequenceType.peaceOffer,
    );
    final event = await eventData.toEvent(game: game);
    nation.events.add(event);
  }

  /// Sign a peace treaty with otherNation.
  /// Does not affect allies of either nation.
  void agreeToPeace(final Nation otherNation) {
    diplomaticRelationships[otherNation] = DiplomaticStatus.peace;
    otherNation.diplomaticRelationships[this] = DiplomaticStatus.peace;
  }

  @override
  List<Object?> get props => [id];
}
