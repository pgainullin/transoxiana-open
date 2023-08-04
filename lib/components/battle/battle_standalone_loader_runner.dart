part of 'battle.dart';

class BattleLoaderRunner extends GameLoaderLifecycle with GameLifecycleRunner {
  BattleLoaderRunner({
    required final TransoxianaGame game,
    required final BuildContext context,
    final GameLoaderSource sourceType = GameLoaderSource.template,
    final NationData? playerData,
    final NationData? enemyData,
    final ProvinceData? provinceData,
    final CampaignDataSource? saveSource,
  })  : campaignLoaderRunner = CampaignLoaderRunner(
          game: game,
          context: context,
          saveSource: saveSource,
          playerData: playerData,
          provinceData: provinceData,
          enemyData: enemyData,
          sourceType: sourceType,
        ),
        super(
          game: game,
          context: context,
          sourceType: sourceType,
          playerData: playerData,
          provinceData: provinceData,
          enemyData: enemyData,
          saveSource: saveSource,
        );
  final CampaignLoaderRunner campaignLoaderRunner;

  @override
  Future<void> cleanGameData() async => campaignLoaderRunner.cleanGameData();

  @override
  Future<bool> confirmStart() async => campaignLoaderRunner.confirmStart();

  @override
  Future<void> loadSave() async {
    await campaignLoaderRunner.loadSave();
    if (game.campaignRuntimeData.data!.sourceType !=
        CampaignDataSourceType.battle) {
      throw ArgumentError.value('You are tryinng to load not battle save');
    }
    await campaignLoaderRunner.setGameData();
    if (game.activeBattle == null) {
      throw ArgumentError.notNull(
        'game save should have activeBattle to load',
      );
    }
  }

  BattleData? _battle;
  @override
  Future<void> loadTemplate() async {
    await campaignLoaderRunner.loadTemplate();

    await campaignLoaderRunner.setGameData();

    /// Setting type of data source as Battle save
    game.campaignRuntimeData.data!.sourceType = CampaignDataSourceType.battle;
    Nation enemy;
    if (enemyData != null) {
      enemy = game.campaignRuntimeData.nations[enemyData!.id]!;
    } else {
      enemy = game.campaignRuntimeData.nations.values
          .where((final element) => element != game.campaignRuntimeData.player)
          .randomElement()!;
    }
    game.player!.declareWar(enemy);

    Province battleProvince;
    if (provinceData != null) {
      battleProvince = game.campaignRuntimeData.provinces[provinceData!.id]!;
    } else {
      battleProvince =
          game.campaignRuntimeData.provinces.values.randomElement()!;
    }

    battleProvince
      ..nation = [game.player, enemy].randomElement()!
      ..visibleForNations[enemy.id] = enemy
      ..visibleForNations[game.player!.id] = game.player!;

    final int unitsInBattle = [5, 6, 6, 7, 8].randomElement()!;

    final unitCount = [
      unitsInBattle +
          (battleProvince.isFortified && enemy == battleProvince.nation
              ? 2
              : 0),
      unitsInBattle +
          (battleProvince.isFortified && game.player == battleProvince.nation
              ? 2
              : 0)
    ];

    final armies = await _generateRandomArmies(
      nations: {
        game.player!,
        enemy,
      },
      unitCount: unitCount,
      province: battleProvince,
    );

    game.temporaryCampaignData.battleProvince = battleProvince;
    game.campaignRuntimeData.armies.addAll(armies);
    _battle = BattleData(
      armies: armies.values.map((final e) => e.id).toSet(),
      provinceId: battleProvince.id,
      mapPath: battleProvince.mapPath ?? Battle.getRandomMap(),
    );
  }

  @override
  Future<void> setGameData() async {
    TutorialState.switchMode(mode: null, game: game);
    if (_battle != null) {
      final battle = await _battle!.toBattle(game: game);
      game.activeBattle = battle;
      game.campaignRuntimeData.battles[battle.id] = battle;
    }
  }

  @override
  Future<void> showMap() async {
    if (game.soundsEnabled) {
      await game.music.playBattleTheme();
    }
    await game.navigator.showBattleScreen();
  }

  /// Helper function returning a set of randomly generated units
  Future<Map<Id, Army>> _generateRandomArmies({
    required final Set<Nation> nations,
    required final List<int> unitCount,
    required final Province province,
  }) async {
    final armies = <Id, Army>{};
    assert(nations.length == unitCount.length);

    int nationIndex = 0;
    for (final nation in nations) {
      final List<Unit> units = [];
      final templateData = nation.armyTemplates.randomElement() ??
          game.campaignRuntimeData.armyTemplates.values.randomElement()!;
      final template = await templateData.toTemplate(game: game);

      int templateUnitIndex = 0;
      for (int i = 0; i <= unitCount[nationIndex]; i++) {
        final randomUnitType =
            template.types[templateUnitIndex].randomElement()!;
        final Unit generatedUnit = await randomUnitType.toUnit(
          game: game,
          nation: nation.data,
          id: null,
        );

        templateUnitIndex += 1;
        if (templateUnitIndex == template.types.length) {
          templateUnitIndex = 0;
        }

        units.add(generatedUnit);
      }

      final armyData = ArmyData(
        id: ArmyId(armyId: null, nationId: nation.id),
        name: template.name,
        unitIds: units.map((final e) => e.id).toSet(),
      );
      final Army army = await armyData.toArmy(game: game);

      for (final unit in units) {
        unit.army = army;
      }

      await army.appointNewCommander();
      armies[army.id.armyId] = army;

      if (province.nation == army.nation) {
        // set to siege mode so that defenders are placed inside the walls
        army.data.siegeMode = true;
      }

      nationIndex++;
    }

    return armies;
  }

  /// process the given battle without checking headlessness etc
  @override
  Future<void> process() async {
    final Nation winner = await game.activeBattle!.battleOutcome() ??
        game.activeBattle!.armies
            .firstWhere((final element) => element.nation != game.player)
            .nation;
    log('Battle completed with winner = $winner');

    if (game.soundsEnabled) {
      unawaited(
        game.music.playBattleEnd(
          isPlayerWinner: winner == game.player,
          isLastBattle: true,
        ),
      );
    }

    await asyncInfoDialog(
      getScaffoldKeyContext(),
      winner == game.player
          ? S.current.victoryDialogueTitle
          : S.current.defeatDialogueTitle,
      S.current.victoryDialogueContent(winner.name),
    );
    game
      ..campaignRuntimeData.armies.clear()
      ..showLoadingOverlay()
      ..clearBattle()
      ..hideTutorial();
    await game.navigator.hideBattleScreen();
    game.removeActiveBattle();
  }

  @override
  Future<void> postGameCleanup() async {
    await LatestGameLoader(context: context, game: game).run();
    game
      ..hideLoadingOverlay()
      ..showMainMenu();
  }
}
