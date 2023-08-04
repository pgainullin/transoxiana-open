part of game;

extension MapCameraPositioningExt on MapCamera {
  void setPosition(
    final Vector2 Function(Vector2 position) positionCallback, {
    final bool useSmoothMovement = false,
  }) {
    if (useSmoothMovement) setCampaignSmoothCameraSpeed();
    final attemptedTarget = positionCallback(scaledWorldPosition.clone());
    if (scaledWorldPosition == attemptedTarget) return;
    final target = scaledWorldPosition.clone();
    final bounds = camera.worldBounds;
    final gameSize = camera.gameSize;
    if (bounds == null) {
      throw ArgumentError.notNull('load world bounds in onLoad');
    }
    final viewportWidth = gameSize.x;
    final viewportHeight = gameSize.y;
    if (bounds.width > viewportWidth) {
      final cameraLeftEdge = attemptedTarget.x;
      final cameraRightEdge = attemptedTarget.x + viewportWidth;
      if (cameraLeftEdge < bounds.left) {
        target.x = bounds.left;
      } else if (cameraRightEdge > bounds.right) {
        target.x = bounds.right - viewportWidth;
      } else {
        target.x = cameraLeftEdge;
      }
    } else {
      target.x = (viewportWidth - bounds.width) / 2;
    }

    if (bounds.height > viewportHeight) {
      final cameraTopEdge = attemptedTarget.y;
      final cameraBottomEdge = attemptedTarget.y + viewportHeight;
      if (cameraTopEdge < bounds.top) {
        target.y = bounds.top;
      } else if (cameraBottomEdge > bounds.bottom) {
        target.y = bounds.bottom - viewportHeight;
      } else {
        target.y = cameraTopEdge;
      }
    } else {
      target.y = (viewportHeight - bounds.height) / 2;
    }
    scaledWorldPosition
      ..x = target.x
      ..y = target.y;
    // verify changes
    if (useSmoothMovement) {
      camera.moveTo(scaledWorldPosition);
    } else {
      if (camera.position != scaledWorldPosition) {
        camera.follow = null;
        followPosition();
        camera.snapTo(scaledWorldPosition);
      }
    }
  }

  void followPosition({final Rect? worldBounds}) {
    camera.followVector2(
      scaledWorldPosition,
      relativeOffset: Anchor.topLeft,
      worldBounds: worldBounds,
    );
  }

  void saveCurrentScaledWorldPosition() {
    if (_isSavingScaledWorldPositionLocked) {
      throw StateError(
        'saveCurrentScaledWorldPosition is locked. '
        'Make sure you restored previous position.',
      );
    }

    _savedScaledWorldPosition = scaledWorldPosition.clone();
    _isSavingScaledWorldPositionLocked = true;
  }

  void restoreSavedScaledWorldPosition() {
    setPosition((final position) => _savedScaledWorldPosition);
    _isSavingScaledWorldPositionLocked = false;
  }
}
