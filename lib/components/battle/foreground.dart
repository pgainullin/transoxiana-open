import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';

class ShadowBackground extends Component {
  ShadowBackground({
    required this.game,
    required final ComponentsRenderPriority priority,
  }) : super(priority: priority.value);
  final TransoxianaGame game;

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    canvas.drawRect(
      game.camera.worldBounds!,
      Paint()..color = Colors.black.withAlpha(alpha),
    );
  }

  static const int alpha = 175;
}
