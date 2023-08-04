import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/campaign/province.dart';

/// Painting provinces in the colour of their nation
class ProvinceRenderFilter extends Component {
  ProvinceRenderFilter({required this.province}) : super(priority: -100);

  final Province province;
  ColorFilter? filter;

  void updateFilter() {
    filter = ColorFilter.mode(
      province.nation.color.withOpacity(
        province.isSelected ? 0.6 : 0.3,
      ),
      BlendMode.srcIn,
    );
  }

  ColorFilter? fogFilter;
  void updateFogFilter() {
    fogFilter = ColorFilter.mode(
      Colors.black54.withOpacity(
        province.isSelected ? 0.5 : 0.3,
      ),
      BlendMode.srcIn,
    );
  }

  void updateFilters() {
    updateFilter();
    updateFogFilter();
  }

  @override
  void render(final Canvas canvas) {
    super.render(canvas);

    if (province.game.campaignRuntimeData.isBattleStarted &&
        province.game.campaignRuntimeData.activeBattle?.isPlayerBattle ==
            true) {
      return;
    }
    if (filter == null) updateFilter();
    if (fogFilter == null) updateFogFilter();

    paintImage(
      canvas: canvas,
      rect: province.touchRect,
      image: province.image,
      colorFilter: filter,
      // fit: BoxFit.fill,
      // filterQuality: FilterQuality.medium,
    );
  }
}
