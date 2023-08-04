// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$UiPersistentFormFactors {
  WidthFormFactor get width => throw _privateConstructorUsedError;
  DeviceWindowFormFactor get deviceWindow => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UiPersistentFormFactorsCopyWith<UiPersistentFormFactors> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UiPersistentFormFactorsCopyWith<$Res> {
  factory $UiPersistentFormFactorsCopyWith(UiPersistentFormFactors value,
          $Res Function(UiPersistentFormFactors) then) =
      _$UiPersistentFormFactorsCopyWithImpl<$Res, UiPersistentFormFactors>;
  @useResult
  $Res call({WidthFormFactor width, DeviceWindowFormFactor deviceWindow});
}

/// @nodoc
class _$UiPersistentFormFactorsCopyWithImpl<$Res,
        $Val extends UiPersistentFormFactors>
    implements $UiPersistentFormFactorsCopyWith<$Res> {
  _$UiPersistentFormFactorsCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? deviceWindow = null,
  }) {
    return _then(_value.copyWith(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as WidthFormFactor,
      deviceWindow: null == deviceWindow
          ? _value.deviceWindow
          : deviceWindow // ignore: cast_nullable_to_non_nullable
              as DeviceWindowFormFactor,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_UiPersistentFormFactorsCopyWith<$Res>
    implements $UiPersistentFormFactorsCopyWith<$Res> {
  factory _$$_UiPersistentFormFactorsCopyWith(_$_UiPersistentFormFactors value,
          $Res Function(_$_UiPersistentFormFactors) then) =
      __$$_UiPersistentFormFactorsCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({WidthFormFactor width, DeviceWindowFormFactor deviceWindow});
}

/// @nodoc
class __$$_UiPersistentFormFactorsCopyWithImpl<$Res>
    extends _$UiPersistentFormFactorsCopyWithImpl<$Res,
        _$_UiPersistentFormFactors>
    implements _$$_UiPersistentFormFactorsCopyWith<$Res> {
  __$$_UiPersistentFormFactorsCopyWithImpl(_$_UiPersistentFormFactors _value,
      $Res Function(_$_UiPersistentFormFactors) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? width = null,
    Object? deviceWindow = null,
  }) {
    return _then(_$_UiPersistentFormFactors(
      width: null == width
          ? _value.width
          : width // ignore: cast_nullable_to_non_nullable
              as WidthFormFactor,
      deviceWindow: null == deviceWindow
          ? _value.deviceWindow
          : deviceWindow // ignore: cast_nullable_to_non_nullable
              as DeviceWindowFormFactor,
    ));
  }
}

/// @nodoc

class _$_UiPersistentFormFactors extends _UiPersistentFormFactors
    with DiagnosticableTreeMixin {
  const _$_UiPersistentFormFactors(
      {required this.width, required this.deviceWindow})
      : super._();

  @override
  final WidthFormFactor width;
  @override
  final DeviceWindowFormFactor deviceWindow;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'UiPersistentFormFactors(width: $width, deviceWindow: $deviceWindow)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'UiPersistentFormFactors'))
      ..add(DiagnosticsProperty('width', width))
      ..add(DiagnosticsProperty('deviceWindow', deviceWindow));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_UiPersistentFormFactors &&
            (identical(other.width, width) || other.width == width) &&
            (identical(other.deviceWindow, deviceWindow) ||
                other.deviceWindow == deviceWindow));
  }

  @override
  int get hashCode => Object.hash(runtimeType, width, deviceWindow);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_UiPersistentFormFactorsCopyWith<_$_UiPersistentFormFactors>
      get copyWith =>
          __$$_UiPersistentFormFactorsCopyWithImpl<_$_UiPersistentFormFactors>(
              this, _$identity);
}

abstract class _UiPersistentFormFactors extends UiPersistentFormFactors {
  const factory _UiPersistentFormFactors(
          {required final WidthFormFactor width,
          required final DeviceWindowFormFactor deviceWindow}) =
      _$_UiPersistentFormFactors;
  const _UiPersistentFormFactors._() : super._();

  @override
  WidthFormFactor get width;
  @override
  DeviceWindowFormFactor get deviceWindow;
  @override
  @JsonKey(ignore: true)
  _$$_UiPersistentFormFactorsCopyWith<_$_UiPersistentFormFactors>
      get copyWith => throw _privateConstructorUsedError;
}

