
class WelcomeStep {
  final json = {
    "title": "This is your empire",
    "description":
        "Mongols have recently defeated the Naiman prince Kuchlug who then fled to Qara Khitai. Kuchlug schemed to take power in this Chinese kingdom also known as Western Liao and Mongolian Empire is now at war with them. Further to the west Khwarezm is looking anxiously - confrontation seems inevitable even though the two empires are at peace for now",
    "svgSrc": "",
    "alignment": "Alignment.center",
    "alignToScreen": true,
    "enumAction": "CampaignTutorialActions.welcome",
    "isCloseButtonVisible": false,
    "isNextButtonVisible": true,
    "isBackButtonVisible": false,
    "pathShape": "HighlightPathShapes.provincePath",
    "tutorialMode": "TutorialModes.campaign",
    "zoomScaleFactor": 8,
    "cameraMovements": [
      "CameraMovement.zoomOut",
      "CameraMovement.toRectCenter"
    ],
    "order": 0
  };

  final String title = "This is your empire";

  final String description =
      "Mongols have recently defeated the Naiman prince Kuchlug who then fled to Qara Khitai. Kuchlug schemed to take power in this Chinese kingdom also known as Western Liao and Mongolian Empire is now at war with them. Further to the west Khwarezm is looking anxiously - confrontation seems inevitable even though the two empires are at peace for now";

  final String svgSrc = "";

  final String alignment = "Alignment.center";

  final bool alignToScreen = true;

  final String enumAction = "CampaignTutorialActions.welcome";

  final bool isCloseButtonVisible = false;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = false;

  final String pathShape = "HighlightPathShapes.provincePath";

  final String tutorialMode = "TutorialModes.campaign";

  final int zoomScaleFactor = 8;

  final List<String> cameraMovements = [
    "CameraMovement.zoomOut",
    "CameraMovement.toRectCenter"
  ];

  final int order = 0;
}

class MapUiHelpButtonStep {
  final json = {
    "title": "Help",
    "description": "This button will show this tutorial anytime",
    "svgSrc": "",
    "alignment": "Alignment.topLeft",
    "enumAction": "CampaignTutorialActions.mapUiHelpButton",
    "isCloseButtonVisible": false,
    "isNextButtonVisible": true,
    "isBackButtonVisible": true,
    "pathShape": "HighlightPathShapes.buttonRect",
    "tutorialMode": "TutorialModes.campaign",
    "order": 1
  };

  final String title = "Help";

  final String description = "This button will show this tutorial anytime";

  final String svgSrc = "";

  final String alignment = "Alignment.topLeft";

  final String enumAction = "CampaignTutorialActions.mapUiHelpButton";

  final bool isCloseButtonVisible = false;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = "HighlightPathShapes.buttonRect";

  final String tutorialMode = "TutorialModes.campaign";

  final int order = 1;
}

class MapUiInfoButtonStep {
  final json = {
    "title": "Information panel",
    "description":
        "This button will show information about selected province with managemnent tools and information about selected army",
    "svgSrc": "",
    "alignment": "Alignment.bottomRight",
    "enumAction": "CampaignTutorialActions.mapUiInfoButton",
    "isCloseButtonVisible": false,
    "isNextButtonVisible": true,
    "isBackButtonVisible": true,
    "pathShape": "HighlightPathShapes.buttonRect",
    "tutorialMode": "TutorialModes.campaign",
    "order": 2
  };

  final String title = "Information panel";

  final String description =
      "This button will show information about selected province with managemnent tools and information about selected army";

  final String svgSrc = "";

  final String alignment = "Alignment.bottomRight";

  final String enumAction = "CampaignTutorialActions.mapUiInfoButton";

  final bool isCloseButtonVisible = false;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = "HighlightPathShapes.buttonRect";

  final String tutorialMode = "TutorialModes.campaign";

  final int order = 2;
}

class MapUiStatusPanelStep {
  final json = {
    "title": "Status panel",
    "description":
        "This panel show info about current season, year. Seasons affect resources (provisions are only harvested in Autumn) and weather (probabilities of Sunny, Clear, Rain, Snow depend on the season as is intuitive). Other than that they just denote turns, such that there are four turns every year.",
    "svgSrc": "",
    "alignment": "Alignment.topCenter",
    "enumAction": "CampaignTutorialActions.mapUiStatusPanel",
    "isCloseButtonVisible": false,
    "isNextButtonVisible": true,
    "isBackButtonVisible": true,
    "pathShape": "HighlightPathShapes.buttonRect",
    "tutorialMode": "TutorialModes.campaign",
    "order": 3
  };

  final String title = "Status panel";

  final String description =
      "This panel show info about current season, year. Seasons affect resources (provisions are only harvested in Autumn) and weather (probabilities of Sunny, Clear, Rain, Snow depend on the season as is intuitive). Other than that they just denote turns, such that there are four turns every year.";

  final String svgSrc = "";

  final String alignment = "Alignment.topCenter";

  final String enumAction = "CampaignTutorialActions.mapUiStatusPanel";

  final bool isCloseButtonVisible = false;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = "HighlightPathShapes.buttonRect";

  final String tutorialMode = "TutorialModes.campaign";

  final int order = 3;
}

