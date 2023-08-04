import '../data/battle_independent_tutorial_actions.dart';
import '../data/battle_intro_tutorial_enum.dart';
import '../data/campaign_independent_tutorial_actions.dart';
import '../data/campaign_intro_tutorial_enum.dart';
import '../data/main_menu_tutorial_enum.dart';

class TutorialActionEnumConverter {
  TutorialActionEnumConverter._();
  static TActionEnum toEnum<TActionEnum>(String val) {
    final campaignTutorialIntroValue =
        CampaignIntroTutorialActions.fromString[val];
    if (campaignTutorialIntroValue != null) {
      return campaignTutorialIntroValue as TActionEnum;
    }
    final campaignIntroValue = CampaignIntroActions.fromString[val];
    if (campaignIntroValue != null) return campaignIntroValue as TActionEnum;
    final mainMenuIntroValue = MainMenuTutorialActions.fromString[val];
    if (mainMenuIntroValue != null) return mainMenuIntroValue as TActionEnum;
    final battleIntroValue = BattleIntroTutorialActions.fromString[val];
    if (battleIntroValue != null) return battleIntroValue as TActionEnum;

    final battleIndependentValue =
        BattleIndependentTutorialActions.fromString[val];
    if (battleIndependentValue != null) {
      return battleIndependentValue as TActionEnum;
    }
    final campaignIndependentValue =
        CampaignIndependentTutorialActions.fromString[val];
    if (campaignIndependentValue != null) {
      return campaignIndependentValue as TActionEnum;
    }

    // TODO(arenukvern): add any converters for tutorial actions
    throw UnimplementedError('enum value $val is not implemented');
  }
}
