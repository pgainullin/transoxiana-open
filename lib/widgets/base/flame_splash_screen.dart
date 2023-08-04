import 'package:flame_splash_screen/flame_splash_screen.dart';
import 'package:flutter/material.dart';

class FlameLogoBuilder extends StatelessWidget {
  const FlameLogoBuilder({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return LayoutBuilder(
      builder: (final context, final constraints) {
        return FractionalTranslation(
          translation: const Offset(0, -0.25),
          child: ConstrainedBox(
            constraints: BoxConstraints.loose(const Size(300, 300)),
            child: const LogoComposite(),
          ),
        );
      },
    );
  }
}

class StaticFlameSplashScreen extends StatelessWidget {
  const StaticFlameSplashScreen({final Key? key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(child: FlameLogoBuilder()),
    );
  }
}
