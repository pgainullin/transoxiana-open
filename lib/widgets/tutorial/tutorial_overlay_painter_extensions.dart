part of 'tutorial_overlay_painter.dart';

extension AlignmentEx on Alignment {
  bool get isHorizontal {
    final s = toString();
    switch (s) {
      case 'Alignment.centerLeft':
      case 'Alignment.centerRight':
      case 'Alignment.center':
        return true;
      default:
        return false;
    }
  }

  bool get isVertical {
    final s = toString();
    switch (s) {
      case 'Alignment.topCenter':
      case 'Alignment.bottomCenter':
      case 'Alignment.center':
        return true;
      default:
        return false;
    }
  }

  bool contains(final String val) => toString().contains(val);
}

extension OffsetExt on Offset {
  double _getHeightToSubstract({
    required final Size size,
    required final bool isFromSize,
    required final Alignment alignment,
  }) {
    if (alignment.isHorizontal) {
      return size.height / 2;
    }
    if (isFromSize) {
      return size.height;
    }
    return 0.0;
  }

  double _getWidthToSubstract({
    required final Size size,
    required final bool isFromSize,
    required final Alignment alignment,
  }) {
    if (alignment.isVertical) {
      return size.width / 2;
    }
    if (isFromSize) {
      return size.width;
    }
    return 0.0;
  }

  Offset _alignByAlignment({
    required final double heightToSubstract,
    required final double widthToSubstract,
  }) =>
      this -
      Offset(
        widthToSubstract,
        heightToSubstract,
      );

  Offset alignOutside({
    required final Alignment alignment,
    required final Size size,
  }) {
    final heightToSubstract = _getHeightToSubstract(
      isFromSize: alignment.contains('top'),
      alignment: alignment,
      size: size,
    );
    final widthToSubstract = _getWidthToSubstract(
      isFromSize: alignment.contains('Left'),
      alignment: alignment,
      size: size,
    );

    return _alignByAlignment(
      heightToSubstract: heightToSubstract,
      widthToSubstract: widthToSubstract,
    );
  }

  Offset alignWithin({
    required final Alignment alignment,
    required final Size size,
  }) {
    final heightToSubstract = _getHeightToSubstract(
      isFromSize: alignment.contains('bottom'),
      size: size,
      alignment: alignment,
    );

    final widthToSubstract = _getWidthToSubstract(
      isFromSize: alignment.contains('Right'),
      alignment: alignment,
      size: size,
    );
    return _alignByAlignment(
      heightToSubstract: heightToSubstract,
      widthToSubstract: widthToSubstract,
    );
  }
}
