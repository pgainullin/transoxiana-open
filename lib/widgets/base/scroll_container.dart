import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:transoxiana/widgets/base/callback_button.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class ScrollContainer extends StatelessWidget {
  const ScrollContainer({
    required this.child,
    final Key? key,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(final BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(UiSizes.paddingM),
        decoration: BoxDecoration(
          color: UiColors.yellowPapyrus,
          image: UiRasterAssets.scroll,
          boxShadow: [UiSettings.buttonShadow],
          borderRadius: UiSettings.borderRadiusAll,
        ),
        child: Material(
          // Material needed to support IconButton and apply default text style
          color: Colors.transparent,
          child: child,
        ),
      ),
    );
  }
}

class ScrollContainerRow extends StatelessWidget {
  const ScrollContainerRow({
    required this.children,
    final Key? key,
    this.childrenFlexFactors,
    this.flex,
  }) : super(key: key);
  final List<Widget> children;
  final int? flex;
  final List<int>? childrenFlexFactors;

  @override
  Widget build(final BuildContext context) {
    // Flexible here to prevent vertical overflow when animating menu
    return Flexible(
      flex: flex ?? 1,
      child: Padding(
        padding: const EdgeInsets.only(
          right: UiSizes.paddingL,
          left: UiSizes.paddingL,
          bottom: UiSizes.paddingXS,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: children
              .asMap()
              .map(
                (final index, final child) => MapEntry(
                  index,
                  // wrap each child in Flexible to prevent overflow issues
                  // when animating menu open/close
                  Flexible(
                    flex: childrenFlexFactors != null
                        ? childrenFlexFactors![index]
                        : 1,
                    child: child,
                  ),
                ),
              )
              .values
              .toList(),
        ),
      ),
    );
  }
}

class ScrollContainerPairRow extends StatelessWidget {
  const ScrollContainerPairRow({
    required this.heading,
    required this.entry,
    final Key? key,
    this.flex,
  }) : super(key: key);
  final Widget heading;
  final Widget entry;
  final int? flex;

  @override
  Widget build(final BuildContext context) {
    // Flexible here to prevent vertical overflow when animating menu
    return Flexible(
      flex: flex ?? 1,
      child: Padding(
        padding: const EdgeInsets.only(
          right: UiSizes.paddingL,
          left: UiSizes.paddingL,
          bottom: UiSizes.paddingXS,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          // mainAxisAlignment: MainAxisAlignment.spaceBetween,
          scrollDirection: Axis.horizontal,
          children: [
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: UiSizes.drawerMenuWidth * 0.5,
                maxHeight: UiSizes.drawerMenuHeight * 0.2,
              ),
              child: heading,
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: UiSizes.drawerMenuWidth * 0.5,
                maxHeight: UiSizes.drawerMenuHeight * 0.2,
              ),
              child: entry,
            ),
          ],
        ),
      ),
    );
  }
}

class ScrollContainerText extends StatelessWidget {
  const ScrollContainerText(
    this.text, {
    this.flex,
    final Key? key,
  }) : super(key: key);
  final String text;
  final int? flex;

  @override
  Widget build(final BuildContext context) {
    return ScrollContainerRow(
      flex: flex,
      children: [Text(text)],
    );
  }
}

class ScrollContainerEmpty extends StatelessWidget {
  const ScrollContainerEmpty(
    this.text, {
    final Key? key,
  }) : super(key: key);
  final String text;

  @override
  Widget build(final BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: Text(text)),
      ],
    );
  }
}

class ScrollContainerTitle extends StatelessWidget {
  const ScrollContainerTitle({
    required this.text,
    required this.icon,
    final Key? key,
    this.shadows,
    this.color = UiColors.blackAsh,
  }) : super(key: key);
  final String text;
  final String icon;
  final Color color;
  final List<Shadow>? shadows;

  @override
  Widget build(final BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: UiSizes.paddingM),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Flexible to prevent overflow issues when animating menu open/close
          Flexible(
            // flex: 1,
            child: SvgPicture.asset(icon, color: color, height: 25),
          ),
          Flexible(
            flex: 5,
            child: Padding(
              padding: const EdgeInsets.only(left: UiSizes.paddingS),
              child: DefaultTextStyle(
                style: Theme.of(context).textTheme.headline2!,
                child: Text(
                  text,
                  textWidthBasis: TextWidthBasis.longestLine,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                  style: TextStyle(
                    color: color,
                    shadows: shadows,
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

// SELECT BUTTONS //////////////////////////////////////////////////////////

class SelectButtons extends StatefulWidget {
  const SelectButtons({
    required this.initialIndex,
    required this.icons,
    required this.callbacks,
    required this.activeColor,
    final Key? key,
    this.decoration,
    this.constraints,
    this.disabled = false,
  }) : super(key: key);
  final int initialIndex;
  final List<String> icons;
  final List<VoidCallback> callbacks;
  final BoxDecoration? decoration;
  final BoxConstraints? constraints;
  static const double size = UiSizes.roundIconButtonSizeS;
  final Color activeColor;
  final bool disabled;

  @override
  _SelectButtonsState createState() => _SelectButtonsState();
}

class _SelectButtonsState extends State<SelectButtons> {
  late int _activeIndex;

  @override
  void initState() {
    super.initState();
    _activeIndex = widget.initialIndex;
  }

  void changeSelection(final int index) {
    if (mounted && widget.disabled == false) {
      widget.callbacks[index].call();
      setState(() {
        _activeIndex = index;
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    final List<Widget> buttons = [];

    widget.icons.asMap().forEach((final index, final icon) {
      buttons.add(
        RoundBorderButton(
          activeStateGetter: () => !widget.disabled,
          selectedStateGetter: () => _activeIndex == index,
          callback: () => changeSelection(index),
          activeColor: widget.activeColor,
          iconSource: icon,
        ),
      );
    });

    return SizedBox(
      width: 100.0,
      child: Row(
        children: buttons.map((final btn) => Expanded(child: btn)).toList(),
      ),
    );
  }
}
