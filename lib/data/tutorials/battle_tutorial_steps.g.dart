 
class MapUiSurrenderButtonStep {
  final json = {
    'title': 'Surrender',
    'description':
        'Press this button to save your commanders - the armies will still be destroyed however.',
    'svgSrc': '',
    'alignment': 'Alignment.bottomLeft',
    'enumAction': 'BattleIntroTutorialActions.mapUiSurrenderButton',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': false,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.battleIntro',
    'order': 0
  };

  final String title = 'Surrender';

  final String description =
      'Press this button to save your commanders - the armies will still be destroyed however.';

  final String svgSrc = '';

  final String alignment = 'Alignment.bottomLeft';

  final String enumAction = 'BattleIntroTutorialActions.mapUiSurrenderButton';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = false;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.battleIntro';

  final int order = 0;
}

class MapUiBattleTurnControlStep {
  final json = {
    'title': 'Turn control',
    'description':
        'End turn button will start the real-time phase of the battle lasting 6 seconds. During that phase you only have overall army control and can\'t select units. Enabling fast forward will end turns automatically.',
    'svgSrc': '',
    'alignment': 'Alignment.topLeft',
    'enumAction': 'BattleIntroTutorialActions.mapUiBattleTurnControl',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.battleIntro',
    'order': 1
  };

  final String title = 'Turn control';

  final String description =
      'End turn button will start the real-time phase of the battle lasting 6 seconds. During that phase you only have overall army control and can\'t select units. Enabling fast forward will end turns automatically.';

  final String svgSrc = '';

  final String alignment = 'Alignment.topLeft';

  final String enumAction = 'BattleIntroTutorialActions.mapUiBattleTurnControl';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.battleIntro';

  final int order = 1;
}

class MapUiBattleStatusBarStep {
  final json = {
    'title': 'Status panel',
    'description': 'Shows battle location and year.',
    'svgSrc': '',
    'alignment': 'Alignment.topCenter',
    'enumAction': 'BattleIntroTutorialActions.mapUiBattleStatusBar',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.battleIntro',
    'order': 2
  };

  final String title = 'Status panel';

  final String description = 'Shows battle location and year.';

  final String svgSrc = '';

  final String alignment = 'Alignment.topCenter';

  final String enumAction = 'BattleIntroTutorialActions.mapUiBattleStatusBar';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.battleIntro';

  final int order = 2;
}

class Fortifications1Step {
  final json = {
    'title': 'This province has a walled city',
    'description':
        'Attacking units will struggle to get up on the walls from the outside. Defending units on top of the walls get defence bonuses and increased shooting range. ',
    'svgSrc': '',
    'alignment': 'Alignment.center',
    'alignToScreen': true,
    'enumAction': 'BattleIntroTutorialActions.fortifications1',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.fromRect',
    'tutorialMode': 'TutorialModes.battleIntro',
    'zoomScaleFactor': 6,
    'cameraMovements': [
      'CameraMovement.zoomOut',
      'CameraMovement.toRectCenter'
    ],
    'order': 3
  };

  final String title = 'This province has a walled city';

  final String description =
      'Attacking units will struggle to get up on the walls from the outside. Defending units on top of the walls get defence bonuses and increased shooting range. ';

  final String svgSrc = '';

  final String alignment = 'Alignment.center';

  final bool alignToScreen = true;

  final String enumAction = 'BattleIntroTutorialActions.fortifications1';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.fromRect';

  final String tutorialMode = 'TutorialModes.battleIntro';

  final int zoomScaleFactor = 6;

  final List<String> cameraMovements = [
    'CameraMovement.zoomOut',
    'CameraMovement.toRectCenter'
  ];

  final int order = 3;
}

class Fortifications2Step {
  final json = {
    'title': 'This province has a walled city',
    'description':
        'Walls can be destroyed with siege weapons. Gates can be opened and closed by units occupying them.',
    'svgSrc': '',
    'alignment': 'Alignment.center',
    'alignToScreen': true,
    'enumAction': 'BattleIntroTutorialActions.fortifications2',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': false,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.fromRect',
    'tutorialMode': 'TutorialModes.battleIntro',
    'zoomScaleFactor': 6,
    'cameraMovements': [
      'CameraMovement.zoomOut',
      'CameraMovement.toRectCenter'
    ],
    'order': 4
  };

  final String title = 'This province has a walled city';

  final String description =
      'Walls can be destroyed with siege weapons. Gates can be opened and closed by units occupying them.';

  final String svgSrc = '';

  final String alignment = 'Alignment.center';

  final bool alignToScreen = true;

  final String enumAction = 'BattleIntroTutorialActions.fortifications2';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = false;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.fromRect';

  final String tutorialMode = 'TutorialModes.battleIntro';

  final int zoomScaleFactor = 6;

  final List<String> cameraMovements = [
    'CameraMovement.zoomOut',
    'CameraMovement.toRectCenter'
  ];

  final int order = 4;
}

class BattleIntroTutorialActionsSteps {
  BattleIntroTutorialActionsSteps() {
    steps = [
      mapUiSurrenderButton,
      mapUiBattleTurnControl,
      mapUiBattleStatusBar,
      fortifications1,
      fortifications2
    ];
  }

  final mapUiSurrenderButton = MapUiSurrenderButtonStep();

  final mapUiBattleTurnControl = MapUiBattleTurnControlStep();

  final mapUiBattleStatusBar = MapUiBattleStatusBarStep();

  final fortifications1 = Fortifications1Step();

  final fortifications2 = Fortifications2Step();

  List steps = [];

  static BattleIntroTutorialActionsSteps current =
      BattleIntroTutorialActionsSteps();
}
