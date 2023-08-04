import 'dart:math';

import 'package:flutter/material.dart';
import 'package:transoxiana/generated/l10n.dart';

/// Flashing overlay with a remove callback triggered after a given period of time
/// triggered to indicate the player can now issue orders
class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.removeCallback,
    this.duration = 1.25,
    final Key? key,
  }) : super(key: key);

  /// duration in seconds until the removeCallback is triggered
  final double duration;

  /// triggered after duration seconds and is intended to let the game remove this overlay
  final VoidCallback removeCallback;

  Future<void> setTimedCallback() async {
    await Future.delayed(
      Duration(
        milliseconds: (duration * 1000.0).toInt(),
      ),
    );
    removeCallback.call();
  }

  @override
  Widget build(final BuildContext context) {
    setTimedCallback();

    final Size screenSize = MediaQuery.of(context).size;
    final Size boxSize = Size.square(min(450.0, screenSize.height * 0.75));

    return Card(
      color: Colors.transparent,
      child: Stack(
        children: [
          // SizedBox(
          //   height: screenSize.height,
          //   width: screenSize.width,
          //   Image.asset('assets/images/background.jpg', fit: BoxFit.cover,),
          // ),
          Positioned(
            left: 0.0,
            top: 0.0,
            width: screenSize.width,
            height: screenSize.height,

            child: Container(
              color: Colors.black.withAlpha(75),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: boxSize.height,
                      width: boxSize.width,
                      child: Icon(
                        Icons.pause,
                        color: Theme.of(context).colorScheme.secondary,
                        size: boxSize.height,
                      ),
                      // Image.asset('assets/images/background.jpg', fit: BoxFit.cover,),
                    ),
                    Text(
                      S.of(context).gamePaused,
                      style: Theme.of(context).textTheme.headline4!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                  ],
                ),
              ),
            ),
            // child: Text('Loading...', style: Theme.of(context).textTheme.headline3,),
          ),
        ],
      ),
    );
  }
}
