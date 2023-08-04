import 'package:flutter/material.dart';
import 'package:flutter_gifimage/flutter_gifimage.dart';
import 'package:flutter_svg/svg.dart';
import 'package:states_rebuilder/states_rebuilder.dart';
import 'package:super_tooltip/super_tooltip.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/temporary_game_data.dart';
import 'package:transoxiana/generated/l10n.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class RoundButton extends StatefulWidget {
  const RoundButton({
    required this.onPressed,
    required this.tooltipTitle,
    required this.tooltipText,
    final Key? key,
    // either child (e.g. a GIF) or icon
    this.icon,
    this.child,
    this.iconOffsetCorner,
    // optional icon size if
    this.iconSize,
    this.size = UiSizes.buttonSize,
    this.background = UiBackgrounds.stone,
    this.fillColor = UiColors.greyStone,
    this.isActive = false,
    this.tooltipDirection = TooltipDirection.up,
    this.tooltipOffset = 40,
    this.color = UiColors.lightGrey,
    this.backgroundOpacity = 1,
    this.backgroundFilterColor = UiColors.greyStone,
    this.borderWidth = UiSizes.borderWidth,
    this.extraIconOffset = 0.0,
    this.extraPadding = 0.0,
  }) : super(key: key);
  final String? icon;
  final VoidCallback? onPressed;
  final bool isActive;
  final Widget? child;
  final String background;
  final double backgroundOpacity;
  final Color fillColor;
  final Color color;
  final Color backgroundFilterColor;
  final double size;
  final double? iconSize;
  final double borderWidth;
  final double extraIconOffset;
  final double extraPadding;
  final Corner? iconOffsetCorner;
  final String tooltipTitle;
  final String tooltipText;
  final TooltipDirection tooltipDirection;
  final double tooltipOffset;

  @override
  _RoundButtonState createState() => _RoundButtonState();
}

class _RoundButtonState extends State<RoundButton> {
  late SuperTooltip _tooltip;

  void handleLongPress() {
    _tooltip = SuperTooltip(
      minimumOutSidePadding: UiSizes.paddingM,
      popupDirection: widget.tooltipDirection,
      // hides the arrow
      arrowBaseWidth: 0,
      // adds padding between button and popup
      arrowLength: widget.tooltipOffset,
      borderColor: Colors.transparent,
      outsideBackgroundColor: Colors.transparent,
      maxWidth: 250,
      backgroundColor: UiColors.yellowPapyrus,
      shadowColor: Colors.black.withOpacity(0.5),
      shadowSpreadRadius: 0,
      shadowBlurRadius: 4,
      content: GestureDetector(
        onTap: () => _tooltip.close(),
        child: RichText(
          text: TextSpan(
            style: Theme.of(context).textTheme.bodyText2,
            children: <TextSpan>[
              TextSpan(
                text: widget.tooltipTitle,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextSpan(text: ' ${widget.tooltipText}'),
            ],
          ),
        ),
      ),
    );

    _tooltip.show(context);
  }

  @override
  Widget build(final BuildContext context) {
    final Color color = widget.isActive ? UiColors.gold : widget.color;
    final Widget buttonImage =
        // display custom child widget if provided (e.g. GIF asset)
        // otherwise display SVG with icon
        widget.child ??
            SvgPicture.asset(
              widget.icon!,
              color: color,
              height: widget.iconSize,
            );

    return Container(
      margin: const EdgeInsets.only(left: UiSizes.paddingM),
      padding: EdgeInsets.all(widget.extraPadding),
      decoration: BoxDecoration(
        boxShadow:
            widget.backgroundOpacity == 0.0 ? null : [UiSettings.buttonShadow],
        border: widget.borderWidth == 0.0
            ? null
            : Border.all(
                color: color,
                width: widget.borderWidth,
              ),
        shape: BoxShape.circle,
        color: widget.fillColor.withOpacity(widget.backgroundOpacity),
        image: widget.backgroundOpacity == 0.0
            ? null
            : DecorationImage(
                fit: BoxFit.none,
                colorFilter: ColorFilter.mode(
                  widget.backgroundFilterColor
                      .withOpacity(widget.backgroundOpacity),
                  BlendMode.dstATop,
                ),
                image: ExactAssetImage(widget.background),
              ),
      ),
      height: widget.size,
      width: widget.size,
      child: RawMaterialButton(
        onLongPress: handleLongPress,
        onPressed: widget.onPressed,
        shape: const CircleBorder(),

        // todo consider moving to ThemeData
        highlightColor: UiColors.goldTransparent,
        child: Stack(
          children: [
            if (widget.iconOffsetCorner == null)
              Center(child: buttonImage)
            else
              Positioned(
                top: UiSizes.cornerButtonSize / 2 + widget.extraIconOffset,
                left: widget.iconOffsetCorner == Corner.topLeft
                    ? UiSizes.cornerButtonSize / 2 + widget.extraIconOffset
                    : null,
                right: widget.iconOffsetCorner == Corner.topRight
                    ? UiSizes.cornerButtonSize / 2 + widget.extraIconOffset
                    : null,
                child: buttonImage,
              )
          ],
        ),
      ),
    );
  }
}

class CornerButton extends StatelessWidget {
  const CornerButton({
    required this.icon,
    required this.tooltipText,
    required this.tooltipTitle,
    required this.onPressed,
    final Key? key,
    this.isActive = false,
    this.color = UiColors.yellowPapyrus,
    this.corner = Corner.topLeft,
    this.iconSize,
    this.extraIconOffset = 0,
  }) : super(key: key);
  final String tooltipText;
  final String tooltipTitle;
  final void Function() onPressed;
  final bool isActive;
  final Corner corner;
  final String icon;
  final Color color;
  final double? iconSize;
  final double extraIconOffset;

