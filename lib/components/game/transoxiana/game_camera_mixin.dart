part of game;

bool get isDesktop {
  switch (defaultTargetPlatform) {
    case TargetPlatform.iOS:
    case TargetPlatform.android:
      return false;
    default:
      return true;
  }
}

mixin _GameCameraMixin on _TransoxianaGameLateState {
  @override
  void onTapDown(final TapDownInfo info) {
    super.onTapDown(info);
    mapCamera.setPointerInfo(name: 'onTapDown', info: info);
    if (activeBattle != null) {
      activeBattle?.onTap(info);
    } else {
      campaign?.onTap(info);
    }
    _mapCameraService.notify();
  }

  Offset startFocalPoint = Offset.zero;
  @override
  void onScaleStart(final ScaleStartInfo info) {
    startFocalPoint = info.raw.focalPoint;
    mapCamera.setPointerInfo(name: 'onScaleStart', info: info);
    mapCamera.lastZoomPosition = mapCamera.scaledWorldPosition.clone();
  }

  @override
  void onScaleUpdate(final ScaleUpdateInfo info) {
    mapCamera.setPointerInfo(name: 'onScaleUpdate', info: info);
    void _drag() {
      final delta =
          (startFocalPoint - info.eventPosition.widget.toOffset()).toVector2();
      final scaledDelta = mapCamera.camera.unscaleVector(delta);
      // final delta =
      // mapCamera.camera.projectVector(info.raw.focalPointDelta.toVector2());
      final newPosition = mapCamera.lastZoomPosition.clone()..add(scaledDelta);
      // mapCamera.camera.snapTo(newPosition);
      mapCamera.finalZoomPosition = newPosition.clone();
      mapCamera.setPosition((final position) => newPosition);
    }

    if (!isDesktop) {
      final isScale = info.pointerCount > 1;
      if (isScale) {
        double lastScale = mapCamera.lastZoom;

        void _scale() {
          final newZoom = camera.zoom + (UiSizes.zoomStepForTouch * scaleSign);
          mapCamera.setZoom(
            newZoom,
            targetScreenPosition: info.eventPosition.global,
          );
          mapCamera.finalZoomPosition = mapCamera.scaledWorldPosition;
        }

        final scale = info.scale.game.normalize();
        void _setDirection() {
          final delta = lastScale - scale;
          final resolvedDelta = delta == 0 ? camera.zoom - scale : delta;
          scaleSign = resolvedDelta > 0 ? -1 : 1;
        }

        if (scaleCounter == 0) {
          mapCamera.lastZoom = scale;
          lastScale = scale;
          scaleCounter++;
        } else if (scaleCounter == 1) {
          _setDirection();
          scaleCounter++;
        } else {
          _setDirection();

          _scale();
        }
      } else {
        _drag();
      }
    } else {
      _drag();
    }

    mapCameraService.notify();
  }

  int scaleCounter = 0;
  int scaleSign = 1;
  @override
  void onScaleEnd(final ScaleEndInfo info) {
    mapCamera.lastZoom = 0;
    scaleCounter = 0;
    mapCamera.setPointerInfo(name: 'onScaleEnd');
    mapCamera.setPosition((final _) => mapCamera.finalZoomPosition);
    mapCameraService.notify();
  }

  @override

  /// works only in desktop
  /// for touch devices use [onScaleUpdate]
  void onScroll(final PointerScrollInfo info) {
    const xSensitivity = 2;
    final skipScale = info.scrollDelta.game.x > xSensitivity ||
        info.scrollDelta.game.x < -1 * xSensitivity ||
        info.scrollDelta.game.y == 0 ||
        info.scrollDelta.game.y == -0;

    final zoomDelta = () {
      final sign = info.scrollDelta.game.y.sign;
      if (info.raw.original?.kind == PointerDeviceKind.mouse) {
        return -1 * sign * UiSizes.zoomStep;
      } else {
        return sign * UiSizes.zoomPerScrollUnit;
      }
    }();
    final newZoom = camera.zoom + zoomDelta;
    mapCamera.setPointerInfo(name: 'onScroll skipScale:$skipScale', info: info);
    if (!skipScale) {
      mapCamera.setZoom(
        newZoom,
        targetScreenPosition: info.eventPosition.global,
      );
    }
    mapCameraService.notify();
  }

  /// Camera controls.
  @override
  KeyEventResult onKeyEvent(
      final RawKeyEvent event, final Set<LogicalKeyboardKey> keys,) {
    final isKeyDown = event is RawKeyDownEvent;
    void moveAlong({required final AxisDirection direction}) {
      if (isKeyDown) {
        mapCamera.moveAlong(direction: direction);
      } else {
        mapCamera.stopMoveAlong();
      }
    }

    if (event.logicalKey == LogicalKeyboardKey.keyA) {
      moveAlong(direction: AxisDirection.left);
    } else if (event.logicalKey == LogicalKeyboardKey.keyD) {
      moveAlong(direction: AxisDirection.right);
    } else if (event.logicalKey == LogicalKeyboardKey.keyW) {
      moveAlong(direction: AxisDirection.up);
    } else if (event.logicalKey == LogicalKeyboardKey.keyS) {
      moveAlong(direction: AxisDirection.down);
    } else if (isKeyDown) {
      if (event.logicalKey == LogicalKeyboardKey.keyQ) {
        mapCamera.zoomOut();
      } else if (event.logicalKey == LogicalKeyboardKey.keyE) {
        mapCamera.zoomIn();
      }
    }
    mapCameraService.notify();
    return KeyEventResult.handled;
  }
}
