import 'dart:math';

import 'package:flutter/material.dart';
import 'package:transoxiana/widgets/base/rounded_border_container.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class DismissibleMenuOverlay extends StatelessWidget {
  const DismissibleMenuOverlay({
    required this.child,
    required this.dismissCallback,
    this.widthFactor = 0.65,
    this.heightFactor = 0.75,
    final Key? key,
  }) : super(key: key);

  final Widget child;
  final VoidCallback dismissCallback;

  final double widthFactor;
  final double heightFactor;

  @override
  Widget build(final BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double width = max(screenSize.width * widthFactor, 400.0);
    final double height = max(screenSize.height * heightFactor, 250.0);

    return Stack(
      children: [
        //dismiss button
        Positioned(
          left: 0.5 * (screenSize.width - width),
          top: 0.5 * (screenSize.height - height),
          child: Card(
            margin: EdgeInsets.zero,
            child: MenuBox(
              width: width,
              height: height,
              child: child,
            ),
          ),
        ),
        Positioned(
          right: 0.5 * (screenSize.width - width) - UiSizes.borderWidth,
          top: 0.5 * (screenSize.height - height) + UiSizes.borderWidth,
          child: Card(
            margin: EdgeInsets.zero,
            color: UiColors.brownWood,
            child: IconButton(
              color: UiColors.yellowPapyrus,
              onPressed: dismissCallback,
              icon: const Icon(Icons.close),
            ),
          ),
        ),
      ],
    );
  }
}
