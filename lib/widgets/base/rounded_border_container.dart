import 'package:flutter/material.dart';
import 'package:transoxiana/widgets/base/scroll_container.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class RoundedBorderContainer extends StatelessWidget {
  const RoundedBorderContainer({
    required this.child,
    required this.height,
    required this.width,
    final Key? key,
    this.topLeftRadius = 0,
    this.topRightRadius = 0,
    this.bottomRightRadius = 0,
    this.bottomLeftRadius = 0,
    this.borderColor = UiColors.yellowPapyrus,
    this.backgroundOpacity = 1,
    this.backgroundFilterColor = Colors.black,
    this.fillColor = UiColors.brownWood,
    this.backgroundImage = UiBackgrounds.wood,
    this.backgroundImageFit = BoxFit.none,
    this.borderInsets = const EdgeInsets.all(UiSizes.borderWidth),
    this.shadow = const BoxShadow(color: Colors.transparent),
  }) : super(key: key);
  final double height;
  final double width;
  final Widget child;
  final double topLeftRadius;
  final double topRightRadius;
  final double bottomRightRadius;
  final double bottomLeftRadius;
  final Color borderColor;
  final Color fillColor;
  final Color backgroundFilterColor;
  final double backgroundOpacity;

  final String backgroundImage;
  final BoxFit backgroundImageFit;

  final EdgeInsetsGeometry borderInsets;
  final BoxShadow shadow;

  @override
  Widget build(final BuildContext context) {
    // hack with two nested containers to achieve both border and radius
    // Flutter does not allow border + radius on one container
    return Container(
      decoration: BoxDecoration(
        color: borderColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(topLeftRadius),
          topRight: Radius.circular(topRightRadius),
          bottomRight: Radius.circular(bottomRightRadius),
          bottomLeft: Radius.circular(bottomLeftRadius),
        ),
        boxShadow: [shadow], // BorderRadius
      ), //
      child: Container(
        height: height,
        width: width,
        // inset is the border here
        margin: borderInsets,
        decoration: BoxDecoration(
          color: fillColor,
          image: DecorationImage(
            fit: backgroundImageFit,
            colorFilter: ColorFilter.mode(
              backgroundFilterColor.withOpacity(backgroundOpacity),
              BlendMode.dstATop,
            ),
            image: ExactAssetImage(backgroundImage),
          ),
          borderRadius: BorderRadius.only(
            bottomRight: Radius.circular(
              bottomRightRadius - UiSizes.innerBorderRadiusOffset,
            ),
            bottomLeft: Radius.circular(
              bottomLeftRadius - UiSizes.innerBorderRadiusOffset,
            ),
            topRight: Radius.circular(
              topRightRadius - UiSizes.innerBorderRadiusOffset,
            ),
            topLeft: Radius.circular(
              topLeftRadius - UiSizes.innerBorderRadiusOffset,
            ),
          ),
        ),
        // ClipRRect to properly clip button highlightColor
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(
              topLeftRadius - UiSizes.innerBorderRadiusOffset,
            ),
            bottomLeft: Radius.circular(
              bottomLeftRadius - UiSizes.innerBorderRadiusOffset,
            ),
            bottomRight: Radius.circular(
              bottomRightRadius - UiSizes.innerBorderRadiusOffset,
            ),
            topRight: Radius.circular(
              topRightRadius - UiSizes.innerBorderRadiusOffset,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Standard box with borders and a background picture used to display menus and dialogues
class MenuBox extends StatelessWidget {
  const MenuBox({
    required this.child,
    required this.width,
    required this.height,
    final Key? key,
  }) : super(key: key);
  final Widget child;
  final double width;
  final double height;

  @override
  Widget build(final BuildContext context) {
    return RoundedBorderContainer(
      width: width,
      height: height,
      // bottomRightRadius: UiSizes.borderRadius,
      backgroundOpacity: UiSettings.buttonFillOpacity,
      backgroundImageFit: BoxFit.cover,
      // borderInsets: const EdgeInsets.all(UiSizes.borderWidth),
      shadow: UiSettings.widgetShadow,
      child: Column(
        children: [
          ScrollContainer(
            child: child,
          ),
        ],
      ),
    );
  }
}
