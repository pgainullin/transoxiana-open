part of 'campaign_tutorial.dart';

/// add gameplay-related campaign tutorial steps
void initializeTutorialCampaignIntro({
  required final TransoxianaGame game,
}) {
  //first item
  game.tutorialStateService.state
    ..pushTutorialStep(
      tutorialStep: TutorialStep.fromStaticJson(
        json: CampaignIntroActionsSteps.current.welcome.json,
      ).copyWith(
        shapeValue: () => game.mapCamera.getWorldOfRects(
          rects: game.player!.getProvinces().map((final e) => e.touchRect),
        ),
        onVerifyNext: () async {
          final tutorialHistory = game.tutorialHistory;
          final isPlayed = tutorialHistory
              .getIsTutorialModePlayed(TutorialModes.campaignButtonsIntro);
          if (isPlayed) return true;
          TutorialState.switchMode(
            mode: TutorialModes.campaignButtonsIntro,
            game: game,
            enableOverlay: true,
          );

          return false;
        },
      ),
    )

    //existing UI items will be in the middle

    //last item
    ..pushTutorialStep(
      tutorialStep: TutorialStep.fromStaticJson(
        json: CampaignIntroActionsSteps.current.yourProvince.json,
      ).copyWith(
        shapeValue: () => game.player!.getProvinces().firstOrNull,
        isCloseButtonVisible: true,
      ),
    )
    ..reorderSteps()
    ..recalculatePointers()
    ..statePointers[TutorialModes.campaignIntro] = 0;

  game.tutorialStateService.notify();
}

Future<void> setCampaignArmySelectTutorialSteps({
  required final TransoxianaGame game,
}) async {
  addWidgetTutorialEntry(
    game: game,
    tutorialStep: TutorialStep.fromStaticJson(
      json: CampaignIndependentTutorialActionsSteps
          .current.firstPlayerArmySelected1.json,
    ),
    key: TutorialKeys.campaignMapUiInfoButton,
  );

  addWidgetTutorialEntry(
    game: game,
    tutorialStep: TutorialStep.fromStaticJson(
      json: CampaignIndependentTutorialActionsSteps
          .current.firstPlayerArmySelected2.json,
    ),
    key: TutorialKeys.campaignManageArmyButton,
  );

  addWidgetTutorialEntry(
    game: game,
    tutorialStep: TutorialStep.fromStaticJson(
      json: CampaignIndependentTutorialActionsSteps
          .current.firstPlayerArmySelected3.json,
    ),
    key: TutorialKeys.campaignArmyModeDropDown,
  );

  addWidgetTutorialEntry(
    game: game,
    tutorialStep: TutorialStep.fromStaticJson(
      json: CampaignIndependentTutorialActionsSteps
          .current.firstPlayerArmySelected4.json,
    ),
    key: TutorialKeys.campaignTaxProvinceButton,
  );

  addWidgetTutorialEntry(
    game: game,
    tutorialStep: TutorialStep.fromStaticJson(
      json: CampaignIndependentTutorialActionsSteps
          .current.firstPlayerArmySelected5.json,
    ),
    key: TutorialKeys.campaignSiegeModeButtons,
  );
}
