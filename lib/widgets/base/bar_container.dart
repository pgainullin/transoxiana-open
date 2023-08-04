import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:transoxiana/components/shared/nation.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class BarContainer extends StatelessWidget {
  const BarContainer({required this.children, final Key? key})
      : super(key: key);
  final List<Widget> children;

  @override
  Widget build(final BuildContext context) {
    return Positioned(
      left: 0,
      width: MediaQuery.of(context).size.width,
      bottom: 0,
      child: IgnorePointer(
        child: Center(
          child: Container(
            padding: const EdgeInsets.only(
              left: UiSizes.paddingS,
              right: UiSizes.paddingS,
              top: UiSizes.paddingXS,
              bottom: UiSizes.paddingXS,
            ),
            decoration: BoxDecoration(
              color: UiColors.yellowPapyrus,
              image: UiRasterAssets.scroll,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.75), blurRadius: 4)
              ],
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(UiSizes.borderRadiusSmall),
                topLeft: Radius.circular(UiSizes.borderRadiusSmall),
              ),
            ),
            child: Material(
              textStyle: Theme.of(context).textTheme.headline4,
              // Material needed to support IconButton and apply default text style
              color: Colors.transparent,
              child: Row(mainAxisSize: MainAxisSize.min, children: children),
            ),
          ),
        ),
      ),
    );
  }
}

class NationTitle extends StatelessWidget {
  const NationTitle({required this.player, final Key? key}) : super(key: key);
  final Nation player;

  @override
  Widget build(final BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: UiSizes.paddingXS,
            right: UiSizes.paddingXS,
          ),
          child: SvgPicture.asset(
            UiIcons.flag,
            color: player.color,
            height: UiSizes.statusIconSize,
          ),
        ),
        Text(
          player.name,
          style: TextStyle(
            color: player.color,
            shadows: UiSettings.textShadows,
          ),
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          maxLines: 1,
        ),
      ],
    );
  }
}
