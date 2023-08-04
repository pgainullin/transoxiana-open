import 'dart:ui';

import 'package:transoxiana/components/campaign/province.dart';

/// This fog of war has more advanced programming
/// principle based on painting shadow map with
/// visibility layer like holes for visible provinces.
class FogOfWarMap {
  // static final Paint paint = Paint();
  final List<Province> visibleProvinces = [];
  static final paint = Paint()
    ..color = const Color.fromRGBO(255, 255, 255, 0.51);
  Image? image;

  void render({
    required final Canvas canvas,
    required final double screenHeight,
    required final double screenWidth,
  }) {
    final pathOfOpenedProvinces = Path();
    for (final province in visibleProvinces) {
      // FIXME: add not rectangle but shape of province
      pathOfOpenedProvinces.addRect(province.touchRect);
    }
    final finalPath = Path.combine(
      PathOperation.difference,
      Path()
        ..addRect(
          Rect.fromLTWH(
            0,
            0,
            screenHeight,
            screenWidth,
          ),
        ),
      pathOfOpenedProvinces..close(),
    );
    canvas.drawPath(
      finalPath,
      paint,
    );
  }

  void update(final double dt) {
    return;
  }
}
