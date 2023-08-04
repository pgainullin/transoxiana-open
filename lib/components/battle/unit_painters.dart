import 'dart:math';

import 'package:collection/src/iterable_extensions.dart';
import 'package:flame/extensions.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/material.dart';
import 'package:transoxiana/components/battle/unit.dart';
import 'package:transoxiana/components/game/game.dart';
import 'package:transoxiana/data/constants.dart';
import 'package:transoxiana/data/direction.dart';
import 'package:transoxiana/data/unit_types.dart';
import 'package:transoxiana/services/painting_utils.dart';
import 'package:transoxiana/widgets/ui_constants.dart';

enum markerType {
  unit,
  army,
  hud,
  none,
}

class UnitPainter extends CustomPainter {
  UnitPainter({
    required this.unit,
    required this.center,
    required this.game,
    this.spriteSize,
    this.marker = markerType.unit,
    this.diameter = 0.0,
    this.scale,
    this.overrideDirection,
  }) {
    spriteSize ??= unit.spriteSize;
    scale ??= unit.spriteScale;
  }
  final Unit unit;
  final TransoxianaGame game;

  ///central coordinates of the unit
  final Vector2 center;
  Vector2? spriteSize;
  final double diameter;
  double? scale;
  final markerType marker;

  /// direction in which the unit sprites will be shown facing. defaults to Direction.south
  final Direction? overrideDirection;

