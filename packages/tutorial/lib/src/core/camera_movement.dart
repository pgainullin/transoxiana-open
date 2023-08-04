import 'package:utils/utils.dart';

enum CameraMovement {
  toProvince,
  toProvinces,
  toNationProvinces,
  toPlayerProvinces,
  toRectCenter,
  zoomIn,
  zoomOut,
  fromString,
}

extension CameraMovementExt on CameraMovement {
  /// Overload the [] getter to get the name
  CameraMovement? operator [](String key) =>
      EnumHelper.findFromString<CameraMovement>(
        list: CameraMovement.values,
        key: key,
      );
}
