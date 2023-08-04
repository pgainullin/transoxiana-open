import 'package:utils/utils.dart';

enum BattleIndependentTutorialActions {
  firstPlayerUnitSelected,

  /// System field, use it as
  /// BattleIndependentTutorialActions.fromString[text]
  fromString,
}

extension BattleIndependentTutorialActionsExt
    on BattleIndependentTutorialActions {
  /// Overload the [] getter to get the name
  BattleIndependentTutorialActions? operator [](String key) =>
      EnumHelper.findFromString<BattleIndependentTutorialActions>(
        list: BattleIndependentTutorialActions.values,
        key: key,
      );
}
