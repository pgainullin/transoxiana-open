import 'package:utils/utils.dart';

enum CampaignIndependentTutorialActions {
  firstPlayerArmySelected1,
  firstPlayerArmySelected2,
  firstPlayerArmySelected3,
  firstPlayerArmySelected4,
  firstPlayerArmySelected5,

  /// System field, use it as
  /// CampaignIndependentTutorialActions.fromString[text]
  fromString,
}

extension CampaignIndependentTutorialActionsExt
    on CampaignIndependentTutorialActions {
  /// Overload the [] getter to get the name
  CampaignIndependentTutorialActions? operator [](String key) =>
      EnumHelper.findFromString<CampaignIndependentTutorialActions>(
        list: CampaignIndependentTutorialActions.values,
        key: key,
      );
}
