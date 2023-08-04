// CALLBACK BUTTON ///////////////////////////////////////////////////////////////

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

/// A text button widget that can be active or inactive depending on the state of the activeStateGetter at rebuild and triggers the callback on press if active
class CallbackButton extends StatefulWidget {
  const CallbackButton({
    required this.callback,
    required this.activeStateGetter,
    final Key? key,
    this.activeText,
    this.activeIcon,
    this.inactiveText,
    this.inactiveIcon,
  })  : assert(!(activeText == null && activeIcon == null)),
        assert(!(inactiveText == null && inactiveIcon == null)),
        super(key: key);
  final String? activeText;
  final Icon? activeIcon;
  final String? inactiveText;
  final Icon? inactiveIcon;
  final ValueGetter<bool> activeStateGetter;

  final VoidCallback callback;

  @override
  _CallbackButtonState createState() => _CallbackButtonState();
}

class _CallbackButtonState extends State<CallbackButton> {
  @override
  void initState() {
    super.initState();
  }

  void toggle() {
    if (mounted && widget.activeStateGetter.call() == true) {
      setState(() {
        widget.callback.call();
      });
    }
  }

  @override
  Widget build(final BuildContext context) {
    return TextButton(
      onPressed: toggle,
      child: widget.activeStateGetter.call()
          ? widget.activeIcon ?? Text(widget.activeText!)
          : widget.inactiveIcon ?? Text(widget.inactiveText!),
    );
  }
}

class RoundBorderButton extends StatelessWidget {
  const RoundBorderButton({
    required this.activeStateGetter,
    required this.callback,
    final Key? key,
    this.activeColor = UiColors.gold,
    this.inactiveColor = UiColors.blackAsh,
    this.iconSource,
    this.selectedIcon,
    this.notSelectedIcon,
    final ValueGetter<bool>? selectedStateGetter,
  })  : selectedStateGetter = selectedStateGetter ?? activeStateGetter,
        assert(
          iconSource != null || (selectedIcon != null),
        ),
        super(key: key);
  final Color activeColor;
  final Color inactiveColor;
  final String? iconSource;
  final Icon? selectedIcon;
  final Icon? notSelectedIcon;

  ///whether this button can be pressed
  final ValueGetter<bool> activeStateGetter;
  ///whether this button displays as the selected one
  final ValueGetter<bool> selectedStateGetter;
  final VoidCallback callback;

  @override
  Widget build(final BuildContext context) {
    final bool isSelected = selectedStateGetter.call();

    final Widget iconWidget = (isSelected ? selectedIcon : notSelectedIcon) ??
        SvgPicture.asset(
          iconSource!,
          color: isSelected ? activeColor : inactiveColor,
          height: UiSizes.roundIconButtonSizeS - UiSizes.paddingXL,
        );

    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: isSelected ? activeColor : inactiveColor,
          width: isSelected ? UiSizes.borderWidth : UiSizes.borderWidth * 0.5,
        ),
      ),
      height: UiSizes.roundIconButtonSizeS,
      width: UiSizes.roundIconButtonSizeS,
      child: RawMaterialButton(
        shape: const CircleBorder(),
        highlightColor:
            UiColors.brownWood.withOpacity(UiSettings.buttonHighlightOpacity),
        onPressed: activeStateGetter.call() ? callback : null,
        child: iconWidget,
      ),
    );
  }
}