RawTutorialStep _$RawTutorialStepFromJson(Map<String, dynamic> json) {
  return _RawTutorialStep.fromJson(json);
}

/// @nodoc
mixin _$RawTutorialStep {
  String get title => throw _privateConstructorUsedError;
  String get description => throw _privateConstructorUsedError;
  String get tutorialMode => throw _privateConstructorUsedError;
  String get alignment => throw _privateConstructorUsedError;
  String get mobileAlignment => throw _privateConstructorUsedError;
  String get enumAction => throw _privateConstructorUsedError;
  bool get isBackButtonVisible => throw _privateConstructorUsedError;
  bool get isCloseButtonVisible => throw _privateConstructorUsedError;
  bool get isNextButtonVisible => throw _privateConstructorUsedError;
  String get pathShape => throw _privateConstructorUsedError;
  String get svgSrc => throw _privateConstructorUsedError;
  List<String> get cameraMovements => throw _privateConstructorUsedError;
  num get zoomScaleFactor => throw _privateConstructorUsedError;
  bool? get alignToScreen => throw _privateConstructorUsedError;
  int? get order => throw _privateConstructorUsedError;
  bool get selfRemoveAfterClose => throw _privateConstructorUsedError;
  bool get resetTutorialModePointers => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RawTutorialStepCopyWith<RawTutorialStep> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RawTutorialStepCopyWith<$Res> {
  factory $RawTutorialStepCopyWith(
          RawTutorialStep value, $Res Function(RawTutorialStep) then) =
      _$RawTutorialStepCopyWithImpl<$Res, RawTutorialStep>;
  @useResult
  $Res call(
      {String title,
      String description,
      String tutorialMode,
      String alignment,
      String mobileAlignment,
      String enumAction,
      bool isBackButtonVisible,
      bool isCloseButtonVisible,
      bool isNextButtonVisible,
      String pathShape,
      String svgSrc,
      List<String> cameraMovements,
      num zoomScaleFactor,
      bool? alignToScreen,
      int? order,
      bool selfRemoveAfterClose,
      bool resetTutorialModePointers});
}

/// @nodoc
class _$RawTutorialStepCopyWithImpl<$Res, $Val extends RawTutorialStep>
    implements $RawTutorialStepCopyWith<$Res> {
  _$RawTutorialStepCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? tutorialMode = null,
    Object? alignment = null,
    Object? mobileAlignment = null,
    Object? enumAction = null,
    Object? isBackButtonVisible = null,
    Object? isCloseButtonVisible = null,
    Object? isNextButtonVisible = null,
    Object? pathShape = null,
    Object? svgSrc = null,
    Object? cameraMovements = null,
    Object? zoomScaleFactor = null,
    Object? alignToScreen = freezed,
    Object? order = freezed,
    Object? selfRemoveAfterClose = null,
    Object? resetTutorialModePointers = null,
  }) {
    return _then(_value.copyWith(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tutorialMode: null == tutorialMode
          ? _value.tutorialMode
          : tutorialMode // ignore: cast_nullable_to_non_nullable
              as String,
      alignment: null == alignment
          ? _value.alignment
          : alignment // ignore: cast_nullable_to_non_nullable
              as String,
      mobileAlignment: null == mobileAlignment
          ? _value.mobileAlignment
          : mobileAlignment // ignore: cast_nullable_to_non_nullable
              as String,
      enumAction: null == enumAction
          ? _value.enumAction
          : enumAction // ignore: cast_nullable_to_non_nullable
              as String,
      isBackButtonVisible: null == isBackButtonVisible
          ? _value.isBackButtonVisible
          : isBackButtonVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isCloseButtonVisible: null == isCloseButtonVisible
          ? _value.isCloseButtonVisible
          : isCloseButtonVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isNextButtonVisible: null == isNextButtonVisible
          ? _value.isNextButtonVisible
          : isNextButtonVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      pathShape: null == pathShape
          ? _value.pathShape
          : pathShape // ignore: cast_nullable_to_non_nullable
              as String,
      svgSrc: null == svgSrc
          ? _value.svgSrc
          : svgSrc // ignore: cast_nullable_to_non_nullable
              as String,
      cameraMovements: null == cameraMovements
          ? _value.cameraMovements
          : cameraMovements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      zoomScaleFactor: null == zoomScaleFactor
          ? _value.zoomScaleFactor
          : zoomScaleFactor // ignore: cast_nullable_to_non_nullable
              as num,
      alignToScreen: freezed == alignToScreen
          ? _value.alignToScreen
          : alignToScreen // ignore: cast_nullable_to_non_nullable
              as bool?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
      selfRemoveAfterClose: null == selfRemoveAfterClose
          ? _value.selfRemoveAfterClose
          : selfRemoveAfterClose // ignore: cast_nullable_to_non_nullable
              as bool,
      resetTutorialModePointers: null == resetTutorialModePointers
          ? _value.resetTutorialModePointers
          : resetTutorialModePointers // ignore: cast_nullable_to_non_nullable
              as bool,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$_RawTutorialStepCopyWith<$Res>
    implements $RawTutorialStepCopyWith<$Res> {
  factory _$$_RawTutorialStepCopyWith(
          _$_RawTutorialStep value, $Res Function(_$_RawTutorialStep) then) =
      __$$_RawTutorialStepCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String title,
      String description,
      String tutorialMode,
      String alignment,
      String mobileAlignment,
      String enumAction,
      bool isBackButtonVisible,
      bool isCloseButtonVisible,
      bool isNextButtonVisible,
      String pathShape,
      String svgSrc,
      List<String> cameraMovements,
      num zoomScaleFactor,
      bool? alignToScreen,
      int? order,
      bool selfRemoveAfterClose,
      bool resetTutorialModePointers});
}

/// @nodoc
class __$$_RawTutorialStepCopyWithImpl<$Res>
    extends _$RawTutorialStepCopyWithImpl<$Res, _$_RawTutorialStep>
    implements _$$_RawTutorialStepCopyWith<$Res> {
  __$$_RawTutorialStepCopyWithImpl(
      _$_RawTutorialStep _value, $Res Function(_$_RawTutorialStep) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? title = null,
    Object? description = null,
    Object? tutorialMode = null,
    Object? alignment = null,
    Object? mobileAlignment = null,
    Object? enumAction = null,
    Object? isBackButtonVisible = null,
    Object? isCloseButtonVisible = null,
    Object? isNextButtonVisible = null,
    Object? pathShape = null,
    Object? svgSrc = null,
    Object? cameraMovements = null,
    Object? zoomScaleFactor = null,
    Object? alignToScreen = freezed,
    Object? order = freezed,
    Object? selfRemoveAfterClose = null,
    Object? resetTutorialModePointers = null,
  }) {
    return _then(_$_RawTutorialStep(
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: null == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String,
      tutorialMode: null == tutorialMode
          ? _value.tutorialMode
          : tutorialMode // ignore: cast_nullable_to_non_nullable
              as String,
      alignment: null == alignment
          ? _value.alignment
          : alignment // ignore: cast_nullable_to_non_nullable
              as String,
      mobileAlignment: null == mobileAlignment
          ? _value.mobileAlignment
          : mobileAlignment // ignore: cast_nullable_to_non_nullable
              as String,
      enumAction: null == enumAction
          ? _value.enumAction
          : enumAction // ignore: cast_nullable_to_non_nullable
              as String,
      isBackButtonVisible: null == isBackButtonVisible
          ? _value.isBackButtonVisible
          : isBackButtonVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isCloseButtonVisible: null == isCloseButtonVisible
          ? _value.isCloseButtonVisible
          : isCloseButtonVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      isNextButtonVisible: null == isNextButtonVisible
          ? _value.isNextButtonVisible
          : isNextButtonVisible // ignore: cast_nullable_to_non_nullable
              as bool,
      pathShape: null == pathShape
          ? _value.pathShape
          : pathShape // ignore: cast_nullable_to_non_nullable
              as String,
      svgSrc: null == svgSrc
          ? _value.svgSrc
          : svgSrc // ignore: cast_nullable_to_non_nullable
              as String,
      cameraMovements: null == cameraMovements
          ? _value._cameraMovements
          : cameraMovements // ignore: cast_nullable_to_non_nullable
              as List<String>,
      zoomScaleFactor: null == zoomScaleFactor
          ? _value.zoomScaleFactor
          : zoomScaleFactor // ignore: cast_nullable_to_non_nullable
              as num,
      alignToScreen: freezed == alignToScreen
          ? _value.alignToScreen
          : alignToScreen // ignore: cast_nullable_to_non_nullable
              as bool?,
      order: freezed == order
          ? _value.order
          : order // ignore: cast_nullable_to_non_nullable
              as int?,
      selfRemoveAfterClose: null == selfRemoveAfterClose
          ? _value.selfRemoveAfterClose
          : selfRemoveAfterClose // ignore: cast_nullable_to_non_nullable
              as bool,
      resetTutorialModePointers: null == resetTutorialModePointers
          ? _value.resetTutorialModePointers
          : resetTutorialModePointers // ignore: cast_nullable_to_non_nullable
              as bool,
    ));
  }
}

