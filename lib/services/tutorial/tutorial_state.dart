part of 'tutorial_states.dart';

typedef TutorialStatePointersMap = Map<TutorialModes, int>;

/// Signature for the callback used by [TutorialStep.shapeValue]
typedef ProvinceCallback = Province Function();

enum _TutorialModesMapAction {
  push,
  unshift,
}

/// Use this function to add [TutorialModes.independent] steps
void addWidgetTutorialEntry({
  required final TutorialStep tutorialStep,
  required final GlobalKey key,
  required final TransoxianaGame game,
  final bool addPostframe = true,
}) {
  void add() {
    game.tutorialStateService.state
      ..pushTutorialStep(
        tutorialStep: tutorialStep,
        key: key,
      )
      ..recalculatePointers();
    game.tutorialStateService.notify();
  }

  if (addPostframe) {
    WidgetsBinding.instance.addPostFrameCallback((final timeStamp) async {
      add();
    });
  } else {
    add();
  }
}

/// {@template tutorial_state}
/// Keeps stack of tutorial steps
/// {@endtemplate}
class TutorialState implements GameRef {
  TutorialState({
    required final TutorialModes mode,
  }) : currentMode = mode;
  TutorialModes? currentMode;

  /// Shortcut to change [currentMode]
  static void switchMode({
    required final TutorialModes? mode,
    required final TransoxianaGame game,
    final bool enableOverlay = false,
  }) {
    game.tutorialStateService
      ..state.currentMode = mode
      ..notify();
    if (enableOverlay) {
      TutorialOverlayState.switchAndInitTutorialSteps(
        isEnabled: true,
        game: game,
      );
    }
  }

  @override
  late TransoxianaGame game;
  void setLateParams({required final TransoxianaGame game}) {
    this.game = game;
  }

  /// can be managed from code
  /// automatically fills by [TutorialStepState]
  TutorialModesMap get modesMap => game.tutorialHistory.modesMap;
  set modesMap(final TutorialModesMap value) =>
      game.tutorialHistory.modesMap = value;

  void _addTutorialStep({
    required final TutorialStep tutorialStep,
    required final _TutorialModesMapAction action,
    final GlobalKey? key,
  }) {
    final tutorialMode = tutorialStep.tutorialMode;
    final mode = modesMap[tutorialMode] ?? TutorialMode(mode: tutorialMode);
    final changedMode = () {
      final steps = [tutorialStep];
      final keys = {tutorialStep.enumAction: key};
      switch (action) {
        case _TutorialModesMapAction.push:
          return mode.pushWith(
            keys: keys,
            mode: tutorialMode,
            steps: steps,
          );
        case _TutorialModesMapAction.unshift:
          return mode.unshiftWith(
            keys: {tutorialStep.enumAction: key},
            mode: tutorialMode,
            steps: steps,
          );
      }
    }();
    final updatedModesMap = {...modesMap};
    updatedModesMap[tutorialMode] = changedMode;
    modesMap = updatedModesMap;
  }

  void unshiftTutorialStep({
    required final TutorialStep tutorialStep,
    final GlobalKey? key,
  }) =>
      _addTutorialStep(
        action: _TutorialModesMapAction.unshift,
        tutorialStep: tutorialStep,
        key: key,
      );

  void pushTutorialStep({
    required final TutorialStep tutorialStep,
    final GlobalKey? key,
  }) =>
      _addTutorialStep(
        action: _TutorialModesMapAction.push,
        tutorialStep: tutorialStep,
        key: key,
      );

  void reorderSteps() => tutorialSteps = tutorialSteps..sort();

  TutorialMode? get currentTutorialMode => modesMap[currentMode];
  List<TutorialStep?> get tutorialSteps =>
      currentTutorialMode?.currentSteps.toList() ?? [];
  set tutorialSteps(final List<TutorialStep?> steps) {
    currentTutorialMode?.currentSteps.clear();
    steps.sort();
    currentTutorialMode?.currentSteps.addAll(steps.whereType<TutorialStep>());
  }

  TutorialStep? get currentStep {
    if (tutorialSteps.isEmpty ||
        statePointer > tutorialSteps.length - 1 ||
        currentMode == null) {
      return null;
    }
    final step = tutorialSteps[statePointer];
    if (step == null) return null;
    return step;
  }

  TutorialStep? get nextCurrentStep {
    final nextPointer = statePointer + 1;
    if (tutorialSteps.isEmpty ||
        nextPointer > tutorialSteps.length - 1 ||
        currentMode == null) {
      return null;
    }
    final step = tutorialSteps[nextPointer];
    if (step == null) return null;
    return step;
  }

  TutorialActionKeysMap get keysMap => currentTutorialMode?.keys ?? {};

  TutorialStatePointersMap get statePointers =>
      game.tutorialHistory.statePointers;
  set statePointers(final TutorialStatePointersMap value) =>
      game.tutorialHistory.statePointers = value;

  int get statePointer {
    final resolvedMode = currentMode;
    if (resolvedMode == null) return 0;
    final pointer = statePointers[resolvedMode];

    return pointer ?? 0;
  }

  set statePointer(final int value) {
    final resolvedMode = currentMode;
    if (resolvedMode == null) return;
    statePointers[resolvedMode] = value;
  }

