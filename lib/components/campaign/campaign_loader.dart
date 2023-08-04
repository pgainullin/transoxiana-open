part of 'campaign.dart';

/// Standalone campaign loader
class CampaignLoader implements AbstractGameLoader {
  CampaignLoader({
    required this.game,
  }) : saveService = SaveService(key: SharedPreferencesKeys.campaignSaves);
  @override
  TransoxianaGame game;
  @override
  final SaveService saveService;

  /// Use to start new Campaign
  @override
  Future<void> start({
    required final BuildContext context,
    required final Nation? playerNation,
  }) async {
    final runner = CampaignLoaderRunner(
      game: game,
      context: context,
      playerData: playerNation?.data,
    );
    await runner.run();
  }

  /// Use to load Campaign save
  @override
  Future<void> continueFrom({
    required final BuildContext context,
    required final CampaignSaveData source,
  }) async {
    final runner = CampaignLoaderRunner(
      game: game,
      context: context,
      sourceType: GameLoaderSource.save,
      saveSource: source,
    );
    await runner.run();
  }

  /// use to save [CampaignSaveData] to file system
  Future<void> saveRuntime({final SaveReservedIds? reservedId}) async {
    final id = prepareId(reservedId: reservedId);
    final saveData = await game.campaignRuntimeData.toSaveData(reservedId: id);

    /// changing game id to ensure we always running the same game as in save
    game.campaignRuntimeData.id = saveData.id;
    unawaited(
      game.setTemporaryData((final s) async {
        s.campaignSaves[saveData.id] = saveData;
        await save(saves: {...s.campaignSaves});

        game.campaignRuntimeDataService.notify();
      }),
    );
  }

  String? prepareId({final SaveReservedIds? reservedId}) {
    switch (reservedId) {
      case SaveReservedIds.autosave:
        if (game.campaignAutosaves.length == 10) {
          return game.campaignAutosaves[9].id;
        } else if (game.campaignAutosaves.isEmpty) {
          return '$autosaveStr 1';
        } else {
          return '$autosaveStr ${game.campaignAutosaves.length + 1}';
        }
      case SaveReservedIds.quickSave:
        return quickSaveStr;
      default:
        return null;
    }
  }

  @override
  Future<void> remove({required final CampaignSaveData source}) async {
    await game.setTemporaryData((final s) async {
      s.campaignSaves.remove(source.id);
      await save(saves: s.campaignSaves);
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
