 
class WelcomeStep {
  final json = {
    'title': 'This is your empire',
    'description':
        'Mongols have recently defeated the Naiman prince Kuchlug who then fled to Qara Khitai. Kuchlug schemed to take power in this Chinese kingdom also known as Western Liao and Mongolian Empire is now at war with them. Further to the west Khwarezm is looking anxiously - confrontation seems inevitable even though the two empires are at peace for now',
    'svgSrc': '',
    'alignment': 'Alignment.center',
    'alignToScreen': true,
    'enumAction': 'CampaignIntroActions.welcome',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': true,
    'isBackButtonVisible': false,
    'pathShape': 'HighlightPathShapes.provincePath',
    'tutorialMode': 'TutorialModes.campaignIntro',
    'zoomScaleFactor': 8,
    'cameraMovements': [
      'CameraMovement.zoomOut',
      'CameraMovement.toPlayerProvinces'
    ],
    'order': 0
  };

  final String title = 'This is your empire';

  final String description =
      'Mongols have recently defeated the Naiman prince Kuchlug who then fled to Qara Khitai. Kuchlug schemed to take power in this Chinese kingdom also known as Western Liao and Mongolian Empire is now at war with them. Further to the west Khwarezm is looking anxiously - confrontation seems inevitable even though the two empires are at peace for now';

  final String svgSrc = '';

  final String alignment = 'Alignment.center';

  final bool alignToScreen = true;

  final String enumAction = 'CampaignIntroActions.welcome';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = false;

  final String pathShape = 'HighlightPathShapes.provincePath';

  final String tutorialMode = 'TutorialModes.campaignIntro';

  final int zoomScaleFactor = 8;

  final List<String> cameraMovements = [
    'CameraMovement.zoomOut',
    'CameraMovement.toPlayerProvinces'
  ];

  final int order = 0;
}

class YourProvinceStep {
  final json = {
    'title': 'This is your province',
    'description':
        'Each province has a population that grows steadily if the province is supplied with provisions. Provisions are produced by the population or bought from neighbouring friendly provinces in exchange for gold. Gold is also produced by the population.',
    'svgSrc': '',
    'alignment': 'Alignment.topCenter',
    'mobileAlignment': 'Alignment.centerRight',
    'enumAction': 'CampaignIntroActions.yourProvince',
    'isCloseButtonVisible': true,
    'isNextButtonVisible': false,
    'isBackButtonVisible': true,
    'pathShape': 'HighlightPathShapes.provincePath',
    'tutorialMode': 'TutorialModes.campaignIntro',
    'zoomScaleFactor': 5,
    'cameraMovements': ['CameraMovement.zoomIn', 'CameraMovement.toProvince'],
    'order': 1,
    'resetTutorialModePointers': true
  };

  final String title = 'This is your province';

  final String description =
      'Each province has a population that grows steadily if the province is supplied with provisions. Provisions are produced by the population or bought from neighbouring friendly provinces in exchange for gold. Gold is also produced by the population.';

  final String svgSrc = '';

  final String alignment = 'Alignment.topCenter';

  final String mobileAlignment = 'Alignment.centerRight';

  final String enumAction = 'CampaignIntroActions.yourProvince';

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = false;

  final bool isBackButtonVisible = true;

  final String pathShape = 'HighlightPathShapes.provincePath';

  final String tutorialMode = 'TutorialModes.campaignIntro';

  final int zoomScaleFactor = 5;

  final List<String> cameraMovements = [
    'CameraMovement.zoomIn',
    'CameraMovement.toProvince'
  ];

  final int order = 1;

  final bool resetTutorialModePointers = true;
}

class CampaignIntroActionsSteps {
  CampaignIntroActionsSteps() {
    steps = [welcome, yourProvince];
  }

  final welcome = WelcomeStep();

  final yourProvince = YourProvinceStep();

  List steps = [];

  static CampaignIntroActionsSteps current = CampaignIntroActionsSteps();
}
