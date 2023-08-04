import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:quiver/core.dart';

import 'package:transoxiana/widgets/tutorial/highlighted_path.dart';

part 'tutorial_overlay_painter_extensions.dart';

final _paint = Paint()..color = const Color.fromRGBO(0, 0, 0, 0.7);

/// [highlightedPath] is a path of highlighted area
/// if it is null then the full size of [paint] size
/// will be painted.
class TutorialOverlayPainter extends CustomPainter {
  const TutorialOverlayPainter({
    this.highlightedPath,
  });
  final HighlightedPath? highlightedPath;

  Rect _getScreenRectFromSize(final Size screenSize) => Rect.fromLTWH(
        0,
        0,
        screenSize.width,
        screenSize.height,
      );

  /// If highlighted path is not provided
  /// then floating offset will be based
  /// on screen size
  ///
  /// [alignToScreen] is a param that force
  /// floating tip to use screen alignment,
  /// instead of highlighted path alignment
  Offset getFloatingOffset({
    required final BuildContext context,
    required final Alignment alignment,
    required final bool? alignToScreen,
    required final Size floatingSize,
  }) {
    final resolvedPath = highlightedPath;

    Offset resolveInsideRect(final Rect rect) {
      final resolvedOffset = alignment.withinRect(rect);
      return resolvedOffset.alignWithin(
        alignment: alignment,
        size: floatingSize,
      );
    }

    Offset resolveOutsideRect(final Rect rect) {
      final resolvedOffset = alignment.withinRect(rect);
      return resolvedOffset.alignOutside(
        alignment: alignment,
        size: floatingSize,
      );
    }

    /// case if highlight element does not exist

    if (resolvedPath == null || alignToScreen == true) {
      final screenSize = MediaQuery.of(context).size;
      return resolveInsideRect(
        _getScreenRectFromSize(
          screenSize,
        ),
      );
    }

    /// case if highlight element exists
    Offset finalOffset = Offset.zero;
    resolvedPath.useIfSource(
      onIfPath: (final path) {
        finalOffset = resolveOutsideRect(
          path.getBounds(),
        );
      },
      onIfRect: (final rect) {
        finalOffset = resolveOutsideRect(rect);
      },
    );
    return finalOffset;
  }

  @override
  bool shouldRepaint(final TutorialOverlayPainter oldDelegate) {
    return oldDelegate.highlightedPath != highlightedPath;
  }

  @override
  void paint(final Canvas canvas, final Size size) {
    final backgroundRect = _getScreenRectFromSize(
      size,
    );
    final finalPath = (() {
      final resolvedPath = highlightedPath;
      if (resolvedPath == null) return Path()..addRect(backgroundRect);

      final effectivePath = Path()
        ..fillType = PathFillType.evenOdd
        ..addRect(backgroundRect);

      resolvedPath.useIfSource(
        onIfPath: (final path) {
          effectivePath.addPath(path, resolvedPath.topLeft.toOffset());
        },
        onIfRect: effectivePath.addRect,
      );

      return effectivePath;
    })();

    canvas.drawPath(
      finalPath,
      _paint,
    );
  }

  @override
  bool operator ==(final Object? other) {
    if (other is! TutorialOverlayPainter) return false;
    return other.highlightedPath == highlightedPath;
  }

  @override
  int get hashCode => hash2(_paint, highlightedPath);
}
