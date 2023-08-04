part of game;

extension GameShortcutsExtension on _TransoxianaGameLateState {
  /// trigger rebuild of all gameData listening widgets
  Future<void> triggerGameDataUpdate() async =>
      temporaryCampaignDataService.notify();
  Future<void> setPlayer(final Nation nation) async =>
      setRuntimeData((final s) {
        s.player = nation;
      });
  Future<void> setRuntimeData(final Function(CampaignRuntimeData s) fn) async =>
      campaignRuntimeDataService.setState(fn);
  Battle? get activeBattle => campaignRuntimeData.activeBattle;
  set activeBattle(final Battle? battle) {
    campaignRuntimeData.activeBattle = battle;
    campaignRuntimeDataService.notify();
  }
}
