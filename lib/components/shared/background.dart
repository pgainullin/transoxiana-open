import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';

class Background extends PositionComponent implements GameRef {
  Background({
    required this.game,
    required final ComponentsRenderPriority priority,
  }) : super(priority: priority.value);
  static final _backgroundColor = Paint()..color = const Color(0xFF465445);
  // final Size size;
  // final Position position;
  @override
  TransoxianaGame game;

  late Sprite sprite;

  @override
  Future<void> onLoad() async {
    sprite = await Sprite.load(
      'background.jpg',
      // x: x * 32.0, y: y * 32.0, width: 32.0, height: 32.0,
    );
    await super.onLoad();
  }

  @override
  void render(final Canvas canvas) {
    // canvas.drawRect(
    //     game.constraints,
    //     // Rect.fromLTWH(position.x - size.width, position.y - size.height,
    //     //     size.width * 10, size.height * 10),
    //     _backgroundColor);
    super.render(canvas);
    if (isHeadless) return;

    final worldBounds = game.camera.worldBounds;
    if (worldBounds == null) {
      throw ArgumentError.value(
        worldBounds,
        'worldBounds',
        'set worldBounds during campaign or battle change',
      );
    }
    sprite.renderRect(canvas, worldBounds);
  }

  @override
  int priority = -1;

  @override
  // ignore: must_call_super
  void update(final double dt) {
//    super.update(dt);
  }
}
