 
class MainMenuCampaignButtonStep {
  final json = {
    'title': 'Hi {player}! This is a basic intro to campaign',
    'description':
        'You will learn how to control provinces, armies and global map mechanics',
    'svgSrc': '',
    'alignment': 'Alignment.bottomCenter',
    'enumAction': 'MainMenuTutorialActions.mainMenuCampaignButton',
    'isCloseButtonVisible': false,
    'isNextButtonVisible': true,
    'isBackButtonVisible': false,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.mainMenu'
  };

  final String description =
      'You will learn how to control provinces, armies and global map mechanics';

  final String svgSrc = '';

  final String alignment = 'Alignment.bottomCenter';

  final String enumAction = 'MainMenuTutorialActions.mainMenuCampaignButton';

  final bool isCloseButtonVisible = false;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = false;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.mainMenu';

  String title({String? player}) {
    return 'Hi $player! This is a basic intro to campaign';
  }
}

class MainMenuBattleButtonStep {
  final json = {
    'title': 'This is a basic intro to battle',
    'description':
        'You will learn how to manage your army during battle and will take a close look to army units',
    'svgSrc': '',
    'alignment': 'Alignment.topCenter',
    'enumAction': 'MainMenuTutorialActions.mainMenuBattleButton',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': false,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.buttonRect',
    'tutorialMode': 'TutorialModes.mainMenu',
    'resetTutorialModePointers': true
  };

  final String title = 'This is a basic intro to battle';

  final String description =
      'You will learn how to manage your army during battle and will take a close look to army units';

  final String svgSrc = '';

  final String alignment = 'Alignment.topCenter';

  final String enumAction = 'MainMenuTutorialActions.mainMenuBattleButton';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = false;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.buttonRect';

  final String tutorialMode = 'TutorialModes.mainMenu';

  final bool resetTutorialModePointers = true;
}

class MainMenuTutorialActionsSteps {
  MainMenuTutorialActionsSteps() {
    steps = [mainMenuCampaignButton, mainMenuBattleButton];
  }

  final mainMenuCampaignButton = MainMenuCampaignButtonStep();

  final mainMenuBattleButton = MainMenuBattleButtonStep();

  List steps = [];

  static MainMenuTutorialActionsSteps current = MainMenuTutorialActionsSteps();
}
