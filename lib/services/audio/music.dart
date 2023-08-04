import 'dart:developer';

import 'package:flame_audio/bgm.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/services/audio/audio_availability_checker.dart';
import 'package:transoxiana/services/audio/jingle.dart';

class Music {
  Music() {
    bgm?.initialize();
  }

  Future<void> dispose() async {
    await bgm?.stop();
    bgm?.dispose();
  }

  Bgm? bgm = AudioAvailabilityChecker.isNotImplemented ? null : Bgm();

  final double _volume = bgmVolume;
  final String mainTheme = 'audio/music/main_theme.mp3';
  final String battleTheme = 'audio/music/battle_theme.mp3';
  Jingle? battleStart;
  Jingle? battleWon;
  Jingle? battleLost;

  Future<void> load() async {
    battleStart = AudioAvailabilityChecker.isNotImplemented
        ? null
        : await Jingle.create(
            'gong_transition.mp3',
            themeFadeDuration: musicThemeFadeDuration,
          );
    battleWon = AudioAvailabilityChecker.isNotImplemented
        ? null
        : await Jingle.create(
            'win.mp3',
            themeFadeDuration: musicThemeFadeDuration,
            delayDuration: musicDelayDurationForBattleWon,
          );
    battleLost = AudioAvailabilityChecker.isNotImplemented
        ? null
        : await Jingle.create(
            'defeat.mp3',
            themeFadeDuration: musicThemeFadeDuration,
            delayDuration: musicDelayDurationForBattleLost,
          );
  }

  Future<void> playMainTheme() async {
    await _fadeOutTheme(battleStart?.themeFadeDuration ?? 0);
    await bgm?.play(mainTheme, volume: _volume);
  }

  Future<void> playBattleTheme() async {
    await battleStart?.start(volume: _volume);
    await _fadeOutTheme(battleStart?.themeFadeDuration ?? 0);
    await bgm?.play(battleTheme, volume: _volume);
  }

  Future<void> playBattleEnd({
    final bool isPlayerWinner = true,
    final bool isLastBattle = false,
  }) async {
    final jingle = isPlayerWinner ? battleWon : battleLost;
    await jingle?.start(volume: _volume);

    await _fadeOutTheme(jingle?.themeFadeDuration ?? musicThemeFadeDuration);
    final delayDuration = jingle?.delayDuration;
    if (delayDuration != null) {
      await Future.delayed(Duration(milliseconds: delayDuration));
    }
    if (isLastBattle) {
      await playMainTheme();
    } else {
      await _fadeInTheme(jingle?.themeFadeDuration ?? musicThemeFadeDuration);
    }
  }

  Future<void> _fadeInTheme(final int duration) async {
    try {
      final audioPlayer = bgm?.audioPlayer;
      if (audioPlayer != null) {
        await bgm?.resume();
        const steps = 10;
        for (var i = 1; i < steps; i++) {
          await audioPlayer.setVolume(i * _volume / steps);
          await Future.delayed(Duration(milliseconds: duration ~/ steps));
        }
      }
    } catch (e) {
      log('ERROR:_fadeInTheme $e');
    }
  }

  Future<void> _fadeOutTheme(final int duration) async {
    try {
      final audioPlayer = bgm?.audioPlayer;
      if (audioPlayer != null) {
        const steps = 10;
        for (var i = 1; i < steps; i++) {
          await audioPlayer.setVolume(_volume - i * (_volume / steps));
          await Future.delayed(Duration(milliseconds: duration ~/ steps));
        }
        await bgm!.pause();
      }
    } catch (e) {
      log('ERROR:_fadeOutTheme $e');
    }
  }
}