  @override
  Widget build(final BuildContext context) {
    return Positioned(
      top: -UiSizes.cornerButtonSize / 2,
      left: corner == Corner.topLeft ? -UiSizes.cornerButtonSize / 2 : null,
      right: corner == Corner.topRight ? -UiSizes.cornerButtonSize / 2 : null,
      child: RoundButton(
        extraIconOffset: extraIconOffset,
        iconSize: iconSize,
        size: UiSizes.cornerButtonSize,
        onPressed: onPressed,
        icon: icon,
        iconOffsetCorner: corner,
        tooltipTitle: tooltipTitle,
        tooltipText: tooltipText,
        tooltipDirection: TooltipDirection.down,
        tooltipOffset: 80,
        isActive: isActive,
        color: color,
        fillColor: UiColors.brownWood,
        background: UiBackgrounds.wood,
        backgroundOpacity: UiSettings.buttonFillOpacity,
        backgroundFilterColor: Colors.black,
      ),
    );
  }
}

/// Widget displaying a button with animated hourglass which ends the turn
/// Uses GifController lib to reset gif animation frame to the first one
/// after turn finishes (i.e. hourglass is back to static)
/// Otherwise, hourglass rotation may start from wrong frame
/// when End Turn is pressed again
class EndTurnButton extends StatefulWidget {
  const EndTurnButton(
    this.game, {
    required this.onPressed,
    required this.tooltipText,
    final Key? key,
  }) : super(key: key);
  final TransoxianaGame game;
  final VoidCallback onPressed;
  final String tooltipText;

  @override
  _EndTurnButtonState createState() => _EndTurnButtonState();
}

class _EndTurnButtonState extends State<EndTurnButton>
    with TickerProviderStateMixin {
  late GifController _gifController;

  bool _cachedInCommand = false;
  VoidCallback? _removeObservable;
  @override
  void initState() {
    _gifController = GifController(vsync: this);

    // listen to RxGameData and start the animation if the state of inCommand changes to false, stop otherwise
    final gameData = widget.game.temporaryCampaignDataService;
    _removeObservable = gameData.addObserver(
      listener: (final snap) {
        if (!snap.hasData || !mounted) return;
        final data = snap.state as TemporaryGameData;
        if (data.inCommand != _cachedInCommand) {
          if (data.inCommand == false) {
            startAnimation();
          } else {
            stopAnimation();
          }
          _cachedInCommand = data.inCommand;
        }
      },
    );

    super.initState();
  }

  @override
  void dispose() {
    // stop controller to properly dispose of ticker
    // otherwise potential CPU leak on entering battle map
    _gifController.stop();
    _removeObservable?.call();
    super.dispose();
  }

  /// start hourglass animation.
  /// min max are first and last frames
  /// these cannot be set automatically if using repeat
  void startAnimation() {
    _gifController.repeat(
      min: 1,
      max: 22,
      period: const Duration(milliseconds: 2000),
    );
  }

  void stopAnimation() {
    /// stops animation
    /// needed for animation to restart from the first frame
    _gifController.stop();
  }

  @override
  Widget build(final BuildContext context) {
    return StateBuilder<TemporaryGameData>(
      observe: () => widget.game.temporaryCampaignDataService,
      builder: (final context, final gameData) {
        if (gameData == null) return Container();
        return gameData.whenConnectionState(
          onIdle: Container.new,
          onWaiting: () => const CircularProgressIndicator(),
          onData: (final data) {
            // if (data.inCommand == true) {
            //   // stops animation
            //   // needed for animation to restart from the first frame
            //   _gifController.stop();
            // }
            return RoundButton(
              size: UiSizes.buttonSize * 1.25,
              onPressed: data.inCommand ? widget.onPressed : null,
              isActive: !data.inCommand,
              tooltipTitle: S.of(context).endTurn,
              tooltipText: widget.tooltipText,
              child: data.inCommand
                  ? UiRasterAssets.hourglass
                  : GifImage(
                      controller: _gifController,
                      image: UiRasterAssets.hourglassAnimated,
                      height: UiSizes.buttonImageSize,
                      gaplessPlayback: true,
                    ),
            );
          },
          onError: (final error) => ErrorWidget(error as Object),
        );
      },
    );
  }
}
