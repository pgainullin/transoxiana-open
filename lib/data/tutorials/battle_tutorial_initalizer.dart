part of 'battle_tutorial.dart';

/// add non-UI and non-event based Battle Tutorial steps
void initializeBattleInFortTutorial({
  required final TransoxianaGame game,
}) {
  //existing UI items will go first

  final walledNodes = game.activeBattle!.nodes
      .where((final element) => element.fortificationSegment != null);

  final double top = walledNodes.fold(
    0.0,
    (
      final value,
      final element,
    ) =>
        game.activeBattle!.tileData[element.terrainTile]!.center!.y < value
            ? game.activeBattle!.tileData[element.terrainTile]!.center!.y
            : value,
  );

  final double bottom = walledNodes.fold(
    0.0,
    (
      final value,
      final element,
    ) =>
        game.activeBattle!.tileData[element.terrainTile]!.center!.y > value
            ? game.activeBattle!.tileData[element.terrainTile]!.center!.y
            : value,
  );

  final double left = walledNodes.fold(
    0.0,
    (
      final value,
      final element,
    ) =>
        game.activeBattle!.tileData[element.terrainTile]!.center!.x < value
            ? game.activeBattle!.tileData[element.terrainTile]!.center!.x
            : value,
  );
  final double right = walledNodes.fold(
    0.0,
    (
      final value,
      final element,
    ) =>
        game.activeBattle!.tileData[element.terrainTile]!.center!.x > value
            ? game.activeBattle!.tileData[element.terrainTile]!.center!.x
            : value,
  );

  final Rect fortRect = Rect.fromLTRB(
    left,
    top,
    right,
    bottom,
  ).inflate(
    game.activeBattle!.tileData[walledNodes.first.terrainTile]!
        .collisionDiameter!,
  );

  //last item
  game.tutorialStateService.state
    ..pushTutorialStep(
      tutorialStep: TutorialStep.fromStaticJson(
        json: BattleIntroTutorialActionsSteps.current.fortifications1.json,
      ).copyWith(
        shapeValue: fortRect,
        isCloseButtonVisible: true,
      ),
    )
    ..pushTutorialStep(
      tutorialStep: TutorialStep.fromStaticJson(
        json: BattleIntroTutorialActionsSteps.current.fortifications2.json,
      ).copyWith(
        shapeValue: fortRect,
        isCloseButtonVisible: true,
      ),
    )
    ..reorderSteps()
    ..recalculatePointers();
  game.tutorialStateService.notify();
}
