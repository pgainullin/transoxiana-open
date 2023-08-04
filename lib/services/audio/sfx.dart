import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:transoxiana/services/audio/audio_availability_checker.dart';
// import 'package:flame/audio_pool.dart';
import 'package:transoxiana/services/audio/to_audio_pool.dart';

enum singleTrackLoopingSfxType {
  melee,
  infantryMove,
  cavalryMove,
  machineryMove
}

const Map<singleTrackLoopingSfxType, String> loopingSfxPaths = {
  singleTrackLoopingSfxType.melee: 'Close_combat.mp3',
  singleTrackLoopingSfxType.infantryMove: 'infantry_move_loop.mp3',
  singleTrackLoopingSfxType.cavalryMove: 'cavalry_move_loop.mp3',
  singleTrackLoopingSfxType.machineryMove: 'marching.mp3'
};

/// short sounds many of which can be played simultaneously.
class MultiTrackSfx {
  static const int _minPlayers = 8;
  static const int _maxPlayers = 32;

  static Future<void> initAllPools() async {
    if (AudioAvailabilityChecker.isNotImplemented) return;

    await horses.init();
    await bows.init();
    await swords.init();
    await explosion.init();
    await cannonShot.init();
    await marching.init();
  }

  static ToAudioPool horses = ToAudioPool(
    'horses.mp3',
    minPlayers: _minPlayers,
    maxPlayers: _maxPlayers,
  );
  static ToAudioPool bows = ToAudioPool(
    'Bow_salvo.mp3',
    minPlayers: _minPlayers,
    maxPlayers: _maxPlayers,
  );
  static ToAudioPool swords = ToAudioPool(
    'swords.mp3',
    minPlayers: _minPlayers,
    maxPlayers: _maxPlayers,
  );
  static ToAudioPool explosion = ToAudioPool(
    'explosion.mp3',
    minPlayers: _minPlayers,
    maxPlayers: _maxPlayers,
  );
  static ToAudioPool cannonShot = ToAudioPool(
    'cannon_shot.mp3',
    minPlayers: _minPlayers,
    maxPlayers: _maxPlayers,
  );
  static ToAudioPool marching = ToAudioPool(
    'marching.mp3',
    minPlayers: _minPlayers,
    maxPlayers: _maxPlayers,
  );
}

/// controller storing players for sound effects that need to be
/// played in a single track like melee sound starting when >=1 melee engagement
/// is ongoing and only pausing when that goes to zero
class SingleTrackSfx {
  final Map<singleTrackLoopingSfxType, SingleLoopingTrackPlayer> players = {};

  Future<void> onLoad() async {
    if (AudioAvailabilityChecker.isNotImplemented) return;

    for (final type in singleTrackLoopingSfxType.values) {
      if (loopingSfxPaths[type] == null) {
        throw Exception('No path given for $type');
      }
      final player = SingleLoopingTrackPlayer(
        loopingSfxPaths[type]!,
        volume: type == singleTrackLoopingSfxType.melee ? 0.2 : 0.4,
      );
      await player.onLoad();
      players[type] = player;
    }
  }

  Future<void> play(final singleTrackLoopingSfxType type) async {
    if (AudioAvailabilityChecker.isNotImplemented) return;
    await players[type]!.startSound();
  }

  Future<void> stop(final singleTrackLoopingSfxType type) async {
    if (AudioAvailabilityChecker.isNotImplemented) return;
    await players[type]!.stopSound();
  }

  Future<void> forceStopAll() async {
    for (final player in players.values) {
      await player.forceStop();
    }
  }
}

class SingleLoopingTrackPlayer {
  SingleLoopingTrackPlayer(this.trackPath, {this.volume = 0.5});

  Future<void> onLoad() async {
    await _cache.load(trackPath);
  }

  final AudioCache _cache = AudioCache(
    prefix: 'assets/audio/sfx/',
    // duckAudio: true,
    fixedPlayer: AudioPlayer(),
  );
  final String trackPath;

  /// increments every time startSound is called and
  /// decremented every time stopSound is called.
  /// Used to ensure one sound is played iff the value is > 1
  int netStartCalls = 0;

  double volume;

  /// the AudioPlayer playing the battle melee sound.
  /// Is null before the first call to startMeleeSound()
  AudioPlayer? player;

  bool get isPlaying => player != null && player!.state == PlayerState.PLAYING;

  /// starts or resumes the melee sound depending on
  /// whether one has already been loaded
  Future<void> startSound() async {
    netStartCalls += 1;

    if (isPlaying || netStartCalls <= 0) return;
    try {
      if (player == null) {
        /// Can cause PlatformException
        ///
        /// PlatformException (PlatformException(Unexpected error!, null,
        /// java.lang.IllegalStateException
        /// at android.media.MediaPlayer.prepareAsync(Native Method)
        /// at
        await initializePlayer();
      } else {
        if (player!.state == PlayerState.COMPLETED) {
          // meleeSoundPlayer!.stop();
          // meleeSoundPlayer!.release();
          await initializePlayer();
        } else {
          await player!.resume();
        }
      }
    } catch (e) {
      log('ERROR: startSound $e');
    }
  }

  /// (re)starts playing the sound and assigns
  /// the resulting AudioPlayer instance.
  Future<void> initializePlayer() async {
    player = await _cache.play(
      trackPath,
      volume: 0.2,
      mode: PlayerMode.LOW_LATENCY,
    );
    await player!.setReleaseMode(ReleaseMode.RELEASE);
  }

  Future<void> stopSound() async {
    netStartCalls -= 1;

    if (!isPlaying) return;

    if (player == null) return;

    if (netStartCalls <= 0) {
      await player!.pause();
    }
  }

  /// stop regardless of netStartCalls value and reset that value to zero
  Future<void> forceStop() async {
    if (!isPlaying) return;

    if (player == null) return;

    await player!.stop();
    netStartCalls = 0;
  }
}
