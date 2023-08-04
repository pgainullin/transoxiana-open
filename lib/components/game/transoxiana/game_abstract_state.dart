part of game;

// ************************************
/// This class keeps all params for [TransoxianaGame] constructor
///
/// Used to separate logic from [TransoxianaGame] only
// ************************************
abstract class _TransoxianaGameStateConstructor {
  _TransoxianaGameStateConstructor();
  late bool isHeadless;
  late Background? battleBackground;
  late ShadowBackground? battleShadowBackground;
  late final Music music;

  // ************************************
  //             Services
  // ************************************
  late final ReactiveModel<double> reactiveTimer;
  late final Injected<MapCamera> mapCameraService;
  late final Injected<DebugGameService> debugService;
  late final Injected<TutorialOverlayState> tutorialOverlayStateService;
  late final Injected<TutorialState> tutorialStateService;
  late final Injected<TutorialHistory> tutorialHistoryService;
  late final ReactiveModel<TemporaryGameData> temporaryCampaignDataService;
  late final ReactiveModel<CampaignRuntimeData> campaignRuntimeDataService;
  late final ReactiveModel<List<String>> debugLogService;
  late final GameNavigator navigator;
  late final GameStreamRunner streamRunner;
  late final TutorialEventHandlerSystem tutorialEventHandlerSystem;

  /// {@template TransoxianaGame_useTemplateToStart}
  /// This variable can be true only per one condition:
  ///
  /// - There was no saves when the game is loaded.
  /// Setting via [LatestGameLoader] only
  /// {@endtemplate}
  bool useTemplateToStart = false;

  /// {@template TransoxianaGame_useTemplateToStart}
  /// This variable can be true only per one condition:
  ///
  /// - There was at least one save when the game is loaded.
  /// Setting via [LatestGameLoader] only
  /// {@endtemplate}
  bool useSaveToStart = false;

  bool soundsEnabled = true;
}

// ************************************
/// This class keeps getters and common state
/// which not be expected to be in [_TransoxianaGameStateConstructor]
///
/// Used to separate logic from [TransoxianaGame] only
/// and provide state for logic mixins such as [_GameCameraMixin]
// ************************************
abstract class _TransoxianaGameLateState extends FlameGame
    with ScrollDetector, KeyboardEvents, ScaleDetector, TapDetector
    implements CampaignRef, _TransoxianaGameStateConstructor {
  MapCamera get mapCamera => mapCameraService.state;
  TutorialOverlayState get tutorialOverlay => tutorialOverlayStateService.state;
  TutorialState get tutorial => tutorialStateService.state;
  TutorialHistory get tutorialHistory => tutorialHistoryService.state;
  CampaignRuntimeData get campaignRuntimeData =>
      campaignRuntimeDataService.state;
  TemporaryGameData get temporaryCampaignData =>
      temporaryCampaignDataService.state;
  List<String> logs = [];
}
