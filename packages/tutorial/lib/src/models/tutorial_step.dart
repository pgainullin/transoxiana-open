part of 'models.dart';

const _defaultIsCloseButtonVisible = false;
const _defaultIsNextButtonVisible = true;
const _defaultIsBackButtonVisible = false;
const _defaultZoomScaleFactor = 0.0;
const _defaultSelfRemoveAfterClose = false;
const _defaultResetTutorialModePointers = false;

/// Use fields with postfix "str" to load stringified values
/// If no [tutorialMode] is not set, default value
/// will be [TutorialModes.independent]
class TutorialStep<TEnumAction> extends Equatable
    implements Comparable<TutorialStep?> {
  TutorialStep({
    this.title = '',
    this.description = '',
    TEnumAction? enumAction,
    String enumActionStr = '',
    Alignment alignment = Alignment.center,
    String alignmentStr = '',
    String mobileAlignmentStr = '',
    TutorialModes? tutorialMode,
    String tutorialModeStr = '',
    this.svgSrc = '',
    HighlightPathShapes? pathShape,
    String pathShapeStr = '',
    this.isCloseButtonVisible = _defaultIsCloseButtonVisible,
    this.isNextButtonVisible = _defaultIsNextButtonVisible,
    this.isBackButtonVisible = _defaultIsBackButtonVisible,
    this.selfRemoveAfterClose = _defaultSelfRemoveAfterClose,
    this.shapeValue,
    List<CameraMovement?>? cameraMovements,
    List<String>? cameraMovementsStr = const [],
    this.zoomScaleFactor = _defaultZoomScaleFactor,
    this.alignToScreen,
    this.order,
    this.resetTutorialModePointers = _defaultResetTutorialModePointers,
    this.onVerifyNext,
  }) {
    try {
      if (alignmentStr.isEmpty) {
        this.alignment = alignment;
      } else {
        this.alignment = alignmentFromString(alignmentStr);
      }
      if (mobileAlignmentStr.isEmpty) {
        mobileAlignment = this.alignment;
      } else {
        mobileAlignment = alignmentFromString(mobileAlignmentStr);
      }
      if (enumActionStr.isEmpty) {
        if (enumAction == null) throw ArgumentError.notNull('enumAction');
        this.enumAction = enumAction;
      } else {
        this.enumAction = enumActionFromString(enumActionStr);
      }
      if (pathShapeStr.isEmpty) {
        this.pathShape = pathShape;
      } else {
        this.pathShape = pathShapeFromString(pathShapeStr);
      }
      if (tutorialModeStr.isEmpty) {
        if (tutorialMode == null) {
          this.tutorialMode = TutorialModes.campaignIndependent;
        } else {
          this.tutorialMode = tutorialMode;
        }
      } else {
        this.tutorialMode = TutorialModes.fromString[tutorialModeStr];
      }
      if (cameraMovementsStr?.isEmpty == true) {
        this.cameraMovements = cameraMovements;
      } else {
        this.cameraMovements = cameraMovementsStr
            ?.where((str) => str.isNotEmpty)
            .map((e) => CameraMovement.fromString[e])
            .toList();
      }
    } catch (e) {
      throw Exception('TutorialStep $e');
    }
  }

  late final TutorialModes tutorialMode;
  late final List<CameraMovement?>? cameraMovements;
  final bool isCloseButtonVisible;
  final bool isNextButtonVisible;
  final bool isBackButtonVisible;

  /// Use to reset [TutorialMode] pointer at the end of tutorial steps
  /// For example,
  ///
  /// you have 3 steps in tutorial mode
  /// then show it to user and if the last step will have
  /// [resetTutorialModePointers] true, then next time, when user
  /// will open this tutorial it will starts again from beginning.
  ///
  /// This param is useful for help buttons which should show always
  /// the same tutorial steps
  ///
  /// To use it just add true to the last step in stack.
  ///
  /// By default it will be false, so in case of battle tutorial
  /// it will remember last step and any new tutorials
  /// will be started from there. But, also in that case
  /// user will be able to click back button
  final bool resetTutorialModePointers;

  /// [selfRemoveAfterClose] is a option to allow remove step itself
  /// after execution
  final bool selfRemoveAfterClose;
  final String title;
  final String description;
  final String svgSrc;
  final num zoomScaleFactor;
  final bool? alignToScreen;
  final int? order;

  /// Is a callback which will be runned on next or close button clicked
  final FutureBoolCallback? onVerifyNext;

  /// Could be a Province, or something else for pathShape usage
  final dynamic shapeValue;
  late final HighlightPathShapes? pathShape;
  static HighlightPathShapes? pathShapeFromString(String? val) {
    if (val == null) return null;
    final shape = HighlightPathShapes.fromString[val];
    return shape;
  }

  static String pathShapeToString<TActionEnum>(TActionEnum shape) =>
      shape.toString();

  late final TEnumAction enumAction;
  static TActionEnum enumActionFromString<TActionEnum>(String? val) {
    if (val == null) throw ArgumentError.notNull('val');
    final action = TutorialActionEnumConverter.toEnum<TActionEnum>(val);
    if (action == null) throw ArgumentError.notNull('enumAction');

    return action;
  }

  static String enumActionToString<TActionEnum>(TActionEnum action) =>
      action.toString();

  late final Alignment alignment;
  late final Alignment mobileAlignment;
  static String alignmentToFromString(Alignment val) => val.toString();
  static Alignment alignmentFromString(String? val) {
    final alignment = val?.toAlignment();
    if (alignment == null) throw ArgumentError.notNull('alignment');
    return alignment;
  }

  @override
  int compareTo(TutorialStep? other) {
    if (other == null) return 1;
    final resolvedOrder = order;
    final resolvedOtherOrder = other.order;
    if (resolvedOrder == null && resolvedOtherOrder == null) {
      /// equal
      return 0;
    } else if (resolvedOrder != null && resolvedOtherOrder == null) {
      /// [this] more then [other]
      return 1;
    } else if (resolvedOrder == null && resolvedOtherOrder != null) {
      /// [this] less then [other]
      return -1;
    } else if (resolvedOrder != null && resolvedOtherOrder != null) {
      return resolvedOrder.compareTo(resolvedOtherOrder);
    }

    /// assume [this] is equal to [other]
    return 0;
  }

  factory TutorialStep.fromStaticJson({
    required Map<String, dynamic> json,
  }) {
    final raw = RawTutorialStep.fromJson(json);
    return TutorialStep(
      title: raw.title,
      description: raw.description,
      tutorialModeStr: raw.tutorialMode,
      alignmentStr: raw.alignment,
      mobileAlignmentStr: raw.mobileAlignment,
      enumActionStr: raw.enumAction,
      isBackButtonVisible: raw.isBackButtonVisible,
      isCloseButtonVisible: raw.isCloseButtonVisible,
      isNextButtonVisible: raw.isNextButtonVisible,
      pathShapeStr: raw.pathShape,
      svgSrc: raw.svgSrc,
      cameraMovementsStr: raw.cameraMovements,
      zoomScaleFactor: raw.zoomScaleFactor,
      alignToScreen: raw.alignToScreen,
      order: raw.order,
      selfRemoveAfterClose: raw.selfRemoveAfterClose,
      resetTutorialModePointers: raw.resetTutorialModePointers,
    );
  }

  @override
  List<Object?> get props => [
        tutorialMode,
        isCloseButtonVisible,
        isNextButtonVisible,
        isBackButtonVisible,
        title,
        description,
        svgSrc,
        pathShape,
        enumAction,
        alignment,
        cameraMovements,
        zoomScaleFactor,
        alignToScreen,
        order,
        selfRemoveAfterClose,
        resetTutorialModePointers,
      ];
  @override
  bool? get stringify => true;
}

