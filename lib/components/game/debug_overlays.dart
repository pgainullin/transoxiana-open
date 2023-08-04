part of game;

class DebugOverlays {
  DebugOverlays._();

  // ************************************
  //       Common methods start
  // ************************************
  static const _prefix = 'debug';

  /// Always add new game overlays to [values] to make it autoregistered
  static Map<String, OverlayWidgetBuilder<TransoxianaGame>> get values =>
      Map.fromEntries(
        [
          debugWindow,
        ].map(
          (final e) => e.toMapEntry(),
        ),
      );

  static final debugWindow = GameOverlay<TransoxianaGame>(
    /// Fake overlay to open it in stack instead
    builder: (final context, final _game) => Container(),
    title: 'DebugWindow',
    prefix: _prefix,
  );
  // ************************************
  //       Common methods end
  // ************************************

}
