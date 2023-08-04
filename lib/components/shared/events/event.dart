part of 'events.dart';

typedef Events = Set<Event>;

// Test event for a quick victory by the Mongols:
// {
// "nation": 1,
// "triggered": false,
// "condition": {
// "type": 2,
// "nationsToCapture": [],
// "armiesToKill": [],
// "provincesToCapture": ["Guzkol"],
// "subconditions": []
// },
// "consequence": {
// "type": 0,
// "otherConsequences":[]
// }
// },
@JsonSerializable(explicitToJson: true)
class EventData with EquatableMixin {
  EventData({
    required this.nationId,
    required this.condition,
    required this.consequence,
    final EventTriggerType? triggerType,
    final bool? triggered,
  })  : triggerType = triggerType ?? EventTriggerType.startTurn,
        triggered = triggered ?? false;
  factory EventData.fromConditionAndConsequence(
    final EventConditionData condition,
    final EventConsequenceData consequence, {
    final EventTriggerType trigger = EventTriggerType.startTurn,
  }) {
    assert(condition.nationId == consequence.nationId);
    final nationId = condition.nationId;
    return EventData(
      condition: condition,
      consequence: consequence,
      nationId: nationId,
      triggerType: trigger,
    );
  }

  /// Will use same game and nation for condition and consequence
  factory EventData.fromConditionAndConsequenceTypes({
    required final Id nationId,
    required final EventConditionType condition,
    required final EventConsequenceType consequence,
    final EventTriggerType trigger = EventTriggerType.startTurn,
    final Id? consequenceOtherNationId,
  }) {
    final resolvedCondition = EventConditionData(
      nationId: nationId,
      type: condition,
    );
    final resolvedConsequence = EventConsequenceData(
      nationId: nationId,
      otherNationId: consequenceOtherNationId,
      type: consequence,
    );

    return EventData.fromConditionAndConsequence(
      resolvedCondition,
      resolvedConsequence,
      trigger: trigger,
    );
  }

  Map<String, dynamic> toJson() => _$EventDataToJson(this);
  static EventData fromJson(final Map<String, dynamic> json) =>
      _$EventDataFromJson(json);
  Future<Event> toEvent({required final TransoxianaGame game}) async {
    final effectiveNation =
        await game.campaignRuntimeData.getNationById(nationId);
    final effectiveCondition = await condition.toEvent(game: game);
    final effectiveConsequence = await consequence.toEvent(game: game);
    return Event._fromData(
      game: game,
      nation: effectiveNation,
      condition: effectiveCondition,
      consequence: effectiveConsequence,
      triggerType: triggerType,
      data: this,
    );
  }

  final EventTriggerType triggerType;
  bool triggered;
  final Id nationId;
  final EventConditionData condition;
  final EventConsequenceData consequence;

  @override
  @JsonKey(ignore: true)
  List<Object?> get props => [
        nationId,
        condition,
        consequence,
        triggerType,
      ];

  @override
  @JsonKey(ignore: true)
  // ignore: hash_and_equals
  int get hashCode => super.hashCode;

  @override
  @JsonKey(ignore: true)
  bool? get stringify => true;
}

class Event
    with EquatableMixin
    implements GameRef, DataSourceRef<EventData, Event> {
  Event._fromData({
    required this.game,
    required this.nation,
    required this.condition,
    required this.consequence,
    required this.triggerType,
    required this.data,
  });

  @override
  Future<void> refillData(final Event otherType) async {
    assert(
      otherType == this,
      'You trying to update different event.',
    );
    final newData = await otherType.toData();
    data = newData;
    nation = otherType.nation;
    condition = otherType.condition;
    consequence = otherType.consequence;
    triggerType = otherType.triggerType;
  }

  @override
  Future<EventData> toData() async {
    final conditionData = await condition.toData();
    final consequenceData = await consequence.toData();
    return EventData(
      condition: conditionData,
      consequence: consequenceData,
      nationId: nation.id,
      triggerType: triggerType,
      triggered: triggered,
    );
  }

  @override
  EventData data;

  @override
  TransoxianaGame game;
  Nation nation;
  EventCondition condition;
  EventConsequence consequence;

  /// determines whether the event conditions will be checked
  /// based on what triggered the check
  EventTriggerType triggerType;

  /// whether the event has been triggered. If true this event
  /// will never be triggered again regardless of its conditions.
  bool get triggered => data.triggered;

  Future<void> evaluateAndTrigger({
    final EventTriggerType trigger = EventTriggerType.startTurn,
  }) async {
    if (trigger != triggerType) return;

    if (!data.triggered && condition.evaluate()) {
      await consequence.trigger();
      data.triggered = true;
    }
  }

  Event copyWith({
    final Nation? nation,
    final EventCondition? condition,
    final EventConsequence? consequence,
  }) =>
      Event._fromData(
        condition: condition ?? this.condition,
        consequence: consequence ?? this.consequence,
        nation: nation ?? this.nation,
        data: data,
        game: game,
        triggerType: triggerType,
      );
  @override
  List<Object?> get props => data.props;
}
