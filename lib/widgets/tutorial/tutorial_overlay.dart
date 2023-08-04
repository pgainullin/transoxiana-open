part of tutorial_widgets;

/// [child] is a widget that will be displayed over
/// tutorial overlay. It can be for example [FloatedTip]
///
/// To position child use [childAlignment], it will use
/// size of [highlightedPath] to align child.
///
/// If you need custom position,use [childPosition]
class TutorialOverlay extends StatelessWidget {
  const TutorialOverlay({
    required this.game,
    this.child,
    final Key? key,
  }) : super(key: key);
  final Widget? child;
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final resolvedChild = child;
    return Stack(
      children: [
        if (resolvedChild != null)
          Positioned.fill(
            child: resolvedChild,
          ),
        OnReactive(() {
          final tutorialState = game.tutorial;
          final tutorialOverlayState = game.tutorialOverlay;
          final painter = tutorialState.painter;
          final tutorialStep = tutorialState.currentStep;
          final nextStep = tutorialState.nextCurrentStep;
          if (tutorialOverlayState.isOverlayNotVisible ||
              painter == null ||
              tutorialState.tutorialSteps.isEmpty) return Container();

          return Positioned.fill(
            child: Stack(
              children: [
                Positioned(
                  width: screenSize.width,
                  height: screenSize.height,
                  child: CustomPaint(
                    painter: painter,
                  ),
                ),
                if (tutorialOverlayState.isFloatingTipVisible &&
                    tutorialStep != null)
                  _FloatingTip(
                    painter: painter,
                    tutorialStep: tutorialStep,
                    nextStep: nextStep,
                    game: game,
                  ),
              ],
            ),
          );
        })
      ],
    );
  }
}

class _FloatingTip extends StatefulWidget {
  const _FloatingTip({
    required this.tutorialStep,
    required this.painter,
    required this.nextStep,
    required this.game,
    final Key? key,
  }) : super(key: key);
  final TutorialStep tutorialStep;
  final TutorialStep? nextStep;
  final TutorialOverlayPainter painter;
  final TransoxianaGame game;
  @override
  _FloatingTipState createState() => _FloatingTipState();
}

class _FloatingTipState extends State<_FloatingTip> {
  final notifier = ValueNotifier(Size.zero);
  Offset floatingOffset = Offset.zero;
  Size lastSize = Size.zero;
  TutorialOverlayPainter? lastPainter;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      final offset = getFloatingOffset(Size.zero);
      if (offset != null) floatingOffset = offset;
    });

    notifier.addListener(checkAndChange);
  }

  @override
  void didUpdateWidget(final _FloatingTip oldWidget) {
    WidgetsBinding.instance.addPostFrameCallback((final _) {
      checkAndChange();
    });
    super.didUpdateWidget(oldWidget);
  }

  void checkAndChange() {
    final size = notifier.value;
    final newFloatingOffset = getFloatingOffset(size);

    final isSizeZero = size == Size.zero;
    final isLastSize = size == lastSize;
    final isSamePainter = lastPainter == widget.painter;
    final isSameOffset = newFloatingOffset == floatingOffset;

    bool isSomethingChanged = false;
    if (!(isSizeZero && isLastSize)) {
      lastSize = size;
      isSomethingChanged = true;
    }
    if (!isSamePainter) {
      lastPainter = widget.painter;
      isSomethingChanged = true;
    }
    if (!isSameOffset && newFloatingOffset != null) {
      floatingOffset = newFloatingOffset;
      isSomethingChanged = true;
    }
    if (isSomethingChanged) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    notifier.removeListener(checkAndChange);
    notifier.dispose();
    super.dispose();
  }

  bool get isMobile {
    return UiPersistentFormFactors.of(context).width == WidthFormFactor.mobile;
  }

  Offset? getFloatingOffset(final Size floatingSize) {
    if (!mounted) return null;
    return widget.painter.getFloatingOffset(
      alignment: isMobile
          ? widget.tutorialStep.mobileAlignment
          : widget.tutorialStep.alignment,
      floatingSize: floatingSize,
      context: context,
      alignToScreen: widget.tutorialStep.alignToScreen,
    );
  }

  @override
  Widget build(final BuildContext context) {
    return Positioned(
      left: floatingOffset.dx,
      top: floatingOffset.dy,
      child: ChildSizeNotifier(
        notifier: notifier,
        builder: (final context, final size, final child) {
          return child ?? Container();
        },
        child: FloatingTip(
          nextStep: widget.nextStep,
          step: widget.tutorialStep,
          game: widget.game,
        ),
      ),
    );
  }
}
