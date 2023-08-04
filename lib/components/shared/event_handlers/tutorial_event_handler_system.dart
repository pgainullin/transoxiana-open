import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/events/events.dart';
import 'package:utils/utils.dart';

typedef TutorialEventsMap = Map<EventConsequenceType, FutureBoolCallback?>;

class TutorialEventHandlerSystem implements GameRef {
  @override
  late TransoxianaGame game;
  // ignore: use_setters_to_change_properties
  void setLateParam({required final TransoxianaGame game}) {
    this.game = game;
  }

  Future<void> executeConsequence(
    final EventConsequenceType consequenceType,
  ) async {
    final toRemove = await _eventsMap[consequenceType]?.call();
    if (toRemove == true) _eventsMap[consequenceType] = null;
  }

  TutorialEventsMap _eventsMap = {};
  TutorialEventsMap get eventsMap => _eventsMap;

  void loadEventHandler(final TutorialEventHandler eventHandler) {
    _eventsMap = eventHandler.eventsMap;
  }
}

abstract class TutorialEventHandler {
  TutorialEventsMap get eventsMap;
}
