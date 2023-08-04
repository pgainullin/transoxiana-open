part of game;

extension MapCameraMovementsExt on MapCamera {
  void recenter() {
    final center = camera.worldBounds!.center;
    camera.moveTo(center.toVector2());
  }

  void moveAlong({required final AxisDirection direction}) {
    double? targetXVelocity = velocity.x;
    double? targetYVelocity = velocity.y;
    switch (direction) {
      case AxisDirection.down:
        targetYVelocity = UiSizes.maxCameraVelocity;
        break;
      case AxisDirection.up:
        targetYVelocity = -UiSizes.maxCameraVelocity;
        break;
      case AxisDirection.left:
        targetXVelocity = -UiSizes.maxCameraVelocity;
        break;
      case AxisDirection.right:
        targetXVelocity = UiSizes.maxCameraVelocity;
        break;
      default:
    }

    /// keep velocity in allowed range
    final effectiveXVelocity = targetXVelocity.clamp(
      -UiSizes.maxCameraVelocity,
      UiSizes.maxCameraVelocity,
    );
    final effectiveYVelocity = targetYVelocity.clamp(
      -UiSizes.maxCameraVelocity,
      UiSizes.maxCameraVelocity,
    );
    velocity.x = effectiveXVelocity;
    velocity.y = effectiveYVelocity;
  }

  void stopMoveAlong() {
    if (velocity.x != 0) velocity.x = 0;
    if (velocity.y != 0) velocity.y = 0;
  }

  void setCampaignSmoothCameraSpeed() {
    camera.speed = 3000;
  }
}
