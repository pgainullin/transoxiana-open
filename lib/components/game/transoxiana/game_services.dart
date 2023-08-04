part of game;

// ************************************
///          RM SERVICES START
///
/// To not have problems with initialization all services
/// should be registered within [TransoxianaGameState] and
/// should be provided into [TransoxianaGame]
///
/// Don't forget to use [TransoxianaGame.setLateParams] if
/// you need to set reference to game.
/// You can do that in [TransoxianaGameWidget]
///
/// Advantages: reactive variables for any widgets
/// (do not need a duplicate states to record game changed values)
///
// ************************************

/// Enable it for production
const _stateIsPersistent = false;
final _tutorialHistoryService = RM.inject<TutorialHistory>(
  TutorialHistory.empty,
  autoDisposeWhenNotUsed: false,
  // TODO(arenukvern): uncomment when persistent storage will be ready
  // persist: () => PersistState(
  //   key: '__ConsequenceHistory__',
  //   toJson: (TutorialHistory s) => _stateIsPersistent ? s.toRawJson() : '',
  //   fromJson: (String json) => _stateIsPersistent
  //       ? TutorialHistory.fromRawJson(json)
  //       : TutorialHistory.empty(),
  // ),
  // initialState: TutorialHistory.empty(),
);

final _tutorialService = RM.inject<TutorialState>(
  () => TutorialState(mode: TutorialModes.mainMenu),
  dependsOn: DependsOn(
    {_tutorialHistoryService},
  ),
  autoDisposeWhenNotUsed: false,
  // initialState: TutorialState(game: game, mode: TutorialModes.mainMenu),
);

final _tutorialOverlayService = RM.inject<TutorialOverlayState>(
  TutorialOverlayState.new,
);

final _mapCameraService = RM.inject<MapCamera>(
  () => MapCamera(viewportResolution: _viewportResolution),
  autoDisposeWhenNotUsed: false,
);

final _debugLogService = <String>[].inj(autoDisposeWhenNotUsed: false);

final _temporaryCampaignDataService = RM.inject<TemporaryGameData>(
  TemporaryGameData.new,
  autoDisposeWhenNotUsed: false,
);

final _campaignRuntimeDataService = RM.inject<CampaignRuntimeData>(
  CampaignRuntimeData.empty,
  autoDisposeWhenNotUsed: false,
  sideEffects: SideEffects.onError(
    (final e, final _) => log('ERROR: _campaignRuntimeDataService:$e'),
  ),
);

final _debugGameService = RM.inject<DebugGameService>(
  DebugGameService.new,
  autoDisposeWhenNotUsed: false,
);

class GameStateInjector extends StatelessWidget {
  const GameStateInjector({required this.child, final Key? key})
      : super(key: key);
  final Widget child;
  @override
  Widget build(final BuildContext context) {
    return Injector(
      inject: [
        Inject<double>(
          () => GameConsts.secondsToCommand,
          name: 'reactiveTimer',
        ),
        Inject<TemporaryGameData>(TemporaryGameData.new),
      ],
      builder: (final _) => child,
    );
  }
}

// ************************************
//          RM SERVICES END
// ************************************
