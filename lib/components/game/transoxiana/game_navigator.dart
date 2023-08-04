part of game;

/// The purpose of this class is only to navigate/show/hide overlays
/// and screens
///
/// If you need to set params use [CampaignLoader] or [BattleInCampaignLoader]
class GameNavigator implements GameRef {
  @override
  late TransoxianaGame game;

  void setLateParam({required final TransoxianaGame game}) {
    this.game = game;
  }

  Future<void> showCampaignScreen() async {
    await game.hideAllOverlays();
    await game.showCampaignMapOverlay();
    game.showCampaignMapUiOverlays();
  }

  Future<void> hideCampaignScreen() async {
    await game.hideCampaignMapOverlay();
    game.hideCampaignMapUiOverlays();
  }

  Future<void> showBattleScreen({final Battle? battle}) async {
    await game.hideAllOverlays(withComponentOverlays: true);
    await game.showBattleBackgroundOverlay();
    await game.showBattleShadowBackgroundOverlay();
    if (battle != null) {
      await game.add(battle);
    } else {
      await game.showBattleMapOverlay();
    }
    game.showBattleMapUiOverlays();
  }

  Future<void> hideBattleScreen({final Battle? battle}) async {
    if (battle != null) {
      if (battle.isPlayerBattle) await showCampaignScreen();
      game.remove(battle);
      // battle.removeFromParent();
    }
    await game.hideBattleMapOverlay();
    await game.hideBattleShadowBackgroundOverlay();
    await game.hideBattleBackgroundOverlay();
    game.hideBattleMapUiOverlays();

    // wait for one frame to ensure the component removal is complete
    // otherwise Flame assets may trigger when the next battle adds its
    // Background (which at the time will still have a non-null parent)
    await Future.delayed(const Duration(milliseconds: 17));
  }

  void showCreditsScreen(final BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (final context) => CreditsScreen(
          onFinish: (final context) => Navigator.of(context).pop(),
          credits: credits,
        ),
      ),
    );
  }

  Future<void> showSavesLoadScreen({
    required final TransoxianaGame game,
    required final BuildContext context,
  }) async =>
      showSavesLoadDialog(context: context, game: game);

  Future<void> showBattleSandboxScreen({
    required final TransoxianaGame game,
    required final BuildContext context,
  }) async =>
      showBattleSandboxDialog(context: context, game: game);
}
