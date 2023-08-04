// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$_RawTutorialStep _$$_RawTutorialStepFromJson(Map<String, dynamic> json) =>
    _$_RawTutorialStep(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      tutorialMode: json['tutorialMode'] as String? ?? '',
      alignment: json['alignment'] as String? ?? '',
      mobileAlignment: json['mobileAlignment'] as String? ?? '',
      enumAction: json['enumAction'] as String? ?? '',
      isBackButtonVisible:
          json['isBackButtonVisible'] as bool? ?? _defaultIsBackButtonVisible,
      isCloseButtonVisible:
          json['isCloseButtonVisible'] as bool? ?? _defaultIsCloseButtonVisible,
      isNextButtonVisible:
          json['isNextButtonVisible'] as bool? ?? _defaultIsNextButtonVisible,
      pathShape: json['pathShape'] as String? ?? '',
      svgSrc: json['svgSrc'] as String? ?? '',
      cameraMovements: (json['cameraMovements'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
      zoomScaleFactor:
          json['zoomScaleFactor'] as num? ?? _defaultZoomScaleFactor,
      alignToScreen: json['alignToScreen'] as bool?,
      order: json['order'] as int?,
      selfRemoveAfterClose:
          json['selfRemoveAfterClose'] as bool? ?? _defaultSelfRemoveAfterClose,
      resetTutorialModePointers: json['resetTutorialModePointers'] as bool? ??
          _defaultResetTutorialModePointers,
    );

Map<String, dynamic> _$$_RawTutorialStepToJson(_$_RawTutorialStep instance) =>
    <String, dynamic>{
      'title': instance.title,
      'description': instance.description,
      'tutorialMode': instance.tutorialMode,
      'alignment': instance.alignment,
      'mobileAlignment': instance.mobileAlignment,
      'enumAction': instance.enumAction,
      'isBackButtonVisible': instance.isBackButtonVisible,
      'isCloseButtonVisible': instance.isCloseButtonVisible,
      'isNextButtonVisible': instance.isNextButtonVisible,
      'pathShape': instance.pathShape,
      'svgSrc': instance.svgSrc,
      'cameraMovements': instance.cameraMovements,
      'zoomScaleFactor': instance.zoomScaleFactor,
      'alignToScreen': instance.alignToScreen,
      'order': instance.order,
      'selfRemoveAfterClose': instance.selfRemoveAfterClose,
      'resetTutorialModePointers': instance.resetTutorialModePointers,
    };
