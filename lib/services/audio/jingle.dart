import 'package:flame_audio/audio_pool.dart';

class Jingle {
  Jingle._({
    required this.themeFadeDuration,
    required this.audioPool,
    this.delayDuration,
  });
  final int themeFadeDuration;
  final int? delayDuration;
  final AudioPool audioPool;
  static Future<Jingle> create(
    final String sound, {
    required final int themeFadeDuration,
    final int? delayDuration,
  }) async {
    final audioPool = await AudioPool.create(
      sound,
      prefix: 'assets/audio/music/',
    );
    return Jingle._(
      themeFadeDuration: themeFadeDuration,
      delayDuration: delayDuration,
      audioPool: audioPool,
    );
  }

  Future<Stoppable> start({final double volume = 1.0}) async =>
      audioPool.start(volume: volume);
}
