part of 'models.dart';

@immutable
@Freezed(
  fromJson: true,
  toJson: true,
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class RawTutorialStep with _$RawTutorialStep {
  // ignore: invalid_annotation_target
  @JsonSerializable(
    explicitToJson: true,
  )
  const factory RawTutorialStep({
    @Default('') final String title,
    @Default('') final String description,
    @Default('') final String tutorialMode,
    @Default('') final String alignment,
    @Default('') final String mobileAlignment,
    @Default('') final String enumAction,
    @Default(_defaultIsBackButtonVisible) final bool isBackButtonVisible,
    @Default(_defaultIsCloseButtonVisible) final bool isCloseButtonVisible,
    @Default(_defaultIsNextButtonVisible) final bool isNextButtonVisible,
    @Default('') final String pathShape,
    @Default('') final String svgSrc,
    @Default([]) final List<String> cameraMovements,
    @Default(_defaultZoomScaleFactor) final num zoomScaleFactor,
    final bool? alignToScreen,
    final int? order,
    @Default(_defaultSelfRemoveAfterClose) final bool selfRemoveAfterClose,
    @Default(_defaultResetTutorialModePointers)
        final bool resetTutorialModePointers,
  }) = _RawTutorialStep;

  const RawTutorialStep._();

  factory RawTutorialStep.fromJson(final Map<String, dynamic> json) =>
      _$RawTutorialStepFromJson(json);
}
