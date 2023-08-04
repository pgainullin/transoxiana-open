part of 'game.dart';

abstract class AbstractGameLoader implements GameRef {
  AbstractGameLoader({
    required this.game,
    required this.saveService,
  });
  @override
  TransoxianaGame game;
  final SaveService saveService;

  Future<void> start({
    required final BuildContext context,
    required final Nation? playerNation,
  });

  /// Use to load Campaign save
  Future<void> continueFrom({
    required final BuildContext context,
    required final CampaignSaveData source,
  });

  /// Remove save
  Future<void> remove({required final CampaignSaveData source});

  /// Remove save by id only from storage
  /// written for debug purpose. In game use always [remove]
  Future<void> removeMapIdFromStorage({
    required final Id id,
    required final Map<String, dynamic> map,
  });
}

extension AbstractGameLoaderMixin on AbstractGameLoader {
  /// use to save [CampaignSaveData] to file system
  Future<void> save({
    required final Map<Id, CampaignSaveData> saves,
  }) async =>
      saveService.saveMap(
          await saves.convertValues((final item) async => item.toJson()),);

  /// use to load map for [CampaignSaveData]s from file system
  Future<Map<Id, dynamic>> getSavesMap() async =>
      (await saveService.loadMap()) ?? {};

  /// use to load [CampaignSaveData]s from file system
  Future<Map<Id, CampaignSaveData>> getSaves() async {
    final decodedMap = await getSavesMap();
    return decodedMap.convertValues(
      (final item) async => CampaignSaveData.fromJson(Map.castFrom(item)),
    );
  }
}
