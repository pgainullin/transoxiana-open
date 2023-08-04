// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class TabPanel extends StatefulWidget {
  const TabPanel({
    required this.icons,
    required this.children,
    required this.activeIndex,
    this.tabWidth = 90.0,
    final Key? key,
  })  : assert(icons.length == children.length),
        super(key: key);
  final List<String> icons;
  final List<Widget> children;
  final int activeIndex;
  static const double tabHeight = 46.0;
  static const double tabButtonHeight = 46.0 - UiSizes.borderWidth * 2;
  final double tabWidth;

  @override
  State<TabPanel> createState() => _TabPanelState();
}

class _TabPanelState extends State<TabPanel> {
  int _activeIndex = 0;
  late double _tabButtonWidth;

  @override
  void initState() {
    _tabButtonWidth = widget.tabWidth - UiSizes.borderWidth * 2;
    super.initState();
  }

  @override
  void didUpdateWidget(final TabPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.activeIndex != _activeIndex) {
      _switchTab(widget.activeIndex);
    }
  }

  void _switchTab(final int tabIndex) {
    if (mounted) setState(() => _activeIndex = tabIndex);
  }

  @override
  Widget build(final BuildContext context) {
    final lastIndex = widget.icons.length - 1;
    final List<Widget> buttons = [];
    final List<Widget> buttonBorders = [];
    Widget? activeBorder;

    widget.icons.asMap().forEach((final index, final tabIcon) {
      // BUTTONS
      buttons.add(
        Positioned(
          top: UiSizes.borderWidth,
          left: UiSizes.borderWidth +
              index.toDouble() * (_tabButtonWidth + UiSizes.borderWidth),
          // clipRRect needed here to properly clip button's highlightColor
          child: ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(
                index == 0
                    ? UiSizes.borderRadius - UiSizes.innerBorderRadiusOffset
                    : 0,
              ),
              bottomLeft: Radius.circular(
                index == 0
                    ? UiSizes.borderRadius - UiSizes.innerBorderRadiusOffset
                    : 0,
              ),
              bottomRight: Radius.circular(
                index == lastIndex
                    ? UiSizes.borderRadius - UiSizes.innerBorderRadiusOffset
                    : 0,
              ),
              topRight: Radius.circular(
                index == lastIndex
                    ? UiSizes.borderRadius - UiSizes.innerBorderRadiusOffset
                    : 0,
              ),
            ),
            child: Container(
              height: TabPanel.tabButtonHeight,
              width: _tabButtonWidth,
              decoration: const BoxDecoration(
                // color: UiColors.lightGrey,
                image: DecorationImage(
                  fit: BoxFit.none,
                  colorFilter:
                      ColorFilter.mode(UiColors.greyStone, BlendMode.dstATop),
                  image: ExactAssetImage(UiBackgrounds.stone),
                ),
              ),
              child: RawMaterialButton(
                highlightColor: UiColors.gold
                    .withOpacity(UiSettings.buttonHighlightOpacity),
                onPressed: () => _switchTab(index),
                child: SvgPicture.asset(
                  tabIcon,
                  color: _activeIndex == index
                      ? UiColors.gold
                      : UiColors.lightGrey,
                  height: UiSizes.tabIconSize,
                ),
              ),
            ),
          ),
        ),
      );

      // BUTTON BORDER RECTS
      final border = Positioned(
        left: index.toDouble() * (widget.tabWidth - UiSizes.borderWidth),
        child: Container(
          decoration: BoxDecoration(
            color: _activeIndex == index ? UiColors.gold : UiColors.lightGrey,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(index == 0 ? UiSizes.borderRadius : 0),
              bottomLeft:
                  Radius.circular(index == 0 ? UiSizes.borderRadius : 0),
              bottomRight: Radius.circular(
                index == lastIndex ? UiSizes.borderRadius : 0,
              ),
              topRight: Radius.circular(
                index == lastIndex ? UiSizes.borderRadius : 0,
              ),
            ),
          ),
          height: TabPanel.tabHeight,
          width: widget.tabWidth,
        ),
      );

      if (_activeIndex == index) {
        // assign active border
        activeBorder = border;
      } else {
        // otherwise, add to borders List
        buttonBorders.add(border);
      }
    });

    // place active button border at the end of the list
    // so that it is at the top of the List and is shown properly inside Stack
    buttonBorders.add(activeBorder!);

    // CONTAINER
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.only(
              top: UiSizes.paddingM,
              right: UiSizes.paddingM,
            ),
            // somewhat complex calculations as children are not fixed
            // and populated with list.map() below
            height: TabPanel.tabHeight,
            width:
                // tab width times number of tabs
                widget.tabWidth * widget.icons.length -
                    // minus border width * number of overlapping borders
                    UiSizes.borderWidth * (widget.icons.length - 1),
            decoration: BoxDecoration(
              boxShadow: [UiSettings.buttonShadow],
              borderRadius: UiSettings.borderRadiusAll,
            ),
            child: Stack(children: buttonBorders + buttons),
          ),
        ),
        // SizedBox(width: UiSizes.drawerMenuWidth, height: 50.0, child: Container(color: Colors.red,),),
        widget.children[_activeIndex],
      ],
    );
  }
}
