part of 'events.dart';

@JsonSerializable(explicitToJson: true)
class EventConsequenceData with EquatableMixin {
  EventConsequenceData({
    required this.type,
    required this.nationId,
    final Set<EventConsequenceData>? otherConsequences,
    final Set<Id>? provincesAffected,
    final Set<ArmyId>? armiesAffected,
    this.message,
    this.otherNationId,
  })  : otherConsequences = otherConsequences ?? {},
        provincesAffected = provincesAffected ?? {},
        armiesAffected = armiesAffected ?? {};

  Map<String, dynamic> toJson() => _$EventConsequenceDataToJson(this);

  static EventConsequenceData fromJson(final Map<String, dynamic> json) =>
      _$EventConsequenceDataFromJson(json);

  Future<EventConsequence> toEvent({
    required final TransoxianaGame game,
  }) async {
    final effectiveNation =
        await game.campaignRuntimeData.getNationById(nationId);
    final effectiveOtherNationId = otherNationId;
    final effectiveOtherNation = effectiveOtherNationId == null
        ? null
        : await game.campaignRuntimeData.getNationById(effectiveOtherNationId);
    final effectiveOtherConsequences = await otherConsequences.convert(
      (final data) async => data.toEvent(game: game),
    );
    final effectiveProvinces = await provincesAffected.convert(
      (final provinceId) async =>
          game.campaignRuntimeData.getProvinceById(provinceId),
    );

    final effectiveArmies = await armiesAffected.convert(
      (final armyId) => game.campaignRuntimeData.getArmyById(armyId),
    );

    return EventConsequence._fromData(
      game: game,
      nation: effectiveNation,
      otherNation: effectiveOtherNation,
      message: message,
      otherConsequences: effectiveOtherConsequences.toSet(),
      provincesAffected: effectiveProvinces,
      armiesAffected: effectiveArmies,
      data: this,
    );
  }

  final EventConsequenceType type;
  final Id nationId;
  final Set<EventConsequenceData> otherConsequences;
  final Set<Id> provincesAffected;
  final Set<ArmyId> armiesAffected;
  String? message;
  Id? otherNationId;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [
        type,
        nationId,
        otherConsequences,
        provincesAffected,
        message,
        otherNationId,
      ];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;
}

