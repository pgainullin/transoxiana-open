part of game;

extension MapCameraZoomExt on MapCamera {
  double get zoom => _zoomCache;
  set zoom(final double value) {
    _zoomCache = value;
    camera.zoom = value;
  }

  void setCampaignZoomLimits() {
    minZoomLimit = UiSizes.minCampaignZoom;
    maxZoomLimit = UiSizes.maxCampaignZoom;
  }

  void setBattleZoomLimits() {
    minZoomLimit = UiSizes.minBattleZoom;
    maxZoomLimit = UiSizes.maxBattleZoom;
  }

  void setMaxZoom() => setZoom(maxZoomLimit);
  void setMinZoom() => setZoom(minZoomLimit);
  void setZoom(
    final double value, {
    final Vector2? targetScreenPosition,
  }) {
    final resolvedZoom = value.clamp(minZoomLimit, maxZoomLimit);
    if (value == zoom || resolvedZoom == zoom) return;
    final oldScreenTarget = targetScreenPosition ?? _screenCenter;
    final oldWorldTarget = camera.screenToWorld(oldScreenTarget);
    zoom = resolvedZoom;
    scaledWorldPosition
      ..x = camera.position.x
      ..y = camera.position.y;
    if (oldWorldTarget.isZero()) return;
    final newScreenTarget = camera.worldToScreen(oldWorldTarget);
    final screenTargetDelta = newScreenTarget - oldScreenTarget;
    if (screenTargetDelta.isZero()) return;
    setPosition(
      (final position) => position..add(screenTargetDelta / zoom),
    );
  }

  Vector2 get _screenCenter =>
      Vector2(game.canvasSize.x / 2, game.canvasSize.y / 2);

  void setPositionBy({
    required final Vector2 worldTarget,
    final Alignment align = Alignment.topLeft,
    final bool useSmoothMovement = false,
  }) {
    final target = worldTarget.clone();
    if (align == Alignment.topLeft) {
      /// nothing to do, because by default camera will use top left position
    } else if (align == Alignment.center) {
      target.sub(camera.unscaleVector(_screenCenter));
    } else {
      throw UnimplementedError();
    }
    setPosition(
      (final position) => position..setFrom(target),
      useSmoothMovement: useSmoothMovement,
    );
  }

  void zoomIn([final double? scaleStep]) {
    double zoom = camera.zoom;
    if (scaleStep != null) {
      zoom = camera.zoom * scaleStep;
    } else {
      zoom = camera.zoom + UiSizes.zoomStep;
    }
    setZoom(zoom);
  }

  void zoomOut([final double? scaleStep]) {
    double zoom = camera.zoom;
    if (scaleStep != null) {
      zoom = camera.zoom / scaleStep;
    } else {
      zoom = camera.zoom - UiSizes.zoomStep;
    }
    setZoom(zoom);
  }
}
