part of tutorial_widgets;

class TutorialStepState extends StatefulWidget {
  const TutorialStepState({
    required this.game,
    required this.tutorialSteps,
    required this.child,
    final GlobalKey? key,
  }) : super(key: key);
  final Widget child;
  final TransoxianaGame game;
  final List<TutorialStep> tutorialSteps;

  @override
  State<TutorialStepState> createState() => _TutorialStepStateState();
}

class _TutorialStepStateState extends State<TutorialStepState> {
  Future<bool> addTutorialEntry() async {
    WidgetsBinding.instance.addPostFrameCallback((final timeStamp) async {
      await widget.game.tutorialStateService.setState(
        (final s) {
          for (final tutorialStep in widget.tutorialSteps) {
            s.pushTutorialStep(
              tutorialStep: tutorialStep,
              key: widget.key as GlobalKey?,
            );
          }
          s.recalculatePointers();
          return null;
        },
      );
    });

    return true;
  }

  Future<bool>? _cache;
  @override
  Widget build(final BuildContext context) {
    return FutureBuilder<bool>(
      future: _cache ??= addTutorialEntry(),
      builder: (final _, final snapshot) => widget.child,
    );
  }
}
