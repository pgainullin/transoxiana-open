part of game;

mixin _GameDimensionsMixin on _TransoxianaGameLateState {
  // double get battleMaxWidth =>
  //     campaignRuntimeData.activeBattle?.hexTiledComponent.maxWidth ??
  //     UiSizes.maxWorldSize;
  double get campaignMaxWidth => campaign?.worldWidth ?? UiSizes.maxWorldSize;

  // double get battleMaxHeight =>
  //     campaignRuntimeData.activeBattle?.hexTiledComponent.maxHeight ??
  //     UiSizes.maxWorldSize;
  double get campaignMaxHeight => campaign?.worldHeight ?? UiSizes.maxWorldSize;

  // Offset get battleBoundaryOffset => Offset(
  //       battleMaxWidth,
  //       battleMaxHeight,
  //     );
  Offset get campaignBoundaryOffset => Offset(
        campaignMaxWidth,
        campaignMaxHeight,
      );

  // Rect get battleScaledConstraints => Rect.fromLTRB(
  //       -UiSizes.tileSize * camera.zoom,
  //       -UiSizes.tileSize * camera.zoom,
  //       battleMaxWidth + (UiSizes.tileSize * camera.zoom),
  //       battleMaxHeight + (UiSizes.tileSize * camera.zoom),
  //     );

  // Rect get battleBounds => Rect.fromLTRB(
  //       0,
  //       0,
  //       battleMaxWidth,
  //       battleMaxHeight,
  //     );

  Rect get campaignWorldBounds => Rect.fromLTRB(
        0,
        0,
        campaignMaxWidth,
        campaignMaxHeight,
      );
}
