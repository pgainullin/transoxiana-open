part of 'campaign.dart';

extension CampaignRenderExt on Campaign {
  double get worldWidth =>
      1 *
      (runtimeData.backgroundImage?.width.roundToDouble() ?? 1000.0) /
      mapImageBaseScale;

  double get worldHeight =>
      1 *
      (runtimeData.backgroundImage?.height.roundToDouble() ?? 500.0) /
      mapImageBaseScale;

  void renderRenderBuffer({
    required final Canvas canvas,
    required final List<RenderCallback> buffer,
  }) {
    for (final renderCallback in buffer) {
      renderCallback(canvas);
    }
  }
}
