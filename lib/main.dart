import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/services/rm_store.dart';

/// To keep it simple, secure loading
/// now here is placed only root app.
///
/// This file was divided to pieces to components/game
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await RM.storageInitializer(RmStore());
  if (!isHeadless) {
      await Flame.device.fullScreen();
      await Flame.device.setLandscape();
  }

  const game = GameApp();
  const effectiveGame = GameStateInjector(child: game);

  runApp(effectiveGame);
}
