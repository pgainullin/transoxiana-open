part of 'battle.dart';

/// Campaign battle loader
class BattleInCampaignLoader implements AbstractBattleLoader {
  BattleInCampaignLoader({required this.game});
  @override
  TransoxianaGame game;

  @override
  Future<void> start({
    required final Battle battle,
  }) async {
    if (battle.isAiBattle) {
      await startAiDriven(battle);
    } else {
      await startPlayerDriven(battle);
    }
  }

  @override
  Future<void> startAiDriven(final Battle battle) async {
    log('startAiDriven. ${DateTime.now()}');
    final province = battle.province;
    game.temporaryCampaignData.battleProvince = province;
    game.activeBattle = battle;
    await game.showAiBattleWidget();
    await game.add(battle);

    await battle.turnStartCallback();

    final audioCompleter = await processBattleResults(game, battle);

    game
      ..temporaryCampaignData.winningNation = null
      ..clearBattle()
      ..removeActiveBattle()
      ..hideAiBattleWidget();

    game.mapCamera
      ..setCampaignSmoothCameraSpeed()
      ..setCampaignZoomLimits();
    await audioCompleter.future;
  }

  @override
  Future<void> startPlayerDriven(final Battle battle) async {
    game.showLoadingOverlay();

    TutorialState.switchMode(mode: null, game: game);
    game.activeBattle = battle;
    final province = battle.province;
    game.temporaryCampaignData.battleProvince = province;
    if (game.soundsEnabled && battle.isFirst) {
      final resolvedMusic = game.music;
      await resolvedMusic.playBattleTheme();
    }
    await game.navigator.showBattleScreen(battle: battle);

    game.showTutorial();

    final audioCompleter = await processBattleResults(game, battle);
    game.showLoadingOverlay();

    /// First - clear all widgets if needed

    game.mapCamera
      ..setCampaignSmoothCameraSpeed()
      ..setCampaignZoomLimits();

    game.camera.worldBounds = game.campaignWorldBounds;

    await game.navigator.hideBattleScreen(battle: battle);

    game
      ..clearBattle()
      ..removeActiveBattle();
    await audioCompleter.future;
    await game.navigator.showCampaignScreen();

    if (game.soundsEnabled && battle.isLast) {
      final resolvedMusic = game.music;
      await resolvedMusic.playMainTheme();
    }
  }
}

/// Returns audio completer
Future<Completer> processBattleResults(
  final TransoxianaGame game,
  final Battle battle,
) async {
  final winner = await battle.battleOutcome() ??
      battle.armies
          .firstWhere((final element) => element.nation != game.player)
          .nation;

  log('Battle completed with winner = $winner');

  distributeGold(battle);
  if (battle.province.nation.isHostileTo(winner)) {
    await battle.province.capture(winner);
  }

  final audioCompleter = battle.isAiBattle
      ? await notifyAiBattleResult(game, winner)
      : await notifyPlayerBattleResult(
          game,
          winner,
          battle,
        );
  return audioCompleter;
}

Future<Completer> notifyAiBattleResult(
  final TransoxianaGame game,
  final Nation winner,
) async {
  /// show battle results
  game.temporaryCampaignData.winningNation = winner;
  game.temporaryCampaignDataService.notify();
  await Future.delayed(const Duration(seconds: 2));
  return Completer()..complete();
}

Future<Completer> notifyPlayerBattleResult(
  final TransoxianaGame game,
  final Nation winner,
  final Battle battle,
) async {
  await asyncInfoDialog(
    getScaffoldKeyContext(),
    winner == game.player
        ? S.current.victoryDialogueTitle
        : S.current.defeatDialogueTitle,
    S.current.victoryDialogueContent(winner.name),
  );
  final completer = Completer();
  unawaited(
    Future.wait([
      if (game.soundsEnabled)
        game.music.playBattleEnd(
          isPlayerWinner: winner == game.player,
          isLastBattle: battle.isLast,
        ),
    ]).whenComplete(completer.complete),
  );
  return completer;
}

void distributeGold(final Battle battle) {
  // seize gold from the losing armies
  // and promote commanders of the winning armies
  double goldSeized = 0.0;
  final Set<Army> winningArmies = {};

  for (final Army army in battle.armies) {
    if (army.defeated) {
      goldSeized += army.goldCarried;
      army.data.goldCarried = 0.0;
    } else {
      army.commander?.promotePostBattle();
      winningArmies.add(army);
    }
  }

  // distribute the gold among the winning armies
  if (winningArmies.isNotEmpty && goldSeized > 0.0) {
    for (final army in winningArmies) {
      army.data.goldCarried +=
          (1 - sackGoldLeakage) * goldSeized / winningArmies.length;
    }
  }
}
