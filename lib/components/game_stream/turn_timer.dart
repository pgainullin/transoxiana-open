part of game_stream;

class TurnTimer {

  TurnTimer({this.timePeriod = 1}) {
    completer = Completer();
    // timeLeft = timePeriod;
  }
  final int timePeriod;
  // late int timeLeft;
  late Completer completer;

  void start([final VoidCallback? callback]) {
    Future.delayed(Duration(seconds: timePeriod), () => _turnEnd(callback));
  }

  void _turnEnd([final VoidCallback? callback]) {
    callback?.call();
    completer.complete();
    completer = Completer();
  }
}
