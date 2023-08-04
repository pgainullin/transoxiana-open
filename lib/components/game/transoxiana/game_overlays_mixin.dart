part of game;

mixin _GameOverlaysMixin on _TransoxianaGameLateState {
  void showMainMenu() => showOverlay(SharedOverlays.mainMenuOverlay);
  void hideMainMenu() => hideOverlay(SharedOverlays.mainMenuOverlay);

  void showCameraDebug() => showOverlay(DebugOverlays.debugWindow);
  void hideCameraDebug() => hideOverlay(DebugOverlays.debugWindow);

  void showLoadingOverlay() => showOverlay(SharedOverlays.loadingOverlay);
  void hideLoadingOverlay() => hideOverlay(SharedOverlays.loadingOverlay);

  void showPauseOverlay() => showOverlay(SharedOverlays.pauseOverlay);
  void hidePauseOverlay() => hideOverlay(SharedOverlays.pauseOverlay);

  void showTutorial() => showOverlay(SharedOverlays.tutorialOverlay);
  void hideTutorial() => hideOverlay(SharedOverlays.tutorialOverlay);

  final componentOverlays = <ComponentOverlayTitle, Component>{};

  Future<void> showCampaignMapOverlay() async => addComponentOverlay(
        title: SharedComponentOverlays.campaign,
        component: campaign!,
      );
  Future<void> hideCampaignMapOverlay() async =>
      removeComponentOverlay(SharedComponentOverlays.campaign);

  Future<void> showBattleMapOverlay() async => addComponentOverlay(
        title: SharedComponentOverlays.battle,
        component: activeBattle!,
      );
  Future<void> hideBattleMapOverlay() async =>
      removeComponentOverlay(SharedComponentOverlays.battle);

  Future<void> showBattleBackgroundOverlay() async => addComponentOverlay(
        title: SharedComponentOverlays.battleBackground,
        component: battleBackground!,
      );
  Future<void> hideBattleBackgroundOverlay() async =>
      removeComponentOverlay(SharedComponentOverlays.battleBackground);

  Future<void> showBattleShadowBackgroundOverlay() async => addComponentOverlay(
        title: SharedComponentOverlays.battleShadowBackground,
        component: battleShadowBackground!,
      );
  Future<void> hideBattleShadowBackgroundOverlay() async =>
      removeComponentOverlay(SharedComponentOverlays.battleShadowBackground);

  static final _campaignMapUiOverlays = [
    CampaignOverlays.gameMenuButtons,
    CampaignOverlays.mainMenuButton,
    CampaignOverlays.menuButton,
    CampaignOverlays.statusBar,
    CampaignOverlays.turnControlButton,
    // CampaignOverlays.zoomButtons,
  ];

  /// show tutorial overlay widgets covering UI elements
  void showCampaignMapUiOverlays() =>
      showOverlays(overlays: _campaignMapUiOverlays);

  /// hide tutorial overlay widgets covering UI elements
  void hideCampaignMapUiOverlays() {
    hideOverlays(overlays: _campaignMapUiOverlays);
  }

  void showTrainUnitOverlay(
    final Province province, [
    final Army? preferredArmy,
  ]) {
    temporaryCampaignData
      ..overlayProvince = province
      ..overlayArmy = preferredArmy;
    showOverlay(SharedOverlays.unitTrainingOverlay);
  }

  void hideTrainUnitOverlay() {
    hideOverlay(SharedOverlays.unitTrainingOverlay);
  }

  static final _battleMapUiOverlays = [
    BattleOverlays.menu,
    BattleOverlays.surrenderButton,
    BattleOverlays.unitButtons,
    BattleOverlays.turnControlButton,
    BattleOverlays.statusBar,
  ];

  void showBattleMapUiOverlays() =>
      showOverlays(overlays: _battleMapUiOverlays);

  void hideBattleMapUiOverlays() =>
      hideOverlays(overlays: _battleMapUiOverlays);

  void showDiplomacyMenu() {
    showOverlay(SharedOverlays.diplomacyMenuOverlay);
    temporaryCampaignData.diplomacyMenuOpen = true;
    triggerGameDataUpdate();
  }

  void hideDiplomacyMenu() {
    hideOverlay(SharedOverlays.diplomacyMenuOverlay);
    // removeRegisteredOverlay('DiplomacyMenu');
    temporaryCampaignData.diplomacyMenuOpen = false;
    triggerGameDataUpdate();
  }

  Future<void> showAiBattleWidget() async {
    // ensure the user can't press command buttons
    temporaryCampaignData.inCommand = false;
    showOverlay(SharedOverlays.aiBattleOverlay);
  }

  void hideAiBattleWidget() => hideOverlay(SharedOverlays.aiBattleOverlay);

  /// open army management overlay menu for a given province
  void showArmyManagement(final Province province) {
    temporaryCampaignDataService.state.overlayProvince = province;
    triggerGameDataUpdate();
    showOverlay(SharedOverlays.armyManagementOverlay);
  }

  /// close the army management screen and trigger an update
  /// of all the army-related widgets
  void hideArmyManagement() {
    hideOverlay(SharedOverlays.armyManagementOverlay);
    hideTrainUnitOverlay();
    temporaryCampaignData
      ..overlayProvince = null
      ..overlayArmy = null;
    triggerGameDataUpdate();
  }

  /// Hides [overlays]
  void hideOverlays({required final List<GameOverlay> overlays}) =>
      overlays.forEach(hideOverlay);

  /// Hides all [overlays]
  Future<void> hideAllOverlays(
      {final bool withComponentOverlays = false,}) async {
    // overlays.clear();
    [...overlays.activeOverlays]
        .map(GameOverlay.byPrefixedTitle)
        .forEach(hideOverlay);
    if (withComponentOverlays) {
      await Future.forEach<ComponentOverlayTitle>(
        [...componentOverlays.keys],
        removeComponentOverlay,
      );
    }
  }

  /// Mark an overlay to be removed from the tree.
  ///
  /// See also:
  /// [GameWidget]
  /// [Game.overlays]
  bool hideOverlay(final GameOverlay overlay) {
    if (isHeadless || (debugMode && overlay == DebugOverlays.debugWindow)) {
      return true;
    }
    return overlays.remove(overlay.title);
  }

  /// Mark an overlays to be rendered.
  void showOverlays({required final List<GameOverlay> overlays}) {
    overlays.forEach(showOverlay);
  }

  /// Mark an overlay to be rendered.
  ///
  /// See also:
  /// [GameWidget]
  /// [Game.overlays]
  bool showOverlay(final GameOverlay overlay) {
    if (isHeadless) return true;
    return overlays.add(overlay.title);
  }

  Future<void> addComponentOverlay({
    required final ComponentOverlayTitle title,
    required final Component component,
  }) async {
    if (componentOverlays.containsKey(title)) return;
    componentOverlays[title] = component;
    await add(component);
  }

  Future<void> removeComponentOverlay(
    final ComponentOverlayTitle title,
  ) async {
    if (!componentOverlays.containsKey(title)) return;
    final component = componentOverlays[title];
    if (component == null) return;
    remove(component);
    // component.removeFromParent();
    // print('Removed $title whose parent is ${component.parent}');
    componentOverlays.remove(title);
  }
}
