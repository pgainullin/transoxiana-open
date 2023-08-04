part of game;

// ************************************
///           GLOBALS START
///
/// Write to this file any globals that could
/// impact a whole game and must be referenced
/// from any component
///
// ************************************

/// Key used to display all the dialogues in the game that require BuildContext
/// Use [getScaffoldKeyContext] instead of [scaffoldKey.currentContext] to
/// insure that currentContext is exists
GlobalKey scaffoldKey = GlobalKey();
BuildContext getScaffoldKeyContext() {
  final context = scaffoldKey.currentContext;
  if (context == null) {
    throw ArgumentError.notNull(
      'getScaffoldKeyContext() - it seems scaffoldKey was '
      'not set in Scaffold. Provide scaffoldKey to root Scaffold ',
    );
  }
  return context;
}

const uuid = Uuid();
final _viewportResolution = Vector2(600, 1024);

/// whether the game is played without any render functions, to train AI through the Python API
const isHeadless = bool.fromEnvironment('isHeadless');

const debugMode = bool.fromEnvironment('debugMode');

const globalSoundsEnabled = true;

/// used to identify a game in the Python AI training API
final int gameTimeStamp = DateTime.now().millisecondsSinceEpoch;

/// controller for non-BGM sound effects that loop a single track
SingleTrackSfx singleTrackSfxController = SingleTrackSfx();

// ************************************
//            GLOBALS END
// ************************************
