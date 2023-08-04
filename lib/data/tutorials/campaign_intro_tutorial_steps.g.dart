 
class MapUiHelpButtonStep {
  final json = {
    'title': 'Help',
    'description':
        'Press this button to return to this tutorial at any time. Long-press buttons to get captions.',
    'svgSrc': '',
    'alignment': 'Alignment.bottomRight',
    'enumAction': 'CampaignIntroTutorialActions.mapUiHelpButton',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': false,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.campaignButtonsIntro',
    'order': 0
  };

  final String title = 'Help';

  final String description =
      'Press this button to return to this tutorial at any time. Long-press buttons to get captions.';

  final String svgSrc = '';

  final String alignment = 'Alignment.bottomRight';

  final String enumAction = 'CampaignIntroTutorialActions.mapUiHelpButton';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = false;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.campaignButtonsIntro';

  final int order = 0;
}

class MapUiInfoButtonStep {
  final json = {
    'title': 'Information panel',
    'description':
        'Press this button to manage selected armies and provinces. The menu will open automatically if you select an army.',
    'svgSrc': '',
    'alignment': 'Alignment.bottomRight',
    'enumAction': 'CampaignIntroTutorialActions.mapUiInfoButton',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.campaignButtonsIntro',
    'order': 1
  };

  final String title = 'Information panel';

  final String description =
      'Press this button to manage selected armies and provinces. The menu will open automatically if you select an army.';

  final String svgSrc = '';

  final String alignment = 'Alignment.bottomRight';

  final String enumAction = 'CampaignIntroTutorialActions.mapUiInfoButton';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.campaignButtonsIntro';

  final int order = 1;
}

class MapUiStatusPanelStep {
  final json = {
    'title': 'Status panel',
    'description':
        'This shows the current season and year. Seasons affect resources (provisions are only harvested in Autumn) and weather (probabilities of rain and snow). One season is equal to one turn on the campaign map.',
    'svgSrc': '',
    'alignment': 'Alignment.topCenter',
    'enumAction': 'CampaignIntroTutorialActions.mapUiStatusPanel',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.campaignButtonsIntro',
    'order': 2
  };

  final String title = 'Status panel';

  final String description =
      'This shows the current season and year. Seasons affect resources (provisions are only harvested in Autumn) and weather (probabilities of rain and snow). One season is equal to one turn on the campaign map.';

  final String svgSrc = '';

  final String alignment = 'Alignment.topCenter';

  final String enumAction = 'CampaignIntroTutorialActions.mapUiStatusPanel';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.campaignButtonsIntro';

  final int order = 2;
}

class MapUiNextTurnButtonStep {
  final json = {
    'title': 'Next turn and turn mechanics',
    'description':
        'The game uses a hybrid turn system where all orders are given in turn-based mode and executed in real-time. Once you have given your orders press this button to end your turn and see the orders being executed by your armies. Real time sequence will stop automatically after 6 seconds.',
    'svgSrc': '',
    'alignment': 'Alignment.topLeft',
    'enumAction': 'CampaignIntroTutorialActions.mapUiNextTurnButton',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.campaignButtonsIntro',
    'order': 4,
    'resetTutorialModePointers': false
  };

  final String title = 'Next turn and turn mechanics';

  final String description =
      'The game uses a hybrid turn system where all orders are given in turn-based mode and executed in real-time. Once you have given your orders press this button to end your turn and see the orders being executed by your armies. Real time sequence will stop automatically after 6 seconds.';

  final String svgSrc = '';

  final String alignment = 'Alignment.topLeft';

  final String enumAction = 'CampaignIntroTutorialActions.mapUiNextTurnButton';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.campaignButtonsIntro';

  final int order = 4;

  final bool resetTutorialModePointers = false;
}

class CampaignIntroTutorialActionsSteps {
  CampaignIntroTutorialActionsSteps() {
    steps = [
      mapUiHelpButton,
      mapUiInfoButton,
      mapUiStatusPanel,
      mapUiNextTurnButton
    ];
  }

  final mapUiHelpButton = MapUiHelpButtonStep();

  final mapUiInfoButton = MapUiInfoButtonStep();

  final mapUiStatusPanel = MapUiStatusPanelStep();

  final mapUiNextTurnButton = MapUiNextTurnButtonStep();

  List steps = [];

  static CampaignIntroTutorialActionsSteps current =
      CampaignIntroTutorialActionsSteps();
}
