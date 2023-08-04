part of game;

mixin _GameSavesMixin on _TransoxianaGameLateState {
  Map<Id, CampaignSaveData> get campaignSaves =>
      temporaryCampaignData.campaignSaves;

  GameSavesBuffer get campaignSortedSavesBuffer =>
      getSavesBuffer(temporaryCampaignData.campaignSaves.values);

  CampaignSaveData? get latestSave {
    CampaignSaveData? saveData;
    final campaignBuffer = campaignSortedSavesBuffer;
    final campaignQuickSave = campaignBuffer.quickSave;
    if (campaignBuffer.all.isNotEmpty) {
      final first = campaignBuffer.all.first;
      if (campaignQuickSave != null) {
        if (first.gameSaveDate.isAfter(campaignQuickSave.gameSaveDate)) {
          saveData = first;
        } else {
          saveData = campaignQuickSave;
        }
      } else {
        saveData = first;
      }
    } else if (campaignQuickSave != null) {
      saveData = campaignBuffer.quickSave;
    }
    final battleBuffer = battleSortedSavesBuffer;
    if (battleBuffer.all.isNotEmpty) {
      final battleSave = battleBuffer.all.first;
      if (saveData == null) {
        saveData = battleSave;
      } else {
        if (battleSave.gameSaveDate.isAfter(saveData.gameSaveDate)) {
          saveData = battleSave;
        }
      }
    }
    return saveData;
  }

  List<CampaignSaveData> get campaignAutosaves =>
      campaignSortedSavesBuffer.autosaves;

  /// random battle saves
  Map<Id, CampaignSaveData> get battleSaves =>
      temporaryCampaignData.battleSaves;
  GameSavesBuffer get battleSortedSavesBuffer =>
      getSavesBuffer(temporaryCampaignData.battleSaves.values);

  math.Random? _rand;
  math.Random get rand => _rand ??= math.Random();

  static GameSavesBuffer getSavesBuffer(
    final Iterable<CampaignSaveData> values,
  ) {
    CampaignSaveData? quickSave;
    final List<CampaignSaveData> autosaves = [];
    final List<CampaignSaveData> sorted = [];
    for (final value in values) {
      final id = value.id;
      if (id == quickSaveStr) {
        quickSave = value;
      } else if (id.contains(autosaveStr)) {
        autosaves.add(value);
      } else {
        sorted.add(value);
      }
    }
    sorted.sort((final a, final b) => b.gameSaveDate.compareTo(a.gameSaveDate));
    autosaves.sort(
      (final a, final b) => b.gameSaveDate.compareTo(a.gameSaveDate),
    );

    return GameSavesBuffer(
      autosaves: autosaves,
      quickSave: quickSave,
      saves: sorted,
    );
  }
}
final quickSaveStr = SaveReservedIds.quickSave.toString();
final autosaveStr = SaveReservedIds.autosave.toString();

@immutable
class GameSavesBuffer {
  const GameSavesBuffer({
    required this.quickSave,
    required this.autosaves,
    required this.saves,
  });
  final CampaignSaveData? quickSave;
  final List<CampaignSaveData> autosaves;
  final List<CampaignSaveData> saves;

  List<CampaignSaveData> get all => [...autosaves, ...saves]
    ..sort((final a, final b) => b.gameSaveDate.compareTo(a.gameSaveDate));
}
