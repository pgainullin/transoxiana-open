import 'package:flame/components.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:transoxiana/components/campaign/province.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/components_render_priority.dart';

class FogOfWar extends Component {
  FogOfWar({
    required this.province,
  }) : super(priority: ComponentsRenderPriority.campaignFogOfWar.value);
  final Province province;
  //used to add transparency to the component image
  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    if (province.isVisibleToPlayer || isHeadless) return;
    paintImage(
      canvas: canvas,
      rect: province.touchRect,
      fit: BoxFit.fill,
      image: province.image,
      colorFilter: province.renderFilter.fogFilter,
    );
  }
}