// class MapUiZoomButtonsStep {
//   final json = {
//     "title": "Zoom in/out",
//     "description": "To control map zoom use these buttons",
//     "svgSrc": "",
//     "alignment": "Alignment.topRight",
//     "enumAction": "CampaignTutorialActions.mapUiZoomButtons",
//     "isCloseButtonVisible": false,
//     "isNextButtonVisible": true,
//     "isBackButtonVisible": true,
//     "pathShape": "HighlightPathShapes.buttonRect",
//     "tutorialMode": "TutorialModes.campaign",
//     "order": 4
//   };
//
//   final String title = "Zoom in/out";
//
//   final String description = "To control map zoom use these buttons";
//
//   final String svgSrc = "";
//
//   final String alignment = "Alignment.topRight";
//
//   final String enumAction = "CampaignTutorialActions.mapUiZoomButtons";
//
//   final bool isCloseButtonVisible = false;
//
//   final bool isNextButtonVisible = true;
//
//   final bool isBackButtonVisible = true;
//
//   final String pathShape = "HighlightPathShapes.buttonRect";
//
//   final String tutorialMode = "TutorialModes.campaign";
//
//   final int order = 4;
// }

class MapUiNextTurnButtonStep {
  final json = {
    "title": "Next turn and turn mechanics",
    "description":
        "give orders in a turn-based mode and then press the hourglass button to play out the results the real-time mode will last a fixed amount of time during which you cannot give any orders. Depending on the Mode your army is in their commanders will take some autonomous decisions after fulfilling your orders if there is time left. once the real time on the campaign map period runs you will be placed in control of any battles that occured in that season involving your troops. After the battles play out you can give orders to your armies in turn-based mode again.",
    "svgSrc": "",
    "alignment": "Alignment.topLeft",
    "enumAction": "CampaignTutorialActions.mapUiNextTurnButton",
    "isCloseButtonVisible": false,
    "isNextButtonVisible": true,
    "isBackButtonVisible": true,
    "pathShape": "HighlightPathShapes.buttonRect",
    "tutorialMode": "TutorialModes.campaign",
    "order": 5
  };

  final String title = "Next turn and turn mechanics";

  final String description =
      "give orders in a turn-based mode and then press the hourglass button to play out the results the real-time mode will last a fixed amount of time during which you cannot give any orders. Depending on the Mode your army is in their commanders will take some autonomous decisions after fulfilling your orders if there is time left. once the real time on the campaign map period runs you will be placed in control of any battles that occured in that season involving your troops. After the battles play out you can give orders to your armies in turn-based mode again.";

  final String svgSrc = "";

  final String alignment = "Alignment.topLeft";

  final String enumAction = "CampaignTutorialActions.mapUiNextTurnButton";

  final bool isCloseButtonVisible = false;

  final bool isNextButtonVisible = true;

  final bool isBackButtonVisible = true;

  final String pathShape = "HighlightPathShapes.buttonRect";

  final String tutorialMode = "TutorialModes.campaign";

  final int order = 5;
}

class YourProvinceStep {
  final json = {
    "title": "This is your province",
    "description":
        "It has population that present a crucial resource for the economy of your empire that ultimately supports your armies.",
    "svgSrc": "",
    "alignment": "Alignment.topCenter",
    "enumAction": "CampaignTutorialActions.yourProvince",
    "isCloseButtonVisible": true,
    "isNextButtonVisible": false,
    "isBackButtonVisible": true,
    "pathShape": "HighlightPathShapes.provincePath",
    "tutorialMode": "TutorialModes.campaign",
    "zoomScaleFactor": 5,
    "cameraMovements": ["CameraMovement.zoomIn", "CameraMovement.toProvince"],
    "order": 6
  };

  final String title = "This is your province";

  final String description =
      "It has population that present a crucial resource for the economy of your empire that ultimately supports your armies.";

  final String svgSrc = "";

  final String alignment = "Alignment.topCenter";

  final String enumAction = "CampaignTutorialActions.yourProvince";

  final bool isCloseButtonVisible = true;

  final bool isNextButtonVisible = false;

  final bool isBackButtonVisible = true;

  final String pathShape = "HighlightPathShapes.provincePath";

  final String tutorialMode = "TutorialModes.campaign";

  final int zoomScaleFactor = 5;

  final List<String> cameraMovements = [
    "CameraMovement.zoomIn",
    "CameraMovement.toProvince"
  ];

  final int order = 6;
}

class CampaignIntroTutorialActionsSteps {
  CampaignIntroTutorialActionsSteps() {
    steps = [
      welcome,
      mapUiHelpButton,
      mapUiInfoButton,
      mapUiStatusPanel,
      mapUiNextTurnButton,
      yourProvince
    ];
  }

  final welcome = WelcomeStep();

  final mapUiHelpButton = MapUiHelpButtonStep();

  final mapUiInfoButton = MapUiInfoButtonStep();

  final mapUiStatusPanel = MapUiStatusPanelStep();

  final mapUiNextTurnButton = MapUiNextTurnButtonStep();

  final yourProvince = YourProvinceStep();

  List steps = [];

  static CampaignIntroTutorialActionsSteps current =
      CampaignIntroTutorialActionsSteps();
}