extension TutorialStepExt on TutorialStep {
  TutorialStep copyWith({
    String? title,
    String? description,
    String? enumAction,
    Alignment? alignment,
    String? svgSrc,
    HighlightPathShapes? pathShape,
    bool? isCloseButtonVisible,
    bool? isNextButtonVisible,
    bool? isBackButtonVisible,
    TutorialModes? tutorialMode,
    dynamic shapeValue,
    List<CameraMovement?>? cameraMovements,
    double? zoomScaleFactor,
    bool? alignToScreen,
    int? order,
    bool? selfRemoveAfterClose,
    bool? resetTutorialModePointers,
    FutureBoolCallback? onVerifyNext,
  }) =>
      TutorialStep(
        title: title ?? this.title,
        onVerifyNext: onVerifyNext ?? this.onVerifyNext,
        tutorialMode: tutorialMode ?? this.tutorialMode,
        description: description ?? this.description,
        enumAction: enumAction ?? this.enumAction,
        alignment: alignment ?? this.alignment,
        svgSrc: svgSrc ?? this.svgSrc,
        pathShape: pathShape ?? this.pathShape,
        isCloseButtonVisible: isCloseButtonVisible ?? this.isCloseButtonVisible,
        isNextButtonVisible: isNextButtonVisible ?? this.isNextButtonVisible,
        isBackButtonVisible: isBackButtonVisible ?? this.isBackButtonVisible,
        shapeValue: shapeValue ?? this.shapeValue,
        cameraMovements: cameraMovements ?? this.cameraMovements,
        zoomScaleFactor: zoomScaleFactor ?? this.zoomScaleFactor,
        alignToScreen: alignToScreen ?? this.alignToScreen,
        order: order ?? this.order,
        selfRemoveAfterClose: selfRemoveAfterClose ?? this.selfRemoveAfterClose,
        resetTutorialModePointers:
            resetTutorialModePointers ?? this.resetTutorialModePointers,
      );
}
