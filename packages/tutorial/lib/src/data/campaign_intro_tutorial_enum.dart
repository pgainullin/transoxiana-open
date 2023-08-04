import 'package:utils/utils.dart';

enum CampaignIntroActions {
  welcome,
  yourProvince,

  /// System field, use it as
  /// CampaignTutorialActions.fromString[text]
  fromString
}

extension CampaignIntroActionsExt on CampaignIntroActions {
  /// Overload the [] getter to get the name
  CampaignIntroActions? operator [](String key) =>
      EnumHelper.findFromString<CampaignIntroActions>(
        list: CampaignIntroActions.values,
        key: key,
      );
}

enum CampaignIntroTutorialActions {
  // mapUiZoomButtons,
  mapUiHelpButton,
  mapUiSettingsButton,
  mapUiNextTurnButton,
  mapUiInfoButton,
  mapUiStatusPanel,

  /// System field, use it as
  /// CampaignTutorialActions.fromString[text]
  fromString
}

extension CampaignIntroTutorialActionsExt on CampaignIntroTutorialActions {
  /// Overload the [] getter to get the name
  CampaignIntroTutorialActions? operator [](String key) =>
      EnumHelper.findFromString<CampaignIntroTutorialActions>(
        list: CampaignIntroTutorialActions.values,
        key: key,
      );
}
