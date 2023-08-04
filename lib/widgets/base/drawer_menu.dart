import 'package:flutter/material.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/base/buttons.dart';
import 'package:transoxiana/widgets/base/rounded_border_container.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class DrawerMenu extends StatefulWidget {
  const DrawerMenu({
    required this.game,
    required this.width,
    required this.height,
    required this.child,
    required this.startOpen,
    this.closeCallback,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final double width;
  final double height;
  final Widget child;
  final bool startOpen;

  final VoidCallback? closeCallback;

  @override
  _DrawerMenuState createState() => _DrawerMenuState();
}

class _DrawerMenuState extends State<DrawerMenu> with TickerProviderStateMixin {
  late AnimationController _controller;
  bool _isOpen = false;
  static const int animationDuration = 500;

  @override
  void initState() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: animationDuration),
    );
    super.initState();
  }

  @override
  void didUpdateWidget(final DrawerMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.startOpen && !_isOpen) {
      // only open menu if an entity was selected AND menu not already open
      _controller.forward();
      _toggleMenuOpen();
    } else if (!widget.startOpen && _isOpen) {
      // only close menu if an entity was deselected AND menu not already closed
      _controller.reverse();
      _toggleMenuOpen();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// if true the children widgets accessing this property can decide to
  /// override automatic menu closing on deselect.
  /// TODO: fix for widget rebuilds
  bool intendedToOpen = false;

  void _toggleMenuOpen({final bool pressedManually = false}) {
    // delay so that menu button highlight does not change before
    // menu is fully open/closed
    // -150 to account for animation bounce curve effect
    Future.delayed(const Duration(milliseconds: animationDuration - 150), () {
      if (!mounted) return;
      if(!_isOpen && pressedManually) intendedToOpen = true;
      if(_isOpen) intendedToOpen = false;
      setState(() => _isOpen = !_isOpen);
      if(!_isOpen){
        widget.closeCallback?.call();
      }
    });
  }

  @override
  Widget build(final BuildContext context) {
    // outerPadding needed for the shadow and border to fit properly
    const double outerPadding = 10;
    return Stack(
      children: [
        IgnorePointer(
          ignoring: !_isOpen,
          child: Container(
            color: Colors.transparent,
            height: widget.height + outerPadding,
            width: widget.width,
            child: Stack(
              children: [
                PositionedTransition(
                  rect: RelativeRectTween(
                    begin: RelativeRect.fromLTRB(
                      0,
                      0,
                      widget.width,
                      widget.height,
                    ),
                    end: const RelativeRect.fromLTRB(0, 0, outerPadding, 0),
                  ).animate(
                    CurvedAnimation(
                      parent: _controller,
                      curve: Curves.elasticInOut,
                    ),
                  ),
                  // scrollview is needed to prevent overflow issues
                  // when animation plays
                  child: SingleChildScrollView(
                    child: RoundedBorderContainer(
                      height: widget.height,
                      width: widget.width,
                      bottomRightRadius: UiSizes.borderRadius,
                      backgroundOpacity: UiSettings.buttonFillOpacity,
                      borderInsets: const EdgeInsetsDirectional.only(
                        end: UiSizes.borderWidth,
                        bottom: UiSizes.borderWidth,
                      ),
                      shadow: UiSettings.widgetShadow,
                      child: widget.child,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        CornerButton(
          icon: UiIcons.scroll,
          onPressed: () {
            if (_isOpen) {
              _controller.reverse();
            } else {
              _controller.forward();
            }

            _toggleMenuOpen(pressedManually: true);
          },
          tooltipTitle: S.of(context).campaignMenu,
          tooltipText: S.of(context).campaignMenuTooltipContent,
          isActive: _isOpen,
        ),
      ],
    );
  }
}
