part of 'models.dart';

/// ********************************************
/// *      PERSISTENT FORM FACTORS
/// *
/// * These parameters depends only from device
/// * and cannot be changed.
/// ********************************************

@immutable
@Freezed(
  equal: true,
  addImplicitFinal: true,
  copyWith: true,
)
class UiPersistentFormFactors with _$UiPersistentFormFactors {
  const factory UiPersistentFormFactors({
    required final WidthFormFactor width,
    required final DeviceWindowFormFactor deviceWindow,
  }) = _UiPersistentFormFactors;
  const UiPersistentFormFactors._();
  factory UiPersistentFormFactors.of(final BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return UiPersistentFormFactors(
      deviceWindow: _getDeviceWindow(),
      width: _getWidthBySize(screenSize),
    );
  }

  static DeviceWindowFormFactor _getDeviceWindow() {
    if (kIsWeb) {
      return DeviceWindowFormFactor.web;
    } else {
      switch (defaultTargetPlatform) {
        case TargetPlatform.macOS:
          return DeviceWindowFormFactor.macOS;
        case TargetPlatform.android:
          return DeviceWindowFormFactor.android;
        case TargetPlatform.iOS:
          return DeviceWindowFormFactor.iOS;
        case TargetPlatform.fuchsia:
          return DeviceWindowFormFactor.macOS;
        case TargetPlatform.windows:
          return DeviceWindowFormFactor.windows;
        case TargetPlatform.linux:
          return DeviceWindowFormFactor.linux;
      }
    }
  }

  static WidthFormFactor _getWidthBySize(final Size screenSize) {
    if (screenSize.width <= WidthFormFactor.mobile.max) {
      return WidthFormFactor.mobile;
    } else if (screenSize.width <= WidthFormFactor.tablet.max) {
      return WidthFormFactor.tablet;
    } else {
      return WidthFormFactor.desktop;
    }
  }
}

enum WidthFormFactor {
  mobile(
    isLeftPanelAllowed: true,
    isCenterPanelAllowed: false,
    isRightPanelAllowed: false,
    max: 839,
  ),
  tablet(
    isLeftPanelAllowed: true,
    isCenterPanelAllowed: true,
    isRightPanelAllowed: false,
    max: 1000,
  ),
  desktop(
    isLeftPanelAllowed: true,
    isCenterPanelAllowed: true,
    isRightPanelAllowed: true,
    max: double.infinity,
  );

  const WidthFormFactor({
    required this.isLeftPanelAllowed,
    required this.isCenterPanelAllowed,
    required this.isRightPanelAllowed,
    required this.max,
  });
  final bool isLeftPanelAllowed;
  final bool isCenterPanelAllowed;
  final bool isRightPanelAllowed;
  final double max;
}

enum DeviceWindowFormFactor {
  android(
    hasTransparencySupport: false,
    hasWindowClose: false,
    hasWindowExpand: false,
    hasWindowHide: false,
  ),
  iOS(
    hasTransparencySupport: false,
    hasWindowClose: false,
    hasWindowExpand: false,
    hasWindowHide: false,
  ),
  macOS(),
  windows(),
  linux(),
  web(
    hasTransparencySupport: false,
    hasWindowClose: false,
    hasWindowExpand: false,
    hasWindowHide: false,
  );

  const DeviceWindowFormFactor({
    this.hasWindowClose = true,
    this.hasWindowExpand = true,
    this.hasWindowHide = true,
    this.hasTransparencySupport = false,
  });
  final bool hasWindowClose;
  final bool hasWindowHide;
  final bool hasWindowExpand;
  final bool hasTransparencySupport;
}
