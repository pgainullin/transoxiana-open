part of game;

class TransoxianaGameWidget extends StatefulWidget {
  const TransoxianaGameWidget({final Key? key}) : super(key: key);
  @override
  State<TransoxianaGameWidget> createState() => _TransoxianaGameWidgetState();
}

class _TransoxianaGameWidgetState extends State<TransoxianaGameWidget> {
  late TransoxianaGame _game;
  late Music _music;

  @override
  void initState() {
    _music = Music();
    _game = TransoxianaGame(
      tutorialEventHandlerSystem: TutorialEventHandlerSystem(),
      onAssetsLoad: onAssetsLoad,
      debugMode: debugMode,
      soundsEnabled: globalSoundsEnabled,
      debugService: _debugGameService,
      navigator: GameNavigator(),
      isHeadless: isHeadless,
      music: _music,
      reactiveTimer: RM.get<double>('reactiveTimer'),
      debugLogService: _debugLogService,
      mapCameraService: _mapCameraService,
      tutorialStateService: _tutorialService,
      tutorialOverlayStateService: _tutorialOverlayService,
      tutorialHistoryService: _tutorialHistoryService,
      temporaryCampaignDataService: _temporaryCampaignDataService,
      campaignRuntimeDataService: _campaignRuntimeDataService,
    );

    super.initState();
  }

  @override
  Future<void> dispose() async {
    await _music.dispose();
    super.dispose();
  }

  /// Use this function to load any game related assets
  /// This function will be called only once in the [Game.onLoad]
  Future<void> onAssetsLoad(final TransoxianaGame game) async {
    await precacheImage(
      const AssetImage(LoadingScreenOverlay.imageSrc),
      context,
    );
    await Future.wait([
      singleTrackSfxController.onLoad(),
      loadAssets(),
      () async {
        final String unitTypesJson =
            await Flame.assets.readFile('json/unit_types.json');
        final String armyTemplatesJson =
            await Flame.assets.readFile('json/army_templates.json');
        final String campaignInitJson =
            await Flame.assets.readFile('json/campaign_init.json');
        final String provincesJson =
            await Flame.assets.readFile('json/province-generated.json');
        final campaignTemplateData = await CampaignTemplateData.fromNamedJson(
          armyTemplatesJson: armyTemplatesJson,
          campaignJson: campaignInitJson,
          provincesJson: provincesJson,
          unitTypesJson: unitTypesJson,
        );

        /// save template data in memory to have always access to template data
        /// for example to start new campaign or battle

        game.temporaryCampaignData
          ..templateDataSource = campaignTemplateData
          ..provincesJson = provincesJson
          ..unitTypesJson = unitTypesJson
          ..campaignInitJson = campaignInitJson
          ..armyTemplatesJson = armyTemplatesJson;

        game.temporaryCampaignDataService.notify();
      }(),
      () async {
        game.tutorialEventHandlerSystem
            .loadEventHandler(FirstTutorialEventHandler(game: game));
      }(),
      () async {
        final campaignSaves = await CampaignLoader(game: game).getSaves();
        final battleSaves = await BattleStandaloneLoader(game: game).getSaves();
        await game.setTemporaryData((final s) {
          s
            ..campaignSaves.addAll(campaignSaves)
            ..battleSaves.addAll(battleSaves);
        });
      }(),
      game.music.load(),
    ]);
    await LatestGameLoader(context: context, game: game).run();
    log('onAssetsLoad complete.');
  }

  final FocusNode focusNode = FocusNode();

  @override
  Widget build(final BuildContext context) {
    /// We assume there will be no routes inside material app
    /// because all routes should be handled by Flame Game
    /// overlays to have valid access to gameRef
    final gameWrapper = GameWidget<TransoxianaGame>.controlled(
      gameFactory: () => _game,
      // verifyLoading: () =>
      //     _game.isLoaded &&
      //     _game.campaignRuntimeData.isCampaignStarted &&
      //     _game.activeBattle?.isPlayerBattle != true,
      overlayBuilderMap: {
        ...CampaignOverlays.values,
        ...BattleOverlays.values,
        ...SharedOverlays.values,
        ...DebugOverlays.values,
      },
      loadingBuilder: (final _) {
        return const StaticFlameSplashScreen();
      },
      initialActiveOverlays: [
        SharedOverlays.mainMenuOverlay.title,
        DebugOverlays.debugWindow.title,
      ],
      focusNode: focusNode,
    );
    return GameNavigatorWidget(
      game: _game,
      gameWidget: gameWrapper,
    );
  }
}

class GameNavigatorWidget extends StatelessWidget {
  const GameNavigatorWidget({
    required this.game,
    required this.gameWidget,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final Widget gameWidget;
  @override
  Widget build(final BuildContext context) {
    return TutorialOverlay(
      game: game,
      child: Stack(
        /// Navigation stack in declarative style
        children: [
          /// should always be here at first place
          Positioned.fill(
            child: gameWidget,
          ),
          if (game.debugMode)
            DebugWindow(
              openedTop: 0,
              openedRight: 0,
              closedTop: 0,
              closedRight: 100,
              game: game,
            ),
        ],
      ),
    );
  }
}
