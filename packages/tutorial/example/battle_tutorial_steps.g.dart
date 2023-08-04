class MapUiSurrenderButtonStep {
  final json = {
    "title": "Surrender",
    "description":
        "If you see too many enemies, sometimes it is wise to keep your army save instead of battle.",
    "svgSrc": "",
    "alignment": "Alignment.bottomLeft",
    "enumAction": "BattleTutorialActions.mapUiSurrenderButton",
    "isCloseButtonVisible": true,
    "isNextButtonVisible": true,
    "isBackButtonVisible": false,
    "pathShape": "HighlightPathShapes.buttonRect",
    "tutorialMode": "TutorialModes.battle",
    "order": 0
  };

  final String title = "Surrender";

  final String description =
      "If you see too many enemies, sometimes it is wise to keep your army save instead of battle.";

  final String svgSrc = "";

  final String alignment = "Alignment.bottomLeft";

  final String enumAction = "BattleTutorialActions.mapUiSurrenderButton";

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = false;

  final String pathShape = "HighlightPathShapes.buttonRect";

  final String tutorialMode = "TutorialModes.battle";

  final int order = 0;
}

class MapUiBattleButtonsStep {
  final json = {
    "title": "Unit modes",
    "description":
        "These buttons appears after unit selection. Attack - find the nearest target and engage them in melee or ranged combat. Hold ground - do not leave the target hex. Bombard - special mode for bombard units which combines Hold ground with order to target city walls in priority.",
    "svgSrc": "",
    "alignment": "Alignment.topRight",
    "enumAction": "BattleTutorialActions.mapUiBattleButtons",
    "isCloseButtonVisible": false,
    "isNextButtonVisible": true,
    "isBackButtonVisible": true,
    "pathShape": "HighlightPathShapes.buttonRect",
    "tutorialMode": "TutorialModes.battle",
    "order": 1
  };

  final String title = "Unit modes";

  final String description =
      "These buttons appears after unit selection. Attack - find the nearest target and engage them in melee or ranged combat. Hold ground - do not leave the target hex. Bombard - special mode for bombard units which combines Hold ground with order to target city walls in priority.";

  final String svgSrc = "";

  final String alignment = "Alignment.topRight";

  final String enumAction = "BattleTutorialActions.mapUiBattleButtons";

  final bool isCloseButtonVisible = false;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = "HighlightPathShapes.buttonRect";

  final String tutorialMode = "TutorialModes.battle";

  final int order = 1;
}

class MapUiBattleTurnControlStep {
  final json = {
    "title": "Manage buttons",
    "description":
        "Skip the battle (will be played by AI) and End turn buttons at the buttom.",
    "svgSrc": "",
    "alignment": "Alignment.topLeft",
    "enumAction": "BattleTutorialActions.mapUiBattleTurnControl",
    "isCloseButtonVisible": false,
    "isNextButtonVisible": true,
    "isBackButtonVisible": true,
    "pathShape": "HighlightPathShapes.buttonRect",
    "tutorialMode": "TutorialModes.battle",
    "order": 2
  };

  final String title = "Manage buttons";

  final String description =
      "Skip the battle (will be played by AI) and End turn buttons at the buttom.";

  final String svgSrc = "";

  final String alignment = "Alignment.topLeft";

  final String enumAction = "BattleTutorialActions.mapUiBattleTurnControl";

  final bool isCloseButtonVisible = false;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = "HighlightPathShapes.buttonRect";

  final String tutorialMode = "TutorialModes.battle";

  final int order = 2;
}

class MapUiBattleStatusBarStep {
  final json = {
    "title": "Status panel",
    "description": "This panel show info battle name and weather conditions.",
    "svgSrc": "",
    "alignment": "Alignment.topCenter",
    "enumAction": "BattleTutorialActions.mapUiBattleStatusBar",
    "isCloseButtonVisible": true,
    "isNextButtonVisible": false,
    "isBackButtonVisible": true,
    "pathShape": "HighlightPathShapes.buttonRect",
    "tutorialMode": "TutorialModes.battle",
    "order": 3
  };

  final String title = "Status panel";

  final String description =
      "This panel show info battle name and weather conditions.";

  final String svgSrc = "";

  final String alignment = "Alignment.topCenter";

  final String enumAction = "BattleTutorialActions.mapUiBattleStatusBar";

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = false;

  final bool isBackButtonVisible = true;

  final String pathShape = "HighlightPathShapes.buttonRect";

  final String tutorialMode = "TutorialModes.battle";

  final int order = 3;
}

class BattleIntroTutorialActionsSteps {
  BattleIntroTutorialActionsSteps() {
    steps = [
      mapUiSurrenderButton,
      mapUiBattleButtons,
      mapUiBattleTurnControl,
      mapUiBattleStatusBar
    ];
  }

  final mapUiSurrenderButton = MapUiSurrenderButtonStep();

  final mapUiBattleButtons = MapUiBattleButtonsStep();

  final mapUiBattleTurnControl = MapUiBattleTurnControlStep();

  final mapUiBattleStatusBar = MapUiBattleStatusBarStep();

  List steps = [];

  static BattleIntroTutorialActionsSteps current =
      BattleIntroTutorialActionsSteps();
}
