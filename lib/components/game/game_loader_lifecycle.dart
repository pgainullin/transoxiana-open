part of 'game.dart';

enum GameLoaderSource {
  template,
  save,
}

abstract class GameLoaderLifecycle {
  GameLoaderLifecycle({
    required this.game,
    required this.context,
    this.sourceType = GameLoaderSource.template,
    this.playerData,
    this.enemyData,
    this.provinceData,
    this.saveSource,
  }) : assert(
          sourceType == GameLoaderSource.save && saveSource != null ||
              sourceType == GameLoaderSource.template,
        );
  final TransoxianaGame game;
  final GameLoaderSource sourceType;
  final BuildContext context;
  NationData? playerData;
  NationData? enemyData;
  ProvinceData? provinceData;
  CampaignDataSource? saveSource;
  Future<bool> confirmStart();
  Future<void> cleanGameData();
  Future<void> loadTemplate();
  Future<void> loadSave();
  Future<void> setGameData();
  Future<void> showMap();
  Future<void> process();
  Future<void> postGameCleanup();
}

mixin GameLifecycleRunner on GameLoaderLifecycle {
  Future<void> run() async {
    game.showLoadingOverlay();
    final startConfirmed = await confirmStart();
    if (!startConfirmed) {
      await game.hideAllOverlays(withComponentOverlays: true);
      game.showMainMenu();
      return;
    }
    await cleanGameData();
    switch (sourceType) {
      case GameLoaderSource.template:
        await loadTemplate();
        break;
      case GameLoaderSource.save:
        await loadSave();
        break;
    }
    await setGameData();
    await showMap();
    await process();
    await postGameCleanup();
  }

  /// Use this function only if it is last save loading
  /// during game load. See more in [TransoxianaGameWidget]
  Future<void> preload() async {
    await loadSave();
    await setGameData();
  }

  /// Use this function only if it is last save/template loading
  /// during game load. See more in [TransoxianaGameWidget]
  ///
  /// Used in [MainMenu] to load game
  Future<void> postStart() async {
    await showMap();
    await process();
    await postGameCleanup();
  }
}
