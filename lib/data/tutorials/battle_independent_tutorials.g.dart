 
class FirstPlayerUnitSelectedStep {
  final json = {
    'title': 'Unit modes',
    'description':
        'These buttons appears after unit selection. Hold ground - do not leave the target hex. Attack - find the nearest target and engage them in melee or ranged combat. Bombard - special mode for bombard units which combines Hold ground with order to target city walls in priority.',
    'alignment': 'Alignment.topRight',
    'enumAction': 'BattleIndependentTutorialActions.firstPlayerUnitSelected',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': false,
    'isBackButtonVisible': false,
    'selfRemoveAfterClose': true,
    'tutorialMode': 'TutorialModes.battleIndependent',
    'pathShape': 'HighlightPathShapes.buttonRect'
  };

  final String title = 'Unit modes';

  final String description =
      'These buttons appears after unit selection. Hold ground - do not leave the target hex. Attack - find the nearest target and engage them in melee or ranged combat. Bombard - special mode for bombard units which combines Hold ground with order to target city walls in priority.';

  final String alignment = 'Alignment.topRight';

  final String enumAction =
      'BattleIndependentTutorialActions.firstPlayerUnitSelected';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = false;

  final bool isBackButtonVisible = false;

  final bool selfRemoveAfterClose = true;

  final String tutorialMode = 'TutorialModes.battleIndependent';

  final String pathShape = 'HighlightPathShapes.buttonRect';
}

class BattleIndependentTutorialActionsSteps {
  BattleIndependentTutorialActionsSteps() {
    steps = [firstPlayerUnitSelected];
  }

  final firstPlayerUnitSelected = FirstPlayerUnitSelectedStep();

  List steps = [];

  static BattleIndependentTutorialActionsSteps current =
      BattleIndependentTutorialActionsSteps();
}