/// @nodoc

@JsonSerializable(explicitToJson: true)
class _$_RawTutorialStep extends _RawTutorialStep with DiagnosticableTreeMixin {
  const _$_RawTutorialStep(
      {this.title = '',
      this.description = '',
      this.tutorialMode = '',
      this.alignment = '',
      this.mobileAlignment = '',
      this.enumAction = '',
      this.isBackButtonVisible = _defaultIsBackButtonVisible,
      this.isCloseButtonVisible = _defaultIsCloseButtonVisible,
      this.isNextButtonVisible = _defaultIsNextButtonVisible,
      this.pathShape = '',
      this.svgSrc = '',
      final List<String> cameraMovements = const [],
      this.zoomScaleFactor = _defaultZoomScaleFactor,
      this.alignToScreen,
      this.order,
      this.selfRemoveAfterClose = _defaultSelfRemoveAfterClose,
      this.resetTutorialModePointers = _defaultResetTutorialModePointers})
      : _cameraMovements = cameraMovements,
        super._();

  factory _$_RawTutorialStep.fromJson(Map<String, dynamic> json) =>
      _$$_RawTutorialStepFromJson(json);

  @override
  @JsonKey()
  final String title;
  @override
  @JsonKey()
  final String description;
  @override
  @JsonKey()
  final String tutorialMode;
  @override
  @JsonKey()
  final String alignment;
  @override
  @JsonKey()
  final String mobileAlignment;
  @override
  @JsonKey()
  final String enumAction;
  @override
  @JsonKey()
  final bool isBackButtonVisible;
  @override
  @JsonKey()
  final bool isCloseButtonVisible;
  @override
  @JsonKey()
  final bool isNextButtonVisible;
  @override
  @JsonKey()
  final String pathShape;
  @override
  @JsonKey()
  final String svgSrc;
  final List<String> _cameraMovements;
  @override
  @JsonKey()
  List<String> get cameraMovements {
    if (_cameraMovements is EqualUnmodifiableListView) return _cameraMovements;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_cameraMovements);
  }

  @override
  @JsonKey()
  final num zoomScaleFactor;
  @override
  final bool? alignToScreen;
  @override
  final int? order;
  @override
  @JsonKey()
  final bool selfRemoveAfterClose;
  @override
  @JsonKey()
  final bool resetTutorialModePointers;

  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return 'RawTutorialStep(title: $title, description: $description, tutorialMode: $tutorialMode, alignment: $alignment, mobileAlignment: $mobileAlignment, enumAction: $enumAction, isBackButtonVisible: $isBackButtonVisible, isCloseButtonVisible: $isCloseButtonVisible, isNextButtonVisible: $isNextButtonVisible, pathShape: $pathShape, svgSrc: $svgSrc, cameraMovements: $cameraMovements, zoomScaleFactor: $zoomScaleFactor, alignToScreen: $alignToScreen, order: $order, selfRemoveAfterClose: $selfRemoveAfterClose, resetTutorialModePointers: $resetTutorialModePointers)';
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
      ..add(DiagnosticsProperty('type', 'RawTutorialStep'))
      ..add(DiagnosticsProperty('title', title))
      ..add(DiagnosticsProperty('description', description))
      ..add(DiagnosticsProperty('tutorialMode', tutorialMode))
      ..add(DiagnosticsProperty('alignment', alignment))
      ..add(DiagnosticsProperty('mobileAlignment', mobileAlignment))
      ..add(DiagnosticsProperty('enumAction', enumAction))
      ..add(DiagnosticsProperty('isBackButtonVisible', isBackButtonVisible))
      ..add(DiagnosticsProperty('isCloseButtonVisible', isCloseButtonVisible))
      ..add(DiagnosticsProperty('isNextButtonVisible', isNextButtonVisible))
      ..add(DiagnosticsProperty('pathShape', pathShape))
      ..add(DiagnosticsProperty('svgSrc', svgSrc))
      ..add(DiagnosticsProperty('cameraMovements', cameraMovements))
      ..add(DiagnosticsProperty('zoomScaleFactor', zoomScaleFactor))
      ..add(DiagnosticsProperty('alignToScreen', alignToScreen))
      ..add(DiagnosticsProperty('order', order))
      ..add(DiagnosticsProperty('selfRemoveAfterClose', selfRemoveAfterClose))
      ..add(DiagnosticsProperty(
          'resetTutorialModePointers', resetTutorialModePointers));
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$_RawTutorialStep &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.tutorialMode, tutorialMode) ||
                other.tutorialMode == tutorialMode) &&
            (identical(other.alignment, alignment) ||
                other.alignment == alignment) &&
            (identical(other.mobileAlignment, mobileAlignment) ||
                other.mobileAlignment == mobileAlignment) &&
            (identical(other.enumAction, enumAction) ||
                other.enumAction == enumAction) &&
            (identical(other.isBackButtonVisible, isBackButtonVisible) ||
                other.isBackButtonVisible == isBackButtonVisible) &&
            (identical(other.isCloseButtonVisible, isCloseButtonVisible) ||
                other.isCloseButtonVisible == isCloseButtonVisible) &&
            (identical(other.isNextButtonVisible, isNextButtonVisible) ||
                other.isNextButtonVisible == isNextButtonVisible) &&
            (identical(other.pathShape, pathShape) ||
                other.pathShape == pathShape) &&
            (identical(other.svgSrc, svgSrc) || other.svgSrc == svgSrc) &&
            const DeepCollectionEquality()
                .equals(other._cameraMovements, _cameraMovements) &&
            (identical(other.zoomScaleFactor, zoomScaleFactor) ||
                other.zoomScaleFactor == zoomScaleFactor) &&
            (identical(other.alignToScreen, alignToScreen) ||
                other.alignToScreen == alignToScreen) &&
            (identical(other.order, order) || other.order == order) &&
            (identical(other.selfRemoveAfterClose, selfRemoveAfterClose) ||
                other.selfRemoveAfterClose == selfRemoveAfterClose) &&
            (identical(other.resetTutorialModePointers,
                    resetTutorialModePointers) ||
                other.resetTutorialModePointers == resetTutorialModePointers));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      title,
      description,
      tutorialMode,
      alignment,
      mobileAlignment,
      enumAction,
      isBackButtonVisible,
      isCloseButtonVisible,
      isNextButtonVisible,
      pathShape,
      svgSrc,
      const DeepCollectionEquality().hash(_cameraMovements),
      zoomScaleFactor,
      alignToScreen,
      order,
      selfRemoveAfterClose,
      resetTutorialModePointers);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$_RawTutorialStepCopyWith<_$_RawTutorialStep> get copyWith =>
      __$$_RawTutorialStepCopyWithImpl<_$_RawTutorialStep>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$_RawTutorialStepToJson(
      this,
    );
  }
}

