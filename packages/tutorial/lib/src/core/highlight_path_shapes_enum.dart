import 'package:utils/utils.dart';

enum HighlightPathShapes {
  provincePath,
  buttonRect,
  fromString,
}

extension HighlightPathShapesExt on HighlightPathShapes {
  /// Overload the [] getter to get the name
  HighlightPathShapes? operator [](String key) =>
      EnumHelper.findFromString<HighlightPathShapes>(
          list: HighlightPathShapes.values, key: key);
}
