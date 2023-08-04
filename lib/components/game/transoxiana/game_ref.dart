part of game;

/// Support class to ensure that class has [game]
abstract class GameRef {
  GameRef(this.game);

  /// ! Use setLateParams function to set game
  late TransoxianaGame game;
}
