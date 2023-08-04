part of 'game.dart';

abstract class AbstractBattleLoader implements GameRef {
  AbstractBattleLoader({required this.game});
  @override
  TransoxianaGame game;

  /// common endpoint
  Future<void> start({required final Battle battle});

  /// Use to start Battle for player
  Future<void> startPlayerDriven(final Battle battle);

  /// Use to start Battle for ai
  Future<void> startAiDriven(final Battle battle);
}
