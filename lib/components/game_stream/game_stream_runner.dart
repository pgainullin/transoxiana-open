part of game_stream;

class GameStreamRunner {
  GameStreamRunner({
    required this.game,
  });
  TurnTimer campaignTimer = TurnTimer(
    timePeriod: GameConsts.secondsToCommand.round(),
  );
  TurnTimer battleTimer = TurnTimer(
    timePeriod: GameConsts.secondsToCommand.round(),
  );

  final TransoxianaGame game;
  final gameStream = GameStream();

  void initListeners() {
    gameStream.listen(onEvent);
  }

  void addEvent(final GameStreamEvent event) => gameStream.add(event);

  void onEvent(final GameStreamEvent event) {
    if (event is CampaignEndTurn) {
      unawaited(onCampaignEndTurn());
    } else if (event is ProcessBattles) {
      unawaited(onProcessBattles());
    } else if (event is BattlesDone) {
      unawaited(onBattlesFinished());
    } else if (event is CampaignEndTurnFinish) {
      unawaited(onCampaignEndTurnFinish());
    } else if (event is StartBattle) {
      unawaited(onStartBattle(event));
    } else if (event is BattleEndTurn) {
      unawaited(onBattleEndTurn());
    } else if (event is BattleEnd) {
      unawaited(onBattleEnd(event));
    }
  }

  Future<void> onCampaignEndTurn() async {
    print('End Turn event');
    final campaign = game.campaign!;
    await campaign.prepareEndTurn();

    game.unpause();
    campaignTimer.start(() => addEvent(CampaignEndTurnFinish()));

    // await campaignTimer.completer.future;
  }

  Future<void> onCampaignEndTurnFinish() async {
    final campaign = game.campaign!;
    game.mapCamera.saveCurrentScaledWorldPosition();
    await campaign.processEngagements();
    game.streamRunner.addEvent(ProcessBattles());
  }

  Future<void> onBattlesFinished() async {
    final campaign = game.campaign!;
    await campaign.advanceCampaignTime();
    await campaign.seasonStartReport();

    await CampaignLoader(game: game)
        .saveRuntime(reservedId: SaveReservedIds.autosave);

    await game.pause();
    game.mapCamera.restoreSavedScaledWorldPosition();
  }

  Future<void> onProcessBattles() async {
    final battles = game.campaignRuntimeData.battles.values;
    if (battles.isEmpty) {
      addEvent(BattlesDone());
      return;
    }

    battles
      ..first.data.isFirst = true
      ..last.data.isLast = true;
    final event = StartBattle(
      battle: battles.first,
      finishEvent: BattlesDone(),
    );
    addEvent(event);
  }

  Future<void> onStartBattle(final StartBattle event) async {
    event.battle.fastForwardEnabled = false;
    await game.pause();

    // if a previous battle in the same province has destroyed all the armies
    // on one side skip the processing
    if (event.battle.armies
        .where(
          (final firstArmy) =>
              event.battle.armies
                  .where(
                    (final secondArmy) =>
                        secondArmy.nation.isHostileTo(firstArmy.nation) &&
                        secondArmy.isFighting,
                  )
                  .isNotEmpty &&
              firstArmy.isFighting,
        )
        .isNotEmpty) {
      game.mapCamera.toProvince(event.battle.province);

      await game.processBattle(event.battle);
    }

    game.streamRunner.addEvent(event.toBattleEnd());
  }

  Future<void> onBattleEnd(final BattleEnd event) async {
    game.campaignRuntimeData.battles.remove(event.battle.id);

    if (game.campaignRuntimeData.battles.isNotEmpty) {
      final startBattle = StartBattle(
        battle: game.campaignRuntimeData.battles.values.first,
        finishEvent: event.finishEvent,
      );
      addEvent(startBattle);
    } else {
      addEvent(event.finishEvent);
    }
  }

  Future<void> onBattleEndTurn() async {
    final activeBattle = game.activeBattle;
    if (activeBattle == null) return;
    // if (campaignTurnTimer != null) {
    //   campaignTurnTimer?.pause();
    // }

    await activeBattle.prepareToEndTurn();

    //then start the clock for the real-time play-through
    game.unpause();
    battleTimer.start();

    final startFuture = activeBattle.turnStartCallback();

    await Future.wait([startFuture, battleTimer.completer.future]);

    await game.pause(
      setCommand: activeBattle.isPlayerBattle,
      showPauseOverlayAtEnd: activeBattle.isPlayerBattle,
    );

    //AI-only and fast-forwarded battle proceeds automatically
    if (activeBattle.isAiBattle || activeBattle.fastForwardEnabled) {
      activeBattle.endTurn();
    }
  }

  void dispose() {
    gameStream.close();
    // campaignTurnTimer?.close();
  }
}
