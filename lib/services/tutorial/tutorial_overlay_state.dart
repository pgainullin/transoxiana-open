part of 'tutorial_states.dart';

/// {@template tutorial_overlay_state}
/// Keeps actual parameters for overlay
/// {@endtemplate}
class TutorialOverlayState {
  TutorialOverlayState({
    this.isOverlayVisible = false,
    this.isFloatingTipVisible = false,
  });
  bool isOverlayVisible;
  bool get isOverlayNotVisible => !isOverlayVisible;
  bool isFloatingTipVisible;
  bool get isFloatingTipNotVisible => !isFloatingTipVisible;
  bool get isAllVisible => isOverlayVisible && isFloatingTipVisible;
  set isAllVisible(final bool isVisible) {
    isOverlayVisible = isVisible;
    isFloatingTipVisible = isVisible;
  }

  /// Shortcut to initialize [TutorialOverlayState]
  static void switchAndInitTutorialSteps({
    required final bool isEnabled,
    required final TransoxianaGame game,
  }) {
    game.tutorialOverlayStateService
      ..state.isAllVisible = isEnabled
      ..notify();
    if (isEnabled) {
      game.tutorialStateService.state
        ..recalculatePointers()
        ..reorderSteps()
        ..runPrerenderStepActions();
      game.tutorialStateService.notify();
    }
  }
}
