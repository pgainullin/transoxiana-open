part of game;

extension MapCameraBattleExt on MapCamera {
  /// {@template only_for_battle}
  /// Works only in battle
  /// {@endtemplate}
  void toTilesByInfo(final Iterable<TileInfo> tilesInfos) {
    final worldTarget = getWorldOfRects(
      rects: tilesInfos
          .where((final node) => node.dstRect != null)
          .map((final e) => e.dstRect!),
    ).center.toVector2();
    setPositionBy(
      worldTarget: worldTarget,
      align: Alignment.center,
      useSmoothMovement: true,
    );
  }

  /// {@macro only_for_battle}
  void toTileByInfo(final TileInfo tileInfo) {
    final tileCenter = tileInfo.dstRect?.center.toVector2();
    if (tileCenter == null) return;
    setPositionBy(
      worldTarget: tileCenter,
      align: Alignment.center,
      useSmoothMovement: true,
    );
  }

  /// {@macro only_for_battle}
  void toUnit(final Unit unit) {
    final locationInfo = unit.locationInfo;
    if (locationInfo != null) toTileByInfo(locationInfo);
  }

  /// {@macro only_for_battle}
  void toUnits(final Iterable<Unit> units) {
    final worldTarget = getWorldOfRects(
      rects: units
          .where((final unit) => unit.location != null)
          .map((final e) => e.locationInfo!.dstRect!),
    ).center.toVector2();
    setPositionBy(
      worldTarget: worldTarget,
      align: Alignment.center,
      useSmoothMovement: true,
    );
  }

  /// {@macro only_for_battle}
  void toPlayerUnits() {
    final playerUnits = game.activeBattle?.units
        .where((final element) => element.nation == game.player);
    if (playerUnits == null || playerUnits.isEmpty) return;
    game.mapCamera.toUnits(playerUnits);
  }
}
