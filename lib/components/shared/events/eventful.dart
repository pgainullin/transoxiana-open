part of 'events.dart';

/// This class should be implemented in classes
/// that have [EventResolver] evaluation
abstract class Eventful {
  Eventful._();
  Future<void> evaluateEvents();
}

/// This class responsible for events consequences evaluation
class EventResolver {
  EventResolver._();
  static Future<void> evaluateEvent({
    required final Event event,
    required final Events events,
    final EventTriggerType trigger = EventTriggerType.startTurn,
  }) async {
    await event.evaluateAndTrigger(trigger: trigger);
    events.add(event);
  }

  static Future<void> evaluateEvents({
    required final Iterable<Event> newEvents,
    required final Events eventsStack,
    final EventTriggerType trigger = EventTriggerType.startTurn,
  }) async {
    await Future.forEach<Event>(
      newEvents,
      (final event) => evaluateEvent(
        event: event,
        events: eventsStack,
        trigger: trigger,
      ),
    );
  }

  static Future<void> evaluate({
    required final Iterable<Nation> aiNations,
    required final Nation player,
    final bool useBattleEvents = false,
    final EventTriggerType trigger = EventTriggerType.startTurn,
  }) async {
    log('[EventResolver] Evaluating ai consequences');
    // check all events including victory conditions
    Events resolveEvents(final Nation nation) =>
        useBattleEvents ? nation.battleEvents : nation.events;

    for (final nation in aiNations) {
      final resolvedEvents = resolveEvents(nation);
      await Future.forEach<Event>(
        resolvedEvents,
        (final event) {
          return event.evaluateAndTrigger(trigger: trigger);
        },
      );
    }

    log('[EventResolver] Evaluating player consequences');
    //run player events last to ensure the player receives any info dialogue messages immediately
    final resolvedEvents = resolveEvents(player);
    await Future.forEach<Event>(
      resolvedEvents,
      (final event) => event.evaluateAndTrigger(trigger: trigger),
    );
  }
}
