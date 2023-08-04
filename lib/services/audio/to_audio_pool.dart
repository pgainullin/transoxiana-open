import 'dart:async';
import 'dart:developer';

import 'package:audioplayers/audioplayers.dart';
import 'package:synchronized/synchronized.dart';

// typedef void Stoppable();

/// An AudioPool is a provider of AudioPlayers that leaves them pre-loaded to minimize delays.
///
/// All AudioPlayers loaded are for the same [sound]. If you want multiple sounds use multiple [AudioPool].
/// Use this class if you'd like have extremely quick firing, repetitive and simultaneous sounds, like shooting a laser in a fast-paced spaceship game.
class ToAudioPool {
  ToAudioPool(
    this.sound, {
    this.repeating = false,
    this.maxPlayers = 1,
    this.minPlayers = 1,
    final String prefix = 'assets/audio/sfx/',
  }) {
    cache = AudioCache(prefix: prefix);
  }
  late AudioCache cache;
  // Map<String, AudioPlayer> currentPlayers = {};
  Set<AudioPlayer> currentPlayers = {};
  Map<AudioPlayer, StreamSubscription<void>> subscriptions = {};
  Set<AudioPlayer> availablePlayers = {};

  String sound;
  bool repeating;
  int minPlayers;
  int maxPlayers;

  final Lock _lock = Lock();

  Future init() async {
    for (int i = 0; i < minPlayers; i++) {
      availablePlayers.add(await _createNewAudioPlayer());
    }
  }

  Future<void> startPlayer({final double volume = 1.0}) async {
    try {
      await _lock.synchronized(() async {
        if (availablePlayers.isEmpty) {
          availablePlayers.add(await _createNewAudioPlayer());
        }
        if (availablePlayers.isEmpty) return;

        final AudioPlayer player = availablePlayers.first;
        availablePlayers.remove(player);
        currentPlayers.add(player);

        await player.setVolume(volume);
        await player.resume();

        // subscription
        subscriptions[player] =
            player.onPlayerCompletion.listen((final _) async {
          if (repeating) {
            await player.resume();
          } else {
            await stopPlayer(player);
          }
        });
      });
    } catch (e) {
      log('ERROR: _fadeInTheme $e');
    }
  }

  Future<void> stopPlayer(final AudioPlayer player) async {
    try {
      await _lock.synchronized(() async {
        currentPlayers.remove(player);
        await subscriptions[player]?.cancel();
        await player.stop();
        if (availablePlayers.length >= maxPlayers) {
          await player.release();
        } else {
          availablePlayers.add(player);
        }
      });
    } catch (e) {
      log('ERROR: stopPlayer $e');
    }
  }

  Future<AudioPlayer> _createNewAudioPlayer() async {
    final AudioPlayer player = AudioPlayer();
    final String url = (await cache.load(sound)).path;
    await player.setUrl(url);
    await player.setReleaseMode(ReleaseMode.STOP);
    return player;
  }
}