class EventConsequence
    with EquatableMixin
    implements GameRef, DataSourceRef<EventConsequenceData, EventConsequence> {
  EventConsequence._fromData({
    required this.game,
    required this.nation,
    required this.otherNation,
    required this.message,
    required this.otherConsequences,
    required this.provincesAffected,
    required this.armiesAffected,
    required this.data,
  });

  @override
  Future<void> refillData(final EventConsequence otherType) async {
    assert(
      otherType == this,
      'You trying to update different event consequence.',
    );

    final newData = await otherType.toData();
    data = newData;
    nation = otherType.nation;
    otherNation = otherType.otherNation;
    message = otherType.message;
    otherConsequences.assignAll(otherType.otherConsequences);
    provincesAffected.assignAll(otherType.provincesAffected);
    armiesAffected.assignAll(otherType.armiesAffected);
  }

  @override
  Future<EventConsequenceData> toData() async {
    final effectiveOtherConsequences = await otherConsequences.convert(
      (final consequence) async => consequence.toData(),
    );
    return EventConsequenceData(
      message: message,
      nationId: nation.id,
      type: type,
      otherConsequences: effectiveOtherConsequences.toSet(),
      provincesAffected: provincesAffected.map((final item) => item.id).toSet(),
      armiesAffected: armiesAffected.map((final e) => e.id).toSet(),
      otherNationId: otherNation?.id,
    );
  }

  EventConsequence copyWith({
    final Nation? nation,
    final EventConsequenceType? type,
    final String? message,
    final Nation? otherNation,
  }) =>
      EventConsequence._fromData(
        game: game,
        nation: nation ?? this.nation,
        otherNation: otherNation ?? this.otherNation,
        message: message ?? this.message,
        otherConsequences: otherConsequences,
        provincesAffected: provincesAffected,
        armiesAffected: armiesAffected,
        data: data,
      );
  @override
  TransoxianaGame game;
  @override
  EventConsequenceData data;

  EventConsequenceType get type => data.type;
  Nation nation;
  final Set<EventConsequence> otherConsequences;
  final Set<Province> provincesAffected;
  final Set<Army> armiesAffected;
  String? message;
  Nation? otherNation;

  Future<void> trigger() async {
    switch (type) {
      case EventConsequenceType.victory:
        await game.triggerVictory(nation);
        break;
      case EventConsequenceType.defeat:
        throw UnimplementedError();
      case EventConsequenceType.fortifiedBattleStarted:
      case EventConsequenceType.nonFortifiedBattleStarted:
      case EventConsequenceType.campaignStarted:
      case EventConsequenceType.battlePlayerUnitSelected:
      case EventConsequenceType.campaignPlayerArmySelected:
        await game.tutorialEventHandlerSystem.executeConsequence(type);
        break;

      case EventConsequenceType.dialogue:
        if (nation == game.player) {
          assert(message != null);
          await infoDialogue(message!);
        }
        break;
      case EventConsequenceType.declareWar:
        assert(otherNation != null);
        assert(otherNation != nation);

        if (nation.diplomaticRelationships[otherNation] !=
            DiplomaticStatus.war) {
          nation.declareWar(otherNation!);

          if (otherNation == game.player) {
            await infoDialogue(
              S
                  .of(getScaffoldKeyContext())
                  .otherNationDeclaredWarOnYou(nation.name),
            );
          } else if (nation == game.player) {
            await infoDialogue(
              S
                  .of(getScaffoldKeyContext())
                  .youDeclareWarOnOtherNation(otherNation!.name),
            );
          }
        }
        break;
      case EventConsequenceType.handoverProvinces:
        assert(
          provincesAffected.isNotEmpty,
          'EventConsequenceType.handoverProvinces provinces empty',
        );
        assert(
          otherNation != null,
          'EventConsequenceType.handoverProvinces other nation is null',
        );

        int provincesAnnexed = 0;
        for (final province in provincesAffected) {
          if (province.nation == nation) {
            province.annex(otherNation!);
            provincesAnnexed += 1;
          }
        }

        //toogle isDefeated to bring any previously defeated nations back
        if (provincesAnnexed > 0) otherNation!.data.isDefeated = false;

        break;
      case EventConsequenceType.handoverArmies:
        assert(
          armiesAffected.isNotEmpty,
          'EventConsequenceType.handoverArmies armiesAffected is empty',
        );
        assert(
          otherNation != null,
          'EventConsequenceType.handoverArmies otherNation is null',
        );

        int fightingArmiesTransferred = 0;
        for (final army in armiesAffected) {
          if (army.nation == nation) {
            army.changeNation(otherNation!);
            if (army.isFighting) fightingArmiesTransferred += 1;
          }
        }

        //toogle isDefeated to bring any previously defeated nations back
        if (fightingArmiesTransferred > 0) otherNation!.data.isDefeated = false;

        break;

      case EventConsequenceType.peaceOffer:
        assert(otherNation != null);
        assert(otherNation != nation);

        if (nation.diplomaticRelationships[otherNation] ==
            DiplomaticStatus.war) {
          if (nation == game.player) {
            if (game.isHeadless) {
              nation.agreeToPeace(otherNation!);
              //TODO(PG): fix headless mode decisions

            } else {
              if (otherNation!.isDefeated) return;

              final confirmedAction = await yesNoDialogue(
                S
                    .of(getScaffoldKeyContext())
                    .otherNationOffersPeace(otherNation!.name),
              );

              if (confirmedAction == ConfirmAction.accept) {
                nation.agreeToPeace(otherNation!);
              }
            }
          } else {
            //AI
            final resolvedOtherNation = otherNation;
            if (resolvedOtherNation == null) {
              throw ArgumentError.notNull('otherNation');
            }
            final ConfirmAction action =
                nation.ai!.evaluatePeaceOffer(resolvedOtherNation);
            final eventConditionData = EventConditionData(
              nationId: resolvedOtherNation.id,
              type: EventConditionType.alwaysTrue,
            );
            final consequenceData = EventConsequenceData(
              nationId: resolvedOtherNation.id,
              type: EventConsequenceType.dialogue,
            );
            final consequence = await consequenceData.toEvent(game: game);
            final eventData = EventData(
              nationId: resolvedOtherNation.id,
              condition: eventConditionData,
              consequence: consequenceData,
            );
            final event = await eventData.toEvent(game: game);
            if (action == ConfirmAction.accept) {
              nation.agreeToPeace(resolvedOtherNation);
              if (resolvedOtherNation == game.player) {
                final peacefulEvent = event.copyWith(
                  consequence: consequence.copyWith(
                    message: S.current.otherNationAcceptsPeace(nation.name),
                  ),
                );
                resolvedOtherNation.events.add(peacefulEvent);
              }
            } else {
              if (resolvedOtherNation == game.player) {
                final rejectedEvent = event.copyWith(
                  consequence: consequence.copyWith(
                    message: S.current.otherNationRejectedPeace(nation.name),
                  ),
                );
                resolvedOtherNation.events.add(rejectedEvent);
              }
            }
          }
        }

        break;
      case EventConsequenceType.composedConsequenceAND:
        assert(otherConsequences.isNotEmpty);
        await Future.forEach<EventConsequence>(
          otherConsequences,
          (final element) => element.trigger(),
        );
        break;
      case EventConsequenceType.composedConsequenceOR:
        assert(otherConsequences.isNotEmpty);
        //TODO: implement dialogues letting the player/AI choose
        throw UnimplementedError();
      case EventConsequenceType.annex:
        assert(otherNation != null);
        assert(otherNation != nation);

        for (final army in otherNation!.getArmies()) {
          if (army.defeated) continue;
          army.changeNation(nation);
        }
        for (final province in otherNation!.getProvinces()) {
          province.annex(nation);
        }
        otherNation!.data.isDefeated = true;
        break;

      default:
        throw Exception('Unhandled EventConsequenceType: $type');
    }
  }

  Future<void> infoDialogue(final String message) async {
    if (game.isHeadless) return;

    await asyncInfoDialog(
      scaffoldKey.currentContext!,
      S.of(getScaffoldKeyContext()).event,
      message,
    );
  }

  Future<ConfirmAction?> yesNoDialogue(final String message) async {
    if (game.isHeadless) return ConfirmAction.accept;

    return asyncConfirmDialog(
      scaffoldKey.currentContext!,
      S.of(getScaffoldKeyContext()).event,
      message,
    );
  }

  @override
  List<Object?> get props => [...data.props];
}
