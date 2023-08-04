part of game;

// ************************************
///       TransoxianaGame - main class
///
/// The idea is to separate this class by logic
///
/// If you need to provide basic logic - use mixin
/// See an examples
/// [_GameCameraMixin], [_GameOverlaysMixin], [_GameDimensionsMixin]
///
/// If you need to provide complex logic - use extension
/// See an examples
/// [GameTimeExtension], [GameBattleExtension]
///
/// If you want to use Rx injected - call it service and place it
/// first:  to [_TransoxianaGameStateConstructor]
/// second: to [_TransoxianaGameLateState] to provide getters and shorcuts
/// third:  use [TransoxianaGame.setLateParams] to provide game instance
/// for your service
///
/// Because all services are inside a game, and provided this way
/// it makes this class is testable and fixes problem when one state
/// already initialized and another - not.
///
// ************************************

class TransoxianaGame extends _TransoxianaGameLateState
    with
        _GameCameraMixin,
        _GameSavesMixin,
        _GameOverlaysMixin,
        _GameDimensionsMixin,
        _GameCrudMixin {
  TransoxianaGame({
    required this.tutorialEventHandlerSystem,
    required this.onAssetsLoad,
    required this.isHeadless,
    required this.reactiveTimer,
    required this.music,
    required this.temporaryCampaignDataService,
    required this.campaignRuntimeDataService,
    required this.mapCameraService,
    required this.tutorialStateService,
    required this.tutorialOverlayStateService,
    required this.tutorialHistoryService,
    required this.debugLogService,
    required this.navigator,
    required this.debugService,
    required this.soundsEnabled,
    required final bool debugMode,
  }) : super() {
    this.debugMode = debugMode;

    /// We provide map camera later to have game instance there
    /// If you need to setup late params -  use setLateParams function
    setLateParams();
  }

  /// Use this callback to load all required basic assets
  /// Not related to scenario in campaign and battle.
  /// Like units, nations etc.
  final FutureValueChanged<TransoxianaGame> onAssetsLoad;

  /// If you need to setup late params -  use this function
  /// You can see an example in [GameWidget]
  void setLateParams() {
    mapCamera.setLateParams(game: this);
    tutorial.setLateParams(game: this);
    navigator.setLateParam(game: this);
    tutorialEventHandlerSystem.setLateParam(game: this);

    /// Add params to have game instance initialized
    final paramsToSetGame = <Injected>[
      mapCameraService,
      tutorialStateService,
    ];

    void setGame(final Injected v) => v.notify();
    paramsToSetGame.forEach(setGame);
  }

  @override
  Future<void> onLoad() async {
    streamRunner = GameStreamRunner(game: this)..initListeners();

    await onAssetsLoad(this);
    mapCamera.followPosition(worldBounds: campaignWorldBounds);
    battleBackground = Background(
      game: this,
      priority: ComponentsRenderPriority.battleBackground,
    );
    battleShadowBackground = ShadowBackground(
      game: this,
      priority: ComponentsRenderPriority.battleShadowBackground,
    );
    resetTimer(showPauseOverlayAtEnd: false);

    unawaited(add(fpsComponent));

    log('Initialization complete');
    await super.onLoad();
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    if (debugMode) renderDebugMode(canvas);
  }

  @override
  void update(final double dt) {
    if (isHeadless) {
      if (campaign != null) headlessUpdate(this);
    } else {
      if (!mapCamera.velocity.isZero()) {
        mapCamera.setPosition(
          (final position) => position
            ..add(mapCamera.velocity * dt * 10)
            // just make it look pretty
            ..x = position.x.roundUpToPlaces(5)
            ..y = position.y.roundUpToPlaces(5),
        );
      }

      super.update(dt);
    }
  }

  @override
  void onRemove() {
    streamRunner.dispose();
    // removeFromParent();
    super.onRemove();
  }

  static final fpsTextConfig = TextPaint(
    style: const TextStyle(
      color: Colors.red,
    ),
  );
  final fpsComponent = FpsComponent();

  @override
  void renderDebugMode(final Canvas canvas) {
    final fps = fpsComponent.fps;

    if (fps.isNaN) return;
    final fpsStr = fps.floor().toString();
    if (kDebugMode && fpsStr != '60' && activeBattle != null) {
      log(fpsStr);
    }
    fpsTextConfig.render(
      canvas,
      fpsStr,
      Vector2(canvasSize.x - 350, 5.0),
    );
  }

  Future<void> setTemporaryData(
    final Function(TemporaryGameData s) setState,
  ) async =>
      temporaryCampaignDataService.setState(setState);

  /// In case if [dataSource] doesn't have an [id] or it is empty
  /// new [id] will be assigned and
  /// as [CampaignRuntimeData.id] will be not empty,
  /// [CampaignRuntimeData.isGameExists] will be true and
  /// in case of new load the data will be overwritten
  Future<void> loadRuntimeData({
    required final CampaignDataSource dataSource,
  }) async =>
      CampaignRuntimeData.load(
        source: dataSource,
        game: this,
      );
  Future<CampaignSaveData> getRuntimeSaveData() async =>
      campaignRuntimeDataService.state.toSaveData();

  @override
  Campaign? campaign;

  Nation? get player => campaignRuntimeData.player;
  set player(final Nation? value) {
    campaignRuntimeData.player = value;
    campaignRuntimeDataService.notify();
  }

  @override
  Background? battleBackground;

  @override
  ReactiveModel<TemporaryGameData> temporaryCampaignDataService;

  @override
  bool isHeadless;

  @override
  Music music;

  @override
  ReactiveModel<double> reactiveTimer;

  @override
  ReactiveModel<CampaignRuntimeData> campaignRuntimeDataService;

  @override
  Injected<MapCamera> mapCameraService;

  @override
  Injected<TutorialHistory> tutorialHistoryService;

  @override
  Injected<TutorialOverlayState> tutorialOverlayStateService;

  @override
  Injected<TutorialState> tutorialStateService;

  @override
  ReactiveModel<List<String>> debugLogService;

  @override
  GameNavigator navigator;

  @override
  ShadowBackground? battleShadowBackground;

  /// {@macro TransoxianaGame_useTemplateToStart}
  @override
  bool useTemplateToStart = false;

  /// {@macro TransoxianaGame_useSaveToStart}
  @override
  bool useSaveToStart = false;

  @override
  Injected<DebugGameService> debugService;

  @override
  late GameStreamRunner streamRunner;

  @override
  bool soundsEnabled;

  @override
  TutorialEventHandlerSystem tutorialEventHandlerSystem;
}

extension DoubleExt on double {
  /// Round [val] up to [places] decimal places.
  double roundUpToPlaces(final int places) {
    final mod = math.pow(10.0, places);
    return (this * mod).round().toDouble() / mod;
  }
}
