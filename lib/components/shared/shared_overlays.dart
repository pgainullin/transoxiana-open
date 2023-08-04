import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/game_overlay.dart';
import 'package:transoxiana/widgets/base/pause_overlay.dart';
import 'package:transoxiana/widgets/battle/ai_battle_overlay.dart';
import 'package:transoxiana/widgets/battle/loading_screen.dart';
import 'package:transoxiana/widgets/campaign/army_management.dart';
import 'package:transoxiana/widgets/campaign/diplomacy_menu.dart';
import 'package:transoxiana/widgets/campaign/unit_training.dart';
import 'package:transoxiana/widgets/main_menu.dart';

class SharedOverlays {
  SharedOverlays._();
  static const _prefix = 'shared';

  /// Always add new game overlays to [values] to make it autoregistered
  static Map<String, OverlayWidgetBuilder<TransoxianaGame>> get values =>
      Map.fromEntries(
        [
          loadingOverlay,
          mainMenuOverlay,
          tutorialOverlay,
          pauseOverlay,
          aiBattleOverlay,
          diplomacyMenuOverlay,
          armyManagementOverlay,
          unitTrainingOverlay
        ].map(
          (final e) => e.toMapEntry(),
        ),
      );

  static final mainMenuOverlay = GameOverlay<TransoxianaGame>(
    builder: (final _, final _game) => MainMenu(
      game: _game,
    ),
    title: 'mainMenuOverlay',
    prefix: _prefix,
  );

  static final loadingOverlay = GameOverlay<TransoxianaGame>(
    builder: (final _, final __) => const LoadingScreenOverlay(),
    title: 'loadingOverlay',
    prefix: _prefix,
  );

  static final tutorialOverlay = GameOverlay<TransoxianaGame>(
    /// Fake overlay to open it upper stack
    builder: (final _, final _game) => Container(),
    title: 'tutorialOverlay',
    prefix: _prefix,
  );

  static final pauseOverlay = GameOverlay<TransoxianaGame>(
    builder: (final _, final _game) => PauseOverlay(
      removeCallback: _game.hidePauseOverlay,
    ),
    title: 'pauseOverlay',
    prefix: _prefix,
  );

  static final aiBattleOverlay = GameOverlay<TransoxianaGame>(
    builder: (final _, final _game) {
      return AiBattleOverlay(
        battle: _game.activeBattle!,
        game: _game,
      );
    },
    title: 'aiBattle',
    prefix: _prefix,
  );

  static final diplomacyMenuOverlay = GameOverlay<TransoxianaGame>(
    builder: (final _, final _game) => DiplomacyMenu(game: _game),
    title: 'diplomacyMenuOverlay',
    prefix: _prefix,
  );

  static final armyManagementOverlay = GameOverlay<TransoxianaGame>(
    builder: (final _, final _game) => ArmyManagementOverlay(
      province: _game.temporaryCampaignData.overlayProvince!,
      dismissCallback: _game.hideArmyManagement,
      game: _game,
    ),
    title: 'armyManagementOverlay',
    prefix: _prefix,
  );

  static final unitTrainingOverlay = GameOverlay<TransoxianaGame>(
    builder: (final _, final _game) {
      final resolvedProvince = _game.temporaryCampaignData.overlayProvince;
      if (resolvedProvince == null) {
        throw ArgumentError.notNull('resolvedProvince');
      }
      return UnitTrainingView(
        dismissCallback: _game.hideTrainUnitOverlay,
        province: resolvedProvince,
        preferredArmy: _game.temporaryCampaignData.overlayArmy,
      );
    },
    title: 'unitTrainingOverlay',
    prefix: _prefix,
  );
}
