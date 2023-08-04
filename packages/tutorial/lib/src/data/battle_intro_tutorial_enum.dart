import 'package:utils/utils.dart';

enum BattleIntroTutorialActions {
  mapUiSurrenderButton,
  mapUiBattleButtons,
  mapUiBattleTurnControl,
  mapUiBattleStatusBar,
  fortifications1,
  fortifications2,

  /// System field, use it as
  /// BattleIntroTutorialActions.fromString[text]
  fromString
}

extension BattleIntroTutorialActionsExt on BattleIntroTutorialActions {
  /// Overload the [] getter to get the name
  BattleIntroTutorialActions? operator [](String key) =>
      EnumHelper.findFromString<BattleIntroTutorialActions>(
        list: BattleIntroTutorialActions.values,
        key: key,
      );
}