abstract class _RawTutorialStep extends RawTutorialStep {
  const factory _RawTutorialStep(
      {final String title,
      final String description,
      final String tutorialMode,
      final String alignment,
      final String mobileAlignment,
      final String enumAction,
      final bool isBackButtonVisible,
      final bool isCloseButtonVisible,
      final bool isNextButtonVisible,
      final String pathShape,
      final String svgSrc,
      final List<String> cameraMovements,
      final num zoomScaleFactor,
      final bool? alignToScreen,
      final int? order,
      final bool selfRemoveAfterClose,
      final bool resetTutorialModePointers}) = _$_RawTutorialStep;
  const _RawTutorialStep._() : super._();

  factory _RawTutorialStep.fromJson(Map<String, dynamic> json) =
      _$_RawTutorialStep.fromJson;

  @override
  String get title;
  @override
  String get description;
  @override
  String get tutorialMode;
  @override
  String get alignment;
  @override
  String get mobileAlignment;
  @override
  String get enumAction;
  @override
  bool get isBackButtonVisible;
  @override
  bool get isCloseButtonVisible;
  @override
  bool get isNextButtonVisible;
  @override
  String get pathShape;
  @override
  String get svgSrc;
  @override
  List<String> get cameraMovements;
  @override
  num get zoomScaleFactor;
  @override
  bool? get alignToScreen;
  @override
  int? get order;
  @override
  bool get selfRemoveAfterClose;
  @override
  bool get resetTutorialModePointers;
  @override
  @JsonKey(ignore: true)
  _$$_RawTutorialStepCopyWith<_$_RawTutorialStep> get copyWith =>
      throw _privateConstructorUsedError;
}
