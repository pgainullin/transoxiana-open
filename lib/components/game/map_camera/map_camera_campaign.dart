part of game;

extension MapCameraCampaignExt on MapCamera {
  /// Returns unscaled world rect
  Rect getWorldOfRects({
    required final Iterable<Rect> rects,
  }) {
    final worldBounds = camera.worldBounds!;

    /// Max to min search params
    double left = worldBounds.right;
    double top = worldBounds.bottom;

    /// min to max search params
    double right = worldBounds.left;
    double bottom = worldBounds.top;

    for (final rect in rects) {
      /// Max to min search params
      if (rect.top < top) {
        top = rect.top;
      }
      if (rect.left < left) {
        left = rect.left;
      }

      /// min to max search params
      if (rect.right > right) {
        right = rect.right;
      }
      if (rect.bottom > bottom) {
        bottom = rect.bottom;
      }
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  /// {@template only_for_campaign}
  /// Works only in campaign
  /// {@endtemplate}
  ///
  /// Centers camera to center of provinces
  void toProvinces(final Iterable<Province> provinces) {
    final worldTarget = getWorldOfRects(
      rects: provinces.map((final e) => e.touchRect),
    ).center.toVector2();
    setPositionBy(
      worldTarget: worldTarget,
      align: Alignment.center,
      useSmoothMovement: true,
    );
  }

  void toPlayerProvinces() {
    final provinces = game.player?.getProvinces() ?? [];
    if (provinces.isEmpty) return;
    toProvinces(provinces);
  }

  /// {@macro only_for_campaign}
  void toProvince(final Province province) {
    // setCinemaCameraSpeed();
    setPositionBy(
      worldTarget: province.center,
      align: Alignment.center,
      useSmoothMovement: true,
    );
  }

  /// {@macro only_for_campaign}
  ///
  /// Centers camera to center of nation provinces
  void toNationProvinces(final Nation nation) =>
      toProvinces(nation.getProvinces());

  /// {@macro only_for_campaign}
  void toArmy(final Army army) {
    final location = army.location;
    if (location != null) toProvince(location);
  }
}
