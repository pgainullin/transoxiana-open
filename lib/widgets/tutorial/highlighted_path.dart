import 'package:equatable/equatable.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';

class HighlightedPath with EquatableMixin implements GameRef {
  HighlightedPath({
    required this.topLeft,
    required this.game,
    this.sourceRect,
    this.sourcePath,
  });

  /// Province highlighting.
  /// It uses polygon province shape
  factory HighlightedPath.fromProvincePath({
    required final Province province,
    required final TransoxianaGame game,
  }) {
    final topLeft = province.touchRect.topLeft;
    final highlightPath = HighlightedPath.fromPath(
      path: province.maskPath,
      topLeft: topLeft.toVector2(),
      game: game,
    );
    return highlightPath;
  }
  factory HighlightedPath.fromProvince({
    required final Province province,
    required final TransoxianaGame game,
  }) {
    final rect = province.touchRect;
    final topLeft =
        (rect.topLeft.toVector2() - game.mapCamera.scaledWorldPosition) *
            game.mapCamera.zoom;

    final size = Size(
          rect.width,
          rect.height,
        ) *
        game.mapCamera.zoom;

    final highlightPath = HighlightedPath.fromSize(
      topLeft: topLeft,
      size: size,
      game: game,
    );

    return highlightPath;
  }

  factory HighlightedPath.fromCampaignRect({
    required final Rect rect,
    required final TransoxianaGame game,
  }) {
    final topLeft =
        rect.topLeft - game.mapCamera.scaledWorldPosition.toOffset();

    final size = Size(
      rect.width,
      rect.height,
    );
    final highlightPath = HighlightedPath.fromSize(
      size: size,
      topLeft: topLeft.toVector2(),
      game: game,
    );
    return highlightPath;
  }
  factory HighlightedPath.fromPath({
    required final Path path,
    required final Vector2 topLeft,
    required final TransoxianaGame game,
  }) {
    final highlightedPath = HighlightedPath(
      topLeft: topLeft,
      sourcePath: path,
      game: game,
    );
    highlightedPath.painterPath.addPath(path, topLeft.toOffset());
    return highlightedPath;
  }

  /// Use it with UI elements, such as buttons
  ///
  /// [size] is a size of child widget
  /// To get size of child widget use [ChildSizeNotifier]
  /// [size] will be summed with [scaledWorldPosition]
  /// coordinates
  factory HighlightedPath.fromSize({
    required final Size size,
    required final Vector2 topLeft,
    required final TransoxianaGame game,
  }) {
    final rect = Rect.fromPoints(
      topLeft.toOffset(),
      Offset(
        topLeft.x + size.width,
        topLeft.y + size.height,
      ),
    );
    return HighlightedPath.fromRect(rect: rect, game: game);
  }
  factory HighlightedPath.fromRect({
    required final Rect rect,
    required final TransoxianaGame game,
  }) {
    final path = HighlightedPath(
      topLeft: rect.topLeft.toVector2(),
      sourceRect: rect,
      game: game,
    );
    path.painterPath.addRect(rect);
    return path;
  }

  static HighlightedPath? fromButtonRectKey({
    required final GlobalKey? key,
    required final TransoxianaGame game,
  }) {
    if (key == null) return null;
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    final size = box.size;
    final topLeftOffset = size.topLeft(
      box.localToGlobal(Offset.zero),
    );
    final topLeft = topLeftOffset.toVector2();
    final path = HighlightedPath.fromSize(
      size: size,
      topLeft: topLeft,
      game: game,
    );
    return path;
  }

  final Vector2 topLeft;
  final painterPath = Path();
  final Rect? sourceRect;
  final Path? sourcePath;
  @override
  TransoxianaGame game;
  void useIfSource({
    final ValueChanged<Rect>? onIfRect,
    final ValueChanged<Path>? onIfPath,
  }) {
    final rect = sourceRect;
    final path = sourcePath;
    if (path != null) {
      onIfPath?.call(path);
    } else if (rect != null) {
      onIfRect?.call(rect);
    }
  }

  @override
  List<Object> get props {
    final arr = <Object>[topLeft];
    final maybeRect = sourceRect;
    if (maybeRect != null) arr.add(maybeRect);
    final maybePath = sourcePath;
    if (maybePath != null) arr.add(maybePath);
    return arr;
  }
}