  /// This method recalcuate pointers
  void recalculatePointers() {
    final updatedStatePointers = {...statePointers};
    for (final key in modesMap.keys) {
      updatedStatePointers.update(
        key,
        (final value) => value,
        ifAbsent: () => 0,
      );
    }
    statePointers = updatedStatePointers;
  }

  int get tutorialStepsLastIndex => tutorialSteps.length - 1;
  void next() {
    final resolvedStep = currentStep;
    final resetPointers = resolvedStep?.resetTutorialModePointers;
    final nextPointer = statePointer + 1;
    if (resolvedStep != null && resolvedStep.selfRemoveAfterClose == true) {
      final steps = tutorialSteps;
      steps.remove(resolvedStep);
      tutorialSteps = steps;
    }
    if (tutorialSteps.isEmpty) {
      return;
    } else if (nextPointer > tutorialStepsLastIndex) {
      TutorialOverlayState.switchAndInitTutorialSteps(
        isEnabled: false,
        game: game,
      );
      if (resetPointers == true) {
        statePointer = 0;
      } else {
        statePointer = tutorialStepsLastIndex + 1;
      }
      return;
    }
    statePointer = nextPointer;
    runPrerenderStepActions();
  }

  void back() {
    if (tutorialSteps.isEmpty || statePointer - 1 < 0) {
      return;
    }
    statePointer--;
    runPrerenderStepActions();
  }

  void _runCameraActions({
    required final List<CameraMovement?>? cameraMovements,
  }) {
    final resolvedCurrentStep = currentStep;
    if (cameraMovements == null ||
        cameraMovements.isEmpty ||
        resolvedCurrentStep == null) return;
    for (final cameraMovement in cameraMovements) {
      if (cameraMovement == null) continue;
      switch (cameraMovement) {
        case CameraMovement.toProvince:
          final dynamicShapeSource = resolvedCurrentStep.shapeValue;
          Province? resolvedProvince;
          if (dynamicShapeSource is ProvinceCallback) {
            resolvedProvince = dynamicShapeSource();
          }
          if (dynamicShapeSource is Province) {
            resolvedProvince = dynamicShapeSource;
          }
          if (resolvedProvince == null) {
            throw Exception(
              'Province or ProvinceCallback is not supplied with tutorial step',
            );
          }
          game.mapCamera.toProvince(resolvedProvince);

          break;
        case CameraMovement.toPlayerProvinces:
          game.mapCamera.toPlayerProvinces();
          break;
        case CameraMovement.toNationProvinces:
          final dynamicShapeSource = resolvedCurrentStep.shapeValue;
          if (dynamicShapeSource is Nation) {
            game.mapCamera.toNationProvinces(dynamicShapeSource);
          } else {
            throw Exception('Nation is not supplied with tutorial step');
          }
          break;
        case CameraMovement.toRectCenter:
          final maybeRectCallback = resolvedCurrentStep.shapeValue;
          if (maybeRectCallback is RectCallback) {
            final rect = maybeRectCallback();
            game.mapCamera.setPositionBy(
              worldTarget: rect.topLeft.toVector2(),
              align: Alignment.center,
            );
          } else if (maybeRectCallback is Rect) {
            game.mapCamera.setPositionBy(
              worldTarget: maybeRectCallback.topLeft.toVector2(),
              align: Alignment.center,
            );
          } else {
            throw Exception('Province is not supplied with tutorial step');
          }
          break;

        case CameraMovement.zoomIn:
          final zoomScaleFactor = resolvedCurrentStep.zoomScaleFactor;
          game.mapCamera.zoomIn(zoomScaleFactor.toDouble());
          break;
        case CameraMovement.zoomOut:
          final zoomScaleFactor = resolvedCurrentStep.zoomScaleFactor;
          game.mapCamera.zoomOut(zoomScaleFactor.toDouble());
          break;
        default:
      }
    }
  }

  void runPrerenderStepActions() {
    _runCameraActions(cameraMovements: currentStep?.cameraMovements);
  }

  GlobalKey? get globalKey {
    final action = currentStep?.enumAction;
    if (action == null) return null;
    final key = keysMap[action];
    return key;
  }

  HighlightedPath? get highlightedPath {
    final resolvedCurrentStep = currentStep;
    if (resolvedCurrentStep == null) return null;
    final key = globalKey;
    switch (resolvedCurrentStep.pathShape) {
      case HighlightPathShapes.provincePath:
        final dynamicShapeSource = resolvedCurrentStep.shapeValue;

        if (dynamicShapeSource is Province) {
          return HighlightedPath.fromProvince(
            province: dynamicShapeSource,
            game: game,
          );
        } else if (dynamicShapeSource is ProvinceCallback) {
          return HighlightedPath.fromProvince(
            game: game,
            province: dynamicShapeSource(),
          );
        } else if (dynamicShapeSource is RectCallback) {
          return HighlightedPath.fromCampaignRect(
            game: game,
            rect: dynamicShapeSource(),
          );
        } else {
          return null;
        }

      // FIXME: if to make correct svg then it will
      // automatically converts them to path
      // return HighlightedPath.fromProvincePath(province: province);
      case HighlightPathShapes.buttonRect:
        if (key == null) return null;
        return HighlightedPath.fromButtonRectKey(key: key, game: game);
      default:
        return null;
    }
  }

  TutorialOverlayPainter? get painter => TutorialOverlayPainter(
        highlightedPath: highlightedPath,
      );
}
