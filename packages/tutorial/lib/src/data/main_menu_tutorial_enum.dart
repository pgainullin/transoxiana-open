import 'package:utils/utils.dart';

enum MainMenuTutorialActions {
  mainMenuCampaignButton,
  mainMenuBattleButton,

  /// System field, use it as
  /// CampaignTutorialActions.fromString[text]
  fromString
}

extension MainMenuTutorialActionsExt on MainMenuTutorialActions {
  /// Overload the [] getter to get the name
  MainMenuTutorialActions? operator [](String key) =>
      EnumHelper.findFromString<MainMenuTutorialActions>(
        list: MainMenuTutorialActions.values,
        key: key,
      );
}
