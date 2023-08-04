part of 'campaign.dart';

/// See [GameLifecycleRunner] to know order of functions
class CampaignLoaderRunner extends GameLoaderLifecycle
    with GameLifecycleRunner {
  CampaignLoaderRunner({
    required final TransoxianaGame game,
    required final BuildContext context,
    final GameLoaderSource sourceType = GameLoaderSource.template,
    final NationData? playerData,
    final NationData? enemyData,
    final ProvinceData? provinceData,
    final CampaignDataSource? saveSource,
  }) : super(
          game: game,
          context: context,
          sourceType: sourceType,
          playerData: playerData,
          enemyData: enemyData,
          provinceData: provinceData,
          saveSource: saveSource,
        );

  /// check is game exists (has an id)
  /// and if it is then reset to template data
  ///
  /// if id is not exists then assume that the template data exists only
  @override
  Future<bool> confirmStart() async {
    final isCampaignExists = game.campaignRuntimeData.isGameExists;
    if (!isCampaignExists ||
        (game.useTemplateToStart && sourceType == GameLoaderSource.template)) {
      if (game.useTemplateToStart) game.useTemplateToStart = false;
      return true;
    }

    /// only need a confirmation if another campaign playthrough
    /// has already been started
    final ConfirmAction confirmAction = await asyncConfirmDialog(
          context,
          S.of(context).confirmRestartDialogueTitle,
          S.of(context).confirmRestartDialogueContent,
        ) ??
        ConfirmAction.cancel;

    return confirmAction == ConfirmAction.accept;
  }

  @override
  Future<void> cleanGameData() async {
    game.temporaryCampaignDataService.state =
        game.temporaryCampaignData.reset();
    game.temporaryCampaignDataService.notify();
    await game.campaignRuntimeDataService.refresh();
  }

  @override
  Future<void> loadSave() async =>
      game.loadRuntimeData(dataSource: saveSource!);

  @override
  Future<void> loadTemplate() async {
    final dataSource = await game.temporaryCampaignData.getDataTemplate();

    final playableNations =
        dataSource.nations.values.where((final nation) => nation.isPlayable);
    final effectivePlayerData = playerData ?? playableNations.randomElement()!;

    final nonPlayersNations = dataSource.nations.values
        .where((final nation) => nation.id != effectivePlayerData.id);

    if (dataSource.ais.isEmpty) {
      final ais = Nation.createAis(
        nations: nonPlayersNations,
        player: effectivePlayerData,
      );
      dataSource.ais.addAll(ais);
    }

    await game.loadRuntimeData(dataSource: dataSource);

    /// Get actual instance for nation
    final player = game.campaignRuntimeData.nations[effectivePlayerData.id]!;
    await game.setPlayer(player);

    final campaignIntroEvent =
        await EventData.fromConditionAndConsequenceTypes(
      nationId: player.id,
      condition: EventConditionType.campaignStart,
      consequence: EventConsequenceType.campaignStarted,
    ).toEvent(game: game);
    player.events.add(campaignIntroEvent);
  }

  @override
  Future<void> setGameData() async {
    final campaign = Campaign(
      game: game,
      runtimeDataService: game.campaignRuntimeDataService,
      temporaryDataService: game.temporaryCampaignDataService,
    );
    final effectiveCampaign = game.campaign;
    
    if (effectiveCampaign != null) await game.hideCampaignMapOverlay();
    game.campaign = campaign;
    game.camera.worldBounds = game.campaignWorldBounds;
    game.campaignRuntimeData.data!.sourceType = CampaignDataSourceType.campaign;

    TutorialState.switchMode(mode: null, game: game);
  }

  @override
  Future<void> showMap() async {
    await game.navigator.showCampaignScreen();
    game.campaign?.postLoadScaling();
  }

  @override
  Future<void> process() async {
    if (game.soundsEnabled) {
      unawaited(game.music.playMainTheme());
    }
  }

  @override
  Future<void> postGameCleanup() async {
    /// no need to cleanup here
  }
}