  @override
  void paint(
    final Canvas canvas,
    final Size size,
  ) {
    // void renderSprite(Canvas canvas, Offset center, Offset size, double scale,
    //     {Direction? overrideDirection}) {
    //    sprite.render(canvas, width: game.map.destTileSize * game.scale, height: game.map.destTileSize * game.scale);

    if (marker == markerType.unit || marker == markerType.hud) {
      UnitMarkersPainter(
        game: game,
        center: center,
        diameter: diameter,
        unit: unit,
        isHud: marker == markerType.hud,
      ).paint(canvas, Size.zero);
    } else if (marker == markerType.army) {
      ArmyMarkersPainter(
        game: game,
        center: center,
        diameter: diameter,
        unit: unit,
      ).paint(canvas, Size.zero);
    }

    final Sprite sprite = unit.type.sprites[Direction.south] != null
        ? unit.type.sprites[overrideDirection ?? unit.direction]!
        : unit.type.sprite;

    final spritePosition = center -
        (spriteSize ?? Vector2.zero()) * 0.5 +
        (marker == markerType.hud
            ? Vector2(
                0.0,
                paints.healthBarPaint.strokeWidth +
                    unit.nation.painter.strokeWidth * 2.0,
              )
            : Vector2.zero());
    sprite.render(
      canvas,
      size: size.isEmpty ? spriteSize ?? Vector2.zero() : size.toVector2(),
      position: spritePosition,
      overridePaint: unit.health > 0.0 ? null : Paints.opacityPaint(0.25),
      //TODO: replace with a "dead" sprite + set of "wounded" sprites,
    );
    // final resolvedScale = scale;
    // if (resolvedScale != null) {
    //   _sprite.originalSize.scale(resolvedScale);
    // }
    // }
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

class UnitTypePainter extends CustomPainter {
  UnitTypePainter({
    required this.type,
    required this.center,
    this.spriteSize,
    this.diameter = 0.0,
    this.scale,
  }) {
    spriteSize ??= type.spriteSizeForHUD(1.0);
    scale ??= type.spriteScaleForHUD(1.0);
  }
  final UnitType type;

  ///central coordinates of the unit
  final Vector2 center;
  Vector2? spriteSize;
  final double diameter;
  double? scale;

  @override
  void paint(
    final Canvas canvas,
    final Size size, {
    final Direction? overrideDirection,
  }) {
    //SPRITE
    final Sprite sprite = type.sprites[Direction.south] != null
        ? type.sprites[overrideDirection ?? Direction.south]!
        : type.sprite;

    final spritePosition = center - (spriteSize ?? Vector2.zero());
    sprite.render(
      canvas,
      position: spritePosition,
      size: Vector2(type.sprite.srcSize.x / 2, type.sprite.srcSize.y),
    );
    // final resolvedScale = scale;
    // if (resolvedScale != null) {
    //   _sprite.originalSize.scale(resolvedScale);
    // }

    // }
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

class UnitMarkersPainter extends CustomPainter {
  UnitMarkersPainter({
    required this.unit,
    required this.center,
    required this.diameter,
    required this.game,
    this.isHud = false,
  });
  final Unit unit;
  final Vector2 center;
  final double diameter;
  final bool isHud;
  final TransoxianaGame game;

  @override
  void paint(final Canvas canvas, final Size size) {
    final temporaryCampaignData = game.temporaryCampaignData;

    // NATION MARKER - shows the colour of the nation
    if (unit.health > 0.0 &&
        temporaryCampaignData.selectedUnit == unit) // only if selected
    {
      drawHexagon(
        canvas,
        diameter / 2,
        center,
        temporaryCampaignData.selectedUnit == unit
            ? Paints.selectionPaint(unit.nation.painter)
            : unit.nation.painter,
      );
    }

    //HEALTH BAR

    final double healthBarLength =
        0.5 * diameter * max(0.0, unit.health) / 100.0;

    final double healthBarX = center.x - 0.5 * diameter / 2;
    final double healthBarY = isHud ? 0.0 : center.y - diameter / 1.8;
    canvas.drawLine(
      Offset(healthBarX, healthBarY),
      Offset(healthBarX + healthBarLength, healthBarY),
      paints.healthBarPaint,
    );

    //MORALE BAR
    final double moraleBarLength =
        0.5 * diameter * max(0.0, unit.morale) / 100.0;

    final double moraleBarX = healthBarX;
    final double moraleBarY = healthBarY + paints.healthBarPaint.strokeWidth;
    if (unit.health > 0.0) {
      canvas.drawLine(
        Offset(moraleBarX, moraleBarY),
        Offset(moraleBarX + moraleBarLength, moraleBarY),
        unit.nation.painter,
      );
    }

    //COMMANDER INDICATOR
    if (unit.isCommandUnit && unit.health > 0.0) {
      final double commanderY = moraleBarY + unit.nation.painter.strokeWidth;

      canvas.drawLine(
        Offset(moraleBarX, commanderY),
        Offset(moraleBarX + moraleBarLength, commanderY),
        unit.nation.commanderPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

class ArmyMarkersPainter extends CustomPainter {
  ArmyMarkersPainter({
    required this.unit,
    required this.center,
    required this.diameter,
    required this.game,
  });
  final TransoxianaGame game;
  final Unit unit;
  final Vector2 center;
  final double diameter;

  @override
  void paint(final Canvas canvas, final Size size) {
    final temporaryCampaignDataService = game.temporaryCampaignDataService;

    final double scaledDiameter = diameter * armyMarkerSizeFactor;

    // NATION MARKER - shows the colour of the nation
    canvas.drawCircle(
      center.toOffset() +
          Offset(0.0, diameter * armyMarkerVerticalOffsetFactor),
      0.5 * scaledDiameter,
      temporaryCampaignDataService.state.selectedArmy == unit.army
          ? Paints.selectionPaint(unit.nation.painter)
          : unit.nation.painter,
    );

    if (unit.army == null) {
      // try to find this unit
      for (final army in unit.nation.getArmies()) {
        final foundUnit = army.units.firstWhereOrNull(
          (final armyUnit) => armyUnit.id.unitId == unit.id.unitId,
        );
        if (foundUnit == null) continue;
        unit.army = army;
        break;
      }
      if (unit.army == null) {
        throw Exception(
            'Army is null for the representative unit in army render',);
      }
    }

    // number indicating army unit count
    canvas
      ..save()
      ..translate(
        center.x + 0.5 * scaledDiameter,
        center.y +
            diameter * armyMarkerVerticalOffsetFactor +
            0.5 * scaledDiameter,
      );

    final bool otherArmiesInTheSamePosition =
        (unit.army!.location!.nation.isFriendlyTo(unit.nation) &&
                unit.army!.location!.armies.values
                        .where(
                          (final element) =>
                              element.nation.isFriendlyTo(unit.nation),
                        )
                        .length >
                    1) ||
            (!unit.army!.location!.nation.isFriendlyTo(unit.nation) &&
                unit.army!.location!.armies.values
                        .where(
                          (final element) =>
                              !element.nation.isFriendlyTo(unit.nation),
                        )
                        .length >
                    1);

    CircleWithNumberPainter(
      unit.army!.fightingUnitCount,
      addPlus: otherArmiesInTheSamePosition,
      textStyle: UiThemes.defaultTextTheme.bodyText1!.copyWith(
        shadows: UiSettings.textShadows,
        color: ThemeData.estimateBrightnessForColor(unit.nation.color) ==
                Brightness.dark
            ? Colors.white
            : Colors.black,
      ),
      color: unit.nation.color,
    ).paint(
      canvas,
      Size.square(0.35 * scaledDiameter),
    );

    canvas.restore();

  }

  @override
  bool shouldRepaint(covariant final CustomPainter oldDelegate) {
    return this != oldDelegate;
  }
}

class CircleWithNumberPainter extends CustomPainter {
  CircleWithNumberPainter(
    this.number, {
    this.addPlus = false,
    this.sweepAngle = 2 * pi,
    this.textStyle = const TextStyle(
      color: Colors.black,
      fontSize: 16,
    ),
    this.color = Colors.black,
    this.strokeWidth = 6.0,
    this.paintingStyle = PaintingStyle.fill,
  });

  ///not implemented
  final double sweepAngle;
  final Color color;
  final int number;

  /// display a plus sign after the number
  final bool addPlus;
  final TextStyle textStyle;

  final double strokeWidth;
  final PaintingStyle paintingStyle;

  // double degToRad(double deg) => deg * (pi / 180.0);

  @override
  void paint(final Canvas canvas, final Size size) {
    final Paint paint = Paint()
      ..strokeWidth = strokeWidth
      ..style = paintingStyle
      ..color = color;
    //
    // final path = Path()
    //   ..arcTo(
    //       Rect.fromCenter(
    //         center: Offset(size.height / 2, size.width / 2),
    //         height: size.height,
    //         width: size.width,
    //       ),
    //       0.0,
    //       sweepAngle,
    //       false);
    //
    // canvas.drawPath(path, paint);
    final double radius = size.width;
    final circleOffset = Offset(radius / 2, radius / 2);
    canvas.drawCircle(circleOffset, radius, paint);

    final textSpan = TextSpan(
      text: UiSettings.wholeNumberFormat.format(number) + (addPlus ? '+' : ''),
      style: textStyle,
    );
    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '+',
    );
    textPainter.layout(
        // minWidth: 0,
        // minWidth: radius * 2,
        );
    final textOffset = Offset(textPainter.width, textPainter.height);
    textPainter.paint(canvas, circleOffset - textOffset / 2);
  }

  @override
  bool shouldRepaint(final CustomPainter oldDelegate) => this != oldDelegate;
}
