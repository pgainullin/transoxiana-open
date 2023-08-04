part of game;

/// This class is separated to several extensions to make it easier to
/// debug the methods and have clean code
///
/// Camera Flame docs:
/// https://github.com/flame-engine/flame/blob/1.0.0-releasecandidate.11/doc/camera_and_viewport.md
class MapCamera implements GameRef {
  MapCamera({required this.viewportResolution});
  final Vector2 viewportResolution;

  @override
  late TransoxianaGame game;
  void setLateParams({required final TransoxianaGame game}) {
    this.game = game;
    zoom = game.camera.zoom;
  }

  /// Transformed and scaled world top left position of camera
  ///
  /// do not change this position directly. use [setPosition]
  Vector2 scaledWorldPosition = Vector2.zero();

  // ignore: prefer_final_fields
  Vector2 _savedScaledWorldPosition = Vector2.zero();

  /// Lock for the [_savedScaledWorldPosition] to ensure that save location
  /// will not be called twice.
  // ignore: prefer_final_fields
  bool _isSavingScaledWorldPositionLocked = false;

  Vector2 velocity = Vector2.zero();
  double lastZoom = 0;
  Vector2 lastZoomPosition = Vector2.zero();
  Vector2 finalZoomPosition = Vector2.zero();

  // *****  DEBUG START ******
  /// Never modify directly. Use [setPointerInfo]
  PositionInfo? pointerInfo;

  /// Name of pointer like TapDown, DragStart etc
  /// Never modify directly. Use [setPointerInfo]
  String pointerName = '';
  void setPointerInfo({required final String name, final PositionInfo? info}) {
    pointerInfo = info;
    pointerName = name;
  }

  RawKeyEvent? keyEvent;
  // *****  DEBUG END ******

  Camera get camera => game.camera;

  // ******** ZOOM START *********
  /// Cached zoom to have reactivity for debugging
  // ignore: prefer_final_fields
  double _zoomCache = 1.0;
  double minZoomLimit = UiSizes.minCampaignZoom;
  double maxZoomLimit = UiSizes.maxCampaignZoom;
  // ******** ZOOM END *********

}
