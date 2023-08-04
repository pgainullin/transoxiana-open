part of 'events.dart';

@JsonSerializable(explicitToJson: true)
class EventConditionData with EquatableMixin {
  EventConditionData({
    required this.type,
    required this.nationId,
    final Set<EventConditionData>? subconditions,
    final Set<Id>? nationsToCapture,
    final Set<Id>? provincesToCapture,
    final Set<ArmyId>? armiesToKill,
  })  : subconditions = subconditions ?? {},
        nationsToCapture = nationsToCapture ?? {},
        provincesToCapture = provincesToCapture ?? {},
        armiesToKill = armiesToKill ?? {};

  Map<String, dynamic> toJson() => _$EventConditionDataToJson(this);

  static EventConditionData fromJson(final Map<String, dynamic> json) =>
      _$EventConditionDataFromJson(json);

  Future<EventCondition> toEvent({
    required final TransoxianaGame game,
  }) async {
    final effectiveNation =
        await game.campaignRuntimeData.getNationById(nationId);
    final effectiveProvincesToCapture = (await provincesToCapture.convert(
      (final provinceId) =>
          game.campaignRuntimeData.getProvinceById(provinceId),
    ))
        .toSet();
    if (type == EventConditionType.captureNations) {
      // fix the provinces that need to be captured at initialization
      effectiveProvincesToCapture.addAll(
        game.campaignRuntimeData.provinces.values.where(
          (final element) => nationsToCapture.contains(element.nation.id),
        ),
      );
    }
    final effectiveNationsToCapture = await nationsToCapture.convert(
      (final nationId) => game.campaignRuntimeData.getNationById(nationId),
    );
    final effectiveArmiesToKill = await armiesToKill.convert(
      (final armyId) => game.campaignRuntimeData.getArmyById(armyId),
    );
    final effectiveSubconditions = await subconditions
        .convert((final condition) async => condition.toEvent(game: game));
    return EventCondition._fromData(
      game: game,
      nation: effectiveNation,
      data: this,
      armiesToKill: effectiveArmiesToKill.toSet(),
      nationsToCapture: effectiveNationsToCapture.toSet(),
      provincesToCapture: effectiveProvincesToCapture,
      subconditions: effectiveSubconditions.toSet(),
    );
  }

  final EventConditionType type;
  final Id nationId;
  final Set<EventConditionData> subconditions;
  final Set<Id> nationsToCapture;
  final Set<Id> provincesToCapture;
  final Set<ArmyId> armiesToKill;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [
        type,
        nationId,
        subconditions,
        nationsToCapture,
        provincesToCapture,
        armiesToKill,
      ];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;
}

class EventCondition
    with EquatableMixin
    implements GameRef, DataSourceRef<EventConditionData, EventCondition> {
  EventCondition._fromData({
    required this.game,
    required this.nation,
    required this.data,
    required this.armiesToKill,
    required this.nationsToCapture,
    required this.provincesToCapture,
    required this.subconditions,
  });

  @override
  Future<EventConditionData> toData() async {
    final effectiveSubconditions =
        (await subconditions.convert((final e) async => e.toData())).toSet();
    return EventConditionData(
      nationId: nation.id,
      type: data.type,
      armiesToKill: armiesToKill.map((final e) => e.id).toSet(),
      nationsToCapture: nationsToCapture.map((final e) => e.id).toSet(),
      provincesToCapture: provincesToCapture.map((final e) => e.id).toSet(),
      subconditions: effectiveSubconditions,
    );
  }

  @override
  Future<void> refillData(final EventCondition otherType) async {
    assert(
      otherType == this,
      'You trying to update different event condition.',
    );
    final newData = await otherType.toData();
    data = newData;
    nation = otherType.nation;
    armiesToKill.assignAll(otherType.armiesToKill);
    nationsToCapture.assignAll(otherType.nationsToCapture);
    provincesToCapture.assignAll(otherType.provincesToCapture);
    subconditions.assignAll(otherType.subconditions);
  }

  @override
  EventConditionData data;

  EventConditionType get type => data.type;
  @override
  TransoxianaGame game;
  Nation nation;
  final Set<EventCondition> subconditions;
  final Set<Nation> nationsToCapture;
  final Set<Province> provincesToCapture;
  final Set<Army> armiesToKill;

  bool evaluate() {
    switch (type) {
      case EventConditionType.composedConditionOR:
        {
          assert(subconditions.isNotEmpty);
          for (final EventCondition orCondition in subconditions) {
            if (orCondition.evaluate() == true) return true;
          }
          return false;
        }

      case EventConditionType.composedConditionNOT:
        {
          assert(
            subconditions.isNotEmpty,
            'EventConditionType.composedConditionNOT subconditions are empty',
          );
          for (final EventCondition notCondition in subconditions) {
            if (notCondition.evaluate() == true) return false;
          }
          return true;
        }

      case EventConditionType.composedConditionAND:
        {
          assert(subconditions.isNotEmpty);

          for (final EventCondition andCondition in subconditions) {
            if (andCondition.evaluate() == false) return false;
          }
          return true;
        }

      case EventConditionType.soleSurvivor:
        {
          assert(subconditions.isEmpty);

          final List<Nation> playableNations =
              game.campaignRuntimeData.playableNations.toList();

          final List<Nation> losers = playableNations
              .where(
                (final testNation) =>
                    game.campaignRuntimeData.armies.values.firstWhereOrNull(
                      (final army) =>
                          army.nation == testNation && army.defeated == false,
                    ) ==
                    null,
              )
              .toList();
          // log('${this.nation.name}: Defeated nations count - ${losers.length} vs. ${playableNations.length} (${losers.join(', ')}) ${losers.contains(this.nation)}');

          if (losers.contains(nation)) return false;
          if (losers.length == playableNations.length - 1) return true;
          return false;
        }

      case EventConditionType.captureProvinces:
        {
          assert(provincesToCapture.isNotEmpty);
          if (provincesToCapture
              .where((final element) => element.nation != nation)
              .isEmpty) return true;
          return false;
        }

      case EventConditionType.captureNations:
        {
          assert(
            nationsToCapture.isNotEmpty,
            'nationsToCapture should not be empty for EventConditionType.captureNations',
          );
          if (provincesToCapture
                  .where((final element) => element.nation != nation)
                  .isEmpty &&
              nationsToCapture
                  .where((final element) => !element.isDefeated)
                  .isEmpty) {
            return true;
          }
          return false;
        }

      case EventConditionType.killArmies:
        {
          assert(armiesToKill.isNotEmpty);
          if (armiesToKill
              .where((final element) => element.defeated == false)
              .isEmpty) return true;
          return false;
        }

      case EventConditionType.alwaysFalse:
        {
          return false;
        }

      case EventConditionType.alwaysTrue:
        {
          return true;
        }

      case EventConditionType.campaignStart:
        {
          return true;
        }

      case EventConditionType.battleStart:
        {
          return true;
        }
      case EventConditionType.battleSelectPlayerUnit:
        {
          return true;
        }
      case EventConditionType.campaignSelectPlayerArmy:
        {
          return true;
        }
      default:
        {
          throw Exception('Unhandled EventConditionType $type');
        }
    }
  }

  @override
  List<Object?> get props => [...data.props];
}
