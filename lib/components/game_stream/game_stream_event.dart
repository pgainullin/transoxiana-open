part of game_stream;

@immutable
abstract class GameStreamEvent {}

@immutable
class CampaignEndTurn implements GameStreamEvent {}

@immutable
class CampaignEndTurnFinish implements GameStreamEvent {}

@immutable
class BattleEndTurn implements GameStreamEvent {}

@immutable
class StartBattle implements GameStreamEvent {
  const StartBattle({
    required this.battle,
    required this.finishEvent,
  });
  final Battle battle;
  final GameStreamEvent finishEvent;
  BattleEnd toBattleEnd() => BattleEnd(
        battle: battle,
        finishEvent: finishEvent,
      );
}

@immutable
class BattleEnd implements GameStreamEvent {
  const BattleEnd({
    required this.battle,
    required this.finishEvent,
  });

  final Battle battle;
  final GameStreamEvent finishEvent;
}

@immutable
class ProcessBattles implements GameStreamEvent {}

@immutable
class BattlesDone implements GameStreamEvent {}

@immutable
class EmptyEvent implements GameStreamEvent {}
