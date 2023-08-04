import 'package:flutter/material.dart';

class LoadingScreenOverlay extends StatelessWidget {
  const LoadingScreenOverlay({final Key? key}) : super(key: key);
  static const imageSrc = 'assets/images/background.jpg';
  @override
  Widget build(final BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    const Size boxSize = Size.square(128.0);

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            imageSrc,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          left: 0.0,
          top: 0.0,
          width: screenSize.width,
          height: screenSize.height,

          child: Container(
            color: Colors.black.withAlpha(125),
            child: Center(
              child: SizedBox(
                width: boxSize.width,
                height: boxSize.height,
                child: const CircularProgressIndicator(),
              ),
            ),
          ),
          // child: Text('Loading...', style: Theme.of(context).textTheme.headline3,),
        ),
      ],
    );
  }
}
