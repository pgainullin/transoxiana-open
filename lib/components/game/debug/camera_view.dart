part of game;

class _CameraDebugView extends ReactiveStatelessWidget {
  const _CameraDebugView({required this.game, final Key? key})
      : super(key: key);
  final TransoxianaGame game;
  @override
  Widget build(final BuildContext context) {
    final mapCameraService = game.mapCameraService;
    final mapCamera = game.mapCamera;
    final pointerInfo = mapCamera.pointerInfo;
    final pointerText = _getPointerInfo(
      mapCamera.pointerName,
      pointerInfo,
    );
    final cameraInfo = [
      'game attached: ${game.hasLayout}',
      'game logical size (camera.gameSize): ${game.size}',
      'camera.position: ${mapCamera.camera.position}',
      'camera.worldBounds: ${mapCamera.camera.worldBounds}',
      'mapCamera.scaledWorldPosition: ${mapCamera.scaledWorldPosition}',
      'mapCamera.velocity: ${mapCamera.velocity}',
      'viewportResolution: ${mapCamera.viewportResolution}',
      'camera.zoom: ${mapCamera.camera.zoom} \n',
      'mapCamera.zoom: ${mapCamera.zoom} \n',
    ].join('\n');
    final keyInfo = 'key: ${mapCamera.keyEvent?.character}';
    return ListView(
      primary: false,
      shrinkWrap: true,
      children: [
        Text(
          [
            'Pointer Event info:',
            pointerText,
            'Camera: WASD to move, QE to zoom \n',
            cameraInfo,
            keyInfo
          ].join('\n'),
        ),
        Row(
          children: [
            const Text('zoom'),
            IconButton(
              onPressed: () {
                game.mapCamera.zoomIn();
                mapCameraService.notify();
              },
              icon: const Icon(Icons.add),
            ),
            IconButton(
              onPressed: () {
                game.mapCamera.zoomOut();
                mapCameraService.notify();
              },
              icon: const Icon(Icons.remove),
            ),
            Expanded(
              child: TextFormField(
                initialValue: mapCamera.minZoomLimit.toString(),
                onChanged: (final newVal) {
                  final val = double.tryParse(newVal);
                  if (val != null) {
                    mapCamera.minZoomLimit = val;
                    mapCameraService.notify();
                  }
                },
              ),
            ),
            Expanded(
              child: TextFormField(
                initialValue: mapCamera.maxZoomLimit.toString(),
                onChanged: (final newVal) {
                  final val = double.tryParse(newVal);
                  if (val != null) {
                    mapCamera.maxZoomLimit = val;
                    mapCameraService.notify();
                  }
                },
              ),
            ),
          ],
        )
      ],
    );
  }

  /// Describes generic event information + some event specific details for
  /// some events.
  String _getPointerInfo(final String name, final PositionInfo? info) {
    if (info == null) return '';
    return [
      name,
      'Global: ${info.eventPosition.global}',
      'Widget: ${info.eventPosition.widget}',
      'Game: ${info.eventPosition.game}',
      if (info is DragUpdateInfo) ...[
        'Delta',
        'Global: ${info.delta.global}',
        'Game: ${info.delta.game}',
      ],
      if (info is PointerScrollInfo) ...[
        'Scroll Delta',
        'Global: ${info.scrollDelta.global}',
        'Game: ${info.scrollDelta.game}',
      ],
    ].join('\n');
  }
}
