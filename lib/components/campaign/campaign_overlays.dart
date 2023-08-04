// import 'package:transoxiana/components/shared/game_overlay.dart';
// import 'package:transoxiana/widgets/battle/loading_screen.dart';

import 'package:flame/game.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/game_overlay.dart';
import 'package:transoxiana/data/tutorial_settings/tutorial_settings.dart';
import 'package:transoxiana/data/tutorials/campaign_intro_tutorial_steps.g.dart';
import 'package:transoxiana/services/tutorial/tutorial_states.dart';
import 'package:transoxiana/widgets/campaign/buttons.dart';
import 'package:transoxiana/widgets/campaign/campaign_menu.dart';
import 'package:transoxiana/widgets/campaign/status_bar.dart';
import 'package:transoxiana/widgets/tutorial/tutorial.dart';
import 'package:tutorial/tutorial.dart';

class CampaignOverlays {
  CampaignOverlays._();

  // ************************************
  //       Common methods start
  // ************************************
  static const _prefix = 'campaign';

  /// Always add new game overlays to [values] to make it autoregistered
  static Map<String, OverlayWidgetBuilder<TransoxianaGame>> get values =>
      Map.fromEntries(
        [
          mainMenuButton,
          gameMenuButtons,
          menuButton,
          turnControlButton,
          // zoomButtons,
          statusBar,
        ].map(
          (final e) => e.toMapEntry(),
        ),
      );
  // ************************************
  //       Common methods end
  // ************************************

  // ************************************
  //           Buttons start
  // ************************************

  static final mainMenuButton = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => TutorialStepState(
      game: game,
      tutorialSteps: const [],
      key: TutorialKeys.campaignMapUiMainMenuButton,
      child: MainMenuButton(game: game),
    ),
    title: 'mainMenuButton',
    prefix: _prefix,
  );
  static final gameMenuButtons = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => GameMenuButtons(
      game: game,
      useTutorialStateWrapper: ({required final child}) => TutorialStepState(
        game: game,
        tutorialSteps: [
          TutorialStep.fromStaticJson(
            json:
                CampaignIntroTutorialActionsSteps.current.mapUiHelpButton.json,
          ),
        ],
        key: TutorialKeys.campaignMapUiHelpButton,
        child: child,
      ),
    ),
    title: 'gameMenuButtons',
    prefix: _prefix,
  );

  static final menuButton = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => CampaignMenu(
      game: game,
      key: TutorialKeys.campaignMapUiInfoButton,
    ),
    title: 'menuButton',
    prefix: _prefix,
  );

  static final turnControlButton = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => TutorialStepState(
      game: game,
      tutorialSteps: [
        TutorialStep.fromStaticJson(
          json: CampaignIntroTutorialActionsSteps
              .current.mapUiNextTurnButton.json,
        ).copyWith(
          onVerifyNext: () async {
            final tutorialHistory = game.tutorialHistory;
            final isPlayed = tutorialHistory
                .getIsTutorialModePlayed(TutorialModes.campaignButtonsIntro);
            if (isPlayed) return true;
            tutorialHistory
                .setTutorialModePlayed(TutorialModes.campaignButtonsIntro);

            TutorialState.switchMode(
              mode: TutorialModes.campaignIntro,
              game: game,
              enableOverlay: true,
            );
            return true;
          },
        ),
      ],
      key: TutorialKeys.campaignMapUiNextTurnButton,
      child: CampaignTurnWidget(game: game),
    ),
    title: 'turnControlButton',
    prefix: _prefix,
  );

  // static final zoomButtons = GameOverlay<TransoxianaGame>(
  //   builder: (final _, final game) => TutorialStepState(
  //     game: game,
  //     tutorialSteps: [
  //       TutorialStep.fromStaticJson(
  //         json: CampaignIntroTutorialActionsSteps.current.mapUiZoomButtons.json,
  //       ),
  //     ],
  //     key: TutorialKeys.campaignMapUiZoomButtons,
  //     child: ZoomButtons(game: game),
  //   ),
  //   title: 'zoomButtons',
  //   prefix: _prefix,
  // );

  static final statusBar = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => TutorialStepState(
      game: game,
      tutorialSteps: [
        TutorialStep.fromStaticJson(
          json: CampaignIntroTutorialActionsSteps.current.mapUiStatusPanel.json,
        ),
      ],
      key: TutorialKeys.campaignMapUiStatusButton,
      child: CampaignStatusBar(game: game),
    ),
    title: 'statusBar',
    prefix: _prefix,
  );

  // ************************************
  //           Buttons end
  // ************************************

  // ************************************
  //           Other overlays start
  // ************************************

}
