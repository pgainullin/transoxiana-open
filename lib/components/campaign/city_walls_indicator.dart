import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';
import 'package:flutter/material.dart' hide Image;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/components/shared/fortification.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

class CityWallsIndicator extends Component implements GameRef {
  CityWallsIndicator(
    this.game,
    this.fort,
  ) {
    initialize();
  }
  @override
  TransoxianaGame game;
  final Fortification fort;

  late final DrawableRoot icon;
  late final Image image;

  bool initialized = false;
  Future<void> initialize() async {
    final String assetFileString =
        await Flame.assets.readFile(UiIcons.cityWalls);
    icon = await svg.fromSvgString(assetFileString, assetFileString);
    final Picture picture = icon.toPicture(
      // colorFilter: filter,
      size: initialSize,
      // clipToViewBox: true,
    );
    image = await picture.toImage(
      initialSize.width.toInt(),
      initialSize.height.toInt(),
    );

    initialized = true;
  }

  static const initialSize = Size(
    UiSizes.tileSize,
    UiSizes.tileSize,
  );

  Size get size => initialSize * unitSpriteCampaignScale;

  @override
  void render(final Canvas canvas) {
    super.render(canvas);
    if (!initialized) return;

    paintImage(
      canvas: canvas,
      rect: Rect.fromPoints(Offset.zero, Offset(size.width, size.height)),
      fit: BoxFit.fill,
      image: image,
      colorFilter: ColorFilter.mode(
        Colors.black87.withOpacity(
          fort.integrity / 100.0,
        ),
        BlendMode.srcIn,
      ),
      // filterQuality: FilterQuality.medium,
    );
  }

  @override
  void update(final double dt) {
    // TODO: implement update
  }
}
