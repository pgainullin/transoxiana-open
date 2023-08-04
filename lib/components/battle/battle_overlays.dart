// import 'package:transoxiana/components/shared/game_overlay.dart';
// import 'package:transoxiana/widgets/battle/loading_screen.dart';

import 'package:flame/game.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/game_overlay.dart';
import 'package:transoxiana/data/tutorial_settings/tutorial_settings.dart';
import 'package:transoxiana/data/tutorials/battle_tutorial_steps.g.dart';
import 'package:transoxiana/widgets/battle/battle_menu.dart';
import 'package:transoxiana/widgets/battle/buttons.dart';
import 'package:transoxiana/widgets/battle/status_bar.dart';
import 'package:transoxiana/widgets/tutorial/tutorial.dart';
import 'package:tutorial/tutorial.dart';

class BattleOverlays {
  BattleOverlays._();
  static const _prefix = 'battle';

  /// Always add new game overlays to [values] to make it autoregistered
  static Map<String, OverlayWidgetBuilder<TransoxianaGame>> get values =>
      Map.fromEntries(
        [
          menu,
          surrenderButton,
          unitButtons,
          turnControlButton,
          statusBar,
        ].map(
          (final e) => e.toMapEntry(),
        ),
      );
  static final menu = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => TutorialStepState(
      game: game,
      key: TutorialKeys.battleMapMenu,
      tutorialSteps: const [],
      child: BattleMenu(game: game),
    ),
    title: 'menu',
    prefix: _prefix,
  );

  static final surrenderButton = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => TutorialStepState(
      game: game,
      tutorialSteps: [
        TutorialStep.fromStaticJson(
          json:
              BattleIntroTutorialActionsSteps.current.mapUiSurrenderButton.json,
        ),
      ],
      key: TutorialKeys.battleMapSurrenderButton,
      child: SurrenderButton(game: game),
    ),
    title: 'surrenderButton',
    prefix: _prefix,
  );

  static final unitButtons = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => UnitButtons(
      game: game,
      key: TutorialKeys.battleMapButtons,
    ),
    title: 'unitButtons',
    prefix: _prefix,
  );

  // FIXME: make tutorial steps for different buttons inside a group
  static final turnControlButton = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => BattleTurnWidget(
      game: game,
      key: TutorialKeys.battleMapTurnControl,
    ),
    title: 'turnControlButton',
    prefix: _prefix,
  );

  static final statusBar = GameOverlay<TransoxianaGame>(
    builder: (final _, final game) => TutorialStepState(
      game: game,
      tutorialSteps: [
        TutorialStep.fromStaticJson(
          json:
              BattleIntroTutorialActionsSteps.current.mapUiBattleStatusBar.json,
        ),
      ],
      key: TutorialKeys.battleMapStatusBar,
      child: BattleStatusBar(game: game),
    ),
    title: 'statusBar',
    prefix: _prefix,
  );
}
