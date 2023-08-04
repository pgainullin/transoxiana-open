import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/event_handlers/tutorial_event_handler_system.dart';
import 'package:transoxiana/components/shared/events/events.dart';
import 'package:transoxiana/data/tutorial_settings/tutorial_settings.dart';
import 'package:transoxiana/data/tutorials/battle_independent_tutorials.g.dart';
import 'package:transoxiana/data/tutorials/battle_tutorial.dart';
import 'package:transoxiana/data/tutorials/campaign_tutorial.dart';
import 'package:transoxiana/services/tutorial/tutorial_states.dart';
import 'package:tutorial/tutorial.dart';

class FirstTutorialEventHandler implements TutorialEventHandler {
  FirstTutorialEventHandler({
    required this.game,
  });
  final TransoxianaGame game;

  @override
  late TutorialEventsMap eventsMap = {
    EventConsequenceType.fortifiedBattleStarted: onFortifiedBattleStarted,
    EventConsequenceType.nonFortifiedBattleStarted: onNonFortifiedBattleStarted,
    EventConsequenceType.battlePlayerUnitSelected: onPlayerFirstUnitSelected,
    EventConsequenceType.campaignPlayerArmySelected: onPlayerArmySelected,
    EventConsequenceType.campaignStarted: onCampaignStarted,
  };

  Future<bool> onPlayerFirstUnitSelected() async {
    addWidgetTutorialEntry(
      game: game,
      key: TutorialKeys.battleMapButtons,
      tutorialStep: TutorialStep.fromStaticJson(
        json: BattleIndependentTutorialActionsSteps
            .current.firstPlayerUnitSelected.json,
      ),
    );
    TutorialState.switchMode(
      mode: TutorialModes.battleIndependent,
      game: game,
      enableOverlay: true,
    );

    return true;
  }

  Future<bool> onPlayerArmySelected() async {
    TutorialState.switchMode(
      mode: TutorialModes.campaignIndependent,
      game: game,
    );
    await setCampaignArmySelectTutorialSteps(game: game);
    TutorialOverlayState.switchAndInitTutorialSteps(
      isEnabled: true,
      game: game,
    );

    return true;
  }

  Future<bool> onCampaignStarted() async {
    initializeTutorialCampaignIntro(game: game);
    TutorialState.switchMode(
      mode: TutorialModes.campaignIntro,
      game: game,
      enableOverlay: true,
    );

    return true;
  }

  Future<bool> onNonFortifiedBattleStarted() async {
    TutorialState.switchMode(
      mode: TutorialModes.battleIntro,
      game: game,
      enableOverlay: true,
    );
    return true;
  }

  Future<bool> onFortifiedBattleStarted() async {
    initializeBattleInFortTutorial(game: game);

    TutorialState.switchMode(
      mode: TutorialModes.battleIntro,
      game: game,
      enableOverlay: true,
    );
    eventsMap[EventConsequenceType.nonFortifiedBattleStarted] = null;

    return true;
  }
}
