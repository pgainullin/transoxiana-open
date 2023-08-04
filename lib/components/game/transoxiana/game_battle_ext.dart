part of game;

extension GameBattleExtension on TransoxianaGame {
  //delete all game data as part of a restart
  void clearBattle({final Battle? battle}) {
    // log('clearing battle: isHeadless? $isHeadless, isAiBattle? ${activeBattle.isAiBattle}');

    logs.clear();
    reactiveTimer.state = GameConsts.secondsToCommand;
    temporaryCampaignData.clearBattle();

    final battleArmies = (battle ?? activeBattle)!.armies;

    for (final Army army in battleArmies) {
      if (army.defeated && army.location != null) {
        assert(
          army.units
              .where(
                (final element) =>
                    element.isFighting && element.location != null,
              )
              .isEmpty,
        );
        assert(
          activeBattle == null || army.location == activeBattle!.province,
          'activeBattle ${activeBattle == null}'
          'army.location == activeBattle!.province ${army.location} ${activeBattle!.province}',
        );
        army.kill();
      }
    }

    final battleUnits = activeBattle!.units;
    if (battleUnits.isNotEmpty) {
      for (final Unit unit in battleUnits) {
        unit
          ..location = null
          ..orderedDestination = null
          ..nextNode = null;
      }
    }
    log('Cleared battle in ${activeBattle?.province.name}');
  }

  //remove map from the game and set it to null
  void removeActiveBattle() {
    if(activeBattle != null && activeBattle!.isMounted) activeBattle!.removeFromParent();
    activeBattle = null;
    log('set activeBattle to null');
  }

  /// start battle between given armies and/or in a given province
  Future<void> processBattle(final Battle battle) async =>
      BattleInCampaignLoader(game: this).start(battle: battle);
}
