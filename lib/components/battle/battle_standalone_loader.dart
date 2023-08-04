part of 'battle.dart';

/// Standalone battle loader for CustomBattles (random)
class BattleStandaloneLoader implements AbstractGameLoader {
  BattleStandaloneLoader({
    required this.game,
  }) : saveService = SaveService(key: SharedPreferencesKeys.battleSaves);
  @override
  final SaveService saveService;
  @override
  TransoxianaGame game;
  @override
  Future<void> start({
    required final BuildContext context,
    required final Nation? playerNation,
    final Nation? enemyNation,
    final Province? province,
  }) async {
    final battleLoaderRunner = BattleLoaderRunner(
      game: game,
      context: context,
      playerData: playerNation?.data,
      enemyData: enemyNation?.data,
      provinceData: province?.data,
    );
    await battleLoaderRunner.run();
  }

  @override
  Future<void> continueFrom({
    required final BuildContext context,
    required final CampaignSaveData source,
  }) async {
    final battleLoaderRunner = BattleLoaderRunner(
      game: game,
      context: context,
      saveSource: source,
      sourceType: GameLoaderSource.save,
    );
    await battleLoaderRunner.run();
  }

  /// use to save [BattleData] to file system
  Future<void> saveBattle() async {
    final saveData = await game.campaignRuntimeData.toSaveData();
    await game.setTemporaryData((final s) async {
      s.battleSaves[saveData.id] = saveData;
      await save(saves: s.battleSaves);
    });
  }

  @override
  Future<void> remove({required final CampaignSaveData source}) async {
    await game.setTemporaryData((final s) async {
      s.battleSaves.remove(source.id);
      await save(saves: s.battleSaves);
    });
  }

  @override
  Future<void> removeMapIdFromStorage({
    required final Id id,
    required final Map<String, dynamic> map,
  }) async {
    map.remove(id);
    await saveService.saveMap(map);
  }
}
